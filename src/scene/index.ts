import type { HeroSceneApi, HeroSceneOptions } from '@lib/contracts';
import { HeroScene } from './HeroScene';

export function createHeroScene(
  canvas: HTMLCanvasElement,
  options: HeroSceneOptions,
): HeroSceneApi {
  return new HeroScene(canvas, options);
}
