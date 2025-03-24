// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoSettings.h"
#import "WSIMapDemoConstants.h"

@implementation WSIMapDemoSettings
{
    BOOL _debugCallouts;
}


- (instancetype)init
{
    if (self = [super init])
    {
        _debugCallouts = NO;
    }
    
    return self;
}


- (BOOL)getDebugCallouts
{
    return _debugCallouts;
}


- (void)setDebugCallouts:(BOOL)val
{
    if (_debugCallouts != val)
    {
        _debugCallouts = val;
        [[NSNotificationCenter defaultCenter] postNotificationName:gSDKDemoDebugCalloutsChangedNotification object:nil];
    }
}

@end
