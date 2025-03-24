// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoCalloutHandler.h"

#import "WSIMapDemoCalloutConstants.h"
#import "WSIMapDemoConstants.h"
#import "WSIMapDemoGeoObjectInfoCell.h"
#import "WSIMapDemoGeoCalloutView.h"
#import "WSIMapDemoSettings.h"
#import "WSIMapDemoUtil.h"
#import "WSIMapDemoUtilGeoCallout.h"

@implementation WSIMapDemoCalloutHandler
{
    UIView *_mapView;
    WSIMapDemoGeoCalloutView *_calloutView;
    WSIMapSDKFeatureInfoList *_lastFeatureInfoList;
}


- (instancetype)initWithMapView:(UIView *)mapView
{
    self = [super init];
    if (!self)
        return nil;
    
    _calloutView = nil;
    _mapView = mapView;
    _lastFeatureInfoList = nil;
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(closeCallouts) name:gSDKDemoCloseCalloutNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(closeCallouts) name:gSDKDemoLayersChangedNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(closeCallouts) name:gSDKDemoMapSingleTapNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(closeCallouts) name:gSDKDemoMapRegionWillChangeNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(closeCallouts) name:gSDKDemoUnitsWillChangeNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(refreshCallouts) name:gSDKDemoDebugCalloutsChangedNotification object:nil];

    return self;
}


- (void)removeCalloutView
{
    if (_calloutView)
    {
        [_calloutView removeFromSuperview];
        _calloutView = nil;
    }
}


- (void)closeCallouts
{
    [self removeCalloutView];
    _lastFeatureInfoList = nil;
}


#pragma mark - gesture handling

- (void)calloutTappedWithFeatureInfoLists:(NSArray<WSIMapSDKFeatureInfoList*> *)featureInfoLists
{
    /*
    // If exactly one instance of one type of geo object was tapped then
    // we'll convert the lat/lon for that to a tap point and use that.
    // If, say, an earthquake and a flood alert OR 2 earthquakes were
    // tapped then we will use the tap point that was passed in above.
    BOOL oneObjectTapped = NO;
    if (featureInfoLists.count == 1)
    {
        // one type of geo object tapped
        WSIMapSDKFeatureInfoList *featureInfoList = [featureInfoLists lastObject];
        oneObjectTapped = (featureInfoList.count == 1);
    }
    */

    [self removeCalloutView];
    
    _calloutView =  [[WSIMapDemoGeoCalloutView alloc] initWithMapView:_mapView withFeatureInfoLists:featureInfoLists];
    
    // center callout view over visible part of map
    _calloutView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [_mapView addSubview:_calloutView];
    
    /*
    if (oneObjectTapped)
    {
        // Not 100% sure why this is needed here unless the view frame was
        // changed above but this forces the tableview within the callout
        // to redraw itself / turn scrolling on/off for the tableview.
        [_calloutView update];
    }
    */
}


- (BOOL)isCalloutForFeatureTypeSupported:(WSIMapSDKFeatureType)featureType featureInfoDict:(WSIMapSDKFeatureInfoDictionary *)featureInfoDict
{
    switch (featureType)
    {
        case WSIMapSDKFeatureType_Alert:
        case WSIMapSDKFeatureType_CurrentCondition:
        case WSIMapSDKFeatureType_Earthquake:
        case WSIMapSDKFeatureType_Lightning:
        case WSIMapSDKFeatureType_StormTrack:
        case WSIMapSDKFeatureType_TrafficIncident:
            return YES;
        case WSIMapSDKFeatureType_TropicalTrack:
            return [WSIMapDemoUtilGeoCallout isTropicalTrackPointFeature:featureInfoDict]; // don't show info for tracks, cones etc.
        case WSIMapSDKFeatureType_TemperaturePlot:
        case WSIMapSDKFeatureType_TrafficFlow:
            return NO;
        case WSIMapSDKFeatureType_None:
            NSAssert(NO, @"Invalid geo data type!");
            return NO;
    }
}


/*
 Processes the given list of tapped features into separate lists for each
 feature type (alertsare grouped into a single list).
 These will each be shown in their own section in the callout view for the
 tapped objects.
 The lists are sorted with the alerts list last and the alerts sorted by
 severity within that list.
 */
