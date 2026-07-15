# Graph Regions

**Status: backlog, not built.** Idea captured 2026-07-15 alongside [[AI-Assisted Analysis]] — deliberately not scoped into concrete tasks yet.

## The idea

A visual boundary drawn on the constellation graph around a cluster of nodes — the kind of "frame" or "region" annotation common in link-analysis tools (Maltego, i2 Analyst's Notebook) and general canvas tools (Miro/FigJam): a labeled, colored area that visually groups a set of entities without changing what they *are*. The main constellation is a `<canvas>` (not SVG/DOM), so drawing the shape itself is a small, contained addition to `draw()` — the real design questions are below.

## The fork that actually matters: how membership is defined

- **Positional/freeform** — a saved shape (rectangle/blob) at fixed canvas coordinates. Cheapest to build: draws behind the nodes each frame, zero new data model. But it drifts out of sync the moment physics or manual dragging moves a member node — the shape stops actually containing what it was meant to represent.
- **Membership-based** — a boundary (padded bounding box or convex hull) recomputed every frame from the live positions of a defined set of entities. Always visually correct, but needs an actual membership concept:
  - Reuse `entity.tags[]` — "draw a region around every visible entity sharing tag X." Zero new schema, exportable/filterable for free (`tag:` already exists) — but inherits the existing gate: tags currently live behind the classification/markings opt-in toggle (`settings.markings`, off by default). A region feature tied to tags would be invisible on a fresh instance until an analyst opts into markings, which is probably the wrong coupling for something this foundational.
  - New `state.regions[]` (`{id, label, color, memberIds:[]}`) — purpose-built, doesn't inherit the markings gate, works for any explicit set of entities regardless of shared tags. Real new schema though: per the "data model is append-safe" convention, needs `demoData()`, JSON export/import, and `buildMarkdown` updated together to stay lossless.

**Leaning:** new `state.regions[]`, not tag-reuse. The markings-gate coupling is the wrong default for something this basic, and explicit membership is more flexible anyway — an analyst should be able to group two entities that have nothing else in common.

## Naming: not "Groups"

The Threat Actors view already has a "Groups" section meaning *campaigns*, with `actorsViewGroupFilter` baked into that terminology throughout the UI. A second, unrelated "group" concept would collide immediately. "Regions" (or "Clusters"/"Annotations") avoids the clash.

## The bigger cost: defining membership, not drawing the shape

Rendering a hull behind some nodes is a small, contained canvas change. The real cost is *how an analyst builds the member list*:

- **Canvas multi-select** (lasso/marquee-drag, or shift/ctrl-click to build a selection set) is the intuitive "point at the graph" interaction, but it's a genuinely new gesture — the canvas today only supports drag-a-single-node and pan-empty-space, and a lasso would need to coexist with both without conflicting.
- **Form-based membership** (pick entities via a search picker, same pattern already used for cases/sandbox/bulk search — see `wireSandboxPicker`) is a much smaller lift, reusing UI that already exists everywhere else in the app, at the cost of not feeling as direct as drawing on the canvas itself.

**Leaning:** ship form-based first — small, consistent with existing patterns, low risk. Treat canvas lasso-select as a distinct, larger follow-up only if the form-based version proves the feature earns the bigger investment.

## Where this fits

Pure frontend, independent of the FastAPI backend item — same as [[Multi-Actor Support]]. See [[Roadmap]] / `CLAUDE.md` "Next tasks" for prioritization against other backlog work.
