// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoGeoTrafficIncidentsInfoCell.h"
#import "WSIMapDemoSettings.h"
#import "WSIMapDemoUtil.h"

@implementation WSIMapDemoGeoTrafficIncidentsInfoCell

- (void)setViewContent
{
    if ([self haveMixedItems])
        [self addText:@"geo_callout_traffic_incident" localize:YES bold:YES];

    [self addTypeInformationWithLabel:nil];
    [self addSeverityInformationWithLabel:nil];
    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
    {
        [self addLabelString:@"geo_callout_debug"];
        [self addLabelString:@"geo_callout_description"     valueStringKey:gWMSKeyIncident_DescriptionLong];
        [self addSeverityInformationWithLabel:@"geo_callout_traffic_incident_severity"];
        [self addTypeInformationWithLabel:@"geo_callout_traffic_incident_type"];
        [self addLabelString:@"geo_callout_featurelat"      valueStringKey:gWMSKey_FeatureLatitude];
        [self addLabelString:@"geo_callout_featurelon"      valueStringKey:gWMSKey_FeatureLongitude];
        [self addElapsedTimeWithLabelString:@"geo_callout_time" forKey:gWMSKeyIncident_ValidTimeSeconds];
    }

    [self addDescriptionWithHeader:nil];
    [self maybeAddDateTimeStringForLabelISO:@"geo_callout_datetime_start" key:gWMSKeyIncident_OccurenceStartTime];
    [self maybeAddDateTimeStringForLabelISO:@"geo_callout_datetime_end" key:gWMSKeyIncident_OccurenceEndTime];
}


- (NSString *)getStringForSeverity:(NSInteger)severityValue
{
    switch (severityValue)
    {
        case 0: return [WSIMapDemoUtil localizedString:@"traffic_incident_minor_impact"];
        case 1: return [WSIMapDemoUtil localizedString:@"traffic_incident_low_impact"];
        case 2: return [WSIMapDemoUtil localizedString:@"traffic_incident_moderate_impact"];
        case 3: return [WSIMapDemoUtil localizedString:@"traffic_incident_high_impact"];
        case 4: return [WSIMapDemoUtil localizedString:@"traffic_incident_severe_impact"];
        default: return @"???";
    }
    return @"???";
}


- (void)addSeverityInformationWithLabel:(NSString *)label
{
    WSIMapSDKFeatureInfoDictionary *featureInfoDict = [self getFeatureInfoDict];
    NSInteger severityValue = [WSIMapSDKGeoInfoUtil getIntegerForFeature:featureInfoDict key:gWMSKeyIncident_Severity];
    NSString *severityString = [self getStringForSeverity:severityValue];
    [self addLabelString:label valueString:severityString];
}


- (NSString *)getStringForType:(NSInteger)typeValue
{
    switch (typeValue)
    {
        case WSIMapSDKTrafficIncidentType_Construction:
            return [WSIMapDemoUtil localizedString:@"traffic_incident_type_construction"];
        case WSIMapSDKTrafficIncidentType_Flow:
            return [WSIMapDemoUtil localizedString:@"traffic_incident_type_flow"];
        case WSIMapSDKTrafficIncidentType_Event:
            return [WSIMapDemoUtil localizedString:@"traffic_incident_type_event"];
        case WSIMapSDKTrafficIncidentType_Incident:
        case WSIMapSDKTrafficIncidentType_Police:  // not sure this ever happens atm
        case WSIMapSDKTrafficIncidentType_Weather: // not sure this ever happens atm
            return [WSIMapDemoUtil localizedString:@"traffic_incident_type_incident"];
        default:
            return [WSIMapDemoUtil localizedString:@"traffic_incident_type_unknown"];
    }
    return [WSIMapDemoUtil localizedString:@"traffic_incident_type_unknown"];
}


- (void)addTypeInformationWithLabel:(NSString *)label
{
    WSIMapSDKFeatureInfoDictionary *featureInfoDict = [self getFeatureInfoDict];
    NSInteger typeValue = [WSIMapSDKGeoInfoUtil getIntegerForFeature:featureInfoDict key:gWMSKeyIncident_Type];
    NSString *typeString = [self getStringForType:typeValue];
    if (label)
        [self addLabelString:label valueString:typeString];
    else
        [self addText:typeString localize:NO bold:YES];
}


- (void)addDescriptionWithHeader:(NSString *)headerText
{
    WSIMapSDKFeatureInfoDictionary *featureInfoDict = [self getFeatureInfoDict];
    NSString *description = [WSIMapSDKGeoInfoUtil getStringForFeatureSanitized:featureInfoDict key:gWMSKeyIncident_DescriptionBrief withDefault:@"???"];
    if (description.length > 0)
        [self addTextSectionWithHeader:headerText bodyText:description bold:NO];
}


- (NSString *)unlocalizedHeaderForSection
{
    return @"geo_callout_traffic_incidents_title";
}


@end
