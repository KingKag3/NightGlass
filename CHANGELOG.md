# Changelog

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
