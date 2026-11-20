# 03 — Motion and interaction specification

## Explicitly requested behaviours

### Ambient clouds

- On the first/hero screen, clouds move continuously from left to right (or horizontally across the scene; direction can be art-directed consistently).
- Use multiple cloud layers with different speeds and slight depth/parallax.
- Motion should be slow and ambient, never distracting from the headline.

### Layered mountain reveal — exact sequence matters

The user explicitly described how the mountain layers should appear: **the mountain range in the foreground first, then the second range behind it, then the third range farther back, and so on.**

Implement separate independently animatable layers with the correct z-order and stagger:

1. Foreground ridge / nearest mountain plane appears first.
2. Mid-ground plane appears next, behind the foreground.
3. Back mountain plane appears next.
4. Distant mountain plane / atmospheric silhouettes appear last.
5. Clouds and mist enter after the major mountain depth is established.
6. Sparrow enters/flys into the scene.
7. Hero copy and CTAs reveal in a deliberate stagger, after the scene has formed.

Do not reverse this order. Do not reveal all mountains as one flat background. Keep layers independent so each can receive a subtly different parallax response.

### Sparrow cursor (desktop / fine pointer)

- The pointer may become a small realistic sparrow in the hero/landscape area (the user said in that page or that area; do not force the interaction globally if it hurts usability elsewhere).
- Bird follows the pointer with smooth, eased movement; no abrupt snapping.
- Wings flap while the bird is moving.
- Bird turns/flips according to horizontal travel direction so it faces where it is travelling.
- As the pointer slows, the bird decelerates smoothly; when idle it should settle/perch rather than continue jittering.
- The pointer-follow motion should feel fluid, as if the bird has momentum and catches up gently.
- The user rejected the previous poor “parrot”/rough bird appearance. Use a believable sparrow asset with convincing wing frames.
- Keep standard pointer behaviour usable for text links/buttons where needed; the bird should not obscure targets or make the site inaccessible.

The GIF at `assets/sparrow-flight.gif` is an existing animated prototype asset and is useful as a starting point. The user expects a higher-quality final integration/artwork; don't assume this asset is the final production bird without visual inspection.

## Opening/site-load sequence

The v3 sheet proposes a short cinematic sequence, approximately 1.5–2.5 seconds for the hero reveal:

1. PA monogram/name fades in.
2. Mountain layers appear from foreground to background (sequence above).
3. Clouds begin their horizontal drift; atmosphere/mist settles into valleys.
4. Sparrow flies into view and takes over the cursor interaction on desktop.
5. Hero copy and calls-to-action reveal one by one.

The user's later emphasis was that the **illustrations must establish the scene first** and content should then load one by one, coordinated with the illustrated layers. The order is more important than rigid millisecond timings.

## Scroll and section motion proposals from design sheets

These are approved as a restrained motion vocabulary, but should be applied selectively:

- Scroll-triggered reveal for project diagrams, metrics, and timeline items; one-by-one/staggered rather than everything appearing simultaneously.
- Build-on-scroll: elements in an illustration can assemble sequentially with a subtle stagger (design sheet reference: about 0.3s between elements).
- Connection animation: diagram lines/nodes draw to communicate actual service/data flow (design sheet reference: about 0.8s ease-out).
- Subtle parallax depth for background layers, clouds, and scene elements.
- Subtle tilt/parallax on appropriate visual components (design sheet reference: maximum about ±3°); omit if it feels gimmicky or harms touch usability.
- Section transitions: soft fade/atmospheric blend (design sheet reference: about 0.6–1.0s), not hard full-screen wipes.

## Closing sequence

- The closing section returns to a warm sunset landscape (v3 board shows a lakeside/cabin scene; the approved hero reference establishes the mountain setting; choose a cohesive closing view that feels part of the same world).
- The sparrow returns in the last/ending scene and flies through it as a visual callback.
- Closing content fades/reveals in a clear sequence: end message, contact CTA, social links.
- Warm light/sunset can subtly change as the scene arrives; retain a calm ambient loop.
- End copy direction shown in the board: “Beyond the systems.” / “Thanks for scrolling.” Contact CTA such as “Let’s Connect”.

## Accessibility and performance

- Respect `prefers-reduced-motion: reduce`; provide a still/static version of the scene and remove nonessential movement.
- No animation should be required to understand page content or operate navigation.
- Use transform/opacity for most transitions; avoid expensive continuous layout animation.
- Pause or reduce off-screen animation where practical.
- Avoid scroll-jacking, forced scroll snapping, or cursor movement that interferes with selecting text.
