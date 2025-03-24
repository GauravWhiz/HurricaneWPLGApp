// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

@interface WSIMapDemoUtilGeoCallout : NSObject

// Helper to set up title / value pair on left / right of given view using labels.
// Returns the right (value) label which can be used by code to update the value.
+ (UILabel *)addLeftText:(NSString *)leftText leftFrame:(CGRect)leftFrame toView:(UIView *)view bold:(BOOL)bold;
+ (UILabel *)addLeftText:(NSString *)leftText rightText:(NSString *)rightText leftFrame:(CGRect)leftFrame rightFrame:(CGRect)rightFrame toView:(UIView *)view;

// return "x minutes ago" or "x hours ago" depening on time delta
+ (NSString *)getElapsedTimeStringForTime:(NSTimeInterval)timeInterval;

+ (BOOL)isTropicalTrackPointFeature:(WSIMapSDKFeatureInfoDictionary *)featureInfoDict;

@end
