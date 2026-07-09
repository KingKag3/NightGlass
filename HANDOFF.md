# NIGHTGLASS — Threat Constellation

**Handoff document for continued development (written by Claude Fable 5, intended for Claude Opus or any future session).**

A single-file cyber threat analysis application: ingest heterogeneous threat data, visualize it as an interactive relationship graph, and export analyst-ready reports. No build step, no framework, no server. Open `threat-constellation.html` in a browser and it works.

---

## 1. Design intent (read this before changing the look)

The aesthetic is a **signals-intelligence observatory**, deliberately *not* the Matrix-green hacker cliché:

- **Palette:** deep indigo void (`#080B16` / `#0B1020`), panel navy (`#111a2e`), signal cyan (`#3BE8DE`) as the single interaction accent, violet (`#B794FF`) as secondary.
- **Severity ramp** (semantic, not decorative): low `#4DD4FF` → medium `#FFC93D` → high `#FF8A3D` → critical `#FF4D6D`. Severity is always shown as a *ring* around graph nodes and a *left border* on feed items.
- **Type colors** (entity identity): actor violet, malware rose, IOC cyan, CVE amber, campaign blue, asset green, technique pink. Defined in the `TYPES` object and mirrored as CSS variables (`--t-*`).
- **Typography:** Space Grotesk for UI, JetBrains Mono strictly for *data* (indicators, hashes, timestamps, metrics). Keep that rule — mono only where real data lives.
- **Signature element:** the constellation graph with traveling signal pulses on edges. All design boldness is spent there; every other surface is a quiet instrument panel. Resist adding glow elsewhere.

## 2. Architecture

Single HTML file, three sections: CSS (design tokens in `:root`), markup (app shell + 5 views + inspector drawer), and vanilla JS (~600 lines).

### App shell
- Left icon rail → view switching (`switchView(v)`), views are absolutely-stacked `<section class="view">` elements toggled via `.is-active`.
- Top bar → live stats, security-posture pill, UTC clock.
- Right **inspector drawer** (`#inspector`) → entity detail panel, opened by `selectEntity(id)` from any view (graph click, ticker, timeline, matrix, top-actors list). Relationship rows navigate to neighboring entities.

### Views
| View | id | Notes |
|---|---|---|
| Command Center | `view-overview` | Metric cards, severity bars, composite-risk gauge (canvas arc), live activity ticker, top actors, IOC type breakdown |
| Threat Constellation | `view-graph` | Custom canvas force graph (see §3) |
| ATT&CK Matrix | `view-matrix` | 7 tactics × 3 base techniques; cells light up when a `technique` entity with matching `meta.ttp` exists |
| Timeline | `view-timeline` | Vertical event timeline from `state.events` |
| Ingest | `view-ingest` | Drag-drop, paste box, parsers, exports, and the design self-Q&A |

## 3. The graph engine (custom, no library)

`#graph` canvas + `requestAnimationFrame` loop (`tick()`):

- **Physics (`physics()`):** pairwise repulsion (`2600/d²`, capped at distance² > 90 000 for perf), spring links (rest length 110, k = 0.012), weak centering force (0.0016), velocity damping 0.86, per-frame velocity clamp ±8.
- **Camera:** `view = {x, y, k}` with `toScreen`/`toWorld`; wheel zoom is cursor-anchored (0.25–3×). Pan by dragging empty space; drag nodes directly.
- **Rendering:** faint grid → edges (highlighted cyan when touching `selectedId`) → pulse particles (spawned randomly ~8 %/frame, `t += 0.02` along a random edge) → nodes (type-colored glow disc, severity ring, dark core, mono label shown when zoom > 0.55 or node is actor/campaign/selected).
- **HUD:** legend with click-to-hide per type (`hiddenTypes` Set — hidden types are excluded from physics and hit-testing too), search box that dims non-matching nodes, Recenter and Freeze controls.
- DPI-aware (`dpr`), basic touch pan/drag supported.

**Known limitation:** physics is O(n²). Fine up to ~300 nodes; beyond that, add a Barnes-Hut quadtree or grid-bucket neighbor lookup (top roadmap item).

