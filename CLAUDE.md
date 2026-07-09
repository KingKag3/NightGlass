# CLAUDE.md

Operational guide for Claude Code working in this repo. Read this first; it is the source of truth for how to work here. For deeper architecture see `HANDOFF.md` and `wiki/`.

## What this is

**NIGHTGLASS** — a self-hosted, single-file cyber threat analysis platform. Ingests threat data (JSON / STIX-lite / CSV / raw text), renders it as a canvas force-directed graph, enforces classification markings with clearance-based redaction, runs auto-ingest pipelines with translation, and fires alerts from saved searches. Defensive analysis tooling only — it never scans, exploits, or contacts hostile infrastructure.

**The entire app is one file: `index.html`** (~1640 lines: CSS in `:root` + markup + one `<script>`). There is no build step, no bundler, no framework, no npm dependencies. Do not add any. If you reach for React/Vite/webpack, stop — that breaks the core constraint.

## Run & test

```bash
# run
python3 -m http.server 8080        # then open http://localhost:8080
# or just open index.html directly

# lint the script (syntax only, no DOM)
node -e "const fs=require('fs');const h=fs.readFileSync('index.html','utf8');new Function(h.match(/<script>([\s\S]*)<\/script>/)[1]);console.log('JS OK')"
```

**Always smoke-test in a headless browser before committing.** Playwright is the harness (`pip install playwright && playwright install chromium`). Minimal pattern — capture page errors and assert behavior via `page.evaluate` against the live globals:

```python
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    b=p.chromium.launch(); pg=b.new_page()
    errs=[]; pg.on("pageerror", lambda e: errs.append(str(e)))
    pg.goto("http://localhost:8080"); pg.wait_for_timeout(1500)
    # example assertions:
    assert pg.evaluate("state.entities.length") > 0
    assert pg.evaluate("isRedacted(state.entities.find(e=>e.id==='actor:nightjar'))") in (True, False)
    print("errors:", errs or "none"); b.close()
```

A change is not done until `node` syntax check passes **and** a Playwright run reports zero page errors.

## Where things live in `index.html`

Navigate by section-comment banners and function names, not line numbers (edits shift lines). Section banners are `/* ===== NAME ===== */`.

| Area | Anchor |
|---|---|
| Design tokens / all styling | `:root` block + component classes in `<style>` |
| Type/severity/classification config | `TYPES`, `SEV`, `CLASSIF`, `USERS`, `settings`, `state` (top of script) |
| Demo data (Operation Nightjar) | `demoData()` — the living spec of the data model |
| Ingestion parsers | `extractIOCs` `refang` `mergeIOCs` `parseCSV` `parseJSON` `guessType` `normSev`; entry point `ingestText` (async) |
| Force graph | `physics` `draw` `tick` `nodeAt`; camera `toScreen`/`toWorld`; `resizeCanvas`/`centerView` |
| Inspector drawer | `selectEntity` (also hosts classification + tag editors), `closeInspector` |
| Dashboard render | `render` (master), `renderLegend` `renderMatrix` `renderTimeline` `drawGauge` `counts` `threatIndex` `posture` |
| View routing | `switchView` |
| Export | `download` `buildMarkdown`; JSON export handler near `exportJson` |
| Classification / redaction | `markingsOn` `clsLvl` `isRedacted` `classChipHtml` `renderBanner` |
| Search & alerts | `parseQuery` `matchesQuery` `renderSearchResults` `renderSearches` `renderAlertsLog` `runAlertScan` |
| Pipelines | `simFeedText` `runPipeline` `pipeTick` `renderPipelines` |
| Translation | `translateText` `DEMO_DICT` |
| Wiring / init | `initV2`; boot sequence at the very bottom |

## Conventions (do not violate)

