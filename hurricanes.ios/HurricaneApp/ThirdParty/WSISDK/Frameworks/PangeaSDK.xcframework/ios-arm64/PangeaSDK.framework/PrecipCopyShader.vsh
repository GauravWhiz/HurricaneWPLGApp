//
//  PrecipCopyShader.vsh
//  PangeaSDK
//
//  Created by Dayle Flowers on 12/7/15.
//  Copyright © 2015 TWC. All rights reserved.
//

attribute highp vec4 position;
attribute highp vec2 texCoord;

varying highp vec2 vTexCoord;

void main() {
    vTexCoord = texCoord;
    gl_Position = position;
}