## 4. Data model

```js
state = {
  entities: [{ id, type, label, severity, meta:{...}, x, y, vx, vy }],
  links:    [{ source, target, relation }],   // ids, directed, verb string
  events:   [{ ts, severity, entityId, text }] // ISO ts; text may contain <b>
}
```

- `type` ∈ `actor | malware | ioc | cve | campaign | asset | technique` (see `TYPES`).
- `severity` ∈ `critical | high | medium | low | info` (see `SEV`, normalized by `normSev()`).
- IOC entities carry `meta.iotype` (`ipv4, domain, url, sha256, sha1, md5, email`).
- Technique entities carry `meta.ttp` (e.g. `T1190`) and `meta.tactic` — these drive the ATT&CK matrix highlighting.
- Position/velocity fields are stripped on export; `seedPos()` re-seeds them on import.

## 5. Ingestion pipeline

`ingestText(raw, filename?)` auto-detects:

1. **JSON** (`JSON.parse` succeeds) → `parseJSON()`:
   - Native graph `{entities, links, events}` — merged by id.
   - STIX-lite bundle (`type:"bundle"` with `indicator` objects) — patterns mined for IOCs.
   - Flat array of `{indicator|value|ioc, type?, severity?}` objects.
2. **CSV** (first line has delimiters, no double-space) → `parseCSV()`: header inference for `indicator/type/severity/actor` columns (`,` or `;` delimiter); unmapped columns preserved as `meta`; an `actor` column auto-creates actor entities + `indicated by` links.
3. **Free text** fallback → `extractIOCs()` regex miner: IPv4, domains, URLs, MD5/SHA1/SHA256 (SHA-substring dedupe for MD5), CVE IDs, emails. Defanged indicators (`evil[.]com`, `hxxp://`, `[at]`) are re-fanged via `refang()`.

All paths dedupe by id, call `render()`, and toast a result summary. Entry points: drag-drop, file picker (multi-file), paste box, demo loader.

## 6. Export / re-import round trip

- **Export JSON** → `nightglass-export.json` — clean `{entities, links, events}` (positions stripped). Re-ingesting it reconstructs the constellation exactly. This is the persistence mechanism.
- **Export Markdown** → `threat-report.md` via `buildMarkdown()`: executive summary with posture + composite index, severity table, per-actor sections with linked entities, IOC table, CVE table, observed ATT&CK techniques, timeline. Footer documents the data model.

## 7. Scoring

- `threatIndex()` — weighted severity sum (crit 10 / high 6 / med 3 / low 1) normalized against max possible, plus up to +30 for actor count. Range 0–100.
- `posture()` — maps index to STANDBY / LOW / GUARDED / ELEVATED / CRITICAL with a color; drives the top-bar pill and gauge.

## 8. Demo scenario

`demoData()` ships **Operation Nightjar** — a fictional espionage campaign (APT-Nightjar → RookDoor/SledgeKey → CVE-2024-3400/CVE-2023-4966 → C2 infrastructure → compromised assets), 21 entities, 22 links, 7 timeline events, 5 mapped ATT&CK techniques. It exercises every feature; keep it in sync if the data model changes. It loads on boot.

## 9. Roadmap (prioritized for the next session)

