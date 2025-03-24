// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoLock.h"

@implementation WSIMapDemoLock
{
    NSLock *_mutex;
}

- (id)initWithName:(NSString *)name
{
    if (self = [super init])
    {
        _mutex = [[NSLock alloc] init];
        _mutex.name = name;
    }
    return self;
}

- (void)setName:(NSString *)name
{
    [_mutex setName:name];
}

- (void)lockFrom:(const char *)methodName
{
    [_mutex lock];
}

- (BOOL)tryLockFrom:(const char *)methodName
{
    BOOL result = [_mutex tryLock];
    return result;
}

- (void)unlockFrom:(const char *)methodName
{
    [_mutex unlock];
}

@end
