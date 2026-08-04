#version 450

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float widthPx;
    float heightPx;
    float minH;
    float maxH;
    vec2 bandsB;
    vec4 bandsA;
    vec4 fillColor;
} ubuf;

const float BAR_W = 2.0;
const float GAP = 1.5;
const float RADIUS = 1.0;

float sdRoundBar(vec2 p, vec2 halfSize, float r) {
    vec2 q = abs(p) - halfSize + vec2(r);
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void main() {
    vec2 px = vec2(qt_TexCoord0.x * ubuf.widthPx, qt_TexCoord0.y * ubuf.heightPx);
    float total = 6.0 * BAR_W + 5.0 * GAP;
    float x0 = (ubuf.widthPx - total) * 0.5;
    float slot = BAR_W + GAP;
    float fi = floor((px.x - x0) / slot);

    if (fi < 0.0 || fi > 5.0) {
        fragColor = vec4(0.0);
        return;
    }

    int i = int(fi);
    float lvl = i == 0 ? ubuf.bandsA.x : i == 1 ? ubuf.bandsA.y : i == 2 ? ubuf.bandsA.z : i == 3 ? ubuf.bandsA.w : i == 4 ? ubuf.bandsB.x : ubuf.bandsB.y;
    float h = ubuf.minH + clamp(lvl, 0.0, 1.0) * (ubuf.maxH - ubuf.minH);

    float lx = px.x - x0 - fi * slot;
    vec2 p = vec2(lx - BAR_W * 0.5, px.y - ubuf.heightPx * 0.5);
    float d = sdRoundBar(p, vec2(BAR_W * 0.5, h * 0.5), RADIUS);
    float mask = 1.0 - smoothstep(-0.6, 0.6, d);

    float a = ubuf.fillColor.a * mask * ubuf.qt_Opacity;
    fragColor = vec4(ubuf.fillColor.rgb * a, a);
}
