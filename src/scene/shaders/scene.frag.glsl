precision highp float;

varying vec2 vUv;

uniform vec2 uResolution;
uniform float uTime;
uniform float uAspect;
uniform float uRevealRise;
uniform float uFogStrength;
uniform float uMajorPeakWidth;
uniform float uSecondaryPeakScale;
uniform float uForestSerration;
uniform float uNoiseAmount;
uniform vec2 uSunPosition;
uniform vec3 uCloudSpeeds;
uniform vec3 uCloudDepths;
uniform vec3 uCloudBands;
uniform vec3 uCloudScales;
uniform float uMistSpeed;
uniform vec3 uMistBand;

uniform vec4 uRidgeDistant;
uniform vec4 uRidgeFar;
uniform vec4 uRidgeMid;
uniform vec4 uRidgeNear;

uniform float uRevealDistant;
uniform float uRevealFar;
uniform float uRevealMid;
uniform float uRevealNear;
uniform float uRevealMist;
uniform float uRevealClouds;
uniform float uRevealSun;

uniform vec2 uOffsetDistant;
uniform vec2 uOffsetFar;
uniform vec2 uOffsetMid;
uniform vec2 uOffsetNear;
uniform vec2 uOffsetMist;
uniform vec2 uOffsetClouds;
uniform vec2 uOffsetSun;

uniform vec3 uSkyZenith;
uniform vec3 uSkyUpper;
uniform vec3 uSkyHorizon;
uniform vec3 uHorizonGlow;
uniform vec3 uSunCore;
uniform vec3 uSunEdge;
uniform vec3 uDistantColor;
uniform vec3 uFarColor;
uniform vec3 uMidColor;
uniform vec3 uNearColor;
uniform vec3 uSnowColor;
uniform vec3 uMistCool;
uniform vec3 uMistWarm;
uniform vec3 uCloudCool;
uniform vec3 uCloudWarm;
uniform vec3 uRimLight;

float hash11(float value) {
  return fract(sin(value * 127.1) * 43758.5453123);
}