1. **Persistence** — the app currently resets on reload (deliberately in-memory; note that Claude.ai artifacts can't use localStorage — use the artifact `window.storage` API there, or localStorage/IndexedDB when self-hosted).
2. **Graph scale** — quadtree repulsion + label decluttering for 1 000+ nodes; optional cluster/community coloring.
3. **Richer STIX 2.1** — relationships (SRO), threat-actor/malware SDOs, marking definitions, not just indicator patterns.
4. **Enrichment hooks** — pluggable lookups (WHOIS, GeoIP, VirusTotal-style hash reputation) behind a provider interface; the inspector already has room for an "Enrichment" section.
5. **Correlation engine** — flag when two ingested sources share an indicator; confidence scoring on links; "pivot" queries (all entities within N hops).
6. **Time scrubber** — filter the constellation by event window; animate campaign progression along the timeline.
7. **Backend option** — the owner's established stack is FastAPI + SQLAlchemy + SQLite with this same single-file frontend, and Tauri for desktop packaging; entities/links/events map 1:1 to three tables.
8. **Report polish** — PDF export, per-actor sub-reports, TLP markings.

## 10. Conventions & gotchas

- No external JS dependencies; fonts are the only network fetch (app degrades gracefully offline to system fonts).
- All user-supplied strings pass through `escapeHtml()` before hitting `innerHTML` — keep that discipline for any new render path.
- `prefers-reduced-motion` disables all animation; keep new motion behind it.
- CSS custom properties in `:root` are the single source of design truth — never hard-code a color in JS except via `TYPES`/`SEV`.
- Event ticker/timeline `text` fields intentionally allow `<b>` only because they're authored (demo/JSON ingest); if you ever render *extracted* text there, escape it first.
- `demoData()` is also the living spec/example of the data model.

---

# v2 addendum (2026-07-08)

The five wish-list features are implemented in `index.html` (repo root). Summary of what changed since the sections above:

- **State grew**: `pipelines`, `searches`, `alerts` arrays; `settings {markings, instanceClass, txMode, txUrl, txLang}`; `CLASSIF` level map; `USERS` + `activeUser` clearance model. Entities gained `classification` and `tags`.
- **New views**: `view-alerts` (query box, saved searches, alert log) and `view-pipes` (instance settings, translation provider, pipeline manager). Two new rail buttons; alert badge on the bell.
- **Redaction**: `isRedacted(e)` enforced in graph draw, inspector open, relationship lists, ticker, timeline, ATT&CK matrix, and search results. Classification banner is a fixed strip; `body.marked` shifts the app grid.
- **Ingestion**: `ingestText` is now async with `opts {classification, tags, translate}` and a `quiet` flag; new-entity diffing feeds `runAlertScan()`. Simulator feed emits a high-sev beacon URL ~50% of the time so the starter alert demo fires.
- **Translation**: `translateText()` — LibreTranslate-compatible endpoint or offline demo dictionary.
- **Exports**: JSON now round-trips classification, tags, searches, pipelines, settings; the Markdown report carries the classification banner and Class/Tags columns.
- Full details live in the repo `wiki/` (Obsidian-compatible).

**Top priority for the next session**: the FastAPI backend with server-side clearance enforcement — client-side redaction is a UX control, not a security boundary.

---

# v0.3.0 addendum (2026-07-09)

Classification markings and tagging became an opt-in "advanced" feature instead of always-on:

- **Default flipped**: `settings.markings` now defaults to `false` (was `true`). The Pipelines & Settings checkbox is relabeled "Classification & tagging (advanced)".
- **Demo data stripped**: `demoData()`'s `cls`/`tg` seed maps are gone — every entity boots with `classification:null, tags:[]`. The starter `p0` simulator pipeline lost its `CUI`/`['auto']` seed too. Operation Nightjar now loads clean; classify/tag things yourself after enabling the toggle.
- **New CSS gate**: `.advonly` class + `body:not(.marked) .advonly{display:none}` (next to the existing `.classbanner`/`.marked` rule at the top of `<style>`). Applied to: the instance-classification select, the ingest form's classification/tag fields, the pipeline form's classification/tag fields, and the inspector's Classification + Tags `insp__section` blocks. Tag chips in search results and the pipeline list are now conditionally rendered on `markingsOn()` in JS instead (template strings, not static markup).
- **Bug fixed in passing**: the pipeline list's classification chip (`renderPipelines`) was rendering unconditionally on `p.classification`, ignoring `markingsOn()` — now gated like every other chip.
- Everything else about the redaction/classification system (`isRedacted`, `CLASSIF`, per-item/per-instance/per-batch scopes, JSON/Markdown export round-trip) is unchanged — only default state and UI visibility moved. See [[Classification & Redaction]] for the updated toggle behavior.
