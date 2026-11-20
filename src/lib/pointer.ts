import type { Point } from './contracts';

export interface PointerSample extends Point {
  /** Pointer is over `target`. */
  inside: boolean;
  /** Pixels per millisecond since the previous sample. */
  vx: number;
  vy: number;
  time: number;
}

export type PointerListener = (sample: PointerSample) => void;

/**
 * One shared pointer stream for the hero. Both the scene (parallax) and the
 * sparrow (follow) subscribe here instead of each adding their own listeners.
 */
export const createPointerTracker = (target: HTMLElement) => {
  const listeners = new Set<PointerListener>();
  let last: PointerSample = { x: innerWidth / 2, y: innerHeight / 2, inside: false, vx: 0, vy: 0, time: performance.now() };

  const emit = (x: number, y: number, inside: boolean) => {
    const time = performance.now();
    const dt = Math.max(1, time - last.time);
    last = { x, y, inside, vx: (x - last.x) / dt, vy: (y - last.y) / dt, time };
    for (const cb of listeners) cb(last);
  };

  const onMove = (e: PointerEvent) => emit(e.clientX, e.clientY, true);
  const onLeave = (e: PointerEvent) => emit(e.clientX, e.clientY, false);

  target.addEventListener('pointermove', onMove, { passive: true });
  target.addEventListener('pointerleave', onLeave, { passive: true });

  return {
    get position(): PointerSample {
      return last;
    },
    subscribe(cb: PointerListener): () => void {
      listeners.add(cb);
      return () => listeners.delete(cb);
    },
    dispose() {
      target.removeEventListener('pointermove', onMove);
      target.removeEventListener('pointerleave', onLeave);
      listeners.clear();
    },
  };
};

export type PointerTracker = ReturnType<typeof createPointerTracker>;
