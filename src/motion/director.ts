import { animate, createTimeline } from 'animejs';
import { SCENE_LAYERS, type HeroSceneApi, type SceneLayer, type SparrowApi } from '@lib/contracts';

interface OpeningOptions {
  scene: HeroSceneApi;
  sparrow: SparrowApi;
  root: HTMLElement;
  reduced: boolean;
}

const EASE_OUT = 'cubic-bezier(0.23, 1, 0.32, 1)';
const EASE_IN_OUT = 'cubic-bezier(0.77, 0, 0.175, 1)';

const revealStarts: Record<SceneLayer, number> = {
  'ridge-near': 300,
  'ridge-mid': 660,
  'ridge-far': 1020,
  'ridge-distant': 1380,
  mist: 1740,
  clouds: 1740,
  sun: 1740,
};

const revealDuration = (layer: SceneLayer): number =>
  layer.startsWith('ridge-') ? 900 : 800;

const getPerch = (root: HTMLElement) => {
  const headline = root.querySelector<HTMLElement>('[data-reveal="headline-2"]');
  const rect = headline?.getBoundingClientRect() ?? root.getBoundingClientRect();

  return {
    x: Math.min(window.innerWidth - 72, rect.right + 44),
    y: rect.top + rect.height * 0.58,
  };
};

const showOpeningContent = (root: HTMLElement) => {
  root.querySelectorAll<HTMLElement>('[data-reveal]').forEach((element) => {
    element.style.opacity = '1';
    element.style.transform = '';
  });
  document.documentElement.classList.remove('js-opening');
};

export const runOpening = async ({ scene, sparrow, root, reduced }: OpeningOptions): Promise<void> => {
  if (reduced) {
    for (const layer of SCENE_LAYERS) scene.setReveal(layer, 1);
    showOpeningContent(root);
    const perch = getPerch(root);
    await sparrow.flyIn({ from: perch, to: perch, duration: 0 });
    sparrow.perch();
    return;
  }

  const timeline = createTimeline({ autoplay: false });

  const header = root.querySelector<HTMLElement>('[data-reveal="header"]');
  if (header) {
    timeline.add(header, {
      opacity: [0, 1],
      transform: ['translateY(24px)', 'translateY(0px)'],
      duration: 400,
      ease: EASE_OUT,
    }, 0);
  }

  for (const layer of SCENE_LAYERS) {
    const progress = { t: 0 };
    scene.setReveal(layer, 0);
    const reveal = animate(progress, {
      t: 1,
      duration: revealDuration(layer),
      ease: layer.startsWith('ridge-') ? EASE_OUT : EASE_IN_OUT,
      autoplay: false,
      onUpdate: () => scene.setReveal(layer, progress.t),
    });
    timeline.sync(reveal, revealStarts[layer]);
  }

  let flight: Promise<void> = Promise.resolve();
  let flightError: unknown;
  timeline.call(() => {
    timeline.pause();
    const to = getPerch(root);
    flight = sparrow.flyIn({
      from: { x: window.innerWidth + 96, y: -72 },
      to,
      duration: 1400,
    }).catch((error: unknown) => {
      flightError = error;
    }).finally(() => timeline.resume());
  }, 2540);

  const contentSteps = [
    ['headline-1', 2550],
    ['headline-2', 2640],
    ['support', 2730],
    ['cta-primary', 2820],
    ['cta-secondary', 2910],
    ['scroll-hint', 3000],
  ] as const;

  for (const [name, start] of contentSteps) {
    const element = root.querySelector<HTMLElement>(`[data-reveal="${name}"]`);
    if (!element) continue;
    const scrollHint = name === 'scroll-hint';
    timeline.add(element, {
      opacity: [0, 1],
      transform: scrollHint
        ? ['translate(-50%, 24px)', 'translate(-50%, 0px)']
        : ['translateY(24px)', 'translateY(0px)'],
      duration: 700,
      ease: EASE_OUT,
    }, start);
  }

  timeline.play();
  await timeline;
  await flight;
  if (flightError) throw flightError;

  document.documentElement.classList.remove('js-opening');
  sparrow.follow();
};
