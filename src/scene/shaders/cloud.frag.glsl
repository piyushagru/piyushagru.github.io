precision highp float;

varying vec2 vUv;

uniform float uTime;
uniform float uAspect;
uniform float uRevealClouds;
uniform float uSunRadius;
uniform float uCloudAnisotropy;
uniform float uCloudDensity;
uniform vec2 uSunPosition;
uniform vec2 uOffsetClouds;
uniform vec3 uCloudSpeeds;
uniform vec3 uCloudDepths;
uniform vec3 uCloudBands;
uniform vec3 uCloudScales;
uniform vec3 uCloudOpacities;
uniform vec3 uCloudCool;
uniform vec3 uCloudWarm;

float hash31(vec3 point) {
  point = fract(point * 0.1031);
  point += dot(point, point.yzx + 33.33);
  return fract((point.x + point.y) * point.z);
}

float noise3(vec3 point) {
  vec3 cell = floor(point);
  vec3 local = fract(point);
  local = local * local * (3.0 - 2.0 * local);
  return mix(
    mix(
      mix(hash31(cell), hash31(cell + vec3(1.0, 0.0, 0.0)), local.x),
      mix(hash31(cell + vec3(0.0, 1.0, 0.0)), hash31(cell + vec3(1.0, 1.0, 0.0)), local.x),
      local.y
    ),
    mix(
      mix(hash31(cell + vec3(0.0, 0.0, 1.0)), hash31(cell + vec3(1.0, 0.0, 1.0)), local.x),
      mix(hash31(cell + vec3(0.0, 1.0, 1.0)), hash31(cell + vec3(1.0)), local.x),
      local.y
    ),
    local.z
  );
}

float fbm3(vec3 point) {
  float total = 0.0;
  float weight = 0.55;
  for (int octave = 0; octave < 3; octave++) {
    total += weight * noise3(point);
    point = point * 2.03 + vec3(7.1, 11.7, 5.3);
    weight *= 0.48;
  }
  return total;
}

float henyeyGreenstein(float cosine, float anisotropy) {
  float g2 = anisotropy * anisotropy;
  return (1.0 - g2) / pow(max(0.001, 1.0 + g2 - 2.0 * anisotropy * cosine), 1.5);
}

vec4 raymarchCloudPlane(
  vec2 uv,
  float band,
  float scale,
  float speed,
  float depth,
  float opacity,
  float seed
) {
  vec2 movingUv = uv + vec2(uTime * speed, 0.0) + uOffsetClouds * depth;
  float slabHalfHeight = mix(0.105, 0.07, depth);
  float slabHeight = (uv.y - band) / slabHalfHeight;
  float evolution = uTime * speed * 3.4;
  float coverage = fbm3(vec3(movingUv.x * scale * 0.72 + seed, seed * 0.17, evolution));
  float coverageGate = clamp((coverage - 0.37) * 5.0, 0.0, 1.0);
  vec3 sunDirection = normalize(vec3((uSunPosition - uv) * vec2(uAspect, 1.0), 0.34));
  vec3 viewDirection = normalize(vec3((uv - 0.5) * vec2(uAspect, 1.0), 1.35));
  float phase = henyeyGreenstein(dot(viewDirection, sunDirection), uCloudAnisotropy);
  float nearHorizon = 1.0 - smoothstep(0.08, 0.52, abs(band - uSunPosition.y));
  float transmittance = 1.0;
  vec3 scattered = vec3(0.0);

  for (int stepIndex = 0; stepIndex < 8; stepIndex++) {
    float depthSample = (float(stepIndex) + 0.5) / 8.0;
    float warpedHeight = slabHeight + (coverage - 0.5) * 0.7 + (depthSample - 0.5) * 0.2;
    float verticalEnvelope = max(0.0, 1.0 - abs(warpedHeight));
    vec3 point = vec3(
      movingUv.x * scale + depthSample * 0.24,
      warpedHeight * 0.9 + seed * 0.13,
      seed + depthSample * 1.75 + evolution
    );
    float field = fbm3(point);
    float erosion = mix(0.72, 0.46, verticalEnvelope);
    float density = max(0.0, field + coverage * 0.16 - erosion);
    density *= verticalEnvelope * coverageGate * uCloudDensity;

    float lightField = noise3(point + sunDirection * 0.48);
    float lightTransmittance = exp(-max(0.0, lightField - 0.38) * 2.8);
    float underside = 1.0 - smoothstep(-0.62, 0.38, warpedHeight);
    float directLight = clamp(lightTransmittance * phase * mix(0.45, 1.0, nearHorizon), 0.0, 1.0);
    float warmth = clamp(directLight * mix(0.68, 1.0, underside), 0.0, 1.0);
    vec3 sampleColor = mix(uCloudCool * 0.78, uCloudWarm, warmth);
    sampleColor += uCloudCool * verticalEnvelope * 0.12;

    float stepAlpha = 1.0 - exp(-density * opacity * 0.82);
    scattered += transmittance * stepAlpha * sampleColor;
    transmittance *= 1.0 - stepAlpha;
  }

  return vec4(scattered, 1.0 - transmittance);
}

vec4 compositeOver(vec4 front, vec4 back) {
  return vec4(
    front.rgb + back.rgb * (1.0 - front.a),
    front.a + back.a * (1.0 - front.a)
  );
}

void main() {
  vec4 farClouds = raymarchCloudPlane(
    vUv, uCloudBands.x, uCloudScales.x, uCloudSpeeds.x,
    uCloudDepths.x, uCloudOpacities.x, 2.4
  );
  vec4 midClouds = raymarchCloudPlane(
    vUv, uCloudBands.y, uCloudScales.y, uCloudSpeeds.y,
    uCloudDepths.y, uCloudOpacities.y, 12.8
  );
  vec4 nearClouds = raymarchCloudPlane(
    vUv, uCloudBands.z, uCloudScales.z, uCloudSpeeds.z,
    uCloudDepths.z, uCloudOpacities.z, 28.1
  );
  vec4 clouds = compositeOver(nearClouds, compositeOver(midClouds, farClouds));
  float sunClearance = smoothstep(
    uSunRadius * 1.05,
    uSunRadius * 2.4,
    length((vUv - uSunPosition) * vec2(uAspect, 1.0))
  );
  gl_FragColor = clouds * sunClearance * uRevealClouds;
}
