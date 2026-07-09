# Architecture

Single HTML file (`index.html`): CSS design tokens in `:root`, markup (shell + 8 views + inspector), ~970 lines of vanilla JS.

## Shell
- Left icon rail → `switchView(v)`; views are stacked `<section class="view">` toggled by `.is-active`
- Top bar → live stats, posture pill, analyst/clearance switcher, UTC clock
- Fixed classification banner above the shell when markings are on (`body.marked`)
- Right inspector drawer → `selectEntity(id)` from any surface; relationship rows pivot to neighbors

## Views
| View | id | Purpose |
|---|---|---|
| Command Center | `view-overview` | metrics, gauge, severity bars, live feed, top actors |
| Constellation | `view-graph` | canvas force graph |
| Threat Actors | `view-actors` | filterable actor list + editable profile (image, meta, live constellation preview) |
| ATT&CK Matrix | `view-matrix` | observed-technique highlighting |
| Timeline | `view-timeline` | event chronology |
| Ingest | `view-ingest` | drop/paste/parse + per-batch options |
| Search & Alerts | `view-alerts` | query, saved searches, alert log |
| Pipelines & Settings | `view-pipes` | auto-ingest sources, markings, translation |

## Graph engine
`requestAnimationFrame` loop → `physics()` (pairwise repulsion 2600/d², springs rest-length 110 k=0.012, centering 0.0016, damping 0.86, velocity clamp ±8) → `draw()` (grid, edges, pulse particles, nodes with severity rings and redaction). Camera `{x,y,k}` with cursor-anchored wheel zoom (0.25–3×). O(n²) — fine to ~300 nodes; quadtree is the scale fix (see [[Roadmap]]).

The force loop's per-tick body lives in `physicsStep()`; `physics()` just gates it on the `frozen` toggle. `organizeLayout()` (the graph controls' "Organize" button) calls `physicsStep()` 180 times synchronously to fast-forward the simulation to a settled state on demand, bypassing `frozen`.

Edges render via `relColor(relation)` — a deterministic hash of the link's `relation` string onto the `TYPES`/`SEV` palette (`hexToRgba()` applies opacity) — with a matching "Relationship Lines" legend section (expandable past 20 via `legendRelExpanded`, since large ingested graphs can have dozens of distinct relation strings). The inspector's Relationships section colors each relation's text the same way, so the two surfaces read consistently.

`linkAt(sx,sy)` mirrors `nodeAt()` — point-to-segment distance in world space — to hit-test edges. Nodes win when both are under the cursor (checked first in both the hover and click handlers). Hovering an edge shows a floating tooltip (`#edgeTip`, positioned next to the cursor, border-colored via `relColor`); clicking one shows a toast (`source — relation — target`) instead of closing the inspector. The hovered edge also gets the same brighter/thicker treatment as a selected node's edges.

**Per-node pinning and hiding** (both view-state only, not exported — same treatment as `x`/`y`/`vx`/`vy`): dragging a node further than 4px sets `entity.pinned=true` (mouse and touch); `physicsStep()` zeroes velocity and skips integration for pinned nodes, so they act as fixed anchors that still exert repulsion/spring forces on everything else. Toggle from the inspector's "Pin in place" button; pinned nodes get a dashed ring in `draw()`. `entity.hidden=true` (inspector "Hide node") excludes an entity from `visibleEntities()` and from any edge touching it (`physicsStep()`, `draw()`); the graph controls' "Unhide all" button (auto-shown/hidden via `updateUnhideBtn()`, called from `render()`) clears every `hidden` flag at once — there's no per-node unhide UI, only clear-all.

**Actor focus**: the Actors panel (`#actorsPanel`, same `.legend` styling as the entity-type/relationship legend, stacked above it in `.graph-hud`) lists every `type:'actor'` entity with its connected-entity count, auto-shown once 2+ actors exist. `actorComponent(id)` does an undirected BFS over `state.links` to find everything reachable from that actor; `focusActor(id)` sets `entity.hidden` for the whole graph based on component membership — reusing the same hide mechanism above, not a separate filter system. `focusedActorId` (null = "Show all") drives the active-row highlight; "Unhide all" also clears it so the two controls can't disagree. Boot/ingest behavior is unaffected — this is opt-in decluttering, never automatic.

