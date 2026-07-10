# Changelog

## v0.9.3 — 2026-07-09
- The Threat Actors sidebar was a flat, unsorted list of every actor — with a large single-network dataset (e.g. the Americans sample, one 60-entity connected component) every actor showed an identical "60 connected," making it impossible to tell who actually mattered. Restructured into **Groups then Actors**: a "Groups" section lists every campaign with a member count; clicking one opens the campaign's own profile *and* narrows the Actors section below to just that group's members ("Show all groups" clears it). Actor rows now sort by **direct** connection count (a plain link count, not the whole connected component's size) descending, so Philip Jennings (24 direct ties) actually reads as more central than a one-scene character (1) — previously indistinguishable.
- Campaign entities now profile through the exact same `selectActorProfile()`/`renderActorProfile()` path as actors — turns out nothing there ever actually required `type==='actor'`, it just hadn't been reachable for other types. Fixed the one place that assumed it (the avatar placeholder's hard-coded actor-purple, now uses the entity's own `TYPES` color). Relationship-row and preview center-node navigation both broadened from "actor only" to "actor or campaign."
- The "Threat Group / Campaign" section's row is now itself clickable (opens that campaign's profile, same as a Relationships row), separate from its existing "Show only this group" full-graph-filter button — `stopPropagation()` on the button so clicking it doesn't also trigger the row's navigation.

