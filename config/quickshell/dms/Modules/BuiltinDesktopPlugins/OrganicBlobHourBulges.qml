import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property color fillColor: "transparent"

    property int lobes: 12
    property real lobeAmount: 0.070
    property real roundness: 0.22
    property real hillPower: 0.78
    property real paddingFrac: 0.020
    property real inset: 0
    property int segments: 120
    property real rotationDeg: -90

    layer.enabled: true
    layer.samples: 4

    function sgn(v) {
        return v < 0 ? -1 : 1;
    }
    function clamp(v, a, b) {
        return Math.max(a, Math.min(b, v));
    }

    function squircleMap(u, v, p) {
        const ax = sgn(u) * Math.pow(Math.abs(u), p);
        const ay = sgn(v) * Math.pow(Math.abs(v), p);
        return {
            x: ax,
            y: ay
        };
    }

    function buildPathD(w, h) {
        const x0 = inset, y0 = inset;
        const x1 = w - inset, y1 = h - inset;
        const iw = Math.max(2, x1 - x0);
        const ih = Math.max(2, y1 - y0);

        const cx = x0 + iw * 0.5;
        const cy = y0 + ih * 0.5;

        const rx = iw * 0.5;
        const ry = ih * 0.5;
        const rMin = Math.min(rx, ry);

        const amp = clamp(lobeAmount, 0.0, 0.14) * rMin;
        const extraPad = paddingFrac * rMin + 1.5;
        const pad = amp + extraPad;

        const rxBase = Math.max(2, rx - pad);
        const ryBase = Math.max(2, ry - pad);

        const blend = clamp(roundness, 0.0, 0.45);
        const squirclePow = 1.0 + blend * 2.8;

        const N = Math.max(48, segments);
        const rot = rotationDeg * Math.PI / 180.0;
        const dt = (Math.PI * 2.0) / N;

        function hillWave(a) {
            const t = (Math.cos(lobes * a) + 1.0) * 0.5;
            return Math.pow(t, hillPower);
        }

        function P(t) {
            const a = t + rot;
            const u = Math.cos(a);
            const v = Math.sin(a);

            const m = 1.0 + (amp / rMin) * hillWave(a);

            const ex = u * rxBase * m;
            const ey = v * ryBase * m;

            const sm = squircleMap(u, v, 1.0 / squirclePow);
            const sx = sm.x * rxBase * m;
            const sy = sm.y * ryBase * m;

            const x = ex * (1.0 - blend) + sx * blend;
            const y = ey * (1.0 - blend) + sy * blend;
            return {
                x: cx + x,
                y: cy + y
            };
        }

        function dP(t) {
            const eps = dt * 0.25;
            const p1 = P(t - eps);
            const p2 = P(t + eps);
            return {
                x: (p2.x - p1.x) / (2 * eps),
                y: (p2.y - p1.y) / (2 * eps)
            };
        }

        const p0 = P(0.0);
        let d = `M ${p0.x.toFixed(2)} ${p0.y.toFixed(2)} `;

        for (let i = 0; i < N; i++) {
            const tA = i * dt;
            const tB = (i + 1) * dt;

            const A = P(tA);
            const B = P(tB);
            const dA = dP(tA);
            const dB = dP(tB);

            const c1x = A.x + (dt / 3.0) * dA.x;
            const c1y = A.y + (dt / 3.0) * dA.y;
            const c2x = B.x - (dt / 3.0) * dB.x;
            const c2y = B.y - (dt / 3.0) * dB.y;

            d += `C ${c1x.toFixed(2)} ${c1y.toFixed(2)}, ${c2x.toFixed(2)} ${c2y.toFixed(2)}, ${B.x.toFixed(2)} ${B.y.toFixed(2)} `;
        }

        d += "Z";
        return d;
    }

    Shape {
        anchors.fill: parent

        ShapePath {
            fillColor: root.fillColor
            strokeColor: "transparent"

            PathSvg {
                path: root.buildPathD(root.width, root.height)
            }
        }
    }
}