- (NSArray<WSIMapSDKFeatureInfoList*> *)getSortedFeatureInfoListsFromFeatureList:(WSIMapSDKFeatureInfoList *)featureInfoList
{
    NSMutableArray<WSIMapSDKFeatureInfoList*> *returnedArrayOfLists = [NSMutableArray new];
    
    NSMutableDictionary<NSNumber*, NSMutableArray<WSIMapSDKFeatureInfoDictionary*>*> *dictionaryOfLists = [NSMutableDictionary new];
    for (WSIMapSDKFeatureInfoDictionary *featureInfoDict in featureInfoList)
    {
        WSIMapSDKFeatureType featureType = [WSIMapSDKGeoInfoUtil getTypeForFeature:featureInfoDict];
        if ([self isCalloutForFeatureTypeSupported:featureType featureInfoDict:featureInfoDict])
        {
            NSNumber *featureTypeNumber = [NSNumber numberWithUnsignedInteger:featureType];
            NSMutableArray<WSIMapSDKFeatureInfoDictionary*> *featureInfoList = [dictionaryOfLists objectForKey:featureTypeNumber];
            if (!featureInfoList)
            {
                // new feature type - create new dictionary
                featureInfoList = [[NSMutableArray alloc] init];
                [dictionaryOfLists setObject:featureInfoList forKey:featureTypeNumber];
            }
            
            [featureInfoList addObject:featureInfoDict];
        }
    }

    // now copy lists in dictionary into array, making sure WnW list goes last
    for (NSNumber *key in dictionaryOfLists.allKeys)
    {
        WSIMapSDKFeatureType featureType = key.unsignedIntegerValue;
        if (featureType != WSIMapSDKFeatureType_Alert)
        {
            WSIMapSDKFeatureInfoList *featureInfoList = [dictionaryOfLists objectForKey:key];
            [returnedArrayOfLists addObject:featureInfoList];
        }
    }

    NSNumber *alertsTypeNumber = [NSNumber numberWithUnsignedInteger:WSIMapSDKFeatureType_Alert];
    NSMutableArray<WSIMapSDKFeatureInfoDictionary*> *alertsFeatureInfoList = [dictionaryOfLists objectForKey:alertsTypeNumber];
    if (alertsFeatureInfoList)
    {
        // Sort if we have at least two WeatherWarning callouts.
        if (alertsFeatureInfoList.count > 1)
        {
            // 2.Sort objects by their (WSI) priority.
            NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:gWMSKeyAlert_Priority ascending:YES]];
            [alertsFeatureInfoList sortUsingDescriptors:descriptors];
        }
        [returnedArrayOfLists addObject:alertsFeatureInfoList];
    }
    
    return returnedArrayOfLists;
}


- (void)processFeatureInfoList:(WSIMapSDKFeatureInfoList *)featureInfoList
{
    NSArray<WSIMapSDKFeatureInfoList*> *sortedFeatureInfoLists = [self getSortedFeatureInfoListsFromFeatureList:featureInfoList];
    if (sortedFeatureInfoLists && sortedFeatureInfoLists.count > 0)
        [self calloutTappedWithFeatureInfoLists:sortedFeatureInfoLists];
    else
        [self closeCallouts]; // no callout to show
}

#pragma mark - WSIMapSDKGestureDelegate methods

/*
 Called when user taps on one or more geo objects in the map view.
 The tap location is in the gesture recognizer.
 */
- (void)handleFeaturesTapped:(UIGestureRecognizer *)gestureRecognizer featureInfoList:(WSIMapSDKFeatureInfoList *)featureInfoList hasDetails:(BOOL)hasDetails
{
    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
    {
        // move the map to the tapped location (before processing the tapped items below)
        WSIMapSDK *mapSDK = [WSIMapSDK sharedInstance];
        CGPoint touchPoint = [gestureRecognizer locationInView:mapSDK.mapView];
        CLLocationCoordinate2D tappedLocation = [[WSIMapSDK sharedInstance] getCoordinateFromMapWithPoint:touchPoint];
        [[WSIMapSDK sharedInstance] setMapCenterCoordinate:tappedLocation animated:YES];
    }

    [self saveFeatureInfoList:featureInfoList];
    [self processFeatureInfoList:featureInfoList];

    if (hasDetails)
        [[WSIMapSDK sharedInstance] featuresRequestDetails:featureInfoList]; // or, could pass list with specific features in it
}


- (void)gotDetailsForFeatures:(WSIMapSDKFeatureInfoList *)featureInfoList
{
    if (_calloutView)
    {
        // option 1: close existing callout views and recreate them from scratch.
        [self saveFeatureInfoList:featureInfoList];
        [self processFeatureInfoList:featureInfoList];

        // option 2: send out a notification and let callout view (cells) update themselves.
        // See how this is handled in WSIMapDemoGeoEarthquakesInfoCell for example.
        //[[NSNotificationCenter defaultCenter] postNotificationName:gSDKDemoMapGotDetailsForFeaturesNotification object:featureInfoList];
    }
}


/*
 Support toggling "Debug Callouts" by saving the most recent
 featureInfoList above and forcing callouts to update themselves
 if the setting is changed.
 */
- (void)saveFeatureInfoList:(WSIMapSDKFeatureInfoList *)featureInfoList
{
    _lastFeatureInfoList = [[WSIMapSDKFeatureInfoList alloc] initWithArray:featureInfoList];
}


- (void)refreshCallouts
{
    if (_calloutView && _lastFeatureInfoList)
        [self processFeatureInfoList:_lastFeatureInfoList];
}

@end
