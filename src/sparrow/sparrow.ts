import type { Point, SparrowApi, SparrowOptions, SparrowState } from '@lib/contracts';
import { hasFinePointer, onReducedMotionChange, prefersReducedMotion } from '@lib/motion-prefs';
import type { PointerSample, PointerTracker } from '@lib/pointer';
import { FlightModel } from './flight-model';
import { SPARROW_CONFIG } from './sparrow.config';
import { SparrowView } from './sparrow-view';
import { SpriteAnimator } from './sprite-animator';
import './sparrow.css';

interface ScriptedFlight {
  from: Point;
  to: Point;
  control: Point;
  durationMs: number;
  startedAt: number;
  lastPoint: Point;
  direction: 1 | -1;
  bankDegrees: number;
  hideOnComplete: boolean;
  resolve: () => void;
}

const easeOut = (progress: number): number => {
  const x1 = 0.23;
  const y1 = 1;
  const x2 = 0.32;
  const y2 = 1;
  let parameter = progress;

  for (let index = 0; index < 5; index += 1) {
    const inverse = 1 - parameter;
    const x = 3 * inverse * inverse * parameter * x1
      + 3 * inverse * parameter * parameter * x2
      + parameter * parameter * parameter;
    const slope = 3 * inverse * inverse * x1
      + 6 * inverse * parameter * (x2 - x1)
      + 3 * parameter * parameter * (1 - x2);
    if (Math.abs(slope) < 0.0001) break;
    parameter -= (x - progress) / slope;
    parameter = Math.max(0, Math.min(1, parameter));
  }

  const inverse = 1 - parameter;
  return 3 * inverse * inverse * parameter * y1
    + 3 * inverse * parameter * parameter * y2
    + parameter * parameter * parameter;
};

const quadraticPoint = (from: Point, control: Point, to: Point, progress: number): Point => {
  const inverse = 1 - progress;
  return {
    x: inverse * inverse * from.x + 2 * inverse * progress * control.x + progress * progress * to.x,
    y: inverse * inverse * from.y + 2 * inverse * progress * control.y + progress * progress * to.y,
  };
};

export class Sparrow implements SparrowApi {
  private _state: SparrowState = 'hidden';
  private readonly view = new SparrowView();
  private readonly flight = new FlightModel();
  private readonly sprites = new SpriteAnimator(this.view);
  private readonly unsubscribePointer: () => void;
  private readonly unsubscribeReducedMotion: () => void;
  private readonly stillRequested: boolean;
  private reduced: boolean;
  private followRequested = false;
  private latestPointer: PointerSample;
  private lastPointerMoveAt = 0;
  private frame: number | null = null;
  private lastFrameAt = 0;
  private scriptedFlight: ScriptedFlight | null = null;
  private disposed = false;

  constructor(
    private readonly options: SparrowOptions,
    pointer: PointerTracker,
  ) {
    this.stillRequested = options.still;
    this.reduced = options.still || prefersReducedMotion();
    this.latestPointer = pointer.position;
    this.flight.setPosition(this.offsetTarget(this.latestPointer));
    this.unsubscribePointer = pointer.subscribe((sample) => this.onPointer(sample));
    this.unsubscribeReducedMotion = onReducedMotionChange((reduced) => this.onReducedMotion(reduced));
  }

  get state(): SparrowState {
    return this._state;
  }

  async flyIn({ from, to, duration }: { from: Point; to: Point; duration: number }): Promise<void> {
    await this.sprites.ready;
    if (this.disposed) return;
    if (this.reduced) {
      this.landImmediately(to);
      return;
    }
    return this.beginScriptedFlight(from, to, duration, false, 'flying-in');
  }

  follow(): void {
    if (this.disposed || this.reduced || !hasFinePointer()) return;
    this.followRequested = true;
    if (this.latestPointer.inside && this._state !== 'flying-in' && this._state !== 'passing') {
      this.beginFollowing();
    }
  }

