/**
 * Contracts between the hero's three independent modules.
 *
 *   scene/    renders the landscape (Three.js)      -> HeroSceneApi
 *   sparrow/  the cursor character (DOM sprites)     -> SparrowApi
 *   motion/   the director that sequences both       -> consumes both
 *
 * Modules import only from this file and from lib/. Never from each other.
 */

export interface Point {
  x: number;
  y: number;
}

/**
 * Independently animatable scene layers, listed nearest -> farthest.
 * The opening reveals them in exactly this order (Piyush's rule:
 * foreground ridge first, each farther range after it).
 */
export const SCENE_LAYERS = [
  'ridge-near',
  'ridge-mid',
  'ridge-far',
  'ridge-distant',
  'mist',
  'clouds',
  'sun',
] as const;

export type SceneLayer = (typeof SCENE_LAYERS)[number];

export interface HeroSceneApi {
  /** Resolves once shaders are compiled and the first frame can render. */
  readonly ready: Promise<void>;
  /** 0 = layer absent, 1 = fully present. The director tweens this. */
  setReveal(layer: SceneLayer, t: number): void;
  /** Normalised pointer offset from viewport centre, both axes in -1..1. */
  setParallax(x: number, y: number): void;
  /** 0 = hero fully in view, 1 = hero scrolled out. Drives depth parallax. */
  setScroll(progress: number): void;
  /** Begin / pause the render loop. Idempotent. */
  start(): void;
  stop(): void;
  dispose(): void;
}

export interface HeroSceneOptions {
  /** Static single frame, no drift. Set when prefers-reduced-motion. */
  still: boolean;
  /** Upper bound for devicePixelRatio. Default 1.5. */
  maxPixelRatio?: number;
}

export type SparrowState = 'hidden' | 'flying-in' | 'following' | 'perched' | 'passing';

export interface SparrowApi {
  readonly state: SparrowState;
  /** Scripted entrance along a gentle arc. Resolves when it lands at `to`. */
  flyIn(opts: { from: Point; to: Point; duration: number }): Promise<void>;
  /** Hand control to the pointer. No-op on coarse pointers. */
  follow(): void;
  /** Settle in place and idle (used when the pointer leaves the hero). */
  perch(): void;
  /** Scripted pass across the viewport (closing scene callback). */
  flyThrough(opts: { from: Point; to: Point; duration: number }): Promise<void>;
  hide(): void;
  dispose(): void;
}

export interface SparrowOptions {
  /** Region in which the sparrow replaces the pointer. */
  bounds: HTMLElement;
  /** Static frame, no flapping or travel. Set when prefers-reduced-motion. */
  still: boolean;
}

/** Sprite sheet produced from raw/assets, see public/sparrow/. */
export const SPARROW_SPRITES = {
  strip: '/sparrow/flap-strip.webp',
  frames: 8,
  frameSize: 320,
  /**
   * Frame index per pose, from the cut sheet:
   * 0,1,7 wings high; 2,3,4 wings level/forward; 5,6 wings low/back.
   */
  flapCycle: [0, 1, 3, 2, 4, 5, 6, 7],
  /** Frame used while perched (wings closest to the body). */
  restFrame: 6,
  /** Sprites face right; flip horizontally when travelling left. */
  facesRight: true,
} as const;
