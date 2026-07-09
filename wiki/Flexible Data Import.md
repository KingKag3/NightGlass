# Flexible Data Import

**Status: designed, not yet implemented.** Scoped 2026-07-09, prompted by a real failure: a custom-schema JSON (fictional HUMINT network data, now [[Data Model|bundled as a second sample dataset]]) silently ingested zero entities because `parseJSON` only recognizes three shapes (native NIGHTGLASS graph, STIX-lite bundle, flat indicator array) and has no fallback when none match.

## The core primitive: a mapping spec

A small declarative object — dot-path field references, no JSONPath library (keeps the no-dependencies rule; the resolver is ~30 lines of plain JS):

```js
{
  entitiesPath: "network_analysis.nodes",     // dot-path to the array in the source JSON
  entity: { id:"id", label:"name", type:"'actor'", severity:"'medium'", meta:"*" },
  linksPath: "network_analysis.edges",
  link: { source:"source", target:"target", relation:"type" }
}
```

Values starting with `'` are literal constants (e.g. `"'actor'"` always resolves to `"actor"`); anything else is a field path read off each object in the array. `meta:"*"` passthrough-copies whatever fields aren't otherwise mapped. This is a direct generalization of the one-off Node script used to convert the Americans dataset — same idea, made reusable instead of hand-written per file.

## Updated ingest flow

Auto-detection runs first and is unchanged — native shape, STIX-lite bundle, flat indicator array all still ingest with zero friction. Only when *none* of those match does the mapping path kick in, replacing today's silent "no new entities found" with an actual way forward.

## Build order (confirmed: mechanism + pipelines before the wizard UI)

1. **Phase 1 — mechanism only.** The mapping resolver + an `applyMapping(rawJson, spec) → {entities, links}` function. No UI; mapping specs are hand-authored. This alone turns "write a one-off conversion script" into "write a ~10-line mapping object."
2. **Phase 3 — pipeline integration** *(built alongside/right after Phase 1, ahead of the wizard)*. A pipeline definition gains an optional saved-mapping reference. `runPipeline()` applies it to whatever a URL source returns instead of assuming a native/STIX shape. This is what makes *unattended* ingestion of a custom-shaped feed actually work — a human can tolerate hand-mapping a file once; a pipeline silently ingesting zero entities on every poll is a much worse failure mode, and it's the scenario most likely to actually occur given "no idea how people are going to ingest."
3. **Phase 2 — mapping wizard UI.** Only after 1+3 prove the mechanism out. When auto-detection fails: pick the array from a tree view of the JSON's structure, map a few fields via dropdowns populated from a real sample object's actual keys, preview the result, confirm to ingest. Optionally name + save the mapping for reuse (by a human next time, or by a pipeline).

## Where this fits

Independent of the FastAPI backend ([[Backend Architecture]]) — pure frontend, same as [[Multi-Actor Support]]. Once a mapping can be saved/named (late Phase 2), it becomes a natural `state.importMappings` list, mirroring how `searches` and `pipelines` are already stored.
