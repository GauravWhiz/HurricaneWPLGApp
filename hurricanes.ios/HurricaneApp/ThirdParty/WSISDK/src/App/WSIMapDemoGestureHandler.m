// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoGestureHandler.h"

#import "WSIMapDemoCalloutHandler.h"
#import "WSIMapDemoConstants.h"

@implementation WSIMapDemoGestureHandler
{
    WSIMapDemoCalloutHandler *_calloutHandler;
}

#pragma mark - gesture handling

- (instancetype)initWithCalloutHandler:(WSIMapDemoCalloutHandler *)calloutHandler
{
    self = [super init];
    if (!self)
        return nil;
    _calloutHandler = calloutHandler;
    return self;
}


- (void)wsiMapSDKMapAnnotationsTapped:(UIGestureRecognizer *)gestureRecognizer tapCoordinate:(CLLocationCoordinate2D)tapCoordinate annotationInfoList:(WSIMapSDKAnnotationInfoList *)annotationInfoList
{
    NSLog(@"annotation tapped");
}


- (void)wsiMapSDKMapFeaturesTapped:(UIGestureRecognizer *)gestureRecognizer featureInfoList:(WSIMapSDKFeatureInfoList *)featureInfoList  hasDetails:(BOOL)hasDetails
{
    [_calloutHandler handleFeaturesTapped:gestureRecognizer featureInfoList:featureInfoList hasDetails:hasDetails];
}


- (void)wsiMapSDKMapFeaturesGotDetails:(WSIMapSDKFeatureInfoList *)featureInfoList
{
    [_calloutHandler gotDetailsForFeatures:featureInfoList];
}


- (void)wsiMapSDKMapGestureOneFingerSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:gSDKDemoMapSingleTapNotification object:nil];
}

@end