  perch(): void {
    if (this.disposed || this._state === 'hidden') return;
    this.cancelScriptedFlight();
    this._state = 'perched';
    this.syncCursor();
    this.stopLoop();
    this.sprites.rest();
    const pose = this.flight.snapshot;
    this.view.render(pose, pose.bankDegrees, pose.direction);
    if (!this.reduced) this.view.startBreathing();
  }

  async flyThrough({ from, to, duration }: { from: Point; to: Point; duration: number }): Promise<void> {
    await this.sprites.ready;
    if (this.disposed) return;
    if (this.reduced) {
      this.hide();
      return;
    }
    return this.beginScriptedFlight(from, to, duration, true, 'passing');
  }

  hide(): void {
    this.cancelScriptedFlight();
    this.followRequested = false;
    this._state = 'hidden';
    this.syncCursor();
    this.stopLoop();
    this.sprites.rest();
    this.view.hide();
  }

  dispose(): void {
    if (this.disposed) return;
    this.disposed = true;
    this.hide();
    this.unsubscribePointer();
    this.unsubscribeReducedMotion();
    this.view.remove();
  }

  private onPointer(sample: PointerSample): void {
    this.latestPointer = sample;
    if (!this.followRequested || this._state === 'flying-in' || this._state === 'passing') return;

    if (!sample.inside) {
      if (this._state === 'following') this.perch();
      return;
    }

    const speed = Math.hypot(sample.vx, sample.vy);
    if (speed >= SPARROW_CONFIG.idle.speedThresholdPxPerMs) {
      this.lastPointerMoveAt = sample.time;
      if (this._state === 'perched') this.beginFollowing();
    }
    if (this._state === 'following') this.flight.setTarget(this.offsetTarget(sample));
  }

  private beginFollowing(): void {
    const target = this.offsetTarget(this.latestPointer);
    if (this._state === 'hidden') this.flight.setPosition(target);
    this.flight.setTarget(target);
    this._state = 'following';
    this.lastPointerMoveAt = performance.now();
    this.view.show();
    this.view.stopBreathing();
    this.sprites.burst(this.lastPointerMoveAt);
    this.syncCursor();
    this.startLoop();
  }

  private beginScriptedFlight(
    from: Point,
    to: Point,
    durationMs: number,
    hideOnComplete: boolean,
    state: 'flying-in' | 'passing',
  ): Promise<void> {
    this.cancelScriptedFlight();
    this.followRequested = false;
    this._state = state;
    this.syncCursor();
    this.stopLoop();
    this.flight.setPosition(from);
    this.view.show();
    this.view.render(from, 0, to.x >= from.x ? 1 : -1);
    const distance = Math.hypot(to.x - from.x, to.y - from.y);
    const lift = Math.max(
      SPARROW_CONFIG.scriptedFlight.minArcLiftPx,
      Math.min(SPARROW_CONFIG.scriptedFlight.maxArcLiftPx, distance * SPARROW_CONFIG.scriptedFlight.arcLiftRatio),
    );
    const control = {
      x: (from.x + to.x) / 2,
      y: Math.min(from.y, to.y) - lift,
    };

    return new Promise((resolve) => {
      this.scriptedFlight = {
        from: { ...from },
        to: { ...to },
        control,
        durationMs: Math.max(1, durationMs),
        startedAt: performance.now(),
        lastPoint: { ...from },
        direction: to.x >= from.x ? 1 : -1,
        bankDegrees: 0,
        hideOnComplete,
        resolve,
      };
      this.startLoop();
    });
  }

  private startLoop(): void {
    if (this.frame !== null || this.disposed) return;
    this.lastFrameAt = performance.now();
    this.frame = requestAnimationFrame((now) => this.tick(now));
  }

  private stopLoop(): void {
    if (this.frame !== null) cancelAnimationFrame(this.frame);
    this.frame = null;
  }

  private tick(now: number): void {
    this.frame = null;
    const elapsedMs = Math.max(0, now - this.lastFrameAt);
    this.lastFrameAt = now;

    if (this.scriptedFlight) {
      this.tickScriptedFlight(now, elapsedMs);
    } else if (this._state === 'following') {
      const pose = this.flight.advance(elapsedMs / 1000);
      this.view.render(pose, pose.bankDegrees, pose.direction);
      this.sprites.update(now, elapsedMs, pose.speedPxPerMs);
      if (now - this.lastPointerMoveAt >= SPARROW_CONFIG.idle.settleDelayMs) {
        this.perch();
        return;
      }
    }

    if (this.scriptedFlight || this._state === 'following') {
      this.frame = requestAnimationFrame((time) => this.tick(time));
    }
  }

