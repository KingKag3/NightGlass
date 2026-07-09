# Roadmap

1. **FastAPI backend** (house stack: FastAPI + SQLAlchemy; `>=` pins; lifespan context manager) — persistence, real users/auth, server-side clearance enforcement, feed relay endpoint that solves CORS and normalizes formats. Full design in [[Backend Architecture]]: SQLite (desktop profile) / PostgreSQL (server profile) behind one config value, search behind a `SearchProvider` interface (Postgres/SQLite full-text now, Elasticsearch later), cache behind a `CacheBackend` interface (in-process now, Redis later).
2. **Server-side redaction** — never send above-clearance rows to the client; JWT with clearance claim
3. **[[Multi-Actor Support]]** — relation-type edge coloring, legend, and a full editable Threat Actors profile view shipped 2026-07-09. Still scoped: quick-add forms for *new* entities/relationships, attribution-colored edges by actor identity, color→actor legend. Independent of the backend, can be picked up any time.
4. **[[Flexible Data Import]]** — scoped, not yet built: declarative mapping spec so custom JSON schemas ingest without a one-off script; mechanism + pipeline integration before the wizard UI.
5. **Graph scale** — Barnes-Hut/quadtree repulsion, label decluttering, community coloring (1,000+ nodes)
6. **Richer STIX 2.1** — SROs, actor/malware SDOs, marking definitions mapped to CLASSIF
7. **Enrichment providers** — WHOIS / GeoIP / hash-reputation lookups behind a provider interface; inspector "Enrichment" section
8. **Correlation engine** — cross-source indicator overlap flags, link confidence, N-hop pivot queries
9. **Time scrubber** — window-filter the constellation, animate campaign progression
10. **Report polish** — PDF export, per-actor sub-reports, TLP mapping alongside classification
11. **Tauri packaging** — desktop build once the backend lands
12. **Custom threat-group sandbox** (backlog, captured 2026-07-09) — analysts create their own named threat-group/campaign and assign existing or new actors into it. Builds on item 3's still-unbuilt quick-add entity/relationship forms rather than needing separate creation logic.
