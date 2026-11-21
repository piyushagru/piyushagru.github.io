import { Vector2, type IUniform } from 'three';
import type { SceneLayer } from '@lib/contracts';

export class Layer {
  readonly reveal: IUniform<number> = { value: 0 };
  readonly offset: IUniform<Vector2> = { value: new Vector2() };

  constructor(
    readonly id: SceneLayer,
    readonly parallaxDepth: number,
  ) {}
}
