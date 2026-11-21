import type { HeroSceneApi } from '@lib/contracts';

const clamp = (value: number): number => Math.min(1, Math.max(0, value));

export const wireHeroScroll = (root: HTMLElement, scene: HeroSceneApi): (() => void) => {
  let inView = true;
  let frame = 0;

  const update = () => {
    frame = 0;
    if (!inView) return;
    const rect = root.getBoundingClientRect();
    scene.setScroll(clamp(-rect.top / Math.max(1, rect.height)));
  };

  const onScroll = () => {
    if (!frame) frame = requestAnimationFrame(update);
  };

  const observer = new IntersectionObserver(([entry]) => {
    inView = entry?.isIntersecting ?? false;
    if (inView) {
      scene.start();
      onScroll();
    } else {
      scene.stop();
    }
  }, { threshold: 0.01 });

  observer.observe(root);
  window.addEventListener('scroll', onScroll, { passive: true });
  update();

  return () => {
    observer.disconnect();
    window.removeEventListener('scroll', onScroll);
    if (frame) cancelAnimationFrame(frame);
  };
};
