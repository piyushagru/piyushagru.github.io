const reduced = () => window.matchMedia('(prefers-reduced-motion: reduce)');
const fine = () => window.matchMedia('(hover: hover) and (pointer: fine)');

export const prefersReducedMotion = (): boolean => reduced().matches;

/** True on mouse/trackpad devices; false on touch-only. */
export const hasFinePointer = (): boolean => fine().matches;

export const onReducedMotionChange = (cb: (reduced: boolean) => void): (() => void) => {
  const mq = reduced();
  const handler = (e: MediaQueryListEvent) => cb(e.matches);
  mq.addEventListener('change', handler);
  return () => mq.removeEventListener('change', handler);
};
