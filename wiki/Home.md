# NIGHTGLASS Wiki

Self-hosted, single-file cyber threat analysis platform. Start here.

## Pages
- [[Architecture]] — app shell, views, graph engine internals
- [[Data Model]] — entities, links, events, classification, tags
- [[Ingestion & Pipelines]] — parsers, auto-ingest, translation
- [[Classification & Redaction]] — markings, clearances, enforcement points
- [[Search & Alerts]] — query syntax, saved searches, alert loop
- [[Multi-Actor Support]] — scoped design for adding actors/APT groups, linking them, attribution-colored edges (not yet built)
- [[Roadmap]] — backend plan and next steps

## House conventions (carried from Temparr / MyMusicBox)
- Single-file vanilla HTML/JS frontend, no build step
- Future backend: FastAPI + SQLAlchemy + SQLite, `>=` version pins, lifespan context manager (not `@app.on_event`)
- DOM manipulation discipline: all user-supplied strings pass through `escapeHtml()`
- Tauri for eventual desktop packaging
