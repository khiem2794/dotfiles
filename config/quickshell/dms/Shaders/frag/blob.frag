#version 450

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float phase;
    float spin;
    float sizePx;
    float baseRadiusPx;
    float amplitudePx;
    float activation;
    float energy;
    vec2 bandsB;
    vec4 bandsA;
    vec4 fillColor;
} ubuf;

const float TAU = 6.28318530718;
const float NOISE_FREQ = 1.25;
const float ORBIT_RADIUS = 1.0;
const float WARP_STRENGTH = 0.75;
const float RING_BIAS = 0.25;
const float MID_FREQ = 2.4;
const float MID_GAIN = 0.34;
const float HIGH_FREQ = 5.0;
const float HIGH_GAIN = 0.16;
const float LOBE_MAX = 1.3;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
    return 0.55 * vnoise(p) + 0.3 * vnoise(p * 2.0 + vec2(17.1, 9.2)) + 0.15 * vnoise(p * 3.9 + vec2(4.3, 21.7));
}

void main() {
    vec2 p = (qt_TexCoord0 - 0.5) * ubuf.sizePx;
    float r = length(p);
    float aa = max(fwidth(r), 0.75);

    float T = ubuf.phase * TAU;
    vec2 dir = r > 0.001 ? p / r : vec2(1.0, 0.0);
    float cs = cos(ubuf.spin);
    float sn = sin(ubuf.spin);
    dir = vec2(dir.x * cs - dir.y * sn, dir.x * sn + dir.y * cs);
    vec2 q = dir * NOISE_FREQ;

    vec2 orbitA = vec2(cos(T), sin(T)) * ORBIT_RADIUS;
    vec2 orbitB = vec2(cos(2.0 * T + 2.1), sin(2.0 * T + 2.1)) * (ORBIT_RADIUS * 0.6);
    float w1 = fbm(q + orbitA);
    float w2 = fbm(q * 1.3 + orbitB + vec2(3.7, 7.3));
    float n = fbm(q + orbitA + WARP_STRENGTH * (vec2(w1, w2) - 0.5));

    float mid = max(ubuf.bandsA.z, ubuf.bandsA.w);
    float high = max(ubuf.bandsB.x, ubuf.bandsB.y);

    vec2 orbitM = vec2(cos(3.0 * T + 0.7), sin(3.0 * T + 0.7)) * 0.9;
    vec2 orbitH = vec2(cos(5.0 * T + 4.2), sin(5.0 * T + 4.2)) * 1.2;
    float midTerm = (vnoise(dir * MID_FREQ + orbitM) - 0.5) * MID_GAIN * mid;
    float highTerm = (vnoise(dir * HIGH_FREQ + orbitH) - 0.5) * HIGH_GAIN * high;

    float shaped = smoothstep(0.34, 0.7, n);
    float body = ubuf.energy * (RING_BIAS + (1.0 - RING_BIAS) * shaped);
    float lobe = clamp(body + midTerm + highTerm, 0.0, LOBE_MAX);
    float blobR = ubuf.baseRadiusPx + ubuf.activation * ubuf.amplitudePx * lobe;

    float mask = 1.0 - smoothstep(-aa, aa, r - blobR);
    float a = ubuf.fillColor.a * mask * ubuf.qt_Opacity;
    fragColor = vec4(ubuf.fillColor.rgb * a, a);
}
