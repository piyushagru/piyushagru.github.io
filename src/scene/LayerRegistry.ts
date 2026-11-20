import { SCENE_LAYERS, type SceneLayer } from '@lib/contracts';
import { Layer } from './Layer';
import { SCENE_CONFIG } from './scene.config';

export class LayerRegistry {
  private readonly layers = new Map<SceneLayer, Layer>();

  constructor() {
    for (const id of SCENE_LAYERS) {
      this.layers.set(id, new Layer(id, SCENE_CONFIG.layers[id].parallaxDepth));
    }
  }

  get(id: SceneLayer): Layer {
    const layer = this.layers.get(id);
    if (!layer) {
      throw new Error(`Unknown scene layer: ${id}`);
    }
    return layer;
  }

  forEach(visitor: (layer: Layer) => void): void {
    for (const layer of this.layers.values()) {
      visitor(layer);
    }
  }
}
