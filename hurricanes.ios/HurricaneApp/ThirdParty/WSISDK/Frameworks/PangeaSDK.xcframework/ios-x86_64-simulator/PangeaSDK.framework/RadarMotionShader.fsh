//
//  RadarMotionShader.fsh
//  PangeaSDK
//
//  Created by Roman Borovyk on 11/18/13.
//  Copyright (c) 2013 Radius. All rights reserved.
//

precision mediump float;

varying highp vec2 vRadarTexCoord;
varying highp vec2 vRadarMotionTexCoord;

uniform sampler2D radarTexture;
uniform sampler2D radarNextTexture;
uniform highp float radarTextureSize;
uniform sampler2D radarMotionTexture;
uniform sampler2D radarMotionNextTexture;
uniform sampler2D paletteTexture;

uniform highp float timeOffset;
uniform int intervalMinutes;
uniform float opacity;
uniform highp float horizontalPointPercentage;
uniform highp float verticalPointPercentage;
uniform highp float horizontalPointMotionPercentage;
uniform highp float verticalPointMotionPercentage;

const highp float kValueBackOffset = 0.0001;
const highp float kBicubicSize = 0.25;
const highp float kBicubicSizeInv = 1.0 / kBicubicSize;
const highp vec2 kHalfVec2 = vec2(0.5, 0.5);

