// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

extern CGFloat const gSDKDemoCalloutTitleMarginX;

extern CGFloat const gSDKDemoCalloutBottomAlignment;
extern CGFloat const gSDKDemoCalloutIconWidth;
extern CGFloat const gSDKDemoCalloutIconHeight;
extern CGFloat const gSDKDemoCalloutIconSizeHeight;
extern CGFloat const gSDKDemoCalloutTableAlignment;
extern CGFloat const gSDKDemoCalloutTitleHeight;

// all callouts use the same cell size and margin within that
extern CGFloat const gSDKDemoCalloutCellMarginX;
extern CGFloat const gSDKDemoCalloutCellMarginY;

extern NSString * const gSDKDemoCloseCalloutNotification;
extern NSString * const gSDKDemoLayersChangedNotification;

@interface WSIMapDemoSizes : NSObject
+ (CGFloat)getCalloutHeaderFontSize;
+ (CGFloat)getCalloutLabelFontSize;
+ (CGFloat)getCalloutLabelFontSizeMinimum;
+ (CGFloat)getCalloutTextSectionFontSize;
+ (CGFloat)getCalloutLabelHeight;
+ (CGFloat)getCalloutCellWidth;
+ (CGFloat)getCalloutContainerMaxHeight;
+ (CGFloat)getCallouLabelWidthRight;
+ (CGFloat)getCallouLabelWidthLeft;
@end
