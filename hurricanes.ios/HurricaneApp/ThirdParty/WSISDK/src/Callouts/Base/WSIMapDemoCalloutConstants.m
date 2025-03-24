// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoCalloutConstants.h"
#import "WSIMapDemoSettings.h"
#import "WSIMapDemoUtil.h"

CGFloat const gSDKDemoCalloutTitleMarginX                               = 5.0;
CGFloat const gSDKDemoCalloutContainerMaxHeightPhonePortrait            = 200.0;
CGFloat const gSDKDemoCalloutCellWidthPhonePortraitBasic                = 160.0f;
CGFloat const gSDKDemoCalloutCellWidthPhonePortraitDebug                = 215.0f;
CGFloat const gSDKDemoCalloutLabelWidthLeftPhonePortrait                = 60.0;
CGFloat const gSDKDemoCalloutContainerMaxHeightPhoneLandscape           = 200.0;
CGFloat const gSDKDemoCalloutCellWidthPhoneLandscape                    = 215.0f;
CGFloat const gSDKDemoCalloutLabelWidthLeftPhoneLandscape               = 60.0;

CGFloat const gSDKDemoCalloutContainerMaxHeightTabletPortraitBasic      = 600.0;
CGFloat const gSDKDemoCalloutContainerMaxHeightTabletPortraitDebug      = 700.0;
CGFloat const gSDKDemoCalloutCellWidthTabletPortraitBasic               = 280.0f;
CGFloat const gSDKDemoCalloutCellWidthTabletPortraitDebug               = 360.0f;
CGFloat const gSDKDemoCalloutLabelWidthLeftTabletPortrait               = 80.0;
CGFloat const gSDKDemoCalloutCellWidthTabletLandscape                   = 360.0f;
CGFloat const gSDKDemoCalloutLabelWidthLeftTabletLandscape              = 80.0;
CGFloat const gSDKDemoCalloutContainerMaxHeightTabletLandscapeBasic     = 400.0;
CGFloat const gSDKDemoCalloutContainerMaxHeightTabletLandscapeDebug     = 700.0;

CGFloat const gSDKDemoCalloutHeaderFontSizePhone                        = 14.0f;
CGFloat const gSDKDemoCalloutHeaderFontSizeTablet                       = 15.0f;
CGFloat const gSDKDemoCalloutLabelFontSizePhone                         = 10.0;
CGFloat const gSDKDemoCalloutLabelFontSizeTablet                        = 13.0;
CGFloat const gSDKDemoCalloutLabelFontSizeMinimum                       =  0.7;
CGFloat const gSDKDemoCalloutTextSectionFontSizePhone                   = 10.0f;
CGFloat const gSDKDemoCalloutTextSectionFontSizeTablet                  = 12.0f;
        
CGFloat const gSDKDemoCalloutBottomAlignment                            = 15.0f;
CGFloat const gSDKDemoCalloutIconWidth                                  = 44.0f;
CGFloat const gSDKDemoCalloutIconHeight                                 = 44.0f;
CGFloat const gSDKDemoCalloutTableAlignment                             = 2.0f;
CGFloat const gSDKDemoCalloutTitleHeight                                = 25.0f;
        
CGFloat const gSDKDemoCalloutCellMarginX                                = 5.0f;
CGFloat const gSDKDemoCalloutCellMarginY                                = 5.0f;
        
NSString * const gSDKDemoCloseCalloutNotification                       = @"SDKDemoCloseCalloutNotification";
NSString * const gSDKDemoLayersChangedNotification                      = @"SDKDemoLayersChangedNotification";

@implementation WSIMapDemoSizes : NSObject

+ (BOOL)isPortrait
{
    return [WSIMapDemoUtil deviceOrientationIsPortrait];
}

+ (CGFloat)getCalloutCellWidthPhonePortrait
{
    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
        return gSDKDemoCalloutCellWidthPhonePortraitDebug;
    return gSDKDemoCalloutCellWidthPhonePortraitBasic;
}


+ (CGFloat)getCalloutCellWidthTabletPortrait
{
    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
        return gSDKDemoCalloutCellWidthTabletPortraitDebug;
    return gSDKDemoCalloutCellWidthTabletPortraitBasic;
}


+ (CGFloat)getCalloutContainerMaxHeightTabletPortrait
{
    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
        return gSDKDemoCalloutContainerMaxHeightTabletPortraitDebug;
    return gSDKDemoCalloutContainerMaxHeightTabletPortraitBasic;
}


