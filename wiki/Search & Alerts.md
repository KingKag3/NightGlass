# Search & Alerts

## Query syntax
Free text plus filters, whitespace-separated, AND-combined:
```
type:ioc sev:high tag:c2 class:S iotype:domain update
```
- `type:` entity type · `sev:`/`severity:` · `tag:` substring match · `class:` exact marking · `iotype:` exact IOC subtype
- Free tokens match label, type, or serialized meta
- Same engine (`parseQuery`/`matchesQuery`) powers the graph filter box

## Saved searches & alerts
Save any query with a name; flag it as **alerting**. On every ingest (manual or pipeline), newly added entities are scanned; matches append to the alert log (capped 200), toast, and badge the bell icon. Alert rows deep-link to the entity in the constellation; redacted matches stay blurred for under-cleared analysts.

Starter content ships with one alerting search (`type:ioc sev:high`) and a paused simulator pipeline — resume it and watch the loop fire end-to-end.
