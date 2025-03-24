// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoUtilGeoCallout.h"

#import "WSIMapDemoMacros.h"
#import "WSIMapDemoUtil.h"
#import "WSIMapDemoUtilTime.h"

@implementation WSIMapDemoUtilGeoCallout

+ (UILabel *)infoLabelWithFrame:(CGRect)frame text:(NSString *)text bold:(BOOL)bold
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = bold ? [WSIMapDemoUtil fontOfSizeBold:[WSIMapDemoSizes getCalloutLabelFontSize]] :
                        [WSIMapDemoUtil fontOfSize:[WSIMapDemoSizes getCalloutLabelFontSize]];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = text;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = [WSIMapDemoSizes getCalloutLabelFontSizeMinimum];
    return label;
}


+ (UILabel *)infoLabelWithFrame:(CGRect)frame text:(NSString *)text alignment:(NSTextAlignment)alignment bold:(BOOL)bold
{
    UILabel *returnedLabel = [self infoLabelWithFrame:frame text:text bold:bold];
    returnedLabel.textAlignment = alignment;
    return returnedLabel;
}


+ (UILabel *)addLeftText:(NSString *)leftText leftFrame:(CGRect)leftFrame toView:(UIView *)view bold:(BOOL)bold
{
    UILabel *leftLabel = [self infoLabelWithFrame:leftFrame text:leftText alignment:NSTextAlignmentLeft bold:bold];

    #if 0 //debug
    leftLabel.backgroundColor = [UIColor redColor];
    rightLabel.backgroundColor = [UIColor blueColor];
    #endif
    
    [view addSubview:leftLabel];
    
    return leftLabel; // in case code wants to update the text
}


+ (UILabel *)addLeftText:(NSString *)leftText rightText:(NSString *)rightText leftFrame:(CGRect)leftFrame rightFrame:(CGRect)rightFrame toView:(UIView *)view
{
    UILabel *leftLabel = [self infoLabelWithFrame:leftFrame text:leftText alignment:NSTextAlignmentLeft bold:NO];
    UILabel *rightLabel = [self infoLabelWithFrame:rightFrame text:rightText alignment:NSTextAlignmentRight bold:NO];
    
    #if 0 //debug
    leftLabel.backgroundColor = [UIColor redColor];
    rightLabel.backgroundColor = [UIColor blueColor];
    #endif
    
    [view addSubview:leftLabel];
    [view addSubview:rightLabel];
    
    return rightLabel; // in case code wants to update the text
}


+ (NSString *)getElapsedTimeStringForTime:(NSTimeInterval)timeInterval
{
    NSTimeInterval nowTimeInterval = [WSIMapDemoUtilTime timeIntervalSince1970];
    NSTimeInterval elapsedMinutes = (nowTimeInterval - timeInterval) / 60.0;

    #if 0 // debug
    CGFloat floorElapsedHours   = MAL_FLOOR_TO_CGFLOAT(elapsedMinutes/60.0f);
    CGFloat remainderMinutes    = (elapsedMinutes - (60.0f*floorElapsedHours));
    WMDLog(@"elapsedMinutes = %0.3f (%0.0f hours and %0.1f minutes ago) showing '%zd %@'",
                elapsedMinutes,
                floorElapsedHours,
                remainderMinutes,
                (elapsedMinutes < 60.0) ? MAL_ROUND_TO_NSINTEGER(elapsedMinutes) : MAL_ROUND_TO_NSINTEGER(elapsedMinutes/60.0),
                (elapsedMinutes < 60.0) ? @"minutes ago" : @"hours ago" );
    #endif
    
    if (elapsedMinutes < 60.0)
        return [NSString stringWithFormat:[WSIMapDemoUtil localizedString:@"timeago_n_minutes_ago_long"], MAL_ROUND_TO_NSINTEGER(elapsedMinutes)];
    return [NSString stringWithFormat:[WSIMapDemoUtil localizedString:@"timeago_n_hours_ago_long"], MAL_ROUND_TO_NSINTEGER(elapsedMinutes/60.0)];
}


+ (BOOL)isTropicalTrackPointFeature:(WSIMapSDKFeatureInfoDictionary *)featureInfoDict
{
    NSString *stormFeatureTypeString = [WSIMapSDKGeoInfoUtil getStringForFeature:featureInfoDict key:gWMSKeyTropical_StormFeatureType];
    if ([stormFeatureTypeString isEqualToString:@"HistoryPosition"] ||
        [stormFeatureTypeString isEqualToString:@"CurrentPosition"] ||
        [stormFeatureTypeString isEqualToString:@"ForecastPosition"])
    {
        return YES;
    }

    return NO;
}

@end
