# Multi-Actor Support

**Status: scoped, not implemented.** Agreed design for handling multiple threat actors / APT groups in one constellation, captured 2026-07-09 so it isn't lost between sessions.

## The gap today

- The only way to add an entity (including a new actor) is JSON/CSV/text ingest. Raw-text mining only extracts IOCs (IPv4, domain, URL, hash, CVE, email) — never actors, malware, or campaigns. There is no "New Actor" form anywhere in the UI.
- `state.links` is already fully generic (`{source, target, relation}`) — actor-to-actor relationships work with **zero schema changes** today (e.g. `{source:'actor:a', target:'actor:b', relation:'rival to'}` renders correctly in graph/inspector/matrix right now). The real gap is that nothing in the UI *creates* a link between two existing entities — only demo data / JSON import populate `links[]`.
- ~~Every edge in the graph draws in one of two flat colors regardless of type~~ **Done, 2026-07-09**: edges now render by `relColor(relation)` — a deterministic hash of the relation string onto the `TYPES`/`SEV` palette, with a "Relationship Lines" legend section. See `draw()`/`relColor()`/`hexToRgba()` in `index.html`. This covers the *relation-type* axis. Every actor node still shares one purple (`TYPES.actor.color`) — the *actor-identity* axis (item 3 below) is separate and still unbuilt.

## Agreed v1 scope

1. **Quick-add entity form** — on the Ingest view. Fields: type (dropdown, including `actor`), label, severity, free-form meta key/value pairs. Submits through the same merge path `ingestText`/JSON-ingest already use (don't invent a second entity-creation code path).
2. **Quick-add relationship form** — pick two existing entities (source, target) + a relation string. Optional: a small `RELKIND` lookup (same pattern as `TYPES`/`SEV`/`CLASSIF`) mapping common relation words (`rebranded as`, `subgroup of`, `shares infra with`, `rival of`, `collaborates with`, `successor of`...) to a category, while still allowing arbitrary free text — mirrors how classification/severity are configs, not hard enums.
3. **Attribution-colored edges (actor identity, distinct from the relation-type coloring already shipped)** — assign each actor entity a deterministic color from a small fixed palette. In `draw()`, any edge where source or target is an `actor`-type entity would render in that actor's color instead of (or blended with) its relation color; edges with no actor endpoint keep current behavior. Needs a design decision on how the two color axes (relation-type vs actor-identity) coexist without visually fighting each other — e.g. node-ring/glow for actor identity, line color for relation type, rather than both competing for line color.
4. **Color → actor legend** — extends the existing entity-type legend panel (`renderLegend`) with a color-to-actor-name key, same pattern as the relation-type legend that already shipped.

## Deliberately deferred (v2+, pick up "based on need")

- ~~Transitive/cluster coloring — tinting the whole subgraph reachable from an actor~~ **Partially addressed differently, 2026-07-09**: rather than tinting, the new Actors panel (`#actorsPanel`, `actorComponent()`/`focusActor()` in `index.html`, see [[Architecture]]) *isolates* an actor's connected component by hiding everything else, for when you have multiple actors that are structurally disconnected (e.g. two unrelated APT groups loaded together) and want to declutter. Coloring the reachable subgraph while keeping everything visible remains a distinct, unbuilt option if that's ever preferred over hide/show.
- Relation-type dashed/solid/arrowheads (directionality/confidence) as a second dimension alongside the color already shipped.
- Any kind of automatic attribution inference — this is purely an analyst-declared relationship model, same as everything else in NIGHTGLASS.

## Where this fits

Independent of the FastAPI backend item — pure frontend, can be picked up any time. See [[Roadmap]] / `CLAUDE.md` "Next tasks" for prioritization against other work.
