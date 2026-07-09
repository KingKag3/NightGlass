# Backend Architecture

**Status: designed, not yet implemented.** This is the confirmed shape of [[Roadmap]] item 1 — decided 2026-07-09. Nothing below exists in code yet; NIGHTGLASS is still frontend-only (JSON export/import is the entire persistence story today).

## Two deployment profiles, one codebase

FastAPI + SQLAlchemy, with the database picked by a config value (`DATABASE_URL`), not a code fork:

- **Desktop profile** (for the eventual Tauri build, roadmap item 8) — `sqlite:///nightglass.db`, single process, ships inside the app bundle. No Redis, no search service.
- **Server profile** (self-hosted, multi-user) — `postgresql://...`. Same models, same code.

Same models either way: `entities` / `links` / `events` map 1:1 to tables, `searches` / `pipelines` / `users` as config tables (per the original item-1 plan). Alembic migrations from day one, exercised against SQLite too, so they're proven before the first Postgres deploy — not discovered broken on it.

**Schema rules that keep the swap free** (violating these is what turns "change a connection string" into "rewrite the data layer"):
- SQLAlchemy's portable `JSON` column type for `meta`/`tags` — not hand-rolled `json.dumps` text columns
- Integer or UUID primary keys — not SQLite `AUTOINCREMENT`-specific behavior
- No raw SQL with engine-specific syntax

## Search: full-text now, Elasticsearch swap-in later

Sits behind a `SearchProvider` interface (`index(entity)`, `search(query) → [entity ids]`, `remove(id)`) so query call sites never know which backend is answering.

- **Default implementation** — native full-text per engine: Postgres `tsvector` + GIN index (`pg_trgm` for fuzzy/typo-tolerant matching) on the server profile, SQLite FTS5 on the desktop profile. Zero extra services either way.
- **Elasticsearch** becomes a second `SearchProvider` implementation, swapped in via config once usage actually justifies the operational cost. Rule of thumb from the architecture review: worth it past ~100k+ entities — well beyond the current 1,000-node scale target (roadmap item 4) — or when relevance tuning Postgres can't do cheaply becomes a real need.

## Cache: in-process now, Redis-swappable later — pub/sub designed the same way

Sits behind a `CacheBackend` interface: `get` / `set` / `invalidate`, plus a `publish` / `subscribe` pair reserved for the real-time piece.

- **Default implementation** — `InMemoryCache`: a process-local TTL dict. Works today with zero extra services, inspectable without Redis running, fine for the desktop profile and a small single-worker server deployment.
- **First job**: cache the expensive dashboard aggregates (posture score, threat index, ATT&CK matrix rollups) so the API isn't recomputing them from Postgres on every request.
- **Pub/sub, designed but not built first**: an in-process implementation (asyncio broadcast within one process) satisfies `publish`/`subscribe` for single-process deployments — real-time alert push, no Redis required. It stops working the moment there's more than one worker process, since in-process broadcast can't reach a sibling process. *That's* the actual trigger for graduating to a `RedisCache` implementation — not an arbitrary scale milestone, but "a second worker got added."
- Alert delivery keeps using the current poll model (server-side equivalent of `pipeTick`) until the pub/sub piece is actually wired into the frontend. The interface existing now just means that becomes a swap later, not a rewrite.

## Build order

1. **Tier 1** — FastAPI + SQLAlchemy + SQLite, JWT auth (clearance claim), server-side redaction. The whole item-1 MVP; this is also the finished desktop profile.
2. **Tier 2** — Postgres for the server profile (connection string + Alembic migration, nothing else changes).
3. **Tier 3** — `InMemoryCache` wired in for the dashboard aggregates.
4. **Tier 4** — `SearchProvider` wired in (Postgres FTS / SQLite FTS5).
5. **Later, only when the trigger condition hits** — `RedisCache` (cache + pub/sub) swap-in when a second worker process is added; Elasticsearch `SearchProvider` swap-in when entity counts actually warrant it.

Cache and search are core to item 1's build order from the start (tiers 3–4) — they're just backed by the lightest implementation that satisfies the interface. Redis and Elasticsearch are later swaps behind that same seam, not day-one dependencies.
