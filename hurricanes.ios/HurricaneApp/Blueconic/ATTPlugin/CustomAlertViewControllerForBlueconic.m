//
//  customAlertViewController.m
//  CustomAlert
//
//  Created by Shital Zope on 4/7/21.
//

#import "CustomAlertViewControllerForBlueconic.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import <BlueConicClient/BlueConicClient-Swift.h>
#import "BlueconicHelper.h"
#import "BlueConicATTPluginHelper.h"
#import <AVKit/AVKit.h>
@interface CustomAlertViewControllerForBlueconic ()
@property BlueConic *client;
@property AVPlayerViewController *playerViewController;

@end

@implementation CustomAlertViewControllerForBlueconic
- (void)viewDidLoad {
    [super viewDidLoad];

    self.alertBackgroiundView.layer.cornerRadius = 30;
    self.alertBackgroiundView.layer.masksToBounds = true;
    
    if(!self.alertTitle)
        self.alertTitle = @"";
    
    if(!self.alertDescription)
        self.alertDescription = @"";
    
    if(!self.alertConfirmBtnText)
        self.alertConfirmBtnText = @"";
    
    if(!self.alertDenyBtnText)
        self.alertDenyBtnText = @"";
    
    self.tilteLabel.text = self.alertTitle;
    self.topDescriptionLabel.text = [self.alertDescription stringByReplacingOccurrencesOfString:@"." withString:@".\n"];
    [self.imInButton setTitle:self.alertConfirmBtnText forState:UIControlStateNormal];
    [self.notNowButton setTitle:self.alertDenyBtnText forState:UIControlStateNormal];

    
    NSString * videoUrl = self.videoBlueconicPath;
    videoUrl = [videoUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *path = self.imageBlueconicPath;
    NSURL *url = [NSURL URLWithString:path];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *alertImage = [UIImage imageWithData:data];
    
    CGFloat imageHeight = self.imageViewHeight.constant;
    if(imageHeight <= 0)
        imageHeight = 70;
    if(videoUrl != nil && ![videoUrl  isEqual: @""])
    {
        
        CGFloat videoWidth = self.alertBackgroiundView.frame.size.width;
        CGFloat videoHeight = videoWidth/1.7777;
        if(videoHeight <= 0)
            videoHeight = 169; // 300/169 = 1.777 ie = 16:9
        
        self.imageViewHeight.constant = videoHeight;
        self.backgroundViewHeight.constant =  self.alertBackgroiundView.frame.size.height + (videoHeight - imageHeight);
        [self videoPlayerSetup:videoUrl];
    }
    else if(alertImage != nil)
    {
        self.alertTopImage.image = alertImage;
    }
    else
    {
        self.imageViewHeight.constant = 0;
        self.backgroundViewHeight.constant =  self.alertBackgroiundView.frame.size.height - imageHeight;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}
-(void)appEnterForeground
{
    if(self.playerViewController != nil)
        [self.playerViewController.player play];
}
- (void)viewDidDisappear:(BOOL)animated
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isBlueConicDialogVisible = NO; 
}
-(void)videoPlayerSetup : (NSString *) urlStr
{
    NSURL *videoUrl = [NSURL URLWithString:urlStr];
    self.alertTopImage.userInteractionEnabled  = YES;
    AVPlayer *player = [AVPlayer playerWithURL:videoUrl];
    self.playerViewController = [AVPlayerViewController new];
    self.playerViewController.showsPlaybackControls = false;
    [player pause];
    [player play];
    self.playerViewController.player = player;
    [self addChildViewController: self.playerViewController];
    self.playerViewController.view.frame = self.alertTopImage.bounds;
    [self.alertTopImage addSubview: self.playerViewController.view];
    [self.playerViewController.player play];//Used to Play On start
}

- (IBAction)NotNowButtonPress:(id)sender {
    [self dissmissView];
    
    if(!self.client)
        self.client = [BlueConic getInstance:self];
    
    [BlueconicHelper setBlueconicProfileValue:@"n-" forBlueconicClient:self.client forProperty:[AppDefaults getBlueconicPropertyName]];
}

- (IBAction)ImInButtonPress:(id)sender
{
    [self dissmissView];

    //[BlueconicHelper setBlueconicProfileValue:@"y-" forBlueconicClient:self.client forProperty:kPROPERTY_ATT_NEWS];// this case is not possible. Because after opting in via blueconic dialog, user must will see att dialog and hence user can't dismiss att dialog without opting in/out.

    
    if (@available(iOS 14, *)) {
        if ([BlueconicATTPluginHelper isATTStatusUndetermined] || [BlueconicATTPluginHelper isATTStatusRestricted]) {
                [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                    // Tracking authorization completed. Start loading ads here.
                    
                    // Get the BlueConic instance
                    if(!self.client)
                        self.client = [BlueConic getInstance:self];
                    [BlueconicATTPluginHelper setATTPermissionFromUserDefaults:status];
                    if(status == ATTrackingManagerAuthorizationStatusAuthorized){
                       NSUUID *idfa = [[ASIdentifierManager sharedManager] advertisingIdentifier];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self.client setMobileAdId: [idfa UUIDString]];
                            
                            [BlueconicHelper setBlueconicProfileValue:@"yy" forBlueconicClient:self.client forProperty:[AppDefaults getBlueconicPropertyName]];

                        });
                    }
                    else if(status == ATTrackingManagerAuthorizationStatusDenied)
                    {
                        [BlueconicHelper setBlueconicProfileValue:@"yn" forBlueconicClient:self.client forProperty:[AppDefaults getBlueconicPropertyName]];

                    }
                }];
            }
        
    } else {
        // Fallback on earlier versions. Don't do anything.
    }
}

-(void)dissmissView
{
    [self removePlayer];
    [self.view removeFromSuperview];
    [self removeFromParentViewController ];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isBlueConicDialogVisible = NO; 
}


-(void)removePlayer
{
    [self.playerViewController.player pause];
    self.playerViewController.player = nil;
    [self.playerViewController.view removeFromSuperview];
    [self.playerViewController removeFromParentViewController];
    self.playerViewController = nil;
}

@end
