# 02 — Design system and art direction

## Visual north star
Cinematic, minimal, human, technical without noise. The approved v3 board uses an elegant editorial layout, warm ivory surfaces, painterly mountain scenes, and restrained green/stone accents. Do not turn it into a dark neon dashboard, a generic component kit, or glossy AI-generated 3D decoration.

## Palette from v3
| Token | Name | Hex | Use |
|---|---|---|---|
| sand | Sand | #F8F5EE | Warm canvas |
| ivory | Ivory | #FBF9F4 | Cards and light surfaces |
| sage | Sage | #8BA989 | Calm accent / diagrams |
| forest | Forest | #506B58 | Primary action / emphasis |
| mist-blue | Mist Blue | #8BACC1 | Atmospheric depth |
| sunset | Sunset | #E9B38E | Warm focal highlights |

Derived tints and shades are fine; preserve contrast and varied section surfaces.

## Typography
- Playfair Display — editorial headlines and selected display moments; italic sparingly.
- Inter — body copy, navigation, and UI.
- IBM Plex Mono — small labels, taxonomy, metrics, and dates.

Use fluid clamp sizing and a controlled scale. Avoid excessive all-caps and tiny monospaced paragraphs.

## Composition
- One continuous scroll with compact navigation.
- Editorial grid, deliberate alignment, generous whitespace.
- Major sections use viewport-sized minimums (100svh / 100dvh) where appropriate.
- Use minimum height rather than fixed height. Long content can grow; never crop required copy or controls.
- Desktop uses a wide, balanced text/illustration composition; mobile gets purposeful vertical rearrangement and separate scene crops.
- Keep transitions soft. Do not turn everything into identical rounded cards.

## Illustration language
1. Landscape: painterly, detailed mountain planes, warm atmosphere, soft clouds, valley mist, a light source, restrained foliage. The sunset hero reference is the principal art direction.
2. Sparrow: recognisable small brown sparrow with believable proportions and feather detail. Never a parrot, generic bird glyph, pointer arrow, or crude cartoon.
3. Engineering diagrams: bespoke and factual — service boundaries, search/ranking flow, data aggregation, queues, system relationships.
4. Icons: thin illustrative line icons, consistent stroke weight, restrained olive/forest palette.
5. Texture: subtle paper/grain only if it improves cohesion and readability.

## Components
- Primary CTA: forest/sage filled, compact, clear label, restrained arrow.
- Secondary CTA: light outline, quiet hierarchy.
- Tags: small restrained pills for real technology/domain labels only.
- Metric chips: only for real, material metrics.
- Project presentation: editorial copy + custom system illustration + factual outcomes; not generic project cards.
- Navigation and footer: light, precise, consistent with the landscape.

## Mobile
- Preserve the same story and identity in a vertical flow.
- Recompose/crop hero and closing landscape so text is not obscured.
- Use touch-appropriate interactions; hide cursor-follow sparrow on touch-only devices.
- Ensure keyboard/touch navigation, readable type, and safe-area spacing.
