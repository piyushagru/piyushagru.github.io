# 05 — Implementation guardrails

## Most important: do not redesign the whole site
The user corrected a previous wholesale rewrite. “Make it premium” means improve craft within the approved concept: illustration quality, typography, spacing, motion, responsiveness, accessibility, and details. It is not permission to replace the identity, narrative, or page structure.

## Build incrementally
1. Inspect the current page and assets before editing.
2. Capture a baseline screenshot on desktop and mobile.
3. Work on a feature branch; don't change production directly.
4. Improve one component/section at a time, beginning with the hero and mountain reveal.
5. Explain structural changes before making them; preserve the approved narrative.
6. Capture desktop and mobile screenshots after each meaningful step.
7. Compare against the v3 board and this brief.
8. Only merge/deploy after Piyush approves the visual result.

## Explicitly avoid
- Generic AI design clichés, arbitrary gradients, glassmorphism, random floating cards, meaningless glow shapes, generic robot/AI art, and filler copy.
- Replacing the landscape with an abstract hero or tech dashboard.
- Replacing the sparrow with a parrot, emoji, generic glyph, crude SVG, or low-quality bird.
- Adding an AI section because an older board shows one.
- Generic project cards or fake architecture diagrams.
- Made-up metrics or achievements.
- Wholesale rewrite, new identity, or unapproved page structure changes.
- Fixed section heights that crop content.
- Forced scroll snapping / scroll-jacking.

## Quality checks
- Intentional desktop and mobile layouts.
- Major sections use viewport minimums (100svh / 100dvh) where appropriate, without fixed-height clipping.
- Mountain reveal order is foreground to background.
- Cloud motion loops smoothly without visible jumps.
- Sparrow follows with easing, flaps while moving, turns with direction, rests when idle, and returns in the closing.
- Keyboard focus is visible; links/buttons are accessible.
- Reduced-motion users get a calm static experience.
- Readable contrast and type sizes; no horizontal overflow.
- No broken assets, console errors, or unexpected layout shifts.

## Previous prototype
The previous refined HTML/ZIP is preserved for inspection. It contains useful copy direction and a sparrow GIF, but is not a finished implementation. “Exists in the prototype” does not mean “approved as final quality”.
