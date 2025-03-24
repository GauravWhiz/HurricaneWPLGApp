//
//  RadarDrawShader.vsh
//  LightSky
//
//  Created by Roman Borovyk on 11/18/13.
//  Copyright (c) 2013 Radius. All rights reserved.
//

attribute highp vec4 position;
attribute highp vec2 radarTexCoord;
attribute highp vec2 radarMotionTexCoord;

varying highp vec2 vRadarTexCoord;
varying highp vec2 vRadarMotionTexCoord;

void main() {
    vRadarTexCoord = radarTexCoord;
    vRadarMotionTexCoord = radarMotionTexCoord;
    gl_Position = position;
}
