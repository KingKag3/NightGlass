# Classification & Redaction

## Levels
`CLASSIF`: U (green) < CUI (purple) < SECRET (red) < TOP SECRET (orange). Banner text is `LEVEL//NIGHTGLASS`, colored per convention, computed as max(instance classification, highest entity marking).

## Marking scopes
- **Whole application** — Pipelines & Settings → "Classification markings enabled" (off = no banner, no chips, no redaction)
- **Per instance** — instance classification select (floor for the banner)
- **Per ingested batch** — classification select on the Ingest view / per pipeline
- **Per item** — classification select in the inspector

## Clearance & redaction
Active analyst is chosen in the top bar (`USERS`, clearance chip). `isRedacted(e)` = markings on ∧ item marked ∧ item level > analyst level. Enforcement points:
- Graph: gray node, no severity ring, label `REDACTED`
- Inspector: open blocked with a clearance toast; redacted neighbors blurred in relationship lists
- Activity feed / timeline / search results / alert log: blurred `■■■` text, click-through disabled
- ATT&CK matrix: redacted techniques not highlighted

## Honest limitation
This is client-side UX enforcement — right for a personal tool, not for adversarial multi-user deployments. Real enforcement belongs server-side: filter/blur at the API layer per authenticated user, never ship above-clearance rows to the client. That is a first-class item in [[Roadmap]].
