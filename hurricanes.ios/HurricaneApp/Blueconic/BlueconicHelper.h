//
//  BlueconicHelper.h
//  Newsreader
//
//  Created by Bhavya on 22/06/21.
//  Copyright © 2021 Graham Media Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BlueConicClient/BlueConicClient-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlueconicHelper : NSObject
{
    
}

+(void)createBlueconicEvent:(id)currentViewController forPageView:(NSString *)screenName;
+(BlueConic *)getBlueconicClient:(id)currentViewController;
+(NSString *)getBlueconicProfileValue:(BlueConic *)client forProperty:(NSString *)profilePropertyId;
+(void)setBlueconicProfileValue:(NSString *)profileValue forBlueconicClient:(BlueConic *)client forProperty:(NSString *)profilePropertyId;

@end

NS_ASSUME_NONNULL_END
