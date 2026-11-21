import type { Point } from '@lib/contracts';
import { SPARROW_CONFIG } from './sparrow.config';

export interface FlightSnapshot extends Point {
  vx: number;
  vy: number;
  speedPxPerMs: number;
  direction: 1 | -1;
  bankDegrees: number;
}

export class FlightModel {
  private position: Point = { x: 0, y: 0 };
  private target: Point = { x: 0, y: 0 };
  private velocity: Point = { x: 0, y: 0 };
  private smoothedVelocity: Point = { x: 0, y: 0 };
  private accumulator = 0;
  private direction: 1 | -1 = 1;
  private bankDegrees = 0;

  setPosition(point: Point, velocity: Point = { x: 0, y: 0 }): void {
    this.position = { ...point };
    this.target = { ...point };
    this.velocity = { ...velocity };
    this.smoothedVelocity = { ...velocity };
    this.accumulator = 0;
    this.updateDirection();
  }

  setTarget(target: Point): void {
    this.target = { ...target };
  }

  advance(elapsedSeconds: number): FlightSnapshot {
    const { fixedStepSeconds, maxFrameSeconds } = SPARROW_CONFIG.spring;
    this.accumulator += Math.min(elapsedSeconds, maxFrameSeconds);

    while (this.accumulator >= fixedStepSeconds) {
      this.integrate(fixedStepSeconds);
      this.accumulator -= fixedStepSeconds;
    }

    return this.snapshot;
  }

  get snapshot(): FlightSnapshot {
    const speedPxPerSecond = Math.hypot(this.velocity.x, this.velocity.y);
    return {
      ...this.position,
      vx: this.velocity.x,
      vy: this.velocity.y,
      speedPxPerMs: speedPxPerSecond / 1000,
      direction: this.direction,
      bankDegrees: this.bankDegrees,
    };
  }

  private integrate(dt: number): void {
    const { mass, stiffness, damping } = SPARROW_CONFIG.spring;
    const accelerationX = (stiffness * (this.target.x - this.position.x) - damping * this.velocity.x) / mass;
    const accelerationY = (stiffness * (this.target.y - this.position.y) - damping * this.velocity.y) / mass;

    this.velocity.x += accelerationX * dt;
    this.velocity.y += accelerationY * dt;
    this.position.x += this.velocity.x * dt;
    this.position.y += this.velocity.y * dt;

    const headingAlpha = 1 - Math.exp(-SPARROW_CONFIG.heading.smoothingPerSecond * dt);
    this.smoothedVelocity.x += (this.velocity.x - this.smoothedVelocity.x) * headingAlpha;
    this.smoothedVelocity.y += (this.velocity.y - this.smoothedVelocity.y) * headingAlpha;
    this.updateDirection();

    const targetBank = Math.max(
      -SPARROW_CONFIG.bank.maxDegrees,
      Math.min(
        SPARROW_CONFIG.bank.maxDegrees,
        this.smoothedVelocity.y * SPARROW_CONFIG.bank.degreesPerPxPerSecond,
      ),
    );
    const bankAlpha = 1 - Math.exp(-SPARROW_CONFIG.bank.smoothingPerSecond * dt);
    this.bankDegrees += (targetBank - this.bankDegrees) * bankAlpha;
  }

  private updateDirection(): void {
    const deadZonePxPerSecond = SPARROW_CONFIG.heading.flipDeadZonePxPerMs * 1000;
    if (this.smoothedVelocity.x > deadZonePxPerSecond) this.direction = 1;
    if (this.smoothedVelocity.x < -deadZonePxPerSecond) this.direction = -1;
  }
}
