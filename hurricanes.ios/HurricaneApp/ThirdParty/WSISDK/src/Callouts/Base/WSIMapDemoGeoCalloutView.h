// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

@interface WSIMapDemoGeoCalloutView : UIView <UITableViewDataSource, UITableViewDelegate>
- (id)initWithMapView:(UIView *)mapView withFeatureInfoLists:(NSArray<WSIMapSDKFeatureInfoList*> *)featureInfoLists;
- (void)update;
@end
