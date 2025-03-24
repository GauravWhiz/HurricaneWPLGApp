//
//  PrecipCombineShader.fsh
//  PangeaSDK
//
//  Created by Dayle Flowers on 12/7/15.
//  Copyright © 2015 TWC. All rights reserved.
//

precision mediump float;

varying highp vec2 vTexCoord;

uniform sampler2D prevTileTexture;
uniform sampler2D nextTileTexture;

void main() {
    vec4 prevColor = texture2D(prevTileTexture, vTexCoord);
    vec4 nextColor = texture2D(nextTileTexture, vTexCoord);
    gl_FragColor = vec4(prevColor.rg, nextColor.rg);
}