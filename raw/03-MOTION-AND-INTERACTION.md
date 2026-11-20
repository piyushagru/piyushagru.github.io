# 03 — Motion and interaction specification

## Explicitly requested

### Ambient clouds
- On the hero/first screen, clouds move continuously and horizontally.
- Use multiple cloud planes with different speeds and subtle parallax.
- Motion is slow and atmospheric, never distracting from the headline.

### Mountain reveal order — important
Piyush explicitly required the nearest mountain range to appear first, then the second range behind it, then the third farther back, and so on. Do not reverse this order.

1. Foreground / nearest ridge appears first.
2. Mid-ground plane appears next, behind the foreground.
3. Back mountain plane appears next.
4. Distant silhouettes / atmospheric ranges appear last.
5. Clouds and valley mist establish after the mountain depth.
6. Sparrow flies into the landscape.
7. Hero content reveals one piece at a time, after the illustrations establish the scene.

Each mountain plane must be independently animatable and able to parallax at a different speed. Never reveal the entire range as one flat image.

### Sparrow cursor (desktop / fine pointer)
- A small realistic sparrow becomes the cursor in the hero/landscape area (not necessarily globally).
- Follow pointer with smooth eased movement and gentle momentum; no snapping.
- Wings flap while moving.
- Bird turns/flips according to horizontal travel direction.
- As pointer slows, bird decelerates; when idle, it settles/perches rather than jittering.
- It must look unmistakably like a sparrow. The previous rough bird/parrot-like treatment was rejected.
- Do not obscure text or make links/buttons difficult to activate.
- Existing starting animation: raw/assets/sparrow-flight.gif. It needs quality review and careful integration; it is not automatically the final production bird.

## Opening sequence
The design sheet proposes a short 1.5–2.5s opening:
1. PA monogram/name fades in.
2. Mountain planes reveal foreground-to-background in the exact order above.
3. Clouds begin horizontal drift; mist settles.
4. Sparrow flies in and takes over cursor interaction on desktop.
5. Headline, supporting copy, and CTAs reveal in a deliberate stagger.

Piyush emphasised that illustrations should load first and copy should follow one by one. Sequence matters more than rigid timing.

## Scroll motion vocabulary
Apply selectively:
- Scroll-triggered, one-by-one reveal of diagrams, metrics, and timeline items.
- Illustration elements assemble with a subtle stagger (reference around 0.3s).
- Diagram connections draw to show actual flow (reference around 0.8s ease-out).
- Subtle parallax for clouds, mountains, and scenic layers.
- Very subtle tilt/parallax (reference maximum ±3°) only if it does not feel gimmicky.
- Soft section atmospheric transitions (reference 0.6–1.0s); no hard wipes or scroll-jacking.

## Closing
- Return to the same scenic world in a warm sunset closing section.
- Sparrow flies through the final scene as a callback.
- Reveal closing message, contact CTA, and social links in sequence.
- A gentle light/sunset shift and ambient loop can finish the experience.
- Copy direction in the board: “Beyond the systems.” / “Thanks for scrolling.” and a “Let's Connect” action.

## Accessibility/performance
- Respect prefers-reduced-motion with a calm still-scene alternative.
- Motion is never required to understand content or navigate.
- Prefer transform/opacity; avoid expensive continuous layout animations.
- Reduce/pause offscreen motion where practical.
- No scroll-jacking, forced snapping, or pointer movement that interferes with text selection.