vec4 advectionCoordinates(int stepsPerInterval,
                          float intervalFraction) { // How far back in time we must go.
    // This function works as follows:
    //
    // The storm field texture gives us a velocity for every texel in mapPoints/step. The interval
    // fraction determines what actual number of steps must be computed for proper advection.
    //
    // From that, we compute the number of steps we want to advect over.
    int totalLoops = int(stepsPerInterval > 15 ? 15 : stepsPerInterval);
    int fractionSteps = int(floor(intervalFraction * float(totalLoops)));
    float stepLength = 1.0 / float(totalLoops);
    float minutesPerLoop = float(stepsPerInterval) / float(totalLoops);
    
    // Advection is done as follows: begin with no offsets (measured in texels).
    highp vec2 backwardOffset = vec2(0,0);
    highp vec2 forwardOffset = vec2(0,0);
    
    // Then, for the backwardOffset, for each time step, we move the current pixel backwards in time
    // (hence the negative sign) by multiplying the storm field velocity at the
    // current offset by the conversion factor. We get a new offset position from that, which we
    // feed back into the loop.
    //
    // The trick we use here, though, is to make the storm field more accurate by interpolating
    // between the initial and the final storm field. This simulates the storm field changing
    // linearly between the two states, reducing the potential error.
    highp vec2 motionTexCoord = vRadarMotionTexCoord;
    for (int i = 0; i < fractionSteps; i++) {
        highp vec4 stormFieldData = texture2D(radarMotionTexture, motionTexCoord);
        highp vec4 stormFieldNextData = texture2D(radarMotionNextTexture, motionTexCoord);
        
        highp vec2 initialTextureOffsetIncrement = minutesPerLoop * vec2(stormFieldData.r * horizontalPointPercentage, stormFieldData.g * verticalPointPercentage);
        highp vec2 finalTextureOffsetIncrement = minutesPerLoop * vec2(stormFieldNextData.r * horizontalPointPercentage, stormFieldNextData.g * verticalPointPercentage);
        
        highp vec2 finalOffsetIncrement = mix(initialTextureOffsetIncrement, finalTextureOffsetIncrement, float(i) * stepLength);
        
        backwardOffset = backwardOffset - finalOffsetIncrement;
        
        highp vec2 initialMotionTextureOffsetIncrement = minutesPerLoop * vec2(stormFieldData.r * horizontalPointMotionPercentage, stormFieldData.g * verticalPointMotionPercentage);
        highp vec2 finalMotionTextureOffsetIncrement = minutesPerLoop * vec2(stormFieldNextData.r * horizontalPointMotionPercentage, stormFieldNextData.g * verticalPointMotionPercentage);
        highp vec2 finalMotionOffsetIncrement = mix(initialMotionTextureOffsetIncrement, finalMotionTextureOffsetIncrement, float(i) * stepLength);
        motionTexCoord = motionTexCoord - finalMotionOffsetIncrement;
    }
    
    // For the forwardOffset, we do the same thing, but with the remaining steps, and a positive
    // sign when accumulating the offset.
    motionTexCoord = vRadarMotionTexCoord;
    for (int i = fractionSteps; i < totalLoops; i++) {
        highp vec4 stormFieldData = texture2D(radarMotionTexture, motionTexCoord);
        highp vec4 stormFieldNextData = texture2D(radarMotionNextTexture, motionTexCoord);

        highp vec2 initialTextureOffsetIncrement = minutesPerLoop * vec2(stormFieldData.r * horizontalPointPercentage, stormFieldData.g * verticalPointPercentage);
        highp vec2 finalTextureOffsetIncrement = minutesPerLoop * vec2(stormFieldNextData.r * horizontalPointPercentage, stormFieldNextData.g * verticalPointPercentage);
        
        highp vec2 finalOffsetIncrement = mix(initialTextureOffsetIncrement, finalTextureOffsetIncrement, float(i));
        
        forwardOffset = forwardOffset + finalOffsetIncrement;
        
        highp vec2 initialMotionTextureOffsetIncrement = minutesPerLoop * vec2(stormFieldData.r * horizontalPointMotionPercentage, stormFieldData.g * verticalPointMotionPercentage);
        highp vec2 finalMotionTextureOffsetIncrement = minutesPerLoop * vec2(stormFieldNextData.r * horizontalPointMotionPercentage, stormFieldNextData.g * verticalPointMotionPercentage);
        highp vec2 finalMotionOffsetIncrement = mix(initialMotionTextureOffsetIncrement, finalMotionTextureOffsetIncrement, float(i) * stepLength);
        motionTexCoord = motionTexCoord + finalMotionOffsetIncrement;
    }
    
    // When we're done, we return the new coordinates, which are the original coordinates plus the
    // given offsets.
    return vec4(vRadarTexCoord + backwardOffset, vRadarTexCoord + forwardOffset);
}

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
	// We begin by computing the initial and final advection coordinates; the initial coordinates are
    // in the RG channels and the final coordinates are in the BA channels.
    vec4 textureCoordinates = advectionCoordinates(intervalMinutes, timeOffset);

    //vec4 initRadarAndTemp = filter(radarTexture, textureCoordinates.rg * radarTextureSize, 1.0 / radarTextureSize);
    //vec4 finalRadarAndTemp = filter(radarNextTexture, textureCoordinates.rg * radarTextureSize, 1.0 / radarTextureSize);
    
    vec4 initRadarAndTemp = texture2D(radarTexture, textureCoordinates.rg);
    vec4 finalRadarAndTemp = texture2D(radarNextTexture, textureCoordinates.ba);

    float radar = mix(initRadarAndTemp.r, finalRadarAndTemp.r, timeOffset) + (0.5 / 64.0);

    vec2 origTexCoord = vRadarTexCoord * radarTextureSize;
    vec2 exactTexCoord = floor(origTexCoord) + kHalfVec2;
    vec2 altTexCoord = floor(exactTexCoord + normalize(origTexCoord - exactTexCoord)) + kHalfVec2;
    float exactTemp = texture2D(radarTexture, exactTexCoord / radarTextureSize).g;
    float altTemp = texture2D(radarTexture, altTexCoord / radarTextureSize).g;
    exactTemp = abs(exactTemp - initRadarAndTemp.g) / abs(altTemp - exactTemp) < 0.5 ? exactTemp : altTemp;

    vec4 paletteColor = texture2D(paletteTexture, vec2(radar, 1.0 - (exactTemp + 0.5 / 4.0)));
    gl_FragColor = vec4(paletteColor.rgb, paletteColor.a * opacity);
}
