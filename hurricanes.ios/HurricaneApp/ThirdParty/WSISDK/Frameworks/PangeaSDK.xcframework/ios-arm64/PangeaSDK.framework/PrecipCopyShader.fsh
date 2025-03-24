//
//  PrecipCopyShader.fsh
//  PangeaSDK
//
//  Created by Dayle Flowers on 12/7/15.
//  Copyright © 2015 TWC. All rights reserved.
//

precision mediump float;

varying highp vec2 vTexCoord;

uniform sampler2D texture;

void main() {
    vec4 copyColor = texture2D(texture, vTexCoord);
    copyColor.b = copyColor.r;
    copyColor.a = copyColor.g;
    copyColor.r = 0.0;
    copyColor.g = 0.0;
    
    gl_FragColor = copyColor;
}