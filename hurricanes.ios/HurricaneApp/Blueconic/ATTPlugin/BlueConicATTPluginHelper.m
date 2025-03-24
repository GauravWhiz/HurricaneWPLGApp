//
//  BlueconicHelper.m
//  Newsreader
//
//  Created by Bhavya on 22/06/21.
//  Copyright © 2021 Graham Media Group. All rights reserved.
//

#import "BlueConicATTPluginHelper.h"
#import "BlueconicHelper.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface BlueconicATTPluginHelper()
{
   
}
@end

@implementation BlueconicATTPluginHelper

+(void)setUpATTPlugin:(BlueConic *)client
{
    if (@available(iOS 14, *)) {
        NSString *property_att_demonews = [BlueconicHelper getBlueconicProfileValue:client forProperty:[AppDefaults getBlueconicPropertyName]];

    if ([self isATTStatusUndetermined] || [self isATTStatusRestricted]) {
       
        if(!property_att_demonews || [property_att_demonews isEqual:@""]) {// if user is new
            [BlueconicHelper setBlueconicProfileValue:@"--" forBlueconicClient:client forProperty:[AppDefaults getBlueconicPropertyName]];
        }
    } else {
        if([self isATTStatusUpdated])
        {
            if ([self isATTStatusAuthorized]) // if user changed the ATT preferences from dilaogue settings. Ex - opted in recently but now opted out or vice-versa
            {
                [BlueconicHelper setBlueconicProfileValue:@"AY" forBlueconicClient:client forProperty:[AppDefaults getBlueconicPropertyName]];
            }
            else if([self isATTStatusDenied])
            {
                [BlueconicHelper setBlueconicProfileValue:@"AN" forBlueconicClient:client forProperty:[AppDefaults getBlueconicPropertyName]];
            }
        }
    }
  }
}


+(BOOL)isATTStatusUndetermined
{
    if (@available(iOS 14, *)) {
          ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];
          if (status == ATTrackingManagerAuthorizationStatusNotDetermined) {
              return true;
          }
      }
    return false;
}

/*
 A restricted condition means the device does not prompt for tracking authorization when requestTrackingAuthorizationWithCompletionHandler: is called, nor is it displayed when the NSUserTrackingUsageDescription is triggered. Also, on restricted devices, Allow Apps To Request To Track setting is disabled and cannot be changed. This setting allows users to opt in or out of allowing apps to request user consent to access app-related data that can be used for tracking the user or the device.
 */
+(BOOL)isATTStatusRestricted
{
    if (@available(iOS 14, *)) {
          ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];
          if (status == ATTrackingManagerAuthorizationStatusRestricted) {
              return true;
          }
      }
    return false;
}

+(BOOL)isATTStatusDenied
{
    if (@available(iOS 14, *)) {
          ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];
          if (status == ATTrackingManagerAuthorizationStatusDenied) {
              return true;
          }
      }
    return false;
}

+(BOOL)isATTStatusAuthorized
{
    if (@available(iOS 14, *)) {
          ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];
          if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
              return true;
          }
      }
    return false;
}


+(BOOL)IsDialogDisplayedToUserForBlueconicClient:(BlueConic *)client forProperty:(NSString *)profilePropertyId
{
    NSString* property_att_news = [BlueconicHelper getBlueconicProfileValue:client forProperty:profilePropertyId];
    if(property_att_news && ([property_att_news compare:@"n-"] == NSOrderedSame || [property_att_news compare:@"yy"] == NSOrderedSame || [property_att_news compare:@"yn"] == NSOrderedSame))
        return YES;
    return NO;
}


+(void)setATTPermissionFromUserDefaults:(NSInteger)status
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:[NSNumber numberWithInteger:status] forKey:@"attTrackingStatus"];
    [standardDefaults synchronize];
}

+(NSInteger)getOldATTPermissionFromUserDefaults
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *attTrackingStatus = [standardDefaults objectForKey:@"attTrackingStatus"];
    if(attTrackingStatus != nil)
        return attTrackingStatus.integerValue;
    
    return -1;
}


// It checks if user has updated ATT permission status from device settings
+(BOOL)isATTStatusUpdated
{
    if (@available(iOS 14, *)) {
    
        if([self getOldATTPermissionFromUserDefaults] != [ATTrackingManager trackingAuthorizationStatus])
        {
            [self setATTPermissionFromUserDefaults:[ATTrackingManager trackingAuthorizationStatus]];
            return YES;
        }
    }
    return NO;
}

@end
