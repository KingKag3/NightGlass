# Ingestion & Pipelines

## Manual ingest (`ingestText(raw, filename, opts, quiet)`)
Auto-detects format:
1. **JSON** → native `{entities,links,events}` graphs, STIX-lite bundles (indicator patterns mined), or flat indicator arrays
2. **CSV** → header inference for indicator/type/severity/actor columns (`,` or `;`); unmapped columns preserved as meta; actor column auto-creates actor entities + links
3. **Free text** → regex miner: IPv4, domains, URLs, MD5/SHA1/SHA256, CVE IDs, emails; defanged forms (`evil[.]com`, `hxxp://`, `[at]`) re-fanged via `refang()`

`opts = { classification, tags, translate }` — applied to every entity in the batch; new entities are diffed (`state.entities.slice(before)`) and passed to `runAlertScan()`.

## Pipelines
- **Simulator** source generates synthetic indicators + events (≈50% include a high-sev beacon URL so alert demos fire); auto-pauses at a 500-entity cap
- **URL poll** fetches any CORS-accessible feed on an interval; browser CORS applies — when self-hosting, point at a small FastAPI relay that proxies + normalizes feeds
- Master scheduler: `setInterval(pipeTick, 5000)` runs any enabled pipeline whose interval has elapsed; per-pipeline Run now / Pause / Delete

## Translation
`translateText(text, lang)`:
- **endpoint** mode → POST `{q, source:'auto', target, format:'text'}` to `<txUrl>/translate` (LibreTranslate-compatible; self-hostable)
- **demo** mode → small built-in RU/ES→EN security-terms dictionary (offline, for demos only)
Failures fall back to untranslated ingest with a toast. Translated entities get `meta.translated`.
