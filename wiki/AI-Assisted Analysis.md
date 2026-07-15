# AI-Assisted Analysis

**Status: backlog, not built.** Idea captured 2026-07-15 during the sandbox pan/zoom/expand work — deliberately not scoped into concrete tasks yet. This page exists so the idea has a home before it's built, not as a spec to implement against.

## The idea

NIGHTGLASS is an analyst tool for data *about* threats — it never scans, exploits, or contacts anything. An AI layer would extend that same posture: assistive, not autonomous. It reads the graph and proposes; it never writes to `state` on its own, and every suggestion is analyst-approved before it becomes real data. Rough tiers, roughly in order of how safe/immediately-useful they are:

1. **Pattern recommendations from the existing graph — no model call at all.** Shared-neighbor overlap, relation-type similarity, degree centrality: "this actor shares 3 relation types with campaign X, consider linking them." Pure local JS over `state.entities`/`state.links`, same trust level as the rest of the app. Natural first step, and useful on its own even if nothing past it ever gets built.
2. **Natural-language relationship/entity suggestions.** Summarize a slice of the graph (labels, types, existing relations — never raw classified attribute values) and ask a model what's plausible but missing. This is the first tier that needs an actual model call, and the first tier where the data-boundary question below actually matters.
3. **Narrative synthesis.** "Summarize this campaign's activity" or "draft an analyst note for this case," pulling from linked entities/events. Highest value for the Investigators workflow, highest stakes to get the UX right — must be unmistakably labeled as AI-generated, never silently merged into an analyst's own notes.

## Design shape (if/when this gets built)

Mirror the pattern the app already uses for translation and classification: an opt-in settings flag (alongside `settings.markings`/`settings.translate`), a pluggable provider interface rather than one hardcoded integration, and a demo/offline/heuristic provider as the default so the feature works with zero external calls out of the box — same shape as `DEMO_DICT` vs. a real LibreTranslate endpoint. A real provider is something the analyst configures with their own endpoint/key, not something baked in.

Recommendations render as dismissible suggestion cards, never auto-applied. An analyst clicks to accept (which then goes through the *same* creation path a human-authored link/entity would — no separate "AI-created" code path or data shape), or dismisses and moves on. This keeps the tool honest about being assistive, which matters more here than almost anywhere else in the app: false attribution in a threat-intel tool has real consequences, and the UI should never blur the line between "the analyst asserted this" and "a model guessed this."

## Open question, deliberately not answered yet

**What data ever leaves the browser, if a hosted (non-local) model is used as a provider.** This app is frontend-only and every other network-touching feature (translation, feed pipelines) already treats "where does data go" as a first-class, analyst-visible decision — a hosted AI provider needs the same scrutiny, probably including a clear warning when classified/tagged entities would be part of what's sent, and likely clearance-gating similar to `isRedacted()`. Worth resolving explicitly before tier 2 gets scoped for real, not something to default silently.

## Where this fits

Independent of the FastAPI backend item — pure frontend to start (tier 1 has zero new dependencies), same as [[Multi-Actor Support]]. See [[Roadmap]] / `CLAUDE.md` "Next tasks" for prioritization against other backlog work.
