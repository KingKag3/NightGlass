# Multi-Actor Support

**Status: scoped, not implemented.** Agreed design for handling multiple threat actors / APT groups in one constellation, captured 2026-07-09 so it isn't lost between sessions.

## The gap today

- The only way to add an entity (including a new actor) is JSON/CSV/text ingest. Raw-text mining only extracts IOCs (IPv4, domain, URL, hash, CVE, email) — never actors, malware, or campaigns. There is no "New Actor" form anywhere in the UI.
- `state.links` is already fully generic (`{source, target, relation}`) — actor-to-actor relationships work with **zero schema changes** today (e.g. `{source:'actor:a', target:'actor:b', relation:'rival to'}` renders correctly in graph/inspector/matrix right now). The real gap is that nothing in the UI *creates* a link between two existing entities — only demo data / JSON import populate `links[]`.
- Every edge in the graph draws in one of two flat colors regardless of type (`draw()`, `index.html` ~line 1013). Every actor node shares the same purple (`TYPES.actor.color`). There's no way to visually tell which entities/edges belong to which actor once you have more than one.

## Agreed v1 scope

1. **Quick-add entity form** — on the Ingest view. Fields: type (dropdown, including `actor`), label, severity, free-form meta key/value pairs. Submits through the same merge path `ingestText`/JSON-ingest already use (don't invent a second entity-creation code path).
2. **Quick-add relationship form** — pick two existing entities (source, target) + a relation string. Optional: a small `RELKIND` lookup (same pattern as `TYPES`/`SEV`/`CLASSIF`) mapping common relation words (`rebranded as`, `subgroup of`, `shares infra with`, `rival of`, `collaborates with`, `successor of`...) to a category, while still allowing arbitrary free text — mirrors how classification/severity are configs, not hard enums.
3. **Attribution-colored edges** — assign each actor entity a deterministic color from a small fixed palette (e.g. hash actor id → cycle through ~8-10 accessible hues). In `draw()`, any edge where source or target is an `actor`-type entity renders in that actor's color instead of the current neutral default; edges with no actor endpoint keep today's behavior unchanged.
4. **Color → actor legend** — extends the existing entity-type legend panel (`renderLegend`) with a color-to-actor-name key. Necessary companion to #3: colored edges are meaningless without a legend once there are 3+ actors.

## Deliberately deferred (v2+, pick up "based on need")

- Transitive/cluster coloring — tinting the whole subgraph reachable from an actor (not just entities it directly touches). v1 only colors *direct* edges.
- Relation-type visual encoding (dashed vs solid, arrowheads for directionality/confidence) as a second dimension alongside color.
- Any kind of automatic attribution inference — this is purely an analyst-declared relationship model, same as everything else in NIGHTGLASS.

## Where this fits

Independent of the FastAPI backend item — pure frontend, can be picked up any time. See [[Roadmap]] / `CLAUDE.md` "Next tasks" for prioritization against other work.