  private tickScriptedFlight(now: number, elapsedMs: number): void {
    const active = this.scriptedFlight;
    if (!active) return;
    const rawProgress = Math.min(1, (now - active.startedAt) / active.durationMs);
    const point = quadraticPoint(active.from, active.control, active.to, easeOut(rawProgress));
    const elapsedSeconds = Math.max(0.001, elapsedMs / 1000);
    const velocityX = (point.x - active.lastPoint.x) / elapsedSeconds;
    const velocityY = (point.y - active.lastPoint.y) / elapsedSeconds;
    const deadZone = SPARROW_CONFIG.heading.flipDeadZonePxPerMs * 1000;
    if (velocityX > deadZone) active.direction = 1;
    if (velocityX < -deadZone) active.direction = -1;
    const targetBank = Math.max(
      -SPARROW_CONFIG.bank.maxDegrees,
      Math.min(SPARROW_CONFIG.bank.maxDegrees, velocityY * SPARROW_CONFIG.bank.degreesPerPxPerSecond),
    );
    const bankAlpha = 1 - Math.exp(-SPARROW_CONFIG.bank.smoothingPerSecond * elapsedSeconds);
    active.bankDegrees += (targetBank - active.bankDegrees) * bankAlpha;
    active.lastPoint = point;
    this.flight.setPosition(point, { x: velocityX, y: velocityY });
    this.view.render(point, active.bankDegrees, active.direction);
    this.sprites.update(now, elapsedMs, SPARROW_CONFIG.flap.fullSpeedPxPerMs, true);

    if (rawProgress >= 1) this.completeScriptedFlight();
  }

  private completeScriptedFlight(): void {
    const active = this.scriptedFlight;
    if (!active) return;
    this.scriptedFlight = null;
    this.flight.setPosition(active.to);
    active.resolve();
    if (active.hideOnComplete) {
      this._state = 'hidden';
      this.sprites.rest();
      this.view.hide();
      return;
    }
    this._state = 'perched';
    this.sprites.rest();
    this.view.render(active.to, 0, active.direction);
    this.view.startBreathing();
  }

  private landImmediately(to: Point): void {
    this.cancelScriptedFlight();
    this.flight.setPosition(to);
    this._state = 'perched';
    this.syncCursor();
    this.stopLoop();
    this.view.show();
    this.view.render(to, 0, 1);
    this.sprites.rest();
  }

  private cancelScriptedFlight(): void {
    const active = this.scriptedFlight;
    if (!active) return;
    this.scriptedFlight = null;
    active.resolve();
  }

  private onReducedMotion(reduced: boolean): void {
    this.reduced = this.stillRequested || reduced;
    if (!this.reduced) return;
    if (this.scriptedFlight) {
      const destination = this.scriptedFlight.to;
      const hideOnComplete = this.scriptedFlight.hideOnComplete;
      this.cancelScriptedFlight();
      if (hideOnComplete) this.hide();
      else this.landImmediately(destination);
      return;
    }
    if (this._state === 'following' || this._state === 'perched') this.perch();
  }

  private offsetTarget(sample: PointerSample): Point {
    const speed = Math.hypot(sample.vx, sample.vy);
    const directionX = speed > 0 ? sample.vx / speed : 0;
    const directionY = speed > 0 ? sample.vy / speed : 0;
    return {
      x: sample.x + directionX * SPARROW_CONFIG.followOffset.aheadPx,
      y: sample.y - SPARROW_CONFIG.followOffset.abovePx + directionY * SPARROW_CONFIG.followOffset.aheadPx,
    };
  }

  private syncCursor(): void {
    const active = this._state === 'following' && this.latestPointer.inside;
    this.options.bounds.classList.toggle('sparrow-cursor-active', active);
  }
}
