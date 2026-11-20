import { SPARROW_SPRITES, type Point } from '@lib/contracts';
import { SPARROW_CONFIG } from './sparrow.config';

export class SparrowView {
  private readonly element: HTMLDivElement;
  private breathing: Animation | null = null;
  private point: Point = { x: 0, y: 0 };
  private bankDegrees = 0;
  private direction: 1 | -1 = 1;

  constructor() {
    this.element = document.createElement('div');
    this.element.setAttribute('aria-hidden', 'true');
    this.element.setAttribute('role', 'presentation');
    Object.assign(this.element.style, {
      position: 'fixed',
      inset: '0 auto auto 0',
      width: `${SPARROW_CONFIG.sizePx}px`,
      height: `${SPARROW_CONFIG.sizePx}px`,
      backgroundImage: `url("${SPARROW_SPRITES.strip}")`,
      backgroundRepeat: 'no-repeat',
      backgroundSize: `${SPARROW_CONFIG.sizePx * SPARROW_SPRITES.frames}px ${SPARROW_CONFIG.sizePx}px`,
      pointerEvents: 'none',
      transformOrigin: '50% 50%',
      willChange: 'transform',
      zIndex: String(SPARROW_CONFIG.zIndex),
    });
    this.element.hidden = true;
    document.body.append(this.element);
  }

  show(): void {
    this.element.hidden = false;
  }

  hide(): void {
    this.stopBreathing();
    this.element.hidden = true;
  }

  setFrame(frame: number): void {
    this.element.style.backgroundPosition = `${-frame * SPARROW_CONFIG.sizePx}px 0`;
  }

  render(point: Point, bankDegrees: number, direction: 1 | -1): void {
    this.stopBreathing();
    this.point = { ...point };
    this.bankDegrees = bankDegrees;
    this.direction = direction;
    this.element.style.transform = this.transformAt(point.y);
  }

  startBreathing(): void {
    if (this.breathing) return;
    const amplitude = SPARROW_CONFIG.idle.breathingAmplitudePx;
    const values = [0, 0.707, 1, 0.707, 0, -0.707, -1, -0.707, 0];
    this.breathing = this.element.animate(
      values.map((value, index) => ({
        offset: index / (values.length - 1),
        transform: this.transformAt(this.point.y + value * amplitude),
      })),
      {
        duration: SPARROW_CONFIG.idle.breathingDurationMs,
        easing: 'linear',
        iterations: Infinity,
      },
    );
  }

  stopBreathing(): void {
    this.breathing?.cancel();
    this.breathing = null;
  }

  remove(): void {
    this.stopBreathing();
    this.element.remove();
  }

  private transformAt(y: number): string {
    const half = SPARROW_CONFIG.sizePx / 2;
    return `translate3d(${this.point.x - half}px, ${y - half}px, 0) rotate(${this.bankDegrees}deg) scaleX(${this.direction})`;
  }
}
