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
uniform float uAnimateGrain;
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
  float warp = (fbm1(domain * 0.47 + 5.3) - 0.5) * 1.55;
  warp += (noise1(domain * 1.17 + 29.4) - 0.5) * 0.46;
  float ridged = pow(clamp(ridgedFbm1(domain + warp) * 1.08, 0.0, 1.0), 1.55);
  float spur = pow(clamp(ridgedFbm1(domain * 1.83 - warp * 0.62 + 17.2) * 1.12, 0.0, 1.0), 1.7);
  float warpedX = x + (fbm1(domain * 1.31 + 3.7) - 0.5) * 0.12;
  float majorCenter = fract(settings.w);
  float majorDistance = (warpedX - majorCenter) / uMajorPeakWidth;
  float massif = exp(-majorDistance * majorDistance * 1.7);
  float secondaryCenter = fract(settings.w * 0.73);
  float secondaryDistance = (warpedX - secondaryCenter) / (uMajorPeakWidth * 0.76);
  float secondaryMassif = exp(-secondaryDistance * secondaryDistance * 2.1);
  float serration = 0.0;
  if (forestDetail > 0.0) {
    float treeFrequency = mix(145.0, 250.0, forestDetail);
    float treeDomain = (x + settings.w) * treeFrequency;
    float treeCell = floor(treeDomain);
    float treeLocal = fract(treeDomain);
    float treeVariation = hash11(treeCell + settings.w * 17.0);
    float treeCenter = 0.5 + (hash11(treeCell + 4.2) - 0.5) * 0.2;
    float halfWidth = mix(0.3, 0.48, hash11(treeCell + 8.6));
    float lean = (hash11(treeCell + 12.4) - 0.5) * 0.16;
    float crown = max(0.0, 1.0 - abs(treeLocal - treeCenter - lean) / halfWidth);
    float shoulder = max(0.0, 1.0 - abs(treeLocal - treeCenter + lean * 0.45) / (halfWidth * 1.34));
    crown = max(crown * crown, shoulder * shoulder * 0.48);
    float treeHeight = uForestSerration * mix(0.5, 1.0, treeVariation);
    serration = crown * treeHeight * mix(0.44, 1.0, forestDetail);
  }
  float crags = (noise1(domain * 5.3 + 23.0) - 0.5) * 0.15 * (0.32 + massif);
  float profile = 0.12 * broad + 0.18 * massif + 0.54 * ridged * (0.28 + 0.72 * massif)
    + uSecondaryPeakScale * secondaryMassif * (0.24 + 0.48 * spur) + 0.2 * spur + crags;
  return settings.x + settings.y * profile + serration * forestDetail;
}

float portraitMix() {
  return smoothstep(0.74, 1.1, uAspect);
}

