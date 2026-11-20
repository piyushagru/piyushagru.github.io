import type { HeroSceneApi, SceneLayer, SparrowApi, SparrowState } from '@lib/contracts';

export const createStubScene = (): HeroSceneApi => ({
  ready: Promise.resolve(),
  setReveal(layer: SceneLayer, t: number) {
    if (t === 1) console.debug(`[hero stub] revealed ${layer}`);
  },
  setParallax() {},
  setScroll() {},
  start() {},
  stop() {},
  dispose() {},
});

export const createStubSparrow = (): SparrowApi => {
  let state: SparrowState = 'hidden';

  return {
    get state() {
      return state;
    },
    async flyIn() {
      state = 'flying-in';
      state = 'perched';
    },
    follow() {
      state = 'following';
    },
    perch() {
      state = 'perched';
    },
    async flyThrough() {
      state = 'passing';
      state = 'hidden';
    },
    hide() {
      state = 'hidden';
    },
    dispose() {
      state = 'hidden';
    },
  };
};
