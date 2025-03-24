// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoGeoCurrentConditionsInfoCell.h"
#import "WSIMapDemoSettings.h"

@implementation WSIMapDemoGeoCurrentConditionsInfoCell

- (void)setViewContent
{
    if ([self haveMixedItems])
        [self addText:@"geo_callout_currentcondition" localize:YES bold:YES];

    [self addLabelString:@"geo_callout_currentconditions_location" valueStringKey:gWMSKeyCondition_Name];
    [self addLabelString:@"geo_callout_currentconditions_dewpoint" valueStringKey:gWMSKeyCondition_DewpointF];
    [self addLabelString:@"geo_callout_currentconditions_feelslike" valueStringKey:gWMSKeyCondition_FeelsLikeF];
    [self addLabelString:@"geo_callout_currentconditions_temperature" valueStringKey:gWMSKeyCondition_TempF];
    [self addLabelString:@"geo_callout_currentconditions_tempchange1hr" valueStringKey:gWMSKeyCondition_TempFChange1Hour];
    [self addLabelString:@"geo_callout_currentconditions_tempchange24hr" valueStringKey:gWMSKeyCondition_TempFChange24Hour];
    [self addDirectionAndSpeedString];

    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
    {
        [self addLabelString:@"geo_callout_debug"];
        [self addLabelString:@"geo_callout_imagename" valueStringKey:gWMSKeyCondition_ImageName];
        [self addLabelString:@"geo_callout_dayind" valueStringKey:gWMSKeyCondition_DayInd];
        [self addLabelString:@"geo_callout_direction" valueStringKey:gWMSKeyCondition_Direction];
        [self addLabelString:@"geo_callout_iconcode" valueStringKey:gWMSKeyCondition_IconCode];
        [self addLabelString:@"geo_callout_iconcodeext" valueStringKey:gWMSKeyCondition_IconCodeExt];
        [self addLabelString:@"geo_callout_datetimegmt" valueStringKey:gWMSKeyCondition_DateTimeGMTSeconds];
        [self addLabelString:@"geo_callout_datetimelocal" valueStringKey:gWMSKeyCondition_DateTimeLocal];
        [self addElapsedTimeWithLabelString:@"geo_callout_time" forKey:gWMSKeyCondition_ValidTimeSeconds];
    }
}


- (void)addDirectionAndSpeedString
{
    NSString *directionAndSpeedString = [self getDirectionAndSpeedString];
    [self addText:directionAndSpeedString localize:NO bold:NO];
}


- (NSString *)unlocalizedHeaderForSection
{
    return @"geo_callout_currentconditions_title";
}

@end
