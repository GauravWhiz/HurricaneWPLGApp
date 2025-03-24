precision mediump float;

varying highp vec2 vTexCoord;

uniform sampler2D baseTexture;
uniform float opacity;

void main() {
    vec4 pixel = texture2D(baseTexture, vTexCoord);
    gl_FragColor = vec4(pixel.rgb, pixel.a * opacity);
}