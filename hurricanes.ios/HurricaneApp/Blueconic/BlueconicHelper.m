//
//  BlueconicHelper.m
//  Newsreader
//
//  Created by Bhavya on 22/06/21.
//  Copyright © 2021 Graham Media Group. All rights reserved.
//

#import "BlueconicHelper.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface BlueconicHelper()
{
   
}
@property BlueConic *client;

@end

@implementation BlueconicHelper

+(void)createBlueconicEvent:(id)currentViewController forPageView:(NSString *)screenName
{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(currentViewController)
            {
                BlueConic *blueconicClient = [BlueConic getInstance:currentViewController];
                [blueconicClient createEvent:@"PAGEVIEW" properties:@{@"screenName": screenName} completion:^
                     {
                   
                }];
            }
        });
}

+(BlueConic *)getBlueconicClient:(id)currentViewController
{
    if(currentViewController)
    {
        BlueConic *blueconicClient = [BlueConic getInstance:currentViewController];
        return blueconicClient;
    }
    return nil;
}

+(NSString *)getBlueconicProfileValue:(BlueConic *)client forProperty:(NSString *)profilePropertyId
{
    if(client != nil && profilePropertyId != nil && [profilePropertyId compare:@""] != NSOrderedSame)
    {
        NSString* property_att_news = [client getProfileValue:profilePropertyId];
        return property_att_news;
    }
    return nil;;
}

+(void)setBlueconicProfileValue:(NSString *)profileValue forBlueconicClient:(BlueConic *)client forProperty:(NSString *)profilePropertyId
{
    // Why do we have a helper function for what is a 1 line thing? addProfileValue and setProfileValue are 2 different operations. For the att_* values, we always want to use set* not add*. We only use add when we want to maintain the history of the values over times (in an array in BlueConic. This is not the case for the att_* values.

            [client setProfileValue:profilePropertyId value:profileValue];
    
}

@end
