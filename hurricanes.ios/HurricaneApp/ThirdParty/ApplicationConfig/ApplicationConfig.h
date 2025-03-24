//
//  ApplicationConfig.h
//  ApplicationConfig
//
//  Created by Sachin Ahuja on 3/4/14.
//  Copyright (c) 2014 PNSDigital. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRemoteConfig @"config.json"

@protocol ApplicationConfigDelegate <NSObject>
- (void)configDownloadComplete;
@end

@interface ApplicationConfig : UIViewController
@property (nonatomic, weak) id<ApplicationConfigDelegate>  delegate;
+ (ApplicationConfig *)sharedInstance;
- (void) downloadRemoteConfig;
- (void) setDefaultForKey:(NSString *)key withValue:(NSString *)value;
- (void)forceUpdate:(NSString *)font withTitleFont:(NSString *)titleFont bgColor:(UIColor *)bgColor headerColor:(UIColor *)headerColor textColor:(UIColor *)textColor buttonBGColor:(UIColor *)buttonBGColor buttonFont:(NSString *)buttonFont;
-(id) lookupConfigByKey:(NSString *)key;
- (NSDictionary *) getConfigData;
- (BOOL)needsUpdate;
- (void)setUpdateButtonTextColor:(UIColor *)updateButtonTextColor;
- (void)setTextFontSize:(float)textFontSize;
- (void)setHeaderFontSize:(float)headerFontSize;
-(BOOL)isRemoteConfigInCache;
-(BOOL)isRemoteConfigUpdating;
-(void)deleteCachedData;

@end
