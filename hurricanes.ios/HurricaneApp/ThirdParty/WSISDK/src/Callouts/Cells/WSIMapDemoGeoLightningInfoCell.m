// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoGeoLightningInfoCell.h"
#import "WSIMapDemoSettings.h"

@implementation WSIMapDemoGeoLightningInfoCell

- (void)setViewContent
{
    if ([self haveMixedItems])
        [self addText:@"geo_callout_lightning_title" localize:YES bold:YES];

    [self addElapsedTimeWithLabelString:nil forKey:gWMSKeyLightning_ValidTimeSeconds];
    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
    {
        [self addLabelString:@"geo_callout_debug"];
        [self addLabelString:@"geo_callout_amplitude" valueStringKey:gWMSKeyLightning_Amplitude];
        [self addLabelString:@"geo_callout_featurelat" valueStringKey:gWMSKey_FeatureLatitude];
        [self addLabelString:@"geo_callout_featurelon" valueStringKey:gWMSKey_FeatureLongitude];
    }
}


- (NSString *)unlocalizedHeaderForSection
{
    return @"geo_callout_lightning_title";
}

@end
