# Raw portfolio handoff package

This folder is the source-of-truth handoff for the portfolio direction approved in the design discussion. It is intended to be supplied to another AI coding/design tool as project context.

## Read these in order

1. `01-APPROVED-BRIEF.md` — what the site is, the intended story, approved sections, and what must not change.
2. `02-DESIGN-SYSTEM.md` — the visual identity, palette, typography, components, illustration style, and responsive rules.
3. `03-MOTION-AND-INTERACTION.md` — the exact opening sequence, cloud movement, layered mountain reveal, sparrow cursor, scroll motion, and closing sequence.
4. `04-CONTENT-AND-FACTS.md` — verified project facts and copy boundaries. No invented metrics or achievements.
5. `05-IMPLEMENTATION-GUARDRAILS.md` — how to iterate without replacing the whole site or introducing generic AI-generated design.
6. `06-HANDOFF-PROMPT.md` — copy/paste brief for another AI tool.
7. `design-references/` and `assets/` — compressed visual references and the animated sparrow asset.
8. `previous-prototype/` — previous HTML and ZIP from the approved warm/cinematic prototype iteration; reference material, not an instruction to restore its exact implementation unchanged.

## Approval status and version history

- **Current visual direction:** the warm, cinematic, illustration-led `Portfolio Design System v3` sheet (`design-references/portfolio-design-system-v3.webp`). It combines desktop and mobile layouts, page flow, motion concepts, and an opening/closing treatment.
- **Primary hero reference:** `design-references/sunset-mountain-hero-reference.webp`.
- **Alternate cinematic sheet:** `design-references/cinematic-design-system-alternate.webp`. Keep for design exploration; do not let it override v3 without discussion.
- **Older dark/neon board:** preserved separately in the downloadable full handoff archive as a historical alternative only. It is not the current approved art direction.
- **Later user correction:** the generic/placeholder AI section was explicitly rejected (“remove any and all AI slop”). Although the early six-section design sheet depicts an AI & Experiments panel, do **not** rebuild that as a standalone section. The current experience is the same cinematic single-page narrative with that placeholder removed; its other approved content and scenic language remain.
- **Sparrow:** user explicitly requested a small sparrow, not a parrot. The rough bird treatment was rejected. The GIF in `assets/sparrow-flight.gif` is the previous animated prototype asset; treat it as a starting asset and improve its integration/quality, not as proof the final cursor is complete.
- **Page height:** user explicitly requested every main page/section to occupy the device window for a premium feel. Use viewport minimum height, not fixed height that clips long content.

## Important distinction

Some images are generated design boards and contain mock text, AI labels, proposed section names, or approximate device UI. Use them to understand composition, visual language, and flow—not as a source of factual biography, exact metrics, or final copy. The content source of truth is `04-CONTENT-AND-FACTS.md` and any later user-approved updates.

## GitHub branch vs. companion archive

The GitHub branch contains the written specifications and decision log under `raw/`. The companion archive `portfolio-approved-raw-handoff.zip` contains the complete raw folder plus the binary source assets: full-resolution design-sheet PNGs, compact visual references, previous HTML/ZIP prototypes, the sparrow GIF, source spritesheet, and sparrow reference render. Use both together when handing this project to another AI tool. The archive's internal paths mirror this folder structure.
