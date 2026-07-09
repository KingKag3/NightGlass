# Architecture

Single HTML file (`index.html`): CSS design tokens in `:root`, markup (shell + 7 views + inspector), ~970 lines of vanilla JS.

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
| ATT&CK Matrix | `view-matrix` | observed-technique highlighting |
| Timeline | `view-timeline` | event chronology |
| Ingest | `view-ingest` | drop/paste/parse + per-batch options |
| Search & Alerts | `view-alerts` | query, saved searches, alert log |
| Pipelines & Settings | `view-pipes` | auto-ingest sources, markings, translation |

## Graph engine
`requestAnimationFrame` loop → `physics()` (pairwise repulsion 2600/d², springs rest-length 110 k=0.012, centering 0.0016, damping 0.86, velocity clamp ±8) → `draw()` (grid, edges, pulse particles, nodes with severity rings and redaction). Camera `{x,y,k}` with cursor-anchored wheel zoom (0.25–3×). O(n²) — fine to ~300 nodes; quadtree is the scale fix (see [[Roadmap]]).

The force loop's per-tick body lives in `physicsStep()`; `physics()` just gates it on the `frozen` toggle. `organizeLayout()` (the graph controls' "Organize" button) calls `physicsStep()` 180 times synchronously to fast-forward the simulation to a settled state on demand, bypassing `frozen`.

Edges render via `relColor(relation)` — a deterministic hash of the link's `relation` string onto the `TYPES`/`SEV` palette (`hexToRgba()` applies opacity) — with a matching "Relationship Lines" legend section.

**Per-node pinning and hiding** (both view-state only, not exported — same treatment as `x`/`y`/`vx`/`vy`): dragging a node further than 4px sets `entity.pinned=true` (mouse and touch); `physicsStep()` zeroes velocity and skips integration for pinned nodes, so they act as fixed anchors that still exert repulsion/spring forces on everything else. Toggle from the inspector's "Pin in place" button; pinned nodes get a dashed ring in `draw()`. `entity.hidden=true` (inspector "Hide node") excludes an entity from `visibleEntities()` and from any edge touching it (`physicsStep()`, `draw()`); the graph controls' "Unhide all" button (auto-shown/hidden via `updateUnhideBtn()`, called from `render()`) clears every `hidden` flag at once — there's no per-node unhide UI, only clear-all.

## Design language
Signals-intelligence observatory: indigo void, signal cyan accent, calibrated severity ramp (blue→yellow→orange→red), Space Grotesk for UI, JetBrains Mono strictly for data. Classification colors follow convention: U green, CUI purple, S red, TS orange.
