// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoGeoStormTrackInfoCell.h"
#import "WSIMapDemoSettings.h"
#import "WSIMapDemoUtil.h"

@implementation WSIMapDemoGeoStormTrackInfoCell

- (void)setViewContent
{
    if ([self haveMixedItems])
        [self addText:@"geo_callout_stormcell_title" localize:YES bold:YES];

    [self addStormTypeString];
    [self addDirectionAndSpeedString];
    [self addElapsedTimeWithLabelString:nil forKey:gWMSKeyStorm_ValidTimeSeconds];
    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
    {
        [self addLabelString:@"geo_callout_debug"];
        [self addLabelString:@"geo_callout_direction"       valueStringKey:gWMSKeyStorm_Direction];
        [self addLabelString:@"geo_callout_hailsize"        valueStringKey:gWMSKeyStorm_HailMaxSizeInches];
        [self addLabelString:@"geo_callout_hailprobability" valueStringKey:gWMSKeyStorm_HailProbability];
        [self addLabelString:@"geo_callout_imagename"       valueStringKey:gWMSKeyStorm_ImageName];
        [self addLabelString:@"geo_callout_impact"          valueStringKey:gWMSKeyStorm_Impact];
        [self addLabelString:@"geo_callout_impactflood"     valueStringKey:gWMSKeyStorm_ImpactFlood];
        [self addLabelString:@"geo_callout_impacthail"      valueStringKey:gWMSKeyStorm_ImpactHail];
        [self addLabelString:@"geo_callout_impacttornado"   valueStringKey:gWMSKeyStorm_ImpactTornado];
        [self addLabelString:@"geo_callout_impactwind"      valueStringKey:gWMSKeyStorm_ImpactWind];
        [self addLabelString:@"geo_callout_featurelat"      valueStringKey:gWMSKey_FeatureLatitude];
        [self addLabelString:@"geo_callout_featurelon"      valueStringKey:gWMSKey_FeatureLongitude];
        [self addLabelString:@"geo_callout_preciprate"      valueStringKey:gWMSKeyStorm_PrecipRateMMPerHour];
        [self addLabelString:@"geo_callout_speed"           valueStringKey:gWMSKeyStorm_SpeedMetersPerSecond];
    }
}


- (void)addStormTypeString
{
    WSIMapSDKFeatureInfoDictionary *featureInfoDict = [self getFeatureInfoDict];
    NSString *imageName = [WSIMapSDKGeoInfoUtil getStringForFeature:featureInfoDict key:gWMSKeyStorm_ImageName];
    NSString *stormTypeString = nil;
    if ([imageName isEqualToString:@"stormTrack_strongCell"])
        stormTypeString = [WSIMapDemoUtil localizedString:@"geo_callout_storm_type_strong_storm"];
    else if ([imageName isEqualToString:@"stormTrack_severeHail"])
        stormTypeString = [WSIMapDemoUtil localizedString:@"geo_callout_storm_type_hail_storm"];
    else if ([imageName isEqualToString:@"stormTrack_mesocyclone"])
        stormTypeString = [WSIMapDemoUtil localizedString:@"geo_callout_storm_type_rotating_storm"];
    else if ([imageName isEqualToString:@"stormTrack_tornadic"])
        stormTypeString = [WSIMapDemoUtil localizedString:@"geo_callout_storm_type_tornadic_storm"];
    else
        stormTypeString = [WSIMapDemoUtil localizedString:@"no_data_sign"];
    [self addText:stormTypeString localize:NO bold:YES];
}


- (void)addDirectionAndSpeedString
{
    NSString *directionAndSpeedString = [self getDirectionAndSpeedString];
    [self addText:directionAndSpeedString localize:NO bold:NO];
}


- (NSString *)unlocalizedHeaderForSection
{
    return @"geo_callout_stormcell_title";
}

@end