float ridgeHeight(vec2 uv, vec4 settings, vec2 offset, float reveal, float forestDetail) {
  float desktop = portraitMix();
  float landscapeX = (uv.x - 0.5) * mix(1.62, 1.0, desktop) + 0.5 + offset.x;
  float compressedAmplitude = mix(uPortraitAmplitudeScale, 1.0, desktop);
  float portraitLift = (1.0 - desktop) * forestDetail * forestDetail * uPortraitNearLift;
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
  float sunContact = exp(-ridgeSunDistance * 5.6);
  float rim = exp(-abs(uv.y - height) * 220.0) * sunContact;
  float warmedFace = exp(-abs(uv.y - height) * 52.0) * sunContact * 0.11;
  color = mix(color, uRimLight, warmedFace * uRidgeGlowStrength * reveal);
  return mix(color, uSunEdge, rim * uRidgeGlowStrength * reveal);
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
  out float sunLighting,
  out float heightLighting
) {
  vec2 drift = vec2(uTime * speed, 0.0) + uOffsetClouds * depth;
  vec2 movingUv = uv + drift;
  float clusterFrequency = mix(2.7, 4.4, depth);
  float clusterPosition = movingUv.x * clusterFrequency + seed;
  float cell = floor(clusterPosition);
  float localX = fract(clusterPosition);
  float centerX = 0.5 + (hash11(cell + seed * 3.7) - 0.5) * 0.16;
  float halfWidth = mix(0.3, 0.47, hash11(cell + seed * 7.1));
  float centerY = band + (hash11(cell + seed * 11.3) - 0.5) * 0.09;
  centerY += (noise1(movingUv.x * 4.1 + seed) - 0.5) * 0.025;
  float halfHeight = mix(0.045, 0.085, hash11(cell + seed * 13.7));
  vec2 cloudPoint = vec2(
    (localX - centerX) / halfWidth,
    (uv.y - centerY) / halfHeight
  );
  float baseLobe = 1.0 - dot(
    vec2(cloudPoint.x, (cloudPoint.y + 0.28) / 0.68),
    vec2(cloudPoint.x, (cloudPoint.y + 0.28) / 0.68)
  );
  vec2 leftPoint = vec2((cloudPoint.x + 0.42) / 0.58, (cloudPoint.y - 0.02) / 0.82);
  vec2 crownPoint = vec2((cloudPoint.x + 0.04) / 0.7, (cloudPoint.y - 0.22) / 1.05);
  vec2 rightPoint = vec2((cloudPoint.x - 0.43) / 0.62, (cloudPoint.y - 0.06) / 0.78);
  float bodyField = max(
    baseLobe,
    max(1.0 - dot(leftPoint, leftPoint), max(1.0 - dot(crownPoint, crownPoint), 1.0 - dot(rightPoint, rightPoint)))
  );
  float body = smoothstep(-0.2, 0.28, bodyField);
  float occupied = step(0.3, hash11(cell + seed * 19.1));

  vec2 domain = vec2(
    movingUv.x * scale + seed,
    (uv.y - centerY) * scale * 3.2 + seed * 0.17
  );
  float field = fbm2(domain);
  float edgeDetail = noise2(domain * 2.03 + vec2(7.3, 3.9));
  float threshold = mix(0.43, 0.5, hash11(cell + seed * 23.9));
  float densityField = field + edgeDetail * 0.17 + bodyField * 0.08;
  float billows = smoothstep(threshold - 0.07, threshold + 0.1, densityField);
  float density = smoothstep(0.12, 0.76, body * billows) * occupied;
  float sunClearance = smoothstep(
    uSunRadius * 1.08,
    uSunRadius * 2.35,
    length((uv - uSunPosition) * vec2(uAspect, 1.0))
  );
  density *= sunClearance;

  vec2 gradientStep = vec2(0.075, 0.0);
  float gradientX = noise2(domain + gradientStep) - noise2(domain - gradientStep);
  float gradientY = noise2(domain + gradientStep.yx) - noise2(domain - gradientStep.yx);
  vec2 outwardNormal = normalize(-vec2(gradientX, gradientY) + vec2(0.001, 0.08));
  vec2 sunDirection = normalize((uSunPosition - uv) * vec2(uAspect, 1.0));
  sunLighting = max(0.0, dot(outwardNormal, sunDirection));
  heightLighting = clamp((uv.y - centerY) / halfHeight * 0.5 + 0.5, 0.0, 1.0);
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
  float heightLighting = 0.0;
  float density = cloudDensity(
    uv, band, scale, speed, depth, seed, sunLighting, heightLighting
  );
  float nearSun = smoothstep(0.78, 0.08, distance(uv, uSunPosition));
  float warmEdge = sunLighting * (0.52 + nearSun * 0.3);
  float warmUnderside = (1.0 - heightLighting) * (0.24 + nearSun * 0.42);
  float warmth = clamp(warmEdge + warmUnderside, 0.0, 1.0);
  vec3 cloudColor = mix(uCloudCool, uCloudWarm, warmth);
  cloudColor = mix(cloudColor, uCloudCool * 1.08, heightLighting * (1.0 - sunLighting) * 0.42);
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
  float midHeight = ridgeHeight(uv, uRidgeMid, uOffsetMid, uRevealMid, 0.38);
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
  float horizonRadiance = exp(-sunDistance * 2.45) * exp(-abs(uv.y - sunPosition.y) * 1.35);
  sky = mix(sky, uHorizonGlow, horizonRadiance * uSunHaloStrength * 0.72 * uRevealSun);
  float broadHalo = exp(-sunDistance * uSunHaloFalloff);
  float innerHalo = exp(-sunDistance * uSunHaloFalloff * 2.1);
  sky = mix(sky, uSunEdge, broadHalo * uSunHaloStrength * 0.42 * uRevealSun);
  sky += uSunCore * innerHalo * uSunHaloStrength * 0.18 * uRevealSun;
  float sunDisc = 1.0 - smoothstep(uSunRadius * 0.88, uSunRadius, sunDistance);
  float sunLimb = smoothstep(uSunRadius, 0.0, sunDistance);
  sky = mix(sky, mix(uSunEdge, uSunCore, sunLimb), sunDisc * uRevealSun);

  float rayAngle = atan(fromSun.y, fromSun.x);
  float rayBreakup = noise1(length(fromSun) * 13.0 + 4.7);
  float rayBands = pow(max(0.0, sin(rayAngle * 17.0 + rayBreakup * 1.4)), 7.0);
  float rayFade = smoothstep(0.7, 0.05, sunDistance)
    * smoothstep(distantHeight + 0.006, distantHeight + 0.075, uv.y);
  sky += uHorizonGlow * rayBands * rayFade * uRayStrength * uRevealSun;

  vec3 color = paintClouds(sky, uv);
  color = compositeRidge(color, uv, distantHeight, distantSlope, uRidgeDistant, uDistantColor, uRevealDistant, 0.78, 0.0, 0.9);
  color = paintValleyMist(color, uv, distantHeight, uMistFar);
  color = compositeRidge(color, uv, farHeight, farSlope, uRidgeFar, uFarColor, uRevealFar, 0.48, 0.0, 0.45);
  color = paintValleyMist(color, uv, farHeight, uMistFar);
  color = compositeRidge(color, uv, midHeight, 0.0, uRidgeMid, uMidColor, uRevealMid, 0.2, 0.38, 0.0);
  color = paintValleyMist(color, uv, midHeight, uMistMid);
  color = compositeRidge(color, uv, nearHeight, 0.0, uRidgeNear, uNearColor, uRevealNear, 0.0, 1.0, 0.0);
  color = paintValleyMist(color, uv, nearHeight, uMistNear);

  float groundBand = 1.0 - smoothstep(uGroundBandHeight * 0.72, uGroundBandHeight, uv.y);
  color = mix(color, uGroundColor, groundBand * 0.94);

  float grainFrame = floor(uTime * 18.0);
  vec2 grainOffset = vec2(grainFrame * 17.0, grainFrame * 7.0);
  float grain = (hash21(gl_FragCoord.xy + grainOffset) - 0.5) * uNoiseAmount * uAnimateGrain;
  color += grain;
  color = pow(max(color, 0.0), vec3(0.96));
  gl_FragColor = vec4(color, 1.0);
  #include <colorspace_fragment>
}
