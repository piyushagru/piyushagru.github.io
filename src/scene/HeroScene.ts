import {
  Clock,
  Color,
  Mesh,
  OrthographicCamera,
  PlaneGeometry,
  Scene,
  ShaderMaterial,
  SRGBColorSpace,
  Vector2,
  Vector3,
  Vector4,
  WebGLRenderer,
  type IUniform,
} from 'three';
import type { HeroSceneApi, HeroSceneOptions, SceneLayer } from '@lib/contracts';
import { LayerRegistry } from './LayerRegistry';
import { SCENE_COLORS, SCENE_CONFIG } from './scene.config';
import fragmentShader from './shaders/scene.frag.glsl?raw';
import vertexShader from './shaders/scene.vert.glsl?raw';

type Uniforms = Record<string, IUniform>;

const clampUnit = (value: number): number => Math.min(1, Math.max(0, value));
const color = (hex: number): Color => new Color(hex);
const vector3 = (values: readonly [number, number, number]): Vector3 => new Vector3(...values);

export class HeroScene implements HeroSceneApi {
  readonly ready: Promise<void>;

  private readonly layers = new LayerRegistry();
  private readonly clock = new Clock(false);
  private readonly targetParallax = new Vector2();
  private readonly currentParallax = new Vector2();
  private readonly uniforms: Uniforms;
  private readonly scene = new Scene();
  private readonly camera = new OrthographicCamera(-1, 1, 1, -1, 0, 1);
  private readonly geometry = new PlaneGeometry(2, 2);
  private readonly material: ShaderMaterial;
  private readonly resizeObserver: ResizeObserver | undefined;
  private readonly maxPixelRatio: number;
  private renderer: WebGLRenderer | undefined;
  private resolveReady!: () => void;
  private animationFrame: number | undefined;
  private elapsedTime = 0;
  private scrollProgress = 0;
  private running = false;
  private disposed = false;

  constructor(
    private readonly canvas: HTMLCanvasElement,
    private readonly options: HeroSceneOptions,
  ) {
    this.ready = new Promise<void>((resolve) => {
      this.resolveReady = resolve;
    });
    this.maxPixelRatio = options.maxPixelRatio ?? SCENE_CONFIG.maxPixelRatio;
    this.uniforms = this.createUniforms();
    this.material = new ShaderMaterial({
      vertexShader,
      fragmentShader,
      uniforms: this.uniforms,
      depthTest: false,
      depthWrite: false,
    });

    try {
      this.renderer = new WebGLRenderer({
        canvas,
        antialias: false,
        alpha: false,
        powerPreference: 'high-performance',
      });
      this.renderer.outputColorSpace = SRGBColorSpace;
      this.scene.add(new Mesh(this.geometry, this.material));
      this.resize();
      this.renderer.compile(this.scene, this.camera);
      this.renderFrame(SCENE_CONFIG.stillFrameDelta, false);
      this.resolveReady();
    } catch {
      canvas.classList.add('scene--fallback');
      this.resolveReady();
    }

    const resizeTarget = canvas.parentElement ?? canvas;
    this.resizeObserver = typeof ResizeObserver === 'undefined'
      ? undefined
      : new ResizeObserver(() => this.resize());
    this.resizeObserver?.observe(resizeTarget);
    document.addEventListener('visibilitychange', this.onVisibilityChange);
  }

  setReveal(layer: SceneLayer, value: number): void {
    this.layers.get(layer).reveal.value = clampUnit(value);
    this.renderIfStill();
  }

  setParallax(x: number, y: number): void {
    this.targetParallax.set(clampUnit((x + 1) * 0.5) * 2 - 1, clampUnit((y + 1) * 0.5) * 2 - 1);
    this.renderIfStill();
  }

  setScroll(progress: number): void {
    this.scrollProgress = clampUnit(progress);
    this.renderIfStill();
  }

