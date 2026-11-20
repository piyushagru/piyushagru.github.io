precision highp float;

varying vec2 vUv;

uniform vec2 uResolution;
uniform float uTime;
uniform float uAspect;
uniform float uRevealRise;
uniform float uFogStrength;
uniform float uSunRadius;
uniform float uSunHaloFalloff;
uniform float uSunHaloStrength;
uniform float uRayStrength;
uniform float uRidgeGlowStrength;
uniform float uGroundBandHeight;
uniform float uPortraitAmplitudeScale;
uniform float uPortraitNearLift;
uniform float uMajorPeakWidth;
uniform float uSecondaryPeakScale;
uniform float uForestSerration;
uniform float uNoiseAmount;
uniform vec2 uSunPosition;
uniform vec3 uCloudSpeeds;
uniform vec3 uCloudDepths;
uniform vec3 uCloudBands;
uniform vec3 uCloudScales;
uniform vec3 uCloudOpacities;
uniform float uMistSpeed;
uniform vec4 uMistFar;
uniform vec4 uMistMid;
uniform vec4 uMistNear;

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
uniform vec3 uGroundColor;
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

float ridgedFbm1(float value) {
  float total = 0.0;
  float weight = 0.54;
  for (int octave = 0; octave < 5; octave++) {
    float ridge = 1.0 - abs(noise1(value) * 2.0 - 1.0);
    ridge *= ridge;
    total += ridge * weight;
    value = value * 2.07 + 11.3;
    weight *= 0.48;
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
  float broad = fbm1(domain * 0.58);
  float warp = (fbm1(domain * 0.47 + 5.3) - 0.5) * 1.15;
  float ridged = ridgedFbm1(domain + warp);
  float spur = ridgedFbm1(domain * 1.83 - warp * 0.55 + 17.2);
  float warpedX = x + (fbm1(domain * 1.31 + 3.7) - 0.5) * 0.09;
  float majorCenter = fract(settings.w);
  float majorDistance = (warpedX - majorCenter) / uMajorPeakWidth;
  float massif = exp(-majorDistance * majorDistance * 1.7);
  float secondaryCenter = fract(settings.w * 0.73);
  float secondaryDistance = (warpedX - secondaryCenter) / (uMajorPeakWidth * 0.76);
  float secondaryMassif = exp(-secondaryDistance * secondaryDistance * 2.1);
  float serration = 0.0;
  if (forestDetail > 0.0) {
    float treeDomain = (x + settings.w) * 118.0;
    float treeCell = floor(treeDomain);
    float treeLocal = fract(treeDomain);
    float treeVariation = hash11(treeCell + settings.w * 17.0);
    float halfWidth = mix(0.17, 0.3, hash11(treeCell + 4.2));
    float crown = max(0.0, 1.0 - abs(treeLocal - 0.5) / halfWidth);
    crown = crown * crown;
    float treeHeight = uForestSerration * mix(0.48, 1.0, treeVariation);
    serration = crown * treeHeight;
  }
  float crags = (fbm1(domain * 4.3 + 23.0) - 0.5) * 0.12 * (0.35 + massif);
  float profile = 0.18 * broad + 0.34 * massif + 0.48 * ridged * massif
    + uSecondaryPeakScale * secondaryMassif * (0.34 + 0.34 * spur) + 0.12 * spur + crags;
  return settings.x + settings.y * profile + serration * forestDetail;
}

float portraitMix() {
  return smoothstep(0.74, 1.1, uAspect);
}

float ridgeHeight(vec2 uv, vec4 settings, vec2 offset, float reveal, float forestDetail) {
  float desktop = portraitMix();
  float landscapeX = (uv.x - 0.5) * mix(1.62, 1.0, desktop) + 0.5 + offset.x;
  float compressedAmplitude = mix(uPortraitAmplitudeScale, 1.0, desktop);
  float portraitLift = (1.0 - desktop) * forestDetail * uPortraitNearLift;
  vec4 adjusted = vec4(settings.x, settings.y * compressedAmplitude, settings.z, settings.w);
  return mountainHeight(landscapeX, adjusted, forestDetail) + portraitLift + offset.y
    - (1.0 - reveal) * uRevealRise;
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
  float ridgeSunDistance = distance(vec2(uv.x, height), uSunPosition);
  float sunContact = exp(-ridgeSunDistance * 8.0);
  float rim = exp(-abs(uv.y - height) * 420.0) * sunContact;
  return mix(color, uRimLight, rim * uRidgeGlowStrength * reveal);
}

vec3 compositeRidge(
  vec3 base,
  vec2 uv,
  float height,
  float slope,
  vec4 settings,
  vec3 ridgeColor,
  float reveal,
  float haze,
  float forestDetail,
  float snowAmount
) {
  float alpha = ridgeMask(uv, height) * smoothstep(0.0, 0.32, reveal);
  vec3 color = ridgePaint(uv, height, ridgeColor, reveal, haze, forestDetail);
  if (snowAmount > 0.0) {
    float sunDirectionSign = sign(uSunPosition.x - uv.x);
    float sunwardSlope = smoothstep(0.0005, 0.005, slope * -sunDirectionSign);
    float snowLine = exp(-abs(uv.y - height + 0.003) * 420.0);
    float highPeak = smoothstep(settings.x + settings.y * 0.31, settings.x + settings.y * 0.68, height);
    color = mix(color, uSnowColor, snowLine * sunwardSlope * highPeak * snowAmount * reveal);
  }
  return mix(base, color, alpha);
}

float cloudDensity(
  vec2 uv,
  float band,
  float scale,
  float speed,
  float depth,
  float seed,
  out float sunLighting
) {
  vec2 drift = vec2(uTime * speed, 0.0) + uOffsetClouds * depth;
  vec2 movingUv = uv + drift;
  float verticalWarp = (noise1(movingUv.x * 5.2 + seed) - 0.5) * 0.055;
  float envelope = exp(-pow((uv.y - band - verticalWarp) * 15.0, 2.0));
  float bodyMask = smoothstep(0.4, 0.57, fbm1(movingUv.x * 1.7 + seed * 0.31));
  vec2 domain = vec2(movingUv.x * scale + seed, movingUv.y * scale * 1.55);
  float billows = fbm2(domain) + noise2(domain * 2.1 + 7.3) * 0.18;
  float density = smoothstep(0.4, 0.57, billows) * envelope * bodyMask;

  vec2 gradientStep = vec2(0.075, 0.0);
  float gradientX = noise2(domain + gradientStep) - noise2(domain - gradientStep);
  float gradientY = noise2(domain + gradientStep.yx) - noise2(domain - gradientStep.yx);
  vec2 outwardNormal = normalize(-vec2(gradientX, gradientY) + vec2(0.0001));
  vec2 sunDirection = normalize((uSunPosition - uv) * vec2(uAspect, 1.0));
  sunLighting = max(0.0, dot(outwardNormal, sunDirection));
  return density;
}

vec3 paintCloudPlane(
  vec3 base,
  vec2 uv,
  float band,
  float scale,
  float speed,
  float depth,
  float opacity,
  float seed
) {
  float sunLighting = 0.0;
  float density = cloudDensity(uv, band, scale, speed, depth, seed, sunLighting);
  float underside = smoothstep(band + 0.055, band - 0.035, uv.y);
  float nearSun = smoothstep(0.82, 0.08, distance(uv, uSunPosition));
  float warmth = clamp(sunLighting * 0.45 + underside * 0.46 + nearSun * 0.34, 0.0, 1.0);
  vec3 cloudColor = mix(uCloudCool, uCloudWarm, warmth);
  return mix(base, cloudColor, density * opacity * uRevealClouds);
}

vec3 paintClouds(vec3 sky, vec2 uv) {
  vec3 color = paintCloudPlane(
    sky, uv, uCloudBands.x, uCloudScales.x, uCloudSpeeds.x,
    uCloudDepths.x, uCloudOpacities.x, 2.4
  );
  color = paintCloudPlane(
    color, uv, uCloudBands.y, uCloudScales.y, uCloudSpeeds.y,
    uCloudDepths.y, uCloudOpacities.y, 12.8
  );
  return paintCloudPlane(
    color, uv, uCloudBands.z, uCloudScales.z, uCloudSpeeds.z,
    uCloudDepths.z, uCloudOpacities.z, 28.1
  );
}

float valleyMistDensity(vec2 uv, float ridgeHeightValue, vec4 settings) {
  vec2 drift = vec2(uTime * uMistSpeed + uOffsetMist.x, uOffsetMist.y);
  vec2 point = vec2((uv.x + drift.x) * settings.z + settings.w, (uv.y + drift.y) * settings.z * 2.6);
  float field = fbm2(point);
  float patches = smoothstep(0.46, 0.68, field);
  float center = ridgeHeightValue - settings.x * 0.42;
  float heightFromCenter = (uv.y - center) / settings.x;
  float vertical = exp(-heightFromCenter * heightFromCenter * 2.2);
  float upperFade = 1.0 - smoothstep(ridgeHeightValue + settings.x * 0.08, ridgeHeightValue + settings.x, uv.y);
  return patches * vertical * upperFade * settings.y * uRevealMist;
}

vec3 paintValleyMist(vec3 base, vec2 uv, float ridgeHeightValue, vec4 settings) {
  float density = valleyMistDensity(uv, ridgeHeightValue, settings);
  float warmth = smoothstep(0.6, 0.0, abs(uv.x - uSunPosition.x));
  vec3 mistColor = mix(uMistCool, uMistWarm, warmth * 0.62);
  return mix(base, mistColor, density);
}

void main() {
  vec2 uv = vUv;
  float distantHeight = ridgeHeight(uv, uRidgeDistant, uOffsetDistant, uRevealDistant, 0.0);
  float farHeight = ridgeHeight(uv, uRidgeFar, uOffsetFar, uRevealFar, 0.0);
  float midHeight = ridgeHeight(uv, uRidgeMid, uOffsetMid, uRevealMid, 0.28);
  float nearHeight = ridgeHeight(uv, uRidgeNear, uOffsetNear, uRevealNear, 1.0);
  float slopeStep = 0.0025;
  float distantSlope = ridgeHeight(
    uv + vec2(slopeStep, 0.0), uRidgeDistant, uOffsetDistant, uRevealDistant, 0.0
  ) - distantHeight;
  float farSlope = ridgeHeight(
    uv + vec2(slopeStep, 0.0), uRidgeFar, uOffsetFar, uRevealFar, 0.0
  ) - farHeight;

  float horizon = smoothstep(0.0, 1.0, uv.y);
  vec3 sky = mix(uSkyHorizon, uSkyUpper, smoothstep(0.18, 0.7, horizon));
  sky = mix(sky, uSkyZenith, smoothstep(0.62, 1.0, horizon));

  vec2 sunPosition = uSunPosition + uOffsetSun;
  vec2 fromSun = uv - sunPosition;
  float sunDistance = length(fromSun * vec2(uAspect, 1.0));
  float horizonRadiance = exp(-sunDistance * 2.9) * exp(-abs(uv.y - sunPosition.y) * 1.6);
  sky = mix(sky, uHorizonGlow, horizonRadiance * uSunHaloStrength * uRevealSun);
  float sunGlow = exp(-sunDistance * uSunHaloFalloff) * uSunHaloStrength;
  sky += uSunEdge * sunGlow * uRevealSun;
  float sunDisc = 1.0 - smoothstep(uSunRadius * 0.88, uSunRadius, sunDistance);
  float sunLimb = smoothstep(uSunRadius, 0.0, sunDistance);
  sky = mix(sky, mix(uSunEdge, uSunCore, sunLimb), sunDisc * uRevealSun);

  float rayAngle = atan(fromSun.y, fromSun.x);
  float rayBreakup = noise1(length(fromSun) * 13.0 + 4.7);
  float rayBands = pow(max(0.0, sin(rayAngle * 17.0 + rayBreakup * 1.4)), 7.0);
  float rayFade = smoothstep(0.64, 0.06, sunDistance) * smoothstep(distantHeight + 0.01, distantHeight + 0.08, uv.y);
  sky += uHorizonGlow * rayBands * rayFade * uRayStrength * uRevealSun;

  vec3 color = paintClouds(sky, uv);
  color = compositeRidge(color, uv, distantHeight, distantSlope, uRidgeDistant, uDistantColor, uRevealDistant, 0.78, 0.0, 0.9);
  color = paintValleyMist(color, uv, distantHeight, uMistFar);
  color = compositeRidge(color, uv, farHeight, farSlope, uRidgeFar, uFarColor, uRevealFar, 0.48, 0.0, 0.45);
  color = paintValleyMist(color, uv, farHeight, uMistFar);
  color = compositeRidge(color, uv, midHeight, 0.0, uRidgeMid, uMidColor, uRevealMid, 0.2, 0.28, 0.0);
  color = paintValleyMist(color, uv, midHeight, uMistMid);
  color = compositeRidge(color, uv, nearHeight, 0.0, uRidgeNear, uNearColor, uRevealNear, 0.0, 1.0, 0.0);
  color = paintValleyMist(color, uv, nearHeight, uMistNear);

  float groundBand = 1.0 - smoothstep(uGroundBandHeight * 0.72, uGroundBandHeight, uv.y);
  color = mix(color, uGroundColor, groundBand * 0.94);

  float grainFrame = floor(uTime * 18.0);
  vec2 grainOffset = vec2(grainFrame * 17.0, grainFrame * 7.0);
  float grain = (hash21(gl_FragCoord.xy + grainOffset) - 0.5) * uNoiseAmount;
  color += grain;
  color = pow(max(color, 0.0), vec3(0.96));
  gl_FragColor = vec4(color, 1.0);
  #include <colorspace_fragment>
}
