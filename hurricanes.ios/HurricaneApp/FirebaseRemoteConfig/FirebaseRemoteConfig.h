//
//  FirebaseRemoteConfig.h
//  Sierra
//
//  Created by Gaurav Purohit on 5/26/22.
//  Copyright © 2022 Graham Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;

NS_ASSUME_NONNULL_BEGIN

@protocol FirebaseRemoteConfigDelegate <NSObject>
- (void)configDownloadComplete;
@end

@interface FirebaseRemoteConfig : NSObject
@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;
@property (nonatomic, weak) id<FirebaseRemoteConfigDelegate>  delegate;

+(FirebaseRemoteConfig *)sharedInstance;
-(void)initSetup;
-(id)lookupConfigByKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