1. **Single file, no dependencies.** All CSS, JS, markup stay in `index.html`. Fonts are the only network fetch.
2. **XSS discipline.** Every user- or feed-supplied string goes through `escapeHtml()` before touching `innerHTML`. The only allowed raw HTML is authored demo/JSON `event.text` (which permits `<b>` deliberately). If you render *extracted* text anywhere, escape it.
3. **No browser storage in the committed app** — it's designed to run as a portable artifact where `localStorage`/`sessionStorage` may be unavailable. Persistence is the JSON export/import loop. (When the backend lands, persistence moves server-side, not to `localStorage`.)
4. **Colors only from `TYPES` / `SEV` / `CLASSIF` or CSS variables.** Never hard-code a hex in JS render paths.
5. **Monospace (`--mono`) is for data only** — indicators, hashes, timestamps, metrics. UI chrome uses `--sans`.
6. **Respect `prefers-reduced-motion`** — keep new animation behind it.
7. **Data model is append-safe.** Adding a field to an entity? Update `demoData()`, the JSON export mapping (`exportJson` handler), `parseJSON`, and `buildMarkdown` together so the round trip stays lossless.
8. **Match the house style for any future backend:** FastAPI + SQLAlchemy + SQLite, `>=` version pins, `lifespan` context manager (not `@app.on_event`), single-file vanilla frontend preserved. Tauri for desktop packaging.

## Critical guardrails

- **Client-side redaction is a UX control, not a security boundary.** `isRedacted()` only blurs in the browser; above-clearance data still ships to the client. Never describe it as access control. Real enforcement must be server-side (top roadmap item). Don't add features that imply it's a real trust boundary without the backend.
- **URL pipelines hit the network via `fetch`** and are subject to browser CORS. Don't add code that tries to defeat CORS; the intended fix is a FastAPI relay that proxies/normalizes feeds.
- **Keep it defensive.** This tool analyzes data *about* threats. Do not add offensive capability (payload generation, live exploitation, C2, scanning of real hosts). Demo data stays fictional.

## Current state

v0.3.0. Implemented: constellation graph, command center, ATT&CK matrix, timeline, multi-format ingestion, auto-ingest pipelines (simulator + URL poll), translation (endpoint + demo dict), U/CUI/S/TS markings + clearance redaction across every view, custom tagging, saved searches + alert engine, JSON + Markdown export. Boots into the Operation Nightjar demo with one alerting search and one paused simulator pipeline.

Classification markings and tagging are gated behind a single opt-in "advanced" toggle (`settings.markings`, default `false` — checkbox in Pipelines & Settings, id `setMark`). Off by default: no banner, no classification/tag chips, and the inspector's Classification/Tags editors plus the ingest and pipeline forms' classification/tag fields are hidden via the `.advonly` CSS class (`body:not(.marked) .advonly{display:none}`, mirroring the existing `.classbanner`/`.marked` pattern). Operation Nightjar demo data ships with `classification:null`/`tags:[]` on every entity — nothing is pre-classified. Data model fields, export/import, and `buildMarkdown` are untouched (still lossless); only in-app *display and editing* of classification/tags is gated. When adding new classification- or tag-bearing UI, give it the `advonly` class (or gate with `markingsOn()` in JS) so it follows this pattern.

## Next tasks (prioritized)

1. **FastAPI backend** — persistence + auth; JWT carries a clearance claim; **server-side redaction** (filter above-clearance rows before they leave the API). Tables map 1:1 to `entities` / `links` / `events`; `searches` / `pipelines` / `users` as config. This unblocks everything below.
2. **Feed relay endpoint** on that backend to solve CORS and normalize incoming feeds for URL pipelines.
3. **Graph scale** — replace O(n²) repulsion in `physics()` with Barnes-Hut/quadtree; label decluttering for 1,000+ nodes.
4. **STIX 2.1** — real SROs and actor/malware SDOs in `parseJSON`; map marking-definitions to `CLASSIF`.
5. **Enrichment providers** — WHOIS / GeoIP / hash-reputation behind a provider interface; add an "Enrichment" section to `selectEntity`.
6. **Correlation** — flag cross-source indicator overlap; N-hop pivot queries.
7. **Time scrubber**; **PDF report export**; **Tauri packaging** (after backend).

## Workflow expectations

- Make focused commits with clear messages; update `CHANGELOG.md` for user-visible changes and bump the version there + in the boot banner if applicable.
- Update the relevant `wiki/` page and `HANDOFF.md` when you change architecture, the data model, or add a subsystem.
- When adding a feature, extend `demoData()` so it has live demo coverage, and add a Playwright assertion for it.
- Prefer editing existing functions over adding parallel ones; keep the single-file structure legible.
