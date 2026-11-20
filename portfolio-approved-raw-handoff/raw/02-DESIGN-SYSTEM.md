# 02 — Design system and art direction

## Visual north star

**Cinematic, minimal, human, technical without noise.** The approved v3 board uses an elegant editorial layout with warm ivory surfaces and painterly mountain scenes. It should feel like a carefully art-directed personal site—not a dark neon dashboard, not an over-rounded component kit, and not glossy AI-generated 3D decoration.

## Palette from the v3 design sheet

| Token | Name | Value | Use |
|---|---|---:|---|
| `--sand` | Sand | `#F8F5EE` | Main warm canvas / page background |
| `--ivory` | Ivory | `#FBF9F4` | Cards, light surfaces, text contrast |
| `--sage` | Sage | `#8BA989` | Calm accent, diagrams, subtle status |
| `--forest` | Forest | `#506B58` | Primary action, emphasis, dark scenic silhouettes |
| `--mist-blue` | Mist Blue | `#8BACC1` | Distance, atmospheric layers, quiet secondary accent |
| `--sunset` | Sunset | `#E9B38E` | Warm focal highlights, sunset light, sparing emphasis |

Use derived tints/shades only where needed. Keep contrast comfortable; don't flatten all sections into the same pale panel.

## Typography from the v3 design sheet

- **Playfair Display** — editorial headlines and selected display moments. Use italic sparingly for emphasis.
- **Inter** — body text, navigation, UI, labels that need quick reading.
- **IBM Plex Mono** — small uppercase labels, metadata, project taxonomy, metrics, timeline dates.

Use responsive `clamp()` sizing and a controlled type scale. Avoid excessive all-caps, too many weights, or large blocks of tiny monospaced text.

## Composition and layout

- Single continuous scroll, with a compact persistent or visually stable navigation treatment.
- Strong editorial grid, generous whitespace, calm margins, deliberate alignment.
- Major sections should use at least one viewport as their visual chapter: `min-height: 100svh` / `100dvh` where appropriate.
- Prefer `min-height` over a hard fixed `height`. If a project section needs more room, it should grow naturally and remain scrollable. Never crop essential content to force an exact screen height.
- Use a desktop-wide composition with strong text/illustration balance; mobile becomes a purposeful vertical narrative with different crops and spacing.
- Keep soft section transitions and scenic continuity. Avoid stacking identical rounded cards for every piece of content.

## Illustration language

1. **Landscape:** painterly, detailed, warm, atmospheric mountain ranges with multiple planes, soft clouds, mist in valleys, a clear light source, and restrained foreground foliage. The hero reference is the principal direction.
2. **Sparrow:** a recognisable small brown sparrow with believable proportions and feather detail. It must read as a sparrow, never a parrot, generic bird glyph, arrow, or crude cartoon. Use a clean cut-out/transparent animation asset where possible.
3. **Engineering diagrams:** bespoke, clear, restrained illustrations of service boundaries, search/ranking flows, data aggregation, queues, and system relationships. They must explain real work. Do not use decorative fake architecture.
4. **Icons:** light illustrative line icons with consistent stroke weight, simple forms, and a restrained olive/forest palette.
5. **Texture:** subtle grain/paper atmosphere is acceptable when it improves cohesion. It must not reduce legibility or look like a generic overlay filter.

## UI components

- Primary action: forest/sage filled, compact, clear label, subtle arrow affordance.
- Secondary action: outline, minimal visual weight.
- Tags: small restrained pills for real technologies/domains only.
- Metric chips: used only where the metric is real and material.
- Project module: editorial text + custom diagram/artwork + factual impact detail, not a generic card grid.
- Navigation and footer: light, precise, consistent with the landscape.

## Mobile behaviour

- Preserve the same story and visual identity, rearranged into a vertical sequence.
- Design separate mobile composition/crops for the hero and closing landscape so important content is not hidden behind text.
- Replace desktop hover behaviour with touch-appropriate interactions.
- Hide the cursor-follow sparrow on touch-only devices; the sparrow may remain as a scene element.
- Make navigation usable with keyboard and touch, maintain readable type, and keep safe-area/padding in mind.