## Threat Actors view

A dedicated view (`view-actors`, `.actorsview` — fixed-width filterable list on the left via `renderActorsView()`, profile panel filling the rest via `renderActorProfile()`), separate from both the compact Actors panel above and the generic inspector drawer. `profileActorId` tracks which actor's profile is open (distinct from `selectedId` — the generic inspector's selection — and `focusedActorId` — the graph filter); redaction is enforced the same way as the inspector (`selectActorProfile()` refuses a redacted actor with a clearance toast; `applyUser()` closes an already-open profile if a clearance switch makes it redacted).

Everything in the profile is editable and writes straight back to the entity, re-rendering on each change (label, severity via `<select>`, classification, tags, and free-form `meta` key/value pairs — add/edit/remove rows, generalizing the tag-chip add/remove pattern to arbitrary attributes). "View in constellation" calls the existing `focusActor(e.id)` + `switchView('graph')` — the profile doesn't run its own graph rendering, it hands off to the real one.

**Profile images**: `handleAvatarUpload(file, entity)` reads the file, draws it to an off-screen `<canvas>` capped at 480px on the long edge, and stores `entity.image` as a JPEG data URI (quality 0.82) — no server, no separate asset storage, and it round-trips through JSON export/import exactly like every other field (unlike `x`/`y`/`vx`/`vy`, which are intentionally stripped). Clicking the avatar opens a hidden file input; a placeholder (first letter of the label, in `TYPES.actor.color`) shows when no image is set.

Clicking a relationship in the profile behaves differently depending on what's on the other end: another actor swaps the profile to them (`selectActorProfile`, stays in this view); anything else jumps to the Constellation view and opens the generic inspector on it (`switchView('graph')` + `selectEntity()`).

**Threat Group / Campaign section**: a profile section, shown above Classification when it applies, listing every `type:'campaign'` entity linked to the profiled actor (filtered from the same `rels` computation the Relationships section uses lower down). Each row has a "Show only this group" button — `focusActor(campaign.id)` + `switchView('graph')`. `focusActor()`/`actorComponent()` were already entity-agnostic BFS/hide logic despite the actor-centric naming, so no new graph-filtering code was needed to root the focus at a campaign instead of an actor. Redacted campaigns blur and drop the button, same pattern as everywhere else.

**Live constellation preview**: `.profile__previewPanel` — a sticky, non-scrolling panel filling the space to the right of the (narrower, `max-width:760px`) profile fields, so the wide profile view doesn't waste horizontal space on large screens. Holds its own `<canvas id="profilePreview">`, redrawn by `drawProfilePreview()`. This works cheaply because `tick()` already runs `physics()` unconditionally every frame regardless of the active view — entity `x`/`y` are always live-simulated in the background, so the preview only needs a lightweight draw pass (auto-fit bounding box of `actorComponent(profileActorId)`, scale/center via a `toPx` closure, nodes + edges in the same `TYPES`/`relColor` colors as the main graph, no grid/pulses/camera-pan) rather than a second physics simulation. Hooked into the existing `tick()` loop, gated on `currentView==='actors' && profileActorId` so it costs nothing on other views. The profiled actor's own node is enlarged with a ring and labeled ("you are here"); redacted nodes render in the same grey as the main graph. Click-to-navigate mirrors the Relationships list (`profilePreviewNodeAt()` hit-tests against the last-drawn transform; another actor swaps the profile in place, anything else jumps to the graph + generic inspector; redacted nodes are inert).

## Design language
Signals-intelligence observatory: indigo void, signal cyan accent, calibrated severity ramp (blue→yellow→orange→red), Space Grotesk for UI, JetBrains Mono strictly for data. Classification colors follow convention: U green, CUI purple, S red, TS orange.
