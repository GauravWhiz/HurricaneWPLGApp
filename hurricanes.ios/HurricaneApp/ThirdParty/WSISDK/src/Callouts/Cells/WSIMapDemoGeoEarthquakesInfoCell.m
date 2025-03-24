// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoGeoEarthquakesInfoCell.h"
#import "WSIMapDemoConstants.h"
#import "WSIMapDemoSettings.h"
#import "WSIMapDemoUtil.h"

@interface WSIMapDemoGeoObjectInfoCell (Friend)
- (void)initialize:(WSIMapSDKFeatureInfoDictionary *)featureInfoDict;
@end

@implementation WSIMapDemoGeoEarthquakesInfoCell
{
    UILabel *_magnitudeValueLabel;
    UILabel *_depthValueLabel;
    UILabel *_timeValueLabel;
    UILabel *_locationValueLabel;
    UILabel *_regionValueLabel;
    UILabel *_sourceValueLabel;
}


- (void)initialize:(WSIMapSDKFeatureInfoDictionary *)featureInfoDict
{
    [super initialize:featureInfoDict];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotDetailsForFeaturesHandler:) name:gSDKDemoMapGotDetailsForFeaturesNotification object:nil];
}


- (void)setViewContent
{
    if ([self haveMixedItems])
        [self addText:@"geo_callout_earthquake" localize:YES bold:YES];

    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
    {
        [self addLabelString:@"geo_callout_debug"];
        _magnitudeValueLabel    = [self addLabelString:@"geo_callout_magnitude" valueStringKey:gWMSKeyEarthquake_Magnitude];
        _depthValueLabel        = [self addLabelString:@"geo_callout_depth" valueStringKey:gWMSKeyEarthquake_DepthKM];
        _locationValueLabel     = [self addLabelString:@"geo_callout_location" valueStringKey:gWMSKeyEarthquakeDetails_Place defaultValue:@"???"];
        _sourceValueLabel       = [self addLabelString:@"geo_callout_type" valueStringKey:gWMSKeyEarthquakeDetails_Type defaultValue:@"???"];
        _timeValueLabel         = [self addElapsedTimeWithLabelString:@"geo_callout_time" forKey:gWMSKeyEarthquake_ValidTimeSeconds];
    }
    else
    {
        _locationValueLabel     = [self addText:[self getLocationString] localize:NO bold:YES];
        _magnitudeValueLabel    = [self addLabelString:nil valueString:[self getMagnitudeString]];
        _timeValueLabel         = [self addElapsedTimeWithLabelString:nil forKey:gWMSKeyEarthquake_ValidTimeSeconds];
    }
}


- (NSString *)getMagnitudeString
{
    WSIMapSDKFeatureInfoDictionary *featureInfoDict = [self getFeatureInfoDict];
    NSString *magnitudeLabel = [WSIMapDemoUtil localizedStringWithDefault:@"geo_callout_magnitude"];
    CGFloat magnitude = [WSIMapSDKGeoInfoUtil getFloatForFeature:featureInfoDict key:gWMSKeyEarthquake_Magnitude];
    return [NSString stringWithFormat:@"%@ %0.1f", magnitudeLabel, magnitude];

}


- (NSString *)getLocationString
{
    return [self getStringForKey:gWMSKeyEarthquakeDetails_Place];
}


- (void)updateViewContent
{
    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
    {
        [self updateLabel:_locationValueLabel valueStringKey:gWMSKeyEarthquakeDetails_Place];
        [self updateLabel:_sourceValueLabel valueStringKey:gWMSKeyEarthquakeDetails_Type];
    }
    else
    {
        [self updateLabel:_locationValueLabel valueString:[self getLocationString]];
    }
}


- (NSString *)unlocalizedHeaderForSection
{
    return @"geo_callout_earthquake_title";
}


- (void)gotDetailsForFeaturesHandler:(NSNotification *)notification
{
    WSIMapSDKFeatureInfoList *featureInfoList = (WSIMapSDKFeatureInfoList*)notification.object;
    if ([self shouldUpdateViewForDetails:featureInfoList])
        [self updateViewContent];
}

@end
