// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#pragma mark - sample code showing how to change layer legend font color and font

#import "WSIMapDemoExamples.h"

@implementation WSIMapDemoExamples

#if DEMO_LEGEND_FONT_CHANGE
/*
 Recursively process all subviews of the given view and (in this example),
 set any labels to use red text.
 You would call this method any time
 Note that as-of 3.0.0, apps have full control over legends (see 
 */
+ (void)processLabelsInSubViewsOfView:(UIView *)view
{
    for (UIView *subView in view.subviews)
    {
        if ([subView isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)subView;
            label.textColor = [UIColor redColor];
            label.font = [UIFont fontWithName:@"Chalkduster" size:8];
        }
        [self processLabelsInSubViewsOfView:subView];
    }
}
#endif

+ (void)adjustAttributionOffsets:(WSIMapSDK *)wsiMapSDK offsetType:(WMDMapboxOffsetType)offsetType
{
    if (offsetType == WMDMapboxOffsetTypeNone)
    {
        return; // don't show
    }

    static const CGFloat kAttributeBorder   = 10.0f;
    static const CGFloat kLogoButtonGap     =  5.0f;

    CGRect buttonFrame = [wsiMapSDK getMapboxButtonFrame];
    CGRect logoFrame = [wsiMapSDK getMapboxLogoFrame];
    CGRect viewFrame = [UIScreen mainScreen].bounds;
    CGFloat buttonHeight = buttonFrame.size.height;
    CGFloat buttonWidth = buttonFrame.size.width;
    //CGFloat logoHeight = logoFrame.size.height;
    CGFloat logoWidth = logoFrame.size.width;
    CGFloat viewHeight = viewFrame.size.height;
    CGFloat viewWidth = viewFrame.size.width;

    CGFloat buttonOffsetX   = 0.0;
    CGFloat buttonOffsetY   = 0.0;
    CGFloat logoOffsetX     = 0.0;
    CGFloat logoOffsetY     = 0.0;
    
    if (offsetType == WMDMapboxOffsetTypeTop)
    {
        // button upper left, logo upper right
        buttonOffsetX       = viewWidth - buttonWidth - kAttributeBorder;
        buttonOffsetY       = kAttributeBorder;
        logoOffsetX         = kAttributeBorder;
        logoOffsetY         = kAttributeBorder;
    }
    else if (offsetType == WMDMapboxOffsetTypeTopLeft)
    {
        // button upper left, logo to right of that
        buttonOffsetX       = viewWidth - buttonWidth - kAttributeBorder;
        buttonOffsetY       = kAttributeBorder;
        logoOffsetX         = buttonOffsetX - logoWidth - kLogoButtonGap;
        logoOffsetY         = kAttributeBorder;
    }
    else if (offsetType == WMDMapboxOffsetTypeTopRight)
    {
        // logo upper right, button to left of that
        logoOffsetX         = kAttributeBorder;
        logoOffsetY         = kAttributeBorder;
        buttonOffsetX       = logoOffsetX + logoWidth + kLogoButtonGap;
        buttonOffsetY       = kAttributeBorder;
    }
    else if (offsetType == WMDMapboxOffsetTypeBottomRight)
    {
        // button lower right, logo to right of that
        buttonOffsetX       = viewWidth - buttonWidth - kAttributeBorder;
        buttonOffsetY       = viewHeight - buttonHeight - kAttributeBorder;
        logoOffsetX         = buttonOffsetX - logoWidth - kLogoButtonGap;
        logoOffsetY         = buttonOffsetY;
    }
    
    [wsiMapSDK setMapboxButtonOffset:
                   CGPointMake(buttonOffsetX, buttonOffsetY)
                   logoOffset:CGPointMake(logoOffsetX, logoOffsetY)];
}


@end
