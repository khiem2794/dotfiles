// hyprshade on gridlines.frag

#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;

out vec4 fragColor;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);

    if (int(mod(gl_FragCoord.x, 7.0)) == 0 ||
        int(mod(gl_FragCoord.y, 7.0)) == 0) {

        // pixColor.r *= 0.97;
        // pixColor.g *= 0.97;
        // pixColor.b *= 0.95;
        pixColor = mix(pixColor, vec4(0.85, 0.85, 0.85, 1.0), 0.03);
    }

    fragColor = pixColor;
}