## v0.9.2 — 2026-07-09
- The actor profile's constellation preview now has the same animation and edge-hover feel as the main Constellation view. Traveling pulse particles (`previewPulses`, same spawn/advance/expire cadence as the main graph's `pulses`) drift along the local-neighborhood edges, driven by `tick()` calling `drawProfilePreview(true)` every frame while the profile is open. Hovering an edge shows a tooltip with the relationship name (`profilePreviewLinkAt()`, mirrors `linkAt()`'s point-to-segment hit-testing) and renders it brighter/thicker; nodes still win when both are under the cursor, same priority as the main graph.
- Pulses are cleared on every re-center (click a neighbor, click a breadcrumb, click the campaign crumb, open a different actor) — otherwise a pulse's neighbor index would point at the wrong edge once the neighborhood changes underneath it.

## v0.9.1 — 2026-07-09
- The preview's single "« back to root" link wasn't enough once you'd drilled several hops deep — replaced with a **full breadcrumb trail** (`previewTrail` array, was a single `previewFocusId`). Every hop you've taken is shown and clickable to jump back to that point; the actor's home campaign is prepended as a fixed first crumb ("the overall group this belongs to"), computed once against the profile's root actor so it stays constant as you explore.
- Fixed: the inspector drawer stayed open showing stale content when navigating away from the Constellation view to an unrelated view (e.g. ATT&CK Matrix) — it's a global overlay, not scoped per-view, and nothing was closing it. `switchView()` now force-closes it whenever leaving the graph view.
- New group filter on the graph HUD's Actors panel: when 2+ campaigns are present, a dropdown narrows the actor list to just one campaign's members, so the panel doesn't become an unwieldy flat list once multiple threat groups are loaded. Deliberately just a list filter — doesn't change what's focused in the graph, that's still the existing per-row click.

## v0.9.0 — 2026-07-09
- Redesigned the actor profile's constellation preview from a "whole connected component, unlabeled" view to a radial **local-neighborhood explorer**: the focal entity centers the panel with its direct neighbors placed around it in a circle, every node labeled. Click a neighbor to re-center the preview on it (pure local navigation); click the centered node to open it for real (swaps the profile in place for another actor, or jumps to the graph + inspector otherwise). A breadcrumb ("« *root actor*") appears once you've drilled away from the actor the profile is actually for. No longer redraws every animation frame — radial positions are computed on demand (open, re-center, clearance change) rather than read from the live simulation, so the earlier per-tick hook was removed as unnecessary.
- Hardened the preview's redaction handling: it now defensively falls back to the root actor if the *currently centered* node becomes redacted out from under it (e.g. a clearance switch while drilled into a neighbor), instead of continuing to render that node's true connections.
- The profile's "View in constellation" button is now labeled with the actor's own name ("Show only *Label* in constellation") instead of generic text.
- Profile images are now a **gallery**, not a single avatar: `entity.images[]` replaces `entity.image`, multi-file upload, per-thumbnail delete, a dashed "+" tile to add more. `images[0]` is the avatar shown in the header/list. `parseJSON` still accepts a legacy single `image` field on import and wraps it into `images`.
- **On clearance lockdown**: discussed and explicitly declined building anything that implies a real access-control boundary client-side — NIGHTGLASS has no backend, so all data (including above-clearance entities) is always present in the browser regardless of blur/hide; a determined user can always see it via devtools or View Source. That remains roadmap item 1 (server-side redaction, see [[Backend Architecture]]), not something to fake client-side. See the expanded "Honest limitation" section in [[Classification & Redaction]].
- Captured a new backlog item (not scoped in detail, not built): a custom threat-group sandbox where analysts create their own named group and assign actors into it — builds on the still-unbuilt quick-add entity/relationship forms from [[Multi-Actor Support]] rather than needing its own creation mechanism.

## v0.8.2 — 2026-07-09
- The actor profile's right-hand side was empty space on wide screens — added a live embedded constellation preview filling it. Cheap by construction: the force simulation (`tick()`/`physics()`) already runs every frame regardless of the active view, so the preview just draws the current (already-live) positions of `actorComponent(profileActorId)`, auto-fit to the panel — no second physics simulation.
- The preview updates continuously while the profile is open, matches the main graph's node/edge coloring, enlarges and labels the profiled actor's own node, and is clickable — another actor's node swaps the profile in place, anything else jumps to the graph + inspector. Redacted nodes render grey and are inert to clicks, same as everywhere else.

## v0.8.1 — 2026-07-09
- Threat Actor profile now shows a "Threat Group / Campaign" section — every `campaign`-type entity the actor is linked to, each with a "Show only this group" button that focuses the constellation on that campaign's connected component. Reuses `focusActor()`/`actorComponent()` as-is (already entity-agnostic despite the naming) rather than adding new graph-filtering logic. Redacted campaigns blur and drop the button, same as everywhere else.

## v0.8.0 — 2026-07-09
- New **Threat Actors** view (8th nav-rail entry) — a filterable, searchable list of every actor entity alongside a fully editable profile: label, severity, classification, tags, free-form meta attributes (add/edit/remove key-value rows), and a new profile image field.
- Profile images: click the avatar to upload one — resized client-side to ≤480px and stored as a JPEG data URI in `entity.image`. No backend, no separate asset storage; round-trips losslessly through JSON export/import like every other field.
- "View in constellation" on a profile reuses the existing actor-focus mechanism (`focusActor()`) to jump into the graph pre-filtered to that actor's connected component.
- Clicking a relationship in the profile swaps to that actor's profile if it's another actor, or jumps to the graph + generic inspector otherwise.
- Redaction is enforced the same way as the main inspector: opening a redacted actor's profile is blocked with a clearance toast, and an already-open profile closes itself if a clearance switch (or an in-profile classification edit) makes it redacted.
- Fixed in passing: the clearance-switch handler (`applyUser`) only ever checked the generic inspector's `selectedId` for newly-redacted content — now also checks the Threat Actors profile.

## v0.7.0 — 2026-07-09
- New Actors panel in the graph HUD (left side, next to the entity-type legend) — lists every `actor` entity with its connected-entity count, auto-shown once 2+ actors are present. Clicking one focuses the graph on that actor's connected component (BFS over `state.links`, undirected) via the existing hide mechanism; "Show all" clears the focus. Boot/ingest behavior is unchanged — this is opt-in decluttering, not automatic filtering.
- "Unhide all" now also clears actor focus, so the two hide-control surfaces stay in sync.

## v0.6.0 — 2026-07-09
- Fixed: the "+N more" row in the Relationship Lines legend was inert — clicking did nothing. It's now a real toggle (`legendRelExpanded`) that expands to the full list ("show fewer" to collapse); `.legend` gained `max-height`/`overflow-y:auto` since an expanded 40+ relation list would otherwise overflow the graph view.
- Hover or click a graph edge to see its relationship — new `linkAt()` hit-test (point-to-segment distance, mirrors how `nodeAt()` already works) drives a floating tooltip on hover and a toast (`source — relation — target`) on click; the hovered edge also renders brighter/thicker, same treatment as a selected node's edges.
- The inspector's Relationships section now color-codes each relation's text with `relColor()`, matching the edge color in the graph (skipped for redacted rows, which keep the neutral muted color).

## v0.5.0 — 2026-07-09
- Fixed: the graph legend's entity-type visibility toggles stopped working after v0.4.0's relationship-lines section was added — `renderLegend()` was using `el.innerHTML += ...`, which re-parses the whole legend and silently drops the click handlers just wired onto the entity-type rows. Now builds one HTML string and wires handlers once, after the single assignment.
- Node pinning: drag a node more than a few pixels and it stays where you drop it (`entity.pinned`) — pinned nodes are excluded from physics integration but still push/pull everything else as fixed anchors, and get a dashed ring in the graph. Toggle from the inspector's "Pin in place" button; works for both mouse and touch drag.
- Node hiding: "Hide node" in the inspector removes an entity (and any edge touching it) from the graph; "Unhide all" in the graph controls (only shown when something's hidden) restores everything at once.
- New "Organize" button in the graph controls — fast-forwards the force simulation (180 synchronous steps) to settle the layout instantly instead of waiting on the ambient animation; respects pinned nodes as anchors.
- Fixed a latent bug found while building pinning: the drag-distance check in the mouse-up handler compared against `lastMouse`, which `mousemove` had already updated to the current position — so it always measured ~0 regardless of actual drag distance. Now tracked via a separate `dragStart` captured on mouse/touch-down.
- Pinned/hidden state is view-only (like node positions) — not written to JSON export.

## v0.4.0 — 2026-07-09
- Graph edges now color by relationship type — `relColor()` hashes each link's `relation` string deterministically onto the existing `TYPES`/`SEV` palette, no new hard-coded colors; selected/hot edges render brighter and thicker
- New "Relationship Lines" section in the graph legend (color swatch + relation text, capped at 20 with a "+N more" indicator)
- Second sample dataset: `docs/samples/the-americans-network.json` (60 entities, 101 links, 42 relation types) — a fictional HUMINT network graph, drag into the Ingest view; not wired into `demoData()`/boot

## v0.3.0 — 2026-07-09
- Classification markings and tagging are now an opt-in "advanced" mode, off by default (`settings.markings`, toggled via the Classification & tagging checkbox in Pipelines & Settings)
- When off: no classification banner, no active-analyst/clearance selector, no classification/tag chips anywhere, and the inspector's Classification/Tags editors, the ingest form's classification/tag fields, and the pipeline form's classification/tag fields are hidden
- Operation Nightjar demo data no longer ships pre-classified/pre-tagged — the constellation boots clean; classify or tag entities yourself after enabling advanced mode
- Fixed: pipeline card classification chip now respects the markings toggle (previously always rendered)
- Docker packaging (`Dockerfile` + `docker-compose.yml`, `python:3.12-alpine` serving `index.html` via `http.server`) — `docker compose up --build`
- Live demo on GitHub Pages, auto-deployed on push to `main`

## v0.2.0 — 2026-07-08
- Automatic ingest pipelines (simulator + URL polling) with per-pipeline classification, auto-tags, translation
- Translation providers: LibreTranslate-compatible endpoint + offline demo dictionary
- Classification markings (U/CUI/S/TS): banner bar, global toggle, per-instance / per-batch / per-item marking
- Clearance-based redaction tied to the active analyst's clearance tag (graph, feed, timeline, matrix, search, inspector)
- Custom tagging with inspector editor and query support
- Search engine (`type:` `sev:` `tag:` `class:` `iotype:` + free text), saved searches, alert flags, alert log + nav badge
- Exports now carry classification, tags, searches, pipelines, settings

## v0.1.0 — 2026-07-06
- Initial release: command center, canvas force-graph constellation, ATT&CK matrix, timeline
- Ingestion: JSON / STIX-lite / CSV / raw-text IOC mining with refanging
- Inspector drawer, Operation Nightjar demo campaign, JSON + Markdown exports
