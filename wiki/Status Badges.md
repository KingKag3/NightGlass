# Status Badges

**Status: backlog, not built.** Idea captured 2026-07-15 alongside [[AI-Assisted Analysis]] and [[Graph Regions]] — deliberately not scoped into concrete tasks yet.

## The idea

A small, visible badge on an entity — "Deceased," "BOLO / Wanted," "Incarcerated," "Relocated," "Confidential source" — distinct from severity, classification, and tags. Three existing mechanisms each half-cover this, and none actually fit.

## Why the existing mechanisms don't fit

- **`entity.meta{}`** — already supports this today with zero new code (`meta.status = 'Deceased'`), editable right on the profile's `metarow` UI. But it's invisible at a glance: just another row in the 2-column attribute grid, no icon, no color, no controlled vocabulary — a typo ("Decesed") wouldn't be caught and would render identically to a correct entry.
- **`tags[]`** — closer in spirit (chip-rendered, searchable via `tag:`), but gated behind the classification/markings opt-in toggle (`settings.markings`, off by default). A status badge is basic enough it probably shouldn't inherit that gate.
- **`state.flags[]`** (Investigators flagging, `flagEntity()`) — closest in *name* ("alert"), but the wrong *semantics*: it means "needs analyst follow-up, resolvable, tied to a reason and an analyst," not "permanent state of being." Marking someone deceased isn't a to-do to resolve.

## Proposed shape

A new, small config-driven system — same pattern as `TYPES`/`SEV`/`CLASSIF`: a short default vocabulary, each with an icon and color, plus a free-text escape hatch for anything not in the default list (mirroring how relation labels already work — common ones get consistent styling via `relColor()`, anything else still works as plain text). An array per entity, since more than one can apply at once (e.g. both "deceased" and a prior "BOLO"). Worth defaulting to a dated/attributed shape rather than a bare label — `{key, label, icon?, setAt, setBy, note?}`, mirroring how cases/flags already carry `createdAt`/analyst attribution — since these read like exactly the kind of fact a case file wants dated and sourced, not a silent boolean flip.

## The real cost: three separate rendering surfaces

A given entity's node isn't drawn once — it's drawn independently in three places that are deliberately *not* unified (there's an explicit comment in the code warning not to conflate the sandbox and profile/print renderers):

1. The main constellation `<canvas>` (`draw()`)
2. The profile's own radial local-neighborhood preview (`drawProfilePreview()` — this is the "radial" the idea is about)
3. The sandbox's SVG mind-map (`sandboxNodeGroup`), if a badged entity gets referenced into a sandbox draft

Getting a badge to show up consistently means touching up to three independent render paths, not one. Not a blocker, but a real 3x surface for what looks like "one small visual feature" — worth sizing the task with that in mind rather than assuming it's a single render-function change.

## Two more things to decide up front

- **Redaction interaction** — should a badge be visible on a redacted (above-clearance) entity? It should probably follow the same `isRedacted()` gating as everything else, so a status badge can't leak information through the redaction boundary by accident.
- **Search operator naming** — `flagged:` is already taken (Investigators follow-up flags). A badge query operator needs a different keyword — `status:` or `badge:`, not `flag:`.

## Where this fits

Pure frontend, independent of the FastAPI backend item. See [[Roadmap]] / `CLAUDE.md` "Next tasks" for prioritization against other backlog work.
