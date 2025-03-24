#pragma once

#import <Foundation/Foundation.h>

@class ParticleSystem;

@interface MapGraphicsEx : NSObject

- (id)init;

- (void)pause;
- (void)resume;

- (void)drawParticles:(ParticleSystem *)particles inViewport:(CGSize)viewport cameraLat:(double)lat cameraLon:(double)lon cameraZoom:(double)zoom layerOpacity:(float)opacity;

- (ParticleSystem *)createParticleSystemWithXML:(char const *)xmlSource;
@end
