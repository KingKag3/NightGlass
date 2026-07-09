# Changelog

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
