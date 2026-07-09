# NIGHTGLASS Wiki

Self-hosted, single-file cyber threat analysis platform. Start here.

## Pages
- [[Architecture]] — app shell, views, graph engine internals
- [[Data Model]] — entities, links, events, classification, tags
- [[Ingestion & Pipelines]] — parsers, auto-ingest, translation
- [[Classification & Redaction]] — markings, clearances, enforcement points
- [[Search & Alerts]] — query syntax, saved searches, alert loop
- [[Multi-Actor Support]] — Threat Actors view + relation-type coloring shipped; quick-add forms and attribution-colored edges still scoped
- [[Backend Architecture]] — source-of-truth, cache, and search design: SQLite/Postgres dual profile, CacheBackend/SearchProvider interfaces (not yet built)
- [[Flexible Data Import]] — declarative mapping spec for custom JSON schemas, pipeline-integrated (not yet built)
- [[Roadmap]] — backend plan and next steps

## House conventions (carried from Temparr / MyMusicBox)
- Single-file vanilla HTML/JS frontend, no build step
- Future backend: FastAPI + SQLAlchemy + SQLite, `>=` version pins, lifespan context manager (not `@app.on_event`)
- DOM manipulation discipline: all user-supplied strings pass through `escapeHtml()`
- Tauri for eventual desktop packaging
