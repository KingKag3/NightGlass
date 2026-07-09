# Data Model

```js
state = {
  entities:  [{ id, type, label, severity, classification, tags:[], meta:{}, images:[], x,y,vx,vy }],
  links:     [{ source, target, relation }],
  events:    [{ ts, severity, entityId, text }],
  pipelines: [{ id, name, src:'sim'|'url', url, interval, classification, tags, translate, enabled, lastRun, count, lastStatus }],
  searches:  [{ id, name, query, alert }],
  alerts:    [{ ts, search, entityId, label }],
}
settings = { markings, instanceClass, txMode:'demo'|'endpoint', txUrl, txLang }
USERS = [{ name, clearance }]   // clearance ∈ U | CUI | S | TS
```

- `type` ∈ actor | malware | ioc | cve | campaign | asset | technique (`TYPES` map: label/color/radius)
- `severity` ∈ critical | high | medium | low | info (`SEV` map), normalized by `normSev()`
- IOC entities carry `meta.iotype` (ipv4, domain, url, sha256, sha1, md5, email)
- Technique entities carry `meta.ttp` + `meta.tactic` → drives ATT&CK matrix
- `classification` null = unmarked; `CLASSIF` map holds level + label + banner color
- `images` — array of data URIs (JPEG, downscaled to ≤480px on the long edge, quality 0.82), added via the Threat Actors profile's gallery (`handleImagesAdd()`, multi-file upload); `images[0]` is the avatar shown in the list/header. Round-trips through export/import like every other field, unlike `x`/`y`/`vx`/`vy`. (Was a single `image` field pre-v0.9.0 — `parseJSON` still accepts a legacy `image` string and wraps it into `images` on import.)
- Positions are stripped on export; `seedPos()` re-seeds on import
- `demoData()` (Operation Nightjar) is the living example of the model
- `docs/samples/the-americans-network.json` — a second, larger reference dataset (60 entities, 101 links, 42 distinct relation types): a fictional HUMINT network graph based on FX's *The Americans*. Not wired into `demoData()`/boot — drag it into the Ingest view to load it. Useful for testing at a scale/relation-density the built-in demo doesn't cover (e.g. relationship-line coloring with a large, varied relation vocabulary).

## SQLite mapping (future backend)
`entities`, `links`, `events` tables map 1:1; `tags` as a join table or JSON column; `pipelines`/`searches`/`users` as config tables. Alerts become rows written by the ingest worker.
