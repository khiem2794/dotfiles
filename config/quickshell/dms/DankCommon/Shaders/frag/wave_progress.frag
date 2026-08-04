#version 450

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float widthPx;
    float heightPx;
    float value;
    float actualValue;
    float phase;
    float ampPx;
    float wavelengthPx;
    float lineWidthPx;
    float showActual;
    vec4 fillColor;
    vec4 trackColor;
    vec4 playheadColor;
    vec4 actualColor;
} ubuf;

const float TAU = 6.28318530718;
const float AA = 0.75; // pixel-space antialias band

// Signed distance to a rounded box centered at the origin.
float sdRoundBar(vec2 p, vec2 halfSize, float r) {
    vec2 q = abs(p) - halfSize + vec2(r);
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

// Composite a straight-alpha color over a premultiplied accumulator.
vec4 blendOver(vec4 dst, vec3 rgb, float a) {
    return vec4(rgb * a + dst.rgb * (1.0 - a), a + dst.a * (1.0 - a));
}

void main() {
    float w = ubuf.widthPx;
    float h = ubuf.heightPx;
    vec2 px = vec2(qt_TexCoord0.x * w, qt_TexCoord0.y * h);

    float mid = h * 0.5;
    float halfW = ubuf.lineWidthPx * 0.5;
    float k = TAU / max(ubuf.wavelengthPx, 1e-3);

    float playX = clamp(ubuf.value, 0.0, 1.0) * w;
    float actualX = clamp(ubuf.actualValue, 0.0, 1.0) * w;
    bool seeking = ubuf.showActual > 0.5;

    float loX = min(playX, actualX);
    float hiX = max(playX, actualX);
    float fillEnd = seeking ? loX : playX;   // filled progress ends here
    float actStart = seeking ? loX : playX;  // seek-preview segment
    float actEnd = seeking ? hiX : playX;
    float trackStart = seeking ? hiX : playX; // unplayed remainder

    // Perpendicular distance to the animated sine stroke.
    float ang = k * px.x + ubuf.phase;
    float wy = mid + ubuf.ampPx * sin(ang);
    float slope = ubuf.ampPx * k * cos(ang);
    float dWave = abs(px.y - wy) / sqrt(1.0 + slope * slope);
    float aaW = AA;
    float waveStroke = 1.0 - smoothstep(halfW - aaW, halfW + aaW, dWave);

    // Straight remainder line.
    float dLine = abs(px.y - mid);
    float aaL = AA;
    float lineStroke = 1.0 - smoothstep(halfW - aaL, halfW + aaL, dLine);

    vec4 col = vec4(0.0);

    // 1. Track (unplayed remainder), to the right of the progress head.
    {
        float m = lineStroke * step(trackStart, px.x);
        col = blendOver(col, ubuf.trackColor.rgb, ubuf.trackColor.a * m);
    }

    // 2. Seek-preview segment (only while seeking).
    if (seeking) {
        float m = waveStroke * step(actStart, px.x) * step(px.x, actEnd);
        col = blendOver(col, ubuf.actualColor.rgb, ubuf.actualColor.a * m);
    }

    // 3. Filled progress wave.
    {
        float m = waveStroke * step(halfW, px.x) * step(px.x, fillEnd);
        // Rounded start cap.
        float capS = length(px - vec2(halfW, mid + ubuf.ampPx * sin(k * halfW + ubuf.phase))) - halfW;
        float capM = 1.0 - smoothstep(-aaW, aaW, capS);
        m = max(m, capM * step(halfW - 1.0, px.x));
        col = blendOver(col, ubuf.fillColor.rgb, ubuf.fillColor.a * m);
    }

    // 4. Actual-position marker (only while seeking).
    if (seeking) {
        float amH = max(ubuf.lineWidthPx + 4.0, 10.0);
        float d = sdRoundBar(px - vec2(actualX, mid), vec2(1.0, amH * 0.5), 1.0);
        float aa = AA;
        float m = 1.0 - smoothstep(-aa, aa, d);
        col = blendOver(col, ubuf.actualColor.rgb, ubuf.actualColor.a * m);
    }

    // 5. Playhead pill (on top).
    {
        float phW = 3.5;
        float phH = max(ubuf.lineWidthPx + 12.0, 16.0);
        float d = sdRoundBar(px - vec2(playX, mid), vec2(phW * 0.5, phH * 0.5), phW * 0.5);
        float aa = AA;
        float m = 1.0 - smoothstep(-aa, aa, d);
        col = blendOver(col, ubuf.playheadColor.rgb, ubuf.playheadColor.a * m);
    }

    fragColor = col * ubuf.qt_Opacity;
}
