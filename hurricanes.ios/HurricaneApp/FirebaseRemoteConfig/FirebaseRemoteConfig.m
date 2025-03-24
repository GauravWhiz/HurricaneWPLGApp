//
//  FirebaseRemoteConfig.m
//  Sierra
//
//  Created by Gaurav Purohit on 5/26/22.
//  Copyright © 2022 Graham Digital. All rights reserved.
//

#import "FirebaseRemoteConfig.h"
#import "ApplicationConfig.h"

@implementation FirebaseRemoteConfig

+(FirebaseRemoteConfig *)sharedInstance {
    static dispatch_once_t pred;
    static FirebaseRemoteConfig *sharedInstance = nil;
    
    dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

-(void)initSetup {
    NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName]){
        
        self.remoteConfig = [FIRRemoteConfig remoteConfig];
        FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] init];
        remoteConfigSettings.minimumFetchInterval = 0;
        remoteConfigSettings.fetchTimeout = 300;
        
        self.remoteConfig.configSettings = remoteConfigSettings;
       
        [self fetchRemoteConfig];
        [self.remoteConfig setDefaults:[self getLocalConfigData]];

    }
}

- (void)fetchRemoteConfig {
    long expirationDuration = 3600;
    [self.remoteConfig fetchWithExpirationDuration:expirationDuration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            
            [self.remoteConfig activateWithCompletion:^(BOOL changed, NSError * _Nullable error) {

                if (error == nil) {
                    [self.delegate configDownloadComplete];
                }
            }];
        } else {
            NSLog(@"Config not fetched");
            NSLog(@"Error %@", error.localizedDescription);
        }
    }];
}

-(id)lookupConfigByKey:(NSString *)key{
    NSArray *remoteConfigKeyArray = [self.remoteConfig allKeysFromSource:FIRRemoteConfigSourceRemote];
    NSArray *localConfigKeyArray = [self.remoteConfig allKeysFromSource:FIRRemoteConfigSourceDefault];
    if ([remoteConfigKeyArray containsObject:key] ||
        [localConfigKeyArray containsObject:key]){
        FIRRemoteConfigValue *configValue = [self.remoteConfig configValueForKey:key];
        if (configValue.JSONValue){
            return configValue.JSONValue;
        }else if (configValue.stringValue && configValue.stringValue.length){
            return [self getObjCString:configValue.stringValue];
        }else if (configValue.numberValue){
            if ([configValue.numberValue intValue] == 0){
                return [[ApplicationConfig sharedInstance] lookupConfigByKey:key];
            }else{
                return configValue.numberValue;
            }
        }else if (configValue.boolValue){
            return [NSNumber numberWithBool:configValue.boolValue];
        }
    }else{
        return [[ApplicationConfig sharedInstance] lookupConfigByKey:key];
    }
    
    return nil;
}

- (NSDictionary *)getLocalConfigData {
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"json"];
    if(configPath){
        NSString *configAsString = [[NSString alloc] initWithContentsOfFile:configPath encoding:NSUTF8StringEncoding error:NULL];
        NSError *error;
        NSDictionary *configData = [NSJSONSerialization JSONObjectWithData:[configAsString dataUsingEncoding:
                                                                            NSUTF8StringEncoding] options:kNilOptions error:&error];
        
        return configData;
    }
    return nil;
}

-(NSString *)getObjCString:(NSString *)str{
    if ([str containsString:@"\""]){
        str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return str;
}

@end
