//
//  customAlertViewController.h
//  CustomAlert
//
//  Created by Shital Zope on 4/7/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomAlertViewControllerForBlueconic : UIViewController
{
    
}
@property (weak, nonatomic) IBOutlet UIView *alertBackgroiundView;
@property (weak, nonatomic) IBOutlet UILabel *tilteLabel;

@property (weak, nonatomic) IBOutlet UIImageView *bacgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *alertTopImage;
@property (weak, nonatomic) IBOutlet UILabel *topDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *subDescriptionLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backgroundViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeight;
@property (strong, nonatomic) IBOutlet UIButton *notNowButton;
@property (strong, nonatomic) IBOutlet UIButton *imInButton;

@property (nonatomic, strong) NSString *alertTitle;
@property (nonatomic, strong) NSString *alertDescription;
@property (nonatomic, strong) NSString *alertConfirmBtnText;
@property (nonatomic, strong) NSString *alertDenyBtnText;
@property (nonatomic, strong) NSString *imageBlueconicPath;
@property (nonatomic, strong) NSString * videoBlueconicPath;
- (IBAction)ImInButtonPress:(id)sender;
- (IBAction)NotNowButtonPress:(id)sender;
@end

NS_ASSUME_NONNULL_END
