// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#define DEMO_LEGEND_FONT_CHANGE 0

typedef NS_ENUM(NSUInteger, WMDMapboxOffsetType)
{
    WMDMapboxOffsetTypeNone,
    WMDMapboxOffsetTypeBottomRight,
    WMDMapboxOffsetTypeTop,
    WMDMapboxOffsetTypeTopLeft,
    WMDMapboxOffsetTypeTopRight,
};

@interface WSIMapDemoExamples : NSObject
#if DEMO_LEGEND_FONT_CHANGE
+ (void)processLabelsInSubViewsOfView:(UIView *)view;
#endif
+ (void)adjustAttributionOffsets:(WSIMapSDK *)wsiMapSDK offsetType:(WMDMapboxOffsetType)offsetType;
@end
