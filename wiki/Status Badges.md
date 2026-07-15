# Status Badges

**Status: shipped 2026-07-15**, mostly as designed below. Idea captured 2026-07-15 alongside [[AI-Assisted Analysis]] and [[Graph Regions]]; built the same day. One deliberate scope cut from the original plan: renders on the main canvas and the profile radial preview, but not yet on the sandbox's SVG mind-map (see "The real cost" section below, now resolved down to two surfaces + one deferred).

## The idea

A small, visible badge on an entity — "Deceased," "BOLO / Wanted," "Incarcerated," "Relocated," "Confidential source" — distinct from severity, classification, and tags. Three existing mechanisms each half-cover this, and none actually fit.

## Why the existing mechanisms don't fit

- **`entity.meta{}`** — already supports this today with zero new code (`meta.status = 'Deceased'`), editable right on the profile's `metarow` UI. But it's invisible at a glance: just another row in the 2-column attribute grid, no icon, no color, no controlled vocabulary — a typo ("Decesed") wouldn't be caught and would render identically to a correct entry.
- **`tags[]`** — closer in spirit (chip-rendered, searchable via `tag:`), but gated behind the classification/markings opt-in toggle (`settings.markings`, off by default). A status badge is basic enough it probably shouldn't inherit that gate.
- **`state.flags[]`** (Investigators flagging, `flagEntity()`) — closest in *name* ("alert"), but the wrong *semantics*: it means "needs analyst follow-up, resolvable, tied to a reason and an analyst," not "permanent state of being." Marking someone deceased isn't a to-do to resolve.

## Shape, as built

A small config-driven system — same pattern as `TYPES`/`SEV`/`CLASSIF` (`STATUS_BADGES`, defined next to `CLASSIF` in `index.html`): five defaults (BOLO / Wanted, Deceased, Incarcerated, Relocated, Informant / Source), each with an icon and color, plus a free-text escape hatch for anything not in the default list (mirroring how relation labels already work — common ones get consistent styling via `relColor()`, anything else still works as plain text). An array per entity (`entity.statusBadges[]`), since more than one can apply at once. Went with the dated/attributed shape as planned — `{key, label, setAt, setBy, note}` — rather than a bare label; icon/color are deliberately *not* baked into the stored badge, resolved live via `statusBadgeMeta(key)` instead, so retuning the default palette re-colors every existing badge for free (same principle as `relColor()` deriving color from the relation string rather than storing it).

Typing or picking a label that matches a default (case-insensitively, via an HTML `<datalist>` for keyboard-friendly autocomplete) resolves to that config's key/icon/color; anything else becomes a free-text custom status keyed on its own lowercased text, with a generic ⚑ fallback icon. Duplicate statuses on one entity are rejected with a toast rather than silently stacking.

## The real cost: three separate rendering surfaces (scoped to two)

A given entity's node isn't drawn once — it's drawn independently in three places that are deliberately *not* unified (there's an explicit comment in the code warning not to conflate the sandbox and profile/print renderers):

1. The main constellation `<canvas>` (`draw()`) — **shipped**, one corner icon (first badge only, kept minimal at graph scale) per node, gated behind the same `isRedacted()` check as the severity ring.
2. The profile's own radial local-neighborhood preview (`drawProfilePreview()` — this is the "radial" the idea is about) — **shipped**, a full icon row under the focus node.
3. The sandbox's SVG mind-map (`sandboxNodeGroup`), if a badged entity gets referenced into a sandbox draft — **deferred**. A draft workspace isn't typically where you'd be checking an established fact like "is this person deceased," so this was cut to ship the other two surfaces same-day rather than blocking on full three-surface parity. Fast-follow if it turns out to matter in practice.

## Two more things, now decided

- **Redaction interaction** — badges follow the same `isRedacted()` gating as the severity ring and label on both canvas surfaces. The profile *edit* page itself (where badges are added/removed) turned out, on inspection, not to redaction-gate *any* of its fields today — not the label, not tags, not attributes — so the new Status section matches that existing (if imperfect) precedent rather than introducing a new, inconsistent gate found nowhere else on that page.
- **Search operator naming** — landed on `status:`/`badge:` as aliases (both set the same query-filter field), matching against a badge's key or label substring. Confirmed distinct from `flagged:`, which still means an open Investigators follow-up flag.

## Where this fits

Pure frontend, independent of the FastAPI backend item. See [[Roadmap]] / `CLAUDE.md` "Next tasks" — sandbox-surface parity is the one remaining fast-follow, not yet scoped as its own task.
