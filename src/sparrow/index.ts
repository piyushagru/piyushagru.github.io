import type { SparrowApi, SparrowOptions } from '@lib/contracts';
import type { PointerTracker } from '@lib/pointer';
import { Sparrow } from './sparrow';

export const createSparrow = (options: SparrowOptions, pointer: PointerTracker): SparrowApi =>
  new Sparrow(options, pointer);
