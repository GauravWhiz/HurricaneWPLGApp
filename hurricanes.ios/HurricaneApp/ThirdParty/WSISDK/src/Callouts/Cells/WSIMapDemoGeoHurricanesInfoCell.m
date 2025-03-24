// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoGeoHurricanesInfoCell.h"
#import "WSIMapDemoConstants.h"
#import "WSIMapDemoSettings.h"
#import "WSIMapDemoUtil.h"
#import "WSIMapDemoUtilTime.h"

@implementation WSIMapDemoGeoHurricanesInfoCell

- (void)setViewContent
{
    [self addText:[self getStormName] localize:NO bold:YES];
    [self addDirectionAndSpeedString];
    [self addText:[self getMaxWindsString] localize:NO bold:NO];
    [self addText:[self getMaxGustsString] localize:NO bold:NO];
    [self addText:[self getDateTimeStringForISOKey:gWMSKeyTropical_DateTimeLocal] localize:NO bold:NO];
    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
    {
        [self addLabelString:@"geo_callout_debug"];
        [self addLabelString:@"geo_callout_cardinal_direction"      valueStringKey:gWMSKeyTropical_DirectionCardinal];
        [self addLabelString:@"geo_callout_cat"                     valueStringKey:gWMSKeyTropical_SubType];
        [self addLabelString:@"geo_callout_direction"               valueStringKey:gWMSKeyTropical_Direction];
        [self addLabelString:@"geo_callout_imagename"               valueStringKey:gWMSKeyTropical_ImageName];
        [self addLabelString:@"geo_callout_featurelat"              valueStringKey:gWMSKey_FeatureLatitude];
        [self addLabelString:@"geo_callout_featurelon"              valueStringKey:gWMSKey_FeatureLongitude];
        [self addLabelString:@"geo_callout_hurricane_max_winds"     valueStringKey:gWMSKeyTropical_MaxSustainedWindMPH];
        [self addLabelString:@"geo_callout_position"                valueStringKey:gWMSKeyTropical_StormFeatureType];
        [self addLabelString:@"geo_callout_hurricane_gusts"         valueStringKey:gWMSKeyTropical_WindGustMPH];
        [self addElapsedTimeWithLabelString:@"geo_callout_time" forKey:gWMSKeyTropical_ValidTimeSeconds];
    }
}


- (NSString *)getStormName
{
    WSIMapSDKFeatureInfoDictionary *featureInfoDict = [self getFeatureInfoDict];
    WSIMapSDKTropicalStormType stormType = [WSIMapSDKGeoInfoUtil getTropicalTypeForFeature:featureInfoDict];
    NSInteger stormSubType = [WSIMapSDKGeoInfoUtil getIntegerForFeature:featureInfoDict key:gWMSKeyTropical_SubType];
    
    NSString *stormTypeString = [WSIMapDemoUtil getStormTypeStringFromStormType:stormType stormSubType:stormSubType];
    NSString *stormNameString = [WSIMapSDKGeoInfoUtil getStringForFeature:featureInfoDict key:gWMSKeyTropical_StormName];
    
    return [NSString stringWithFormat:@"%@ %@", stormTypeString, stormNameString];
}


- (NSString *)getSpeedStringForLocalizeKey:(NSString *)localizeKey featureKey:(NSString *)featureKey
{
    WSIMapSDK *wsiMapSDK = [WSIMapSDK sharedInstance];
    NSString *unitsKey = (wsiMapSDK.getDistanceUnits == WSIMapSDKUnitPreferencesMetric) ? @"wsi_LegendSpeedKPH" : @"wsi_LegendSpeedMPH";

    NSString *label = [WSIMapDemoUtil localizedStringWithDefault:localizeKey];
    WSIMapSDKFeatureInfoDictionary *featureInfoDict = [self getFeatureInfoDict];
    CGFloat speed = [WSIMapSDKGeoInfoUtil getFloatForFeature:featureInfoDict key:featureKey];
    if (wsiMapSDK.getDistanceUnits == WSIMapSDKUnitPreferencesMetric)
        speed = speed/gKilometersToMilesMultiplier;
    return [NSString stringWithFormat:@"%@ %0.0f %@", label, speed, [WSIMapDemoUtil localizedString:unitsKey]];
}


- (NSString *)getMaxWindsString
{
    return [self getSpeedStringForLocalizeKey:@"geo_callout_hurricane_max_winds" featureKey:gWMSKeyTropical_MaxSustainedWindMPH];
}


- (NSString *)getMaxGustsString
{
    return [self getSpeedStringForLocalizeKey:@"geo_callout_hurricane_gusts" featureKey:gWMSKeyTropical_WindGustMPH];
}


- (void)addDirectionAndSpeedString
{
    NSString *directionAndSpeedString = [self getDirectionAndSpeedString];
    [self addText:directionAndSpeedString  localize:NO bold:NO];
}


- (NSString *)unlocalizedHeaderForSection
{
    return @"wsi_OverlayTropicalTracks";
}

@end
