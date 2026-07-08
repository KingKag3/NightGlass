# Data Model

```js
state = {
  entities:  [{ id, type, label, severity, classification, tags:[], meta:{}, x,y,vx,vy }],
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
- Positions are stripped on export; `seedPos()` re-seeds on import
- `demoData()` (Operation Nightjar) is the living example of the model

## SQLite mapping (future backend)
`entities`, `links`, `events` tables map 1:1; `tags` as a join table or JSON column; `pipelines`/`searches`/`users` as config tables. Alerts become rows written by the ingest worker.
