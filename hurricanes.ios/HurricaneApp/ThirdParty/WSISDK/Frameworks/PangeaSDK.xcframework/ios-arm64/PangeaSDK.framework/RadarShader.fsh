//
//  RadarShader.fsh
//  PangeaSDK
//
//  Created by Roman Borovyk on 11/18/13.
//  Copyright (c) 2013 Radius. All rights reserved.
//

precision mediump float;

varying highp vec2 vRadarTexCoord;
varying highp vec2 vRadarMotionTexCoord;

uniform sampler2D radarTexture;
uniform highp float radarTextureSize;
uniform sampler2D radarMotionTexture;
uniform sampler2D paletteTexture;

uniform highp float timeOffset;
uniform int intervalMinutes;
uniform float opacity;

const highp float kBicubicSize = 0.25;
const highp float kBicubicSizeInv = 1.0 / kBicubicSize;
const highp vec2 kHalfVec2 = vec2(0.5, 0.5);

// cubic and filter modified versions of http://stackoverflow.com/questions/13501081/efficient-bicubic-filtering-code-in-glsl
vec4 cubic(float v) {
    vec4 n = vec4(1.0, 2.0, 3.0, 4.0) - v;
    vec4 s = n * n * n;
    float x = s.x;
    float y = s.y - 4.0 * s.x;
    float z = s.z - 4.0 * s.y + 6.0 * s.x;
    float w = 6.0 - x - y - z;
    return vec4(x, y, z, w);
}

vec4 filter(sampler2D texture, vec2 texcoord, float texsize) {
    float fx = fract(texcoord.x * kBicubicSizeInv);
    float fy = fract(texcoord.y * kBicubicSizeInv);
    texcoord.x -= fx * kBicubicSize;
    texcoord.y -= fy * kBicubicSize;
    
    vec4 xcubic = cubic(fx);
    vec4 ycubic = cubic(fy);
    
    vec4 c = vec4(texcoord.x - kBicubicSize, texcoord.x + kBicubicSize, texcoord.y - kBicubicSize, texcoord.y + kBicubicSize);
    vec4 s = vec4(xcubic.x + xcubic.y, xcubic.z + xcubic.w, ycubic.x + ycubic.y, ycubic.z + ycubic.w) * kBicubicSizeInv;
    vec4 offset = (c + vec4(xcubic.y, xcubic.w, ycubic.y, ycubic.w) / s) * texsize;
    
    vec4 sample0 = texture2D(texture, vec2(offset.x, offset.z));
    vec4 sample1 = texture2D(texture, vec2(offset.y, offset.z));
    vec4 sample2 = texture2D(texture, vec2(offset.x, offset.w));
    vec4 sample3 = texture2D(texture, vec2(offset.y, offset.w));
    
    float sx = s.x / (s.x + s.y);
    float sy = s.z / (s.z + s.w);
    
    return mix(mix(sample3, sample2, sx), mix(sample1, sample0, sx), sy);
}

void main() {
    //vec4 radarAndTemp = filter(radarTexture, vRadarTexCoord * radarTextureSize, 1.0 / radarTextureSize);
    vec4 radarAndTemp = texture2D(radarTexture, vRadarTexCoord);
    float radar = radarAndTemp.r + (0.5 / 64.0);
    vec2 origTexCoord = vRadarTexCoord * radarTextureSize;
    vec2 exactTexCoord = floor(origTexCoord) + kHalfVec2;
    vec2 altTexCoord = floor(exactTexCoord + normalize(origTexCoord - exactTexCoord)) + kHalfVec2;
    float exactTemp = texture2D(radarTexture, exactTexCoord / radarTextureSize).g;
    float altTemp = texture2D(radarTexture, altTexCoord / radarTextureSize).g;
    exactTemp = abs(exactTemp - radarAndTemp.g) / abs(altTemp - exactTemp) < 0.5 ? exactTemp : altTemp;
    vec4 paletteColor = texture2D(paletteTexture, vec2(radar, 1.0 - (exactTemp + 0.5 / 4.0)));
    gl_FragColor = vec4(paletteColor.rgb, paletteColor.a * opacity);
}
