// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

@interface WSIMapDemoLock : NSObject

- (id)initWithName:(NSString *)name;
- (void)setName:(NSString *)name;
- (void)lockFrom:(const char *)methodName;
- (BOOL)tryLockFrom:(const char *)methodName;
- (void)unlockFrom:(const char *)methodName;

@end
