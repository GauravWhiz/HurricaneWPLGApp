// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoSingleton.h"

static NSMutableDictionary *_instances = nil;
    
@implementation WSIMapDemoSingleton

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instances = [[NSMutableDictionary alloc] init];
    });
    
    @synchronized(_instances)
    {
        NSString *instanceKey = NSStringFromClass(self);
        id instance = [_instances objectForKey:instanceKey];
        if (!instance)
        {
            instance = [[super allocWithZone:nil] init];
            [_instances setObject:instance forKey:instanceKey];
        }
        return instance;
    }
}

+ (instancetype)allocWithZone:(NSZone *)zone
{
	#ifndef __clang_analyzer__
    return [self sharedInstance];
	#endif
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