  start(): void {
    if (this.disposed || this.running || !this.renderer) {
      return;
    }
    this.running = true;
    if (this.options.still || document.hidden) {
      this.renderFrame(SCENE_CONFIG.stillFrameDelta, false);
      return;
    }
    this.clock.start();
    this.animationFrame = requestAnimationFrame(this.onAnimationFrame);
  }

  stop(): void {
    this.running = false;
    if (this.animationFrame !== undefined) {
      cancelAnimationFrame(this.animationFrame);
      this.animationFrame = undefined;
    }
    this.clock.stop();
  }

  dispose(): void {
    if (this.disposed) {
      return;
    }
    this.disposed = true;
    this.stop();
    this.resizeObserver?.disconnect();
    document.removeEventListener('visibilitychange', this.onVisibilityChange);
    this.geometry.dispose();
    this.material.dispose();
    this.renderer?.dispose();
    this.renderer = undefined;
  }

  private createUniforms(): Uniforms {
    const distant = SCENE_CONFIG.ridge.distant;
    const far = SCENE_CONFIG.ridge.far;
    const mid = SCENE_CONFIG.ridge.mid;
    const near = SCENE_CONFIG.ridge.near;

    return {
      uResolution: { value: new Vector2(1, 1) },
      uTime: { value: 0 },
      uAspect: { value: 1 },
      uRevealRise: { value: SCENE_CONFIG.revealRise },
      uFogStrength: { value: SCENE_CONFIG.fogStrength },
      uMajorPeakWidth: { value: SCENE_CONFIG.majorPeakWidth },
      uSecondaryPeakScale: { value: SCENE_CONFIG.secondaryPeakScale },
      uForestSerration: { value: SCENE_CONFIG.forestSerration },
      uNoiseAmount: { value: SCENE_CONFIG.noiseAmount },
      uSunPosition: { value: new Vector2(SCENE_CONFIG.sunDesktop.x, SCENE_CONFIG.sunDesktop.y) },
      uCloudSpeeds: { value: vector3(SCENE_CONFIG.cloudSpeeds) },
      uCloudDepths: { value: vector3(SCENE_CONFIG.cloudDepths) },
      uCloudBands: { value: vector3(SCENE_CONFIG.cloudBands) },
      uCloudScales: { value: vector3(SCENE_CONFIG.cloudScales) },
      uMistSpeed: { value: SCENE_CONFIG.mistSpeed },
      uMistBand: { value: vector3(SCENE_CONFIG.mistBand) },
      uRidgeDistant: { value: new Vector4(distant.baseline, distant.amplitude, distant.frequency, distant.seed) },
      uRidgeFar: { value: new Vector4(far.baseline, far.amplitude, far.frequency, far.seed) },
      uRidgeMid: { value: new Vector4(mid.baseline, mid.amplitude, mid.frequency, mid.seed) },
      uRidgeNear: { value: new Vector4(near.baseline, near.amplitude, near.frequency, near.seed) },
      uRevealDistant: this.layers.get('ridge-distant').reveal,
      uRevealFar: this.layers.get('ridge-far').reveal,
      uRevealMid: this.layers.get('ridge-mid').reveal,
      uRevealNear: this.layers.get('ridge-near').reveal,
      uRevealMist: this.layers.get('mist').reveal,
      uRevealClouds: this.layers.get('clouds').reveal,
      uRevealSun: this.layers.get('sun').reveal,
      uOffsetDistant: this.layers.get('ridge-distant').offset,
      uOffsetFar: this.layers.get('ridge-far').offset,
      uOffsetMid: this.layers.get('ridge-mid').offset,
      uOffsetNear: this.layers.get('ridge-near').offset,
      uOffsetMist: this.layers.get('mist').offset,
      uOffsetClouds: this.layers.get('clouds').offset,
      uOffsetSun: this.layers.get('sun').offset,
      uSkyZenith: { value: color(SCENE_COLORS.skyZenith) },
      uSkyUpper: { value: color(SCENE_COLORS.skyUpper) },
      uSkyHorizon: { value: color(SCENE_COLORS.skyHorizon) },
      uHorizonGlow: { value: color(SCENE_COLORS.horizonGlow) },
      uSunCore: { value: color(SCENE_COLORS.sunCore) },
      uSunEdge: { value: color(SCENE_COLORS.sunEdge) },
      uDistantColor: { value: color(SCENE_COLORS.distant) },
      uFarColor: { value: color(SCENE_COLORS.far) },
      uMidColor: { value: color(SCENE_COLORS.mid) },
      uNearColor: { value: color(SCENE_COLORS.near) },
      uSnowColor: { value: color(SCENE_COLORS.snow) },
      uMistCool: { value: color(SCENE_COLORS.mistCool) },
      uMistWarm: { value: color(SCENE_COLORS.mistWarm) },
      uCloudCool: { value: color(SCENE_COLORS.cloudCool) },
      uCloudWarm: { value: color(SCENE_COLORS.cloudWarm) },
      uRimLight: { value: color(SCENE_COLORS.rimLight) },
    };
  }

