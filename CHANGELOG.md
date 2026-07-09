# Changelog

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
