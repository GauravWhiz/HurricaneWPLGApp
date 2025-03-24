// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoGeoAlertsInfoCell.h"
#import "WSIMapDemoSettings.h"

@implementation WSIMapDemoGeoAlertsInfoCell

- (void)setViewContent
{
    [self setViewContentForAllAlert];
    [self setCellBackgroundColorForKey:gWMSKeyAlert_FillColor];
}


/*
 With the "all" (e.g.648) alerts, far less data is available in the initial
 dictionary of data than with "category" (e.g. 644) alerts.
 Most of the same data is available via the "details" call, although we
 only expose a subset of those currently.
 */
- (void)setViewContentForAllAlert
{
    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
    {
        [self addLabelString:@"geo_callout_debug"];
        [self addHealineTextWithHeader:nil];
        [self addLabelString:@"geo_callout_category" valueStringKey:gWMSKeyAlert_Category];
        [self addLabelString:@"geo_callout_priority" valueStringKey:gWMSKeyAlert_Priority];
        [self addLabelString:@"geo_callout_phenomena" valueStringKey:gWMSKeyAlert_Phenomena];
        [self addLabelString:@"geo_callout_significance" valueStringKey:gWMSKeyAlert_Significance];
        [self addLabelString:@"geo_callout_countrycode" valueStringKey:gWMSKeyAlert_CountryCode];
        [self addLabelString:@"geo_callout_identifier" valueStringKey:gWMSKeyAlert_ID];
        [self addLabelString:@"geo_callout_featureid" valueStringKey:gWMSKey_FeatureID];
        [self addLabelString:@"geo_callout_datetime_start" valueStringKey:gWMSKeyAlert_EffectiveTimeLocal];
        [self addLabelString:@"geo_callout_timezone" valueStringKey:gWMSKeyAlert_EffectiveTimeLocalTZ];
        [self addLabelString:@"geo_callout_time_expire" valueStringKey:gWMSKeyAlert_ExpireTimeSeconds];
        [self addLabelString:@"geo_callout_timezone" valueStringKey:gWMSKeyAlert_ExpireTimeLocalTZ];
        [self addLabelString:@"geo_callout_time" valueStringKey:gWMSKeyAlert_ValidTimeSeconds];

        [self addLabelString:@"geo_callout_featurelat" valueStringKey:gWMSKey_FeatureLatitude];
        [self addLabelString:@"geo_callout_featurelon" valueStringKey:gWMSKey_FeatureLongitude];
        [self addLabelString:@"geo_callout_fill" valueStringKey:gWMSKeyAlert_FillColor];
        [self addLabelString:@"geo_callout_fill_opacity" valueStringKey:gWMSKeyAlert_FillOpacity];
        [self addLabelString:@"geo_callout_outline" valueStringKey:gWMSKeyAlert_OutlineColor];
        [self addLabelString:@"geo_callout_outline_opacity" valueStringKey:gWMSKeyAlert_OutlineOpacity];
        [self addText:@"" localize:NO bold:NO];

        //[self addDetailsOverviewWithHeader:@"geo_callout_overview"];
        //[self addDetailsDescriptionWithHeader:@"geo_callout_details"];
    }
    else
    {
        [self addHealineTextWithHeader:nil];
        [self addDateTimeStringForLabelISO:@"geo_callout_datetime_start" key:gWMSKeyAlert_EffectiveTimeLocal];
        [self addDateTimeStringForLabelUTC:@"geo_callout_datetime_end" key:gWMSKeyAlert_ExpireTimeSeconds];
        //[self addLabelString:@"geo_callout_datetime_start" valueStringKey:gWMSKeyAlert_EffectiveTimeLocal];
        //[self addLabelString:@"geo_callout_datetime_end" valueStringKey:gWMSKeyAlert_ExpireTimeSeconds];
        //[self maybeAddDateTimeStringForLabel:@"geo_callout_datetime_start" key:gWMSKeyAlertDetails_EffectiveTimeLocal];
        //[self addHealineTextWithHeader:nil];
        //[self maybeAddDateTimeStringForLabel:@"geo_callout_datetime_end" key:gWMSKeyAlertDetails_ExpireTimeLocal];
        [self addText:@"" localize:NO bold:NO];
        [self addDetailsOverviewWithHeader:nil];
        [self addDetailsDescriptionWithHeader:nil];
    }
}


/*
 Note: This is currently set up to show the "alert headline" text which combines
 the "alert description with duration information.
 This text is never localized currently - it is generally in English regardless
 of the device's locale.
 If "details" fetching is enabled, the DetailsOverview and DetailsDescription
 text only supports English (most alerts) and French (Canadian alerts where
 localization has been provided in the source alert information).
 One way to generate a localized table is to use the phenomena+significance
 (AlertPhenomena+AlertSignificance) as localization keys. Some of these are
 provided for English and Spanish in the included Localizable.strings files
 but the list isn't complete. The full set of supported alerts can be found
 in the "map_alert_styles.xml" file.
 */
- (void)addHealineTextWithHeader:(NSString *)headerText
{
    WSIMapSDKFeatureInfoDictionary *featureInfoDict = [self getFeatureInfoDict];
    NSString *healineText = [WSIMapSDKGeoInfoUtil getStringForFeatureSanitized:featureInfoDict key:gWMSKeyAlert_HeadlineText withDefault:@"???"];
    if (healineText.length > 0)
        [self addTextSectionWithHeader:headerText bodyText:healineText bold:(headerText==nil)];
}


- (void)addDetailsOverviewWithHeader:(NSString *)headerText
{
    WSIMapSDKFeatureInfoDictionary *featureInfoDict = [self getFeatureInfoDict];
    NSString *alertDetailsOverview = [WSIMapSDKGeoInfoUtil getStringForFeatureSanitized:featureInfoDict key:gWMSKeyAlertDetails_Overview withDefault:@"???"];
    if (alertDetailsOverview.length > 0)
        [self addTextSectionWithHeader:headerText bodyText:alertDetailsOverview bold:NO];
}


- (void)addDetailsDescriptionWithHeader:(NSString *)headerText
{
    WSIMapSDKFeatureInfoDictionary *featureInfoDict = [self getFeatureInfoDict];
    NSString *alertDetailsDescription = [WSIMapSDKGeoInfoUtil getStringForFeatureSanitized:featureInfoDict key:gWMSKeyAlertDetails_Description withDefault:@"???"];
    if (alertDetailsDescription.length > 0)
        [self addTextSectionWithHeader:headerText bodyText:alertDetailsDescription bold:NO];
}


- (NSString *)unlocalizedHeaderForSection
{
    return @"geo_callout_alerts_title";
}

@end
