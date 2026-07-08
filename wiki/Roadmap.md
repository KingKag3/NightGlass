# Roadmap

1. **FastAPI backend** (house stack: FastAPI + SQLAlchemy + SQLite; `>=` pins; lifespan context manager) — persistence, real users/auth, server-side clearance enforcement, feed relay endpoint that solves CORS and normalizes formats
2. **Server-side redaction** — never send above-clearance rows to the client; JWT with clearance claim
3. **Graph scale** — Barnes-Hut/quadtree repulsion, label decluttering, community coloring (1,000+ nodes)
4. **Richer STIX 2.1** — SROs, actor/malware SDOs, marking definitions mapped to CLASSIF
5. **Enrichment providers** — WHOIS / GeoIP / hash-reputation lookups behind a provider interface; inspector "Enrichment" section
6. **Correlation engine** — cross-source indicator overlap flags, link confidence, N-hop pivot queries
7. **Time scrubber** — window-filter the constellation, animate campaign progression
8. **Report polish** — PDF export, per-actor sub-reports, TLP mapping alongside classification
9. **Tauri packaging** — desktop build once the backend lands
