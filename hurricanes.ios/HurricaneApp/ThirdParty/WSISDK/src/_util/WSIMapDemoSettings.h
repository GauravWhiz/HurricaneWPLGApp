// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoSingleton.h"

@interface WSIMapDemoSettings : WSIMapDemoSingleton
- (BOOL)getDebugCallouts;
- (void)setDebugCallouts:(BOOL)val;
@end
