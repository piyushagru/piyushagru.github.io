import { SPARROW_SPRITES } from '@lib/contracts';
import { SPARROW_CONFIG } from './sparrow.config';
import type { SparrowView } from './sparrow-view';

export class SpriteAnimator {
  readonly ready: Promise<void>;

  private cycleIndex = 0;
  private elapsedSinceFrameMs = 0;
  private burstUntil = 0;

  constructor(private readonly view: SparrowView) {
    this.ready = this.preload();
    this.view.setFrame(SPARROW_SPRITES.restFrame);
  }

  update(now: number, elapsedMs: number, speedPxPerMs: number, fullFlap = false): void {
    const speedRatio = Math.min(1, speedPxPerMs / SPARROW_CONFIG.flap.fullSpeedPxPerMs);
    const fps = fullFlap || now < this.burstUntil
      ? SPARROW_CONFIG.flap.flightFps
      : SPARROW_CONFIG.flap.glideFps
        + (SPARROW_CONFIG.flap.flightFps - SPARROW_CONFIG.flap.glideFps) * speedRatio;
    const frameDurationMs = 1000 / fps;
    this.elapsedSinceFrameMs += elapsedMs;

    while (this.elapsedSinceFrameMs >= frameDurationMs) {
      this.elapsedSinceFrameMs -= frameDurationMs;
      this.cycleIndex = (this.cycleIndex + 1) % SPARROW_SPRITES.flapCycle.length;
      this.view.setFrame(SPARROW_SPRITES.flapCycle[this.cycleIndex] ?? SPARROW_SPRITES.restFrame);
    }
  }

  burst(now: number): void {
    this.burstUntil = now + SPARROW_CONFIG.flap.burstMs;
  }

  rest(): void {
    this.elapsedSinceFrameMs = 0;
    this.cycleIndex = 0;
    this.view.setFrame(SPARROW_SPRITES.restFrame);
  }

  private preload(): Promise<void> {
    return new Promise((resolve, reject) => {
      const image = new Image();
      image.decoding = 'async';
      image.addEventListener('load', () => resolve(), { once: true });
      image.addEventListener('error', () => reject(new Error(`Unable to load ${SPARROW_SPRITES.strip}`)), { once: true });
      image.src = SPARROW_SPRITES.strip;
      if (image.complete && image.naturalWidth > 0) resolve();
    });
  }
}
