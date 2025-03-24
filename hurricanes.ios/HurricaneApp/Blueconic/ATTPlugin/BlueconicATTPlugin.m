//
//  BlueconiciOSPlugin.m
//  Newsreader
//
//  Created by Bhavya on 23/03/21.
//  Copyright © 2021 Graham Media Group. All rights reserved.
//

#import "BlueconicATTPlugin.h"
#import "CustomAlertViewControllerForBlueconic.h"
#import "BlueconicHelper.h"
#import "BlueConicATTPluginHelper.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
//#import "AppDelegate.h"


@interface BlueconicATTPlugin ()

@property BlueConic* _client;
@property InteractionContext* _context;
@property LandingPageViewController *rootViewController;

@end

@implementation BlueconicATTPlugin

- (instancetype) initWithClient: (BlueConic *)client context:(InteractionContext *)context {
    self = [super init];
    if (self) {
        self._client = client;
        self._context = context;
    }
    return self;
}

- (NSString *) getValueFromParameters: (NSString *)key {
    NSDictionary* parameters = [self._context getParameters];
    NSArray* values = [parameters objectForKey:key];
    if (values != nil && values.count > 0) {
      return values[0];
    }
    return @"";
}


- (void) onLoad
{
    [self displayAlert];
}

- (void) displayAlert {
    
    NSString *title = [self getValueFromParameters:@"title"];
    NSString *description = [self getValueFromParameters:@"description"];
    NSString *videoPath = [self getValueFromParameters:@"video"];
    NSString *imagePath = [self getValueFromParameters:@"image"];
    NSString *confirmBtnText = [self getValueFromParameters:@"confirmBtn"];
    NSString *denyBtnText = [self getValueFromParameters:@"denyBtn"];
    
    if((confirmBtnText != nil && [confirmBtnText isEqual: @""]) || (denyBtnText != nil && [denyBtnText  isEqual: @""])) {
        if (@available(iOS 14, *)) {
            if ([BlueconicATTPluginHelper isATTStatusUndetermined] || [BlueconicATTPluginHelper isATTStatusRestricted]) {
                [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                    // Tracking authorization completed. Start loading ads here.
                    
                    [BlueconicATTPluginHelper setATTPermissionFromUserDefaults:status];
                    if(status == ATTrackingManagerAuthorizationStatusAuthorized){
                       NSUUID *idfa = [[ASIdentifierManager sharedManager] advertisingIdentifier];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self._client setMobileAdId: [idfa UUIDString]];
                            
                            [BlueconicHelper setBlueconicProfileValue:@"-Y" forBlueconicClient:self._client forProperty:[AppDefaults getBlueconicPropertyName]];

                        });
                    }
                    else if(status == ATTrackingManagerAuthorizationStatusDenied)
                    {
                        [BlueconicHelper setBlueconicProfileValue:@"-N" forBlueconicClient:self._client forProperty:[AppDefaults getBlueconicPropertyName]];

                    }
                }];
            }
        }
    } else {
        [self displayBlueconicDialogue:title description:description imagePath:imagePath videoPath:videoPath confirmBtnText:confirmBtnText DenyBtnText:denyBtnText];
    }
}

-(void)displayBlueconicDialogue:(NSString *)title description:(NSString *)description imagePath:(NSString *)imagePath  videoPath:(NSString *)videoPath confirmBtnText:(NSString *)confirm DenyBtnText:(NSString *)deny
{
    // Way 0. The custom alert design. It is latest too.
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if(!appDelegate.isBlueConicDialogVisible && [AppDefaults getBlueconicDialogStatus])
    {
        appDelegate.isBlueConicDialogVisible = YES;
        UIViewController *childViewController;
        CustomAlertViewControllerForBlueconic* alertViewController = [[CustomAlertViewControllerForBlueconic alloc] initWithNibName:@"CustomAlertViewController" bundle:nil];
        alertViewController.alertTitle = title;
        alertViewController.alertDescription = description;
        alertViewController.imageBlueconicPath = imagePath;
        alertViewController.videoBlueconicPath = videoPath;
        alertViewController.alertConfirmBtnText = confirm;
        alertViewController.alertDenyBtnText = deny;
        childViewController = alertViewController;
        childViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [topController addChildViewController:childViewController];
        [topController.view addSubview:childViewController.view];
        [childViewController didMoveToParentViewController:topController];
    }
}

- (void) onDestroy
{
    
}
@end

