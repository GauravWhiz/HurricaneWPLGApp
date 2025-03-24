#pragma once

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define DEPRECATED_IN_1_0_8(REASON) __attribute__((deprecated(REASON)))

typedef double pangea_float_t;

///
typedef NS_ENUM(NSInteger, PRColorSource) {
  PRColorSourceNone = 0,        ///<
  PRColorSourceProgress = 1,    ///<
  PRColorSourceTemperature = 2, ///<
  PRColorSourceSpeed = 3,       ///<
};

typedef NS_ENUM(NSInteger, PRWindFormat) {
  PRWindFormatUVTemperature = 0,
  PRWindFormatSpeedDirectionTemperature = 1,
};

@interface ParticleSystem : NSObject
- (void)setSprite:(UIImage *)image;

/** */
- (bool)isColorSupported;

/** */
- (void)setPalette:(UIImage const *)image;

/** */
- (void)setColor:(UIColor const *)color;

/** */
- (void)mixColorsWithRedWeight:(pangea_float_t const)red
                   greenWeight:(pangea_float_t const)green
                    blueWeight:(pangea_float_t const)blue
                   alphaWeight:(pangea_float_t const)alpha;

/** */
- (void)setColorSource:(PRColorSource const)value;

/** */
- (bool)isMovementSupported;

/** */
- (void)setSpeedRangeFrom:(pangea_float_t)minSpeed to:(pangea_float_t)maxSpeed;

- (void)setDurationScale:(pangea_float_t)scaleFactor;

- (void)setExtent:(CGSize)size;

- (void)toggle:(bool)enabled;

- (void)setDataWithFormat:(PRWindFormat)format
                     data:(float const *)data
                dataWidth:(size_t)width
               dataHeight:(size_t)height
           dataBoundsWest:(double)west
          dataBoundsSouth:(double)south
           dataBoundsEast:(double)east
          dataBoundsNorth:(double)north;

- (void)enableClipping:(bool)enabled;
- (void)setClipRegion:(pangea_float_t)minLon minLat:(pangea_float_t)minLat maxLon:(pangea_float_t)maxLon maxLat:(pangea_float_t)maxLat;

- (void)enableUvDebugging:(bool)enabled;

- (void)setMaxDuration:(pangea_float_t)seconds;
- (pangea_float_t)getMaxDuration;

- (void)setFadeInStart:(pangea_float_t)start stop:(pangea_float_t)stop;
- (void)setFadeOutStart:(pangea_float_t)start stop:(pangea_float_t)stop;

- (void)setMaxParticleCount:(size_t)numParticles;
- (size_t)getMaxParticleCount;

- (void)setEmissionRate:(pangea_float_t)particlesPerSecond;
- (pangea_float_t)getEmissionRate;

- (pangea_float_t)getTailLength;
- (void)setTailLength:(pangea_float_t)value;

- (pangea_float_t)getTailSpringConstant;
- (void)setTailSpringConstant:(pangea_float_t)value;

@end
