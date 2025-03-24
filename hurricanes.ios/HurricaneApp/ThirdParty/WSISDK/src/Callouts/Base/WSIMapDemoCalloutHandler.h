// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

@interface WSIMapDemoCalloutHandler : NSObject <WSIMapSDKGestureDelegate>
- (instancetype)initWithMapView:(UIView *)mapView;
- (void)handleFeaturesTapped:(UIGestureRecognizer *)gestureRecognizer featureInfoList:(WSIMapSDKFeatureInfoList *)features hasDetails:(BOOL)hasDetails;
- (void)gotDetailsForFeatures:(WSIMapSDKFeatureInfoList *)features;
- (void)closeCallouts;
@end
