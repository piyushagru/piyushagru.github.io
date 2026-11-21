import type {
  HeroSceneApi,
  HeroSceneOptions,
  SparrowApi,
  SparrowOptions,
} from '@lib/contracts';
import { prefersReducedMotion } from '@lib/motion-prefs';
import { createPointerTracker, type PointerTracker } from '@lib/pointer';
import { runOpening } from '@motion/director';
import { wireHeroParallax } from '@motion/parallax';
import { wireHeroScroll } from '@motion/scroll';
import { createStubScene, createStubSparrow } from './stubs';

type SceneFactory = (canvas: HTMLCanvasElement, opts: HeroSceneOptions) => HeroSceneApi;
type SparrowFactory = (opts: SparrowOptions, pointer: PointerTracker) => SparrowApi;
type SceneModule = { createHeroScene: SceneFactory };
type SparrowModule = { createSparrow: SparrowFactory };

interface HeroDebugApi {
  scene: HeroSceneApi;
  sparrow: SparrowApi;
  pointer: PointerTracker;
  dispose: () => void;
}

declare global {
  interface Window {
    __hero?: HeroDebugApi;
  }
}

// Empty globs keep this module buildable until the independently owned real modules land.
const sceneModules = import.meta.glob<SceneModule>('/src/scene/index.ts');
const sparrowModules = import.meta.glob<SparrowModule>('/src/sparrow/index.ts');

export const bootHero = async (root: HTMLElement): Promise<void> => {
  const canvas = root.querySelector<HTMLCanvasElement>('[data-hero-scene]');
  if (!canvas) return;

  const reduced = prefersReducedMotion();
  const pointer = createPointerTracker(root);
  const loadScene = sceneModules['/src/scene/index.ts'];
  const loadSparrow = sparrowModules['/src/sparrow/index.ts'];
  const [sceneModule, sparrowModule] = await Promise.all([
    loadScene?.(),
    loadSparrow?.(),
  ]);

  const scene = sceneModule
    ? sceneModule.createHeroScene(canvas, { still: reduced })
    : createStubScene();
  const sparrow = sparrowModule
    ? sparrowModule.createSparrow({ bounds: root, still: reduced }, pointer)
    : createStubSparrow();

  let unwireScroll = () => {};
  let unwireParallax = () => {};
  let pointerDemoFrame = 0;

  const dispose = () => {
    cancelAnimationFrame(pointerDemoFrame);
    unwireScroll();
    unwireParallax();
    pointer.dispose();
    sparrow.dispose();
    scene.dispose();
    delete window.__hero;
  };

  try {
    await scene.ready;
    scene.start();
    unwireScroll = wireHeroScroll(root, scene);
    unwireParallax = wireHeroParallax(pointer, scene);
    await runOpening({ scene, sparrow, root, reduced });
    scene.start();

    if (import.meta.env.DEV) {
      console.debug('[hero] steady state active', {
        scene: 'running',
        scroll: 'wired',
        parallax: 'wired',
        sparrow: sparrow.state,
      });

      const birdDemo = new URLSearchParams(window.location.search).get('bird');
      if (birdDemo !== null) {
        const startedAt = performance.now();
        const movePointer = (now: number) => {
          const elapsed = now - startedAt;
          if (birdDemo === 'leave' && elapsed >= 1200) {
            root.dispatchEvent(new PointerEvent('pointerleave', {
              clientX: window.innerWidth * 0.78,
              clientY: window.innerHeight * 0.32,
            }));
            return;
          }
          const progress = (elapsed % 5000) / 5000;
          root.dispatchEvent(new PointerEvent('pointermove', {
            clientX: window.innerWidth * (0.3 + progress * 0.48),
            clientY: window.innerHeight * (0.32 + Math.sin(progress * Math.PI * 2) * 0.08),
            bubbles: true,
          }));
          pointerDemoFrame = requestAnimationFrame(movePointer);
        };
        movePointer(startedAt);
      }

      window.__hero = { scene, sparrow, pointer, dispose };
    }
  } catch (error) {
    document.documentElement.classList.remove('js-opening');
    console.error('Hero failed to start', error);
  }

  window.addEventListener('pagehide', dispose, { once: true });
};
