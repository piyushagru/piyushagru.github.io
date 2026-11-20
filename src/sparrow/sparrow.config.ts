export const SPARROW_CONFIG = {
  sizePx: 64,
  zIndex: 80,
  followOffset: {
    abovePx: 18,
    aheadPx: 10,
  },
  spring: {
    mass: 1.05,
    stiffness: 115,
    damping: 18.5,
    fixedStepSeconds: 1 / 120,
    maxFrameSeconds: 0.05,
  },
  heading: {
    smoothingPerSecond: 12,
    flipDeadZonePxPerMs: 0.05,
  },
  bank: {
    degreesPerPxPerSecond: 0.055,
    maxDegrees: 18,
    smoothingPerSecond: 10,
  },
  idle: {
    speedThresholdPxPerMs: 0.045,
    settleDelayMs: 350,
    breathingAmplitudePx: 1.5,
    breathingDurationMs: 2400,
  },
  flap: {
    glideFps: 5.5,
    flightFps: 11,
    fullSpeedPxPerMs: 0.65,
    burstMs: 280,
  },
  scriptedFlight: {
    arcLiftRatio: 0.18,
    minArcLiftPx: 54,
    maxArcLiftPx: 150,
  },
} as const;
