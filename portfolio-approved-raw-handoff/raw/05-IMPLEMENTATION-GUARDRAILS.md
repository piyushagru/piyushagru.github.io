# 05 — Implementation guardrails (read before editing)

## Most important instruction: do not redesign the whole site

The user corrected a previous wholesale rewrite. The approved concept and raw requirements must be preserved. “Make it premium” means improve execution, illustration quality, typography, spacing, motion, responsiveness, and polish **within the approved art direction**. It does not grant permission to replace the identity, section narrative, or visual language.

## Work incrementally

1. Inspect the current page and assets before editing.
2. Create a baseline screenshot at desktop and mobile sizes.
3. Work on a feature branch; do not modify the production branch directly.
4. Improve one component/section at a time (start with the hero scene and mountain layers).
5. Before broad structural changes, explain the intended change and preserve the existing approved page architecture.
6. Capture desktop and mobile screenshots after each meaningful step.
7. Check the result against the approved v3 design sheet and this brief.
8. Only merge/deploy after Piyush approves the visual result.

## Explicitly avoid

- Generic AI-generated visual clichés, arbitrary gradients, glassmorphism, random floating cards, endless rounded rectangles, meaningless glowing shapes, generic robot/AI art, and filler copy.
- Replacing the mountain landscape with a generic abstract hero or tech dashboard.
- Replacing the sparrow with a parrot, simple emoji, arrow pointer, crude SVG doodle, or low-quality bird asset.
- Adding a new AI section just because an older concept board contains one.
- Replacing the selected work with generic project cards or fake architecture diagrams.
- Adding made-up statistics or claims.
- Rewriting the page as a different visual concept without approval.
- Fixed section heights that crop content, text, or controls.
- Forced scroll snapping or scroll-jacking.

## Required quality checks

- Desktop and mobile layouts both deliberate and visually composed.
- Sections use viewport-height minimums where appropriate (`100svh` / `100dvh`), and can grow when content requires it.
- Foreground-to-background mountain reveal order is correct.
- Cloud movement is smooth and continuous without visible jumps.
- Sparrow animation looks like a real sparrow and follows with eased movement; it flips direction and rests when idle.
- Closing section brings the sparrow back.
- Links/buttons are keyboard accessible and visibly focusable.
- Reduced-motion users get a calm static experience.
- Text contrast and type sizes remain readable.
- No horizontal overflow at narrow widths.
- No console errors, broken assets, or layout shifts from unreserved image dimensions.

## Existing prototype status

`previous-prototype/approved-refined-index.html` and `previous-prototype/piyush-portfolio-refined.zip` are a previous implementation iteration. It contains real content direction and the original animated sparrow GIF, but it is not a finished design reference. In particular, the bird and some scene implementations still need refinement. Do not confuse “exists in the prototype” with “approved as final visual quality”.
