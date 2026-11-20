import type { HeroSceneApi } from '@lib/contracts';
import type { PointerTracker } from '@lib/pointer';

const clamp = (value: number): number => Math.min(1, Math.max(-1, value));

export const wireHeroParallax = (
  pointer: PointerTracker,
  scene: HeroSceneApi,
): (() => void) => pointer.subscribe(({ x, y }) => {
  scene.setParallax(
    clamp((x / window.innerWidth) * 2 - 1),
    clamp((y / window.innerHeight) * 2 - 1),
  );
});
