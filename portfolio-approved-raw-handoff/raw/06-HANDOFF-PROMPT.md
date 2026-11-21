# 06 — Copy/paste prompt for another AI design or coding tool

You are continuing Piyush Aggarwal’s personal portfolio project. Read every file in this `raw/` folder before making changes, especially the approved brief, design system, motion specification, content facts, and implementation guardrails.

Your job is to elevate the approved cinematic portfolio—not to invent a new site. Preserve the warm, illustration-led mountain landscape identity shown in `design-references/portfolio-design-system-v3.webp` and the sunset hero reference. The site is one continuous scroll with these chapters: Hero/Introduction, Engineering Philosophy, Selected Work (Ads in Amazon Now, Speed in Search, Lifetime Savings Engine), Experience, and Beyond the Systems/Closing.

The early v3 board includes an AI & Experiments panel, but Piyush later explicitly rejected generic AI content and asked for “remove any and all AI slop”. Do not add an AI section or generic AI claims. The user also explicitly rejected the poor previous bird treatment: the cursor character must be a recognisable, high-quality sparrow, not a parrot or rough SVG.

Critical motion order: reveal the nearest foreground mountain range first, then each mountain plane progressively farther back; after that establish the moving horizontal clouds and valley mist; then fly the sparrow into the scene; then reveal headline, supporting copy, and CTAs one by one. Clouds should loop horizontally at calm speeds. On desktop/fine pointer, the sparrow follows the mouse with smooth eased motion, flaps while moving, turns in the direction of travel, slows when the pointer stops, and perches when idle. Bring the sparrow back in the final closing scene.

Every major section should feel like a viewport-sized chapter on desktop and mobile, but implement this with minimum height rather than fixed height so long content can grow and never be clipped. The mobile version must be intentionally composed, not merely scaled down. Respect reduced-motion preferences and keyboard accessibility.

Use the exact palette and typography tokens in `02-DESIGN-SYSTEM.md`. Keep diagrams factual and tied to the real projects. Use only the verified claims in `04-CONTENT-AND-FACTS.md`; never invent metrics, links, awards, or biography. Do not use generic filler copy or decorative AI slop.

Work one section/component at a time on a feature branch. First inspect and screenshot the current repo so you preserve the existing structure. Then refine the hero/landscape as the first deliverable and present desktop and mobile screenshots for approval before moving to the next section. Never wholesale-rewrite the site, change its identity, or merge/deploy without Piyush’s approval.