+ (CGFloat)getCalloutContainerMaxHeightTabletLandscape
{
    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
        return gSDKDemoCalloutContainerMaxHeightTabletLandscapeDebug;
    return gSDKDemoCalloutContainerMaxHeightTabletLandscapeBasic;
}


+ (CGFloat)getCalloutHeaderFontSize
{
    return [WSIMapDemoUtil isPhoneIdiom] ? gSDKDemoCalloutHeaderFontSizePhone : gSDKDemoCalloutHeaderFontSizeTablet;
}

+ (CGFloat)getCalloutLabelFontSize
{
    return [WSIMapDemoUtil isPhoneIdiom] ? gSDKDemoCalloutLabelFontSizePhone : gSDKDemoCalloutLabelFontSizeTablet;
}

+ (CGFloat)getCalloutLabelFontSizeMinimum
{
    return gSDKDemoCalloutLabelFontSizeMinimum;
}

+ (CGFloat)getCalloutTextSectionFontSize
{
    return [WSIMapDemoUtil isPhoneIdiom] ? gSDKDemoCalloutTextSectionFontSizePhone : gSDKDemoCalloutTextSectionFontSizeTablet;
}

+ (CGFloat)getCalloutLabelHeight
{
    return [WSIMapDemoUtil isPhoneIdiom] ? gSDKDemoCalloutLabelFontSizePhone + 1.0f : gSDKDemoCalloutLabelFontSizeTablet + 1.0f;
}

+ (CGFloat)getCalloutContainerMaxHeight
{
    if ([WSIMapDemoUtil isPhoneIdiom])
    {
        if ([self isPortrait])
            return gSDKDemoCalloutContainerMaxHeightPhonePortrait;
        else
            return gSDKDemoCalloutContainerMaxHeightPhoneLandscape;
    }
    else
    {
        if ([self isPortrait])
            return [self getCalloutContainerMaxHeightTabletPortrait];
        else
            return [self getCalloutContainerMaxHeightTabletLandscape];
    }
}

+ (CGFloat)getCalloutCellWidth
{
    if ([WSIMapDemoUtil isPhoneIdiom])
    {
        if ([self isPortrait])
            return [self getCalloutCellWidthPhonePortrait];
        else
            return gSDKDemoCalloutCellWidthPhoneLandscape;
    }
    else
    {
        if ([self isPortrait])
            return [self getCalloutCellWidthTabletPortrait];
        else
            return gSDKDemoCalloutCellWidthTabletLandscape;
    }
}

+ (CGFloat)getCallouLabelWidthRight
{
    CGFloat cellWidth = 0.0;
    CGFloat labelWidth = 0.0;
    if ([WSIMapDemoUtil isPhoneIdiom])
    {
        if ([self isPortrait])
        {
            cellWidth = [self getCalloutCellWidthPhonePortrait];
            labelWidth = gSDKDemoCalloutLabelWidthLeftPhonePortrait;
        }
        else
        {
            cellWidth = gSDKDemoCalloutCellWidthPhoneLandscape;
            labelWidth = gSDKDemoCalloutLabelWidthLeftPhoneLandscape;
        }
    }
    else
    {
        if ([self isPortrait])
        {
            cellWidth = [self getCalloutCellWidthTabletPortrait];
            labelWidth = gSDKDemoCalloutLabelWidthLeftTabletPortrait;
        }
        else
        {
            cellWidth = gSDKDemoCalloutCellWidthTabletLandscape;
            labelWidth = gSDKDemoCalloutLabelWidthLeftTabletLandscape;
        }
    }
   return cellWidth - labelWidth - gSDKDemoCalloutCellMarginX - gSDKDemoCalloutCellMarginX;
}

+ (CGFloat)getCallouLabelWidthLeft
{
    //return [WSIMapDemoUtil isPhoneIdiom] ? gSDKDemoCalloutLabelWidthLeftPhone : gSDKDemoCalloutLabelWidthLeftTablet;
    
    if ([WSIMapDemoUtil isPhoneIdiom])
    {
        if ([self isPortrait])
            return gSDKDemoCalloutLabelWidthLeftPhonePortrait;
        else
            return gSDKDemoCalloutLabelWidthLeftPhoneLandscape;
    }
    else
    {
        if ([self isPortrait])
            return gSDKDemoCalloutLabelWidthLeftTabletPortrait;
        else
            return gSDKDemoCalloutLabelWidthLeftTabletLandscape;
    }
}

@end
