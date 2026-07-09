# Changelog

## v0.3.0 — 2026-07-09
- Classification markings and tagging are now an opt-in "advanced" mode, off by default (`settings.markings`, toggled via the Classification & tagging checkbox in Pipelines & Settings)
- When off: no classification banner, no classification/tag chips anywhere, and the inspector's Classification/Tags editors, the ingest form's classification/tag fields, and the pipeline form's classification/tag fields are hidden
- Operation Nightjar demo data no longer ships pre-classified/pre-tagged — the constellation boots clean; classify or tag entities yourself after enabling advanced mode
- Fixed: pipeline card classification chip now respects the markings toggle (previously always rendered)

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
