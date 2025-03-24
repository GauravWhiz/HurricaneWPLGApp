#import <Foundation/Foundation.h>
#import <BlueConicClient/BlueConicClient-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlueconicATTPluginHelper : NSObject
{
    
}

+(void)setUpATTPlugin:(BlueConic *)client;
+(BOOL)isATTStatusUndetermined;
+(BOOL)isATTStatusRestricted;
+(BOOL)isATTStatusDenied;
+(BOOL)isATTStatusAuthorized;
+(void)setATTPermissionFromUserDefaults:(NSInteger)status;
+(NSInteger)getOldATTPermissionFromUserDefaults;
+(BOOL)isATTStatusUpdated;


@end

NS_ASSUME_NONNULL_END