float hash21(vec2 point) {
  return fract(sin(dot(point, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise1(float value) {
  float cell = floor(value);
  float local = fract(value);
  local = local * local * (3.0 - 2.0 * local);
  return mix(hash11(cell), hash11(cell + 1.0), local);
}

float noise2(vec2 point) {
  vec2 cell = floor(point);
  vec2 local = fract(point);
  local = local * local * (3.0 - 2.0 * local);
  return mix(
    mix(hash21(cell), hash21(cell + vec2(1.0, 0.0)), local.x),
    mix(hash21(cell + vec2(0.0, 1.0)), hash21(cell + 1.0), local.x),
    local.y
  );
}

float fbm1(float value) {
  float total = 0.0;
  float weight = 0.5;
  for (int octave = 0; octave < 5; octave++) {
    total += weight * noise1(value);
    value = value * 2.03 + 13.17;
    weight *= 0.5;
  }
  return total;
}

float fbm2(vec2 point) {
  float total = 0.0;
  float weight = 0.5;
  for (int octave = 0; octave < 4; octave++) {
    total += weight * noise2(point);
    point = point * 2.01 + vec2(9.7, 4.3);
    weight *= 0.5;
  }
  return total;
}

float mountainHeight(float x, vec4 settings, float forestDetail) {
  float domain = x * settings.z + settings.w;
  float broad = fbm1(domain);
  float ridged = 1.0 - abs(noise1(domain * 0.72 + 19.0) * 2.0 - 1.0);
  ridged = ridged * ridged * ridged;
  float warpedX = x + (fbm1(domain * 1.41 + 5.3) - 0.5) * 0.075;
  float majorCenter = fract(settings.w);
  float majorPeak = pow(max(0.0, 1.0 - abs(warpedX - majorCenter) / uMajorPeakWidth), 1.55);
  float secondaryCenter = fract(settings.w * 0.73);
  float secondaryPeak = pow(max(0.0, 1.0 - abs(warpedX - secondaryCenter) / (uMajorPeakWidth * 0.72)), 1.7);
  float serration = 0.0;
  if (forestDetail > 0.0) {
    float trees = fract((x + settings.w) * 220.0);
    float crowns = pow(1.0 - abs(trees * 2.0 - 1.0), 6.0);
    serration = crowns * uForestSerration * (0.72 + 0.28 * noise1(floor((x + settings.w) * 220.0)));
  }
  float crags = (fbm1(domain * 4.7 + 23.0) - 0.5) * 0.15 * (0.35 + majorPeak + secondaryPeak * 0.5);
  float profile = 0.25 * broad + 0.2 * ridged + 0.78 * majorPeak
    + uSecondaryPeakScale * secondaryPeak + crags;
  return settings.x + settings.y * profile + serration * forestDetail;
}

float portraitMix() {
  return smoothstep(0.74, 1.1, uAspect);
}

float ridgeHeight(vec2 uv, vec4 settings, vec2 offset, float reveal, float forestDetail) {
  float desktop = portraitMix();
  float landscapeX = (uv.x - 0.5) * mix(1.62, 1.0, desktop) + 0.5 + offset.x;
  float compressedAmplitude = mix(0.64, 1.0, desktop);
  vec4 adjusted = vec4(settings.x, settings.y * compressedAmplitude, settings.z, settings.w);
  return mountainHeight(landscapeX, adjusted, forestDetail) + offset.y - (1.0 - reveal) * uRevealRise;
}

float ridgeMask(vec2 uv, float height) {
  float edge = max(fwidth(height), 1.25 / uResolution.y);
  return smoothstep(height + edge, height - edge, uv.y);
}

vec3 ridgePaint(
  vec2 uv,
  float height,
  vec3 ridgeColor,
  float reveal,
  float haze,
  float forestDetail
) {
  float depth = clamp((height - uv.y) * 4.0, 0.0, 1.0);
  vec3 fogColor = mix(uSkyHorizon, uSkyUpper, clamp(uv.y * 1.45, 0.0, 1.0));
  vec3 color = mix(fogColor, ridgeColor, reveal * (1.0 - haze * uFogStrength));
  color *= mix(1.04, 0.8, depth);
  if (forestDetail > 0.0) {
    float trunks = noise1(uv.x * 560.0 + floor(uv.y * 170.0) * 0.7);
    float forest = smoothstep(0.42, 0.82, trunks) * smoothstep(0.2, 0.9, depth);
    color *= 1.0 - forest * 0.12 * forestDetail;
  }
  float sunFacing = smoothstep(0.6, 0.98, 1.0 - abs(uv.x - uSunPosition.x));
  float rim = exp(-abs(uv.y - height) * 420.0) * sunFacing;
  return mix(color, uRimLight, rim * 0.18 * reveal);
}

vec3 compositeRidge(
  vec3 base,
  vec2 uv,
  vec4 settings,
  vec2 offset,
  vec3 ridgeColor,
  float reveal,
  float haze,
  float forestDetail,
  float snowAmount
) {
  float height = ridgeHeight(uv, settings, offset, reveal, forestDetail);
  float alpha = ridgeMask(uv, height) * smoothstep(0.0, 0.32, reveal);
  vec3 color = ridgePaint(uv, height, ridgeColor, reveal, haze, forestDetail);
  if (snowAmount > 0.0) {
    float nearbyHeight = ridgeHeight(uv + vec2(0.0025, 0.0), settings, offset, reveal, forestDetail);
    float sunwardSlope = smoothstep(0.001, 0.006, abs(height - nearbyHeight));
    float snowLine = exp(-abs(uv.y - height + 0.0035) * 360.0);
    float highPeak = smoothstep(settings.x + settings.y * 0.34, settings.x + settings.y * 0.72, height);
    color = mix(color, uSnowColor, snowLine * sunwardSlope * highPeak * snowAmount * reveal);
  }
  return mix(base, color, alpha);
}

float cloudDensity(vec2 uv, float band, float scale, float speed, float depth, float seed) {
  vec2 drift = vec2(uTime * speed, 0.0) + uOffsetClouds * depth;
  vec2 domain = vec2((uv.x + drift.x) * scale + seed, (uv.y + drift.y) * scale * 1.7);
  float body = fbm2(domain);
  body += fbm2(domain * 2.07 + vec2(4.1, 8.7)) * 0.28;
  float envelope = exp(-pow((uv.y - band) * 15.5, 2.0));
  float cloud = smoothstep(0.53, 0.69, body);
  return cloud * envelope;
}

vec3 paintClouds(vec3 sky, vec2 uv) {
  float back = cloudDensity(uv, uCloudBands.x, uCloudScales.x, uCloudSpeeds.x, uCloudDepths.x, 2.4);
  float middle = cloudDensity(uv, uCloudBands.y, uCloudScales.y, uCloudSpeeds.y, uCloudDepths.y, 12.8);
  float front = cloudDensity(uv, uCloudBands.z, uCloudScales.z, uCloudSpeeds.z, uCloudDepths.z, 28.1);
  float density = clamp(back * 0.28 + middle * 0.44 + front * 0.34, 0.0, 0.64);
  float sunlight = smoothstep(0.8, 0.0, distance(uv, uSunPosition + vec2(0.0, 0.13)));
  float underside = smoothstep(0.72, 0.28, uv.y);
  vec3 cloudColor = mix(uCloudCool, uCloudWarm, clamp(sunlight * 0.74 + underside * 0.3, 0.0, 1.0));
  return mix(sky, cloudColor, density * uRevealClouds * 0.58);
}

float mistDensity(vec2 uv) {
  vec2 point = vec2((uv.x + uOffsetMist.x + uTime * uMistSpeed) * 4.8, uv.y * 15.0);
  float shape = fbm2(point) + fbm2(point * 1.9 + 8.0) * 0.23;
  float band = smoothstep(uMistBand.x, uMistBand.y, uv.y) * (1.0 - smoothstep(uMistBand.y, uMistBand.z, uv.y));
  return smoothstep(0.44, 0.76, shape * band + band * 0.48) * uRevealMist;
}

vec3 paintMist(vec3 base, vec2 uv, float opacity) {
  float density = mistDensity(uv) * opacity;
  float warmth = smoothstep(0.62, 0.0, abs(uv.x - uSunPosition.x));
  vec3 color = mix(uMistCool, uMistWarm, warmth * 0.58);
  return mix(base, color, density);
}

void main() {
  vec2 uv = vUv;
  float horizon = smoothstep(0.0, 1.0, uv.y);
  vec3 sky = mix(uSkyHorizon, uSkyUpper, smoothstep(0.18, 0.7, horizon));
  sky = mix(sky, uSkyZenith, smoothstep(0.62, 1.0, horizon));

  vec2 sunPosition = uSunPosition + uOffsetSun;
  float sunDistance = length((uv - sunPosition) * vec2(uAspect, 1.0));
  float horizonRadiance = exp(-sunDistance * 3.8) * exp(-abs(uv.y - sunPosition.y) * 1.8);
  sky = mix(sky, uHorizonGlow, horizonRadiance * 0.34 * uRevealSun);
  float sunGlow = exp(-sunDistance * 15.0) * 0.4;
  sky += uSunEdge * sunGlow * uRevealSun;
  float sunDisc = 1.0 - smoothstep(0.031, 0.036, sunDistance);
  float sunLimb = smoothstep(0.036, 0.0, sunDistance);
  sky = mix(sky, mix(uSunEdge, uSunCore, sunLimb), sunDisc * uRevealSun);

  vec3 color = paintClouds(sky, uv);
  color = compositeRidge(color, uv, uRidgeDistant, uOffsetDistant, uDistantColor, uRevealDistant, 0.78, 0.0, 0.82);
  color = compositeRidge(color, uv, uRidgeFar, uOffsetFar, uFarColor, uRevealFar, 0.48, 0.0, 0.28);
  color = paintMist(color, uv, 0.68);
  color = compositeRidge(color, uv, uRidgeMid, uOffsetMid, uMidColor, uRevealMid, 0.2, 0.72, 0.0);
  color = paintMist(color, uv, 0.32);
  color = compositeRidge(color, uv, uRidgeNear, uOffsetNear, uNearColor, uRevealNear, 0.0, 1.0, 0.0);

  float dither = (hash21(gl_FragCoord.xy) - 0.5) * uNoiseAmount;
  color += dither;
  color = pow(max(color, 0.0), vec3(0.96));
  gl_FragColor = vec4(color, 1.0);
  #include <colorspace_fragment>
}
