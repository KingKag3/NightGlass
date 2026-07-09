# Classification & Redaction

## Levels
`CLASSIF`: U (green) < CUI (purple) < SECRET (red) < TOP SECRET (orange). Banner text is `LEVEL//NIGHTGLASS`, colored per convention, computed as max(instance classification, highest entity marking).

## Opt-in advanced mode
Classification and tagging are off by default (`settings.markings = false`). Pipelines & Settings → "Classification & tagging (advanced)" is the single master toggle for both. Off means: no banner, no classification/tag chips anywhere, and every drill-down editing control (inspector's Classification + Tags sections, the instance-classification select, the ingest form's classification/tag fields, the pipeline form's classification/tag fields) is hidden — CSS class `advonly`, hidden via `body:not(.marked) .advonly{display:none}`. The Operation Nightjar demo boots with `classification:null`/`tags:[]` on every entity; nothing is pre-seeded. Turn the toggle on to classify/tag manually. The fields still exist in the data model and round-trip through JSON export/import regardless of the toggle — only in-app display/editing is gated.

## Marking scopes (once advanced mode is on)
- **Whole application** — the advanced-mode toggle itself (off = no banner, no chips, no redaction, no drill-down editors)
- **Per instance** — instance classification select (floor for the banner)
- **Per ingested batch** — classification select on the Ingest view / per pipeline
- **Per item** — classification select in the inspector

## Clearance & redaction
Active analyst is chosen in the top bar (`USERS`, clearance chip). `isRedacted(e)` = markings on ∧ item marked ∧ item level > analyst level. Enforcement points:
- Graph: gray node, no severity ring, label `REDACTED`
- Inspector: open blocked with a clearance toast; redacted neighbors blurred in relationship lists
- Activity feed / timeline / search results / alert log: blurred `■■■` text, click-through disabled
- ATT&CK matrix: redacted techniques not highlighted
- Threat Actors view (see [[Architecture]]): the actor list blurs redacted rows and drops their click handler; `selectActorProfile()` refuses to open a redacted actor's profile (clearance toast, same as the inspector); if the *currently open* profile's actor becomes redacted — either by editing its classification from within the profile, or by switching to a lower-clearance analyst — the profile closes itself (`applyUser()` checks `profileActorId` the same way it already checked `selectedId` for the generic inspector); the profile's local-neighborhood preview greys out redacted neighbors and refuses to re-center/click-through on them, and defensively falls back to the root actor if the *currently centered* node becomes redacted mid-session (e.g. a clearance switch while drilled into a neighbor) rather than continuing to show its true connections

## Honest limitation
This is client-side UX enforcement — right for a personal tool, not for adversarial multi-user deployments. `isRedacted()` only blurs in the browser; the above-clearance entity is still present in `state.entities`, still in the page's memory and network response. A user with devtools open, or just View Source, can see it regardless of blur/hide — there is no way to make a U-clearance browser genuinely unable to discover that a TS entity exists without a server that never sends it that data in the first place. Discussed and explicitly declined as a client-only feature 2026-07-09: building something that *looks* locked down while the data is still fully present would be worse than the current honest-about-its-limits blur, since it implies a boundary that isn't there. Real enforcement belongs server-side: filter/blur at the API layer per authenticated user, never ship above-clearance rows to the client. That is roadmap item 1 — see [[Backend Architecture]] and [[Roadmap]].