  private resize(): void {
    if (!this.renderer || this.disposed) {
      return;
    }
    const parent = this.canvas.parentElement;
    const width = Math.max(1, parent?.clientWidth ?? this.canvas.clientWidth);
    const height = Math.max(1, parent?.clientHeight ?? this.canvas.clientHeight);
    const pixelRatio = Math.min(window.devicePixelRatio || 1, this.maxPixelRatio);
    this.renderer.setPixelRatio(pixelRatio);
    this.renderer.setSize(width, height, false);
    this.renderer.getDrawingBufferSize(this.uniforms.uResolution!.value as Vector2);
    const aspect = width / height;
    this.uniforms.uAspect!.value = aspect;
    const desktopWeight = clampUnit(
      (aspect - SCENE_CONFIG.portraitAspectBoundary) / SCENE_CONFIG.sunAspectTransition,
    );
    (this.uniforms.uSunPosition!.value as Vector2).set(
      SCENE_CONFIG.sunPortrait.x + (SCENE_CONFIG.sunDesktop.x - SCENE_CONFIG.sunPortrait.x) * desktopWeight,
      SCENE_CONFIG.sunPortrait.y + (SCENE_CONFIG.sunDesktop.y - SCENE_CONFIG.sunPortrait.y) * desktopWeight,
    );
    this.renderIfStill();
  }

  private renderIfStill(): void {
    if (this.options.still) {
      this.renderFrame(SCENE_CONFIG.stillFrameDelta, false);
    }
  }

  private renderFrame(delta: number, advanceTime: boolean): void {
    if (!this.renderer || this.disposed) {
      return;
    }
    const smoothing = 1 - Math.exp(-SCENE_CONFIG.parallaxSmoothing * delta);
    this.currentParallax.lerp(this.targetParallax, smoothing);
    this.layers.forEach((layer) => {
      layer.offset.value.set(
        this.currentParallax.x * layer.parallaxDepth,
        this.currentParallax.y * layer.parallaxDepth
          + this.scrollProgress * layer.parallaxDepth * SCENE_CONFIG.scrollLift,
      );
    });
    if (advanceTime) {
      this.elapsedTime += delta;
      this.uniforms.uTime!.value = this.elapsedTime;
    }
    this.renderer.render(this.scene, this.camera);
  }

  private readonly onAnimationFrame = (): void => {
    if (!this.running || this.options.still || document.hidden) {
      return;
    }
    const delta = Math.min(this.clock.getDelta(), SCENE_CONFIG.frameDeltaCap);
    this.renderFrame(delta, true);
    this.animationFrame = requestAnimationFrame(this.onAnimationFrame);
  };

  private readonly onVisibilityChange = (): void => {
    if (!this.running || this.options.still) {
      return;
    }
    if (document.hidden) {
      if (this.animationFrame !== undefined) {
        cancelAnimationFrame(this.animationFrame);
        this.animationFrame = undefined;
      }
      this.clock.stop();
      return;
    }
    this.clock.start();
    this.animationFrame = requestAnimationFrame(this.onAnimationFrame);
  };
}
