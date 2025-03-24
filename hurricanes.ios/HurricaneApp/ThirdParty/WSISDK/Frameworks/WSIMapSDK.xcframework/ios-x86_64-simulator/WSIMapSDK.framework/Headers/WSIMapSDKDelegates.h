// IBM Confidential
// Copyright IBM Corp. 2016, 2023. Copyright WSI Corporation 1998, 2015.

//------------------------------------------------------------------------------
// WSIMapSDKDelegate
//------------------------------------------------------------------------------

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import <WSIMapSDK/WSIMapSDKGeoInfo.h>
#import <WSIMapSDK/WSIMapSDKTypes.h>

@class WSIMapSDK;
@class WSIMapSDKMapObject;

typedef NS_ENUM(NSInteger, WSIMapSDKErrorCode)
{
    WSIMapSDKErrorCodeAuthenticationFailed,
    WSIMapSDKErrorCodeAuthenticationLayer,
    WSIMapSDKErrorCodeDataInvalid,
    WSIMapSDKErrorCodeDataInvalidJSON,
	WSIMapSDKErrorCodeDataUnavailable,
};

@protocol WSIMapSDKDelegate <NSObject>

@required

/*
 Called when certain errors occur within the SDK.
 This can be due to invalid credentials, layers that are inaccessible, 
 missing delegate methods etc.
 See WSIMapSDKErrorCode enumeration for possible error codes stored
 in the given NSError object.
 */
- (void)wsiMapSDKError:(NSError *)error;

@optional

/*
 Called once the provided clientKey has been validated.
 At this point getAvailabilityStatus can be called for any configured
 raster layers and overlays to determine whether these are actually
 available, if desired.
 */
- (void)wsiMapSDKCredentialsValidated;

/* ----------------------------------------------------------------------------
 Map layers / overlays delegates.
 These are optional however at least some of these will need to be implemented
 on your delegate object depending on whether you are using layers / overlays.
 ---------------------------------------------------------------------------- */

/*
 Called whenever the map view finishes loading (if your delegate is set up).
 This happens on startup when the map view is first created as well as any time
 the map style is changed.
 */
- (void)wsiMapSDKMapViewDidFinishLoading;

/*
 Called whenever the map view starts loading (if your delegate is set up).
 This happens on startup when the map view is first created as well as any time
 the map style is changed.
 */
- (void)wsiMapSDKMapViewDidStartLoading;

/*
 Called when the active raster layer changes.
 This is called as soon as the layer is added to the map but before the map
 data has been loaded so the layer might not actually be on the map and the
 current frame and timestamps etc. for the layer might not be available yet.
 Since the raster layer can only be changed via setActiveRasterLayerXXX, the
 app can often handle this itself, by generating its own internal
 notifications, for example.
 Use the WSIMapSDK "getActiveLayerXXX" methods to get the current frame
 time, index and time stamps etc.
 */
- (void)wsiMapSDKActiveRasterLayerChanged;

/*
 Called when the data (available frames / timestamps) changes for the active
 raster layer. This happens when the layer is made active or when the server
 data for that layer updates.
 Use the WSIMapSDK "getActiveLayerXXX" methods to get the current frame
 time, index and time stamps etc.
 */
- (void)wsiMapSDKActiveRasterLayerDataChanged;

/*
 Called when the frame for the selected raster layer changes. This happens for
 each available frame when looping and when a specific frame is selected via
 setLayerDataOffset:willEnableLooping or setActiveRasterLayerTime.
 Use the WSIMapSDK "getActiveLayerXXX" methods to get the current frame
 time, index and time stamps etc.
 */
- (void)wsiMapSDKActiveRasterLayerFrameChanged;


/*
 Some events that are internal to the map SDK cause looping to be stopped if
 it was enabled. This includes, changing the map style, changing the raster
 layer, obtaining layer authentication, and changes to the SmartRadar selected
 layer.
 Your app can hook into this to update its UI if necessary.
 */
- (void)wsiMapSDKStopLoopingInternal;

/*
 Called when the map's zoom level changes. You can access the current
 zoom level by calling -[WSIMapSDK getMapZoomLevel].
 */
- (void)wsiMapSDKZoomLevelDidChange;

/*
 Called when the map region did/will change (e.g. due to user moving or zooming
 the map or due to this happening via code when, say, the map location changes).
 */
- (void)wsiMapSDKRegionDidChange;
- (void)wsiMapSDKRegionWillChange;


/* ----------------------------------------------------------------------------
 SmartRadar layer delegates.
 These are optional but will be needed if you want to work with SmartRadar
 data and state changes.
 ---------------------------------------------------------------------------- */

/*
 Called on the main thread if the SmartRadar data changed for the given
 layerID. This method might be called multiple times after local radar data 
 is retrieved from the web service, once for each local radar layer whose data 
 changed.
 Also called when data for a layer is obtained when none was already 
 present (e.g. after the first call to fetch radar data).
 
 Implement this method on your delegate object if you want to react to
 status changes in your own code.
 
 The delegate method will be called if any of the following change:
     +status (offline/online)
     +range
     +latitude
     +longitude
 
 Note that changes to the lastUpdated time do not trigger calls to this method.
 
 Use -[WSIMapSDK getSmartRadarServiceData] to fetch the actual data.
 */
- (void)wsiMapSDKSmartRadarServiceDataChanged:(NSString *)layerID;

/*
 Called on the main thread for each local radar layer when doing a SmartRadar
 update. An update happens when the SmartRadar layer is active and any of the
 following occur:
    + the SmartRadar layer was selected via your app
    + the status for any local radar layer changed (e.g. from online to offline)
    + the region for the map changed
    + a local radar layer annotation in the SmartRadar layer was tapped
    + your app called -[WSIMapSDK setLocalRadarAutoZoomRecenter]
    + your app called -[WSIMapSDK setSmartRadarZoomedLevel]
    + your app called -[WSIMapSDK refreshSmartRadar]
 Return the UIImage* that your app would like to use for the given local radar
 layer (ID) based on the given state flags.
 Return nil to not show any image.
 The given stateFlags are a bitfield -- see WSIMapSDKLocalRadarState enumeration
 for details.
 If you don't implement this delegate, the "radar_default_xxx" images (must be
 in the app bundle) will be used to show active / online / offline local radars).
 */
- (UIImage *)wsiMapSDKSmartRadarIconForLocalRadarID:(NSString *)localRadarID stateFlags:(NSUInteger)stateFlags;

/*
 Called on the main thread if the active layer within the SmartRadar layer
 changes (e.g. from the default / national radar layer to one of the local 
 radar layers).
 The radarID parameter is the service ID for the activated layer. If this is
 for a local radar layer, this can be used as a key into the dictionary returned
 by -[WSIMapSDK getSmartRadarServiceData] to obtain status information on the
 activated layer.
 You can also call the "getActiveXXX" methods on the given WSIMapSDKMapObject
 (SmartRadar) object to get the raw or localized name for the current active
 layer if you want to, for example, show the name of the active layer within
 the SmartRadar layer.
 */
- (void)wsiMapSDKSmartRadarSelectedLayerChanged:(WSIMapSDKMapObject *)mapObject radarID:(NSString*)radarID;


/*
 Called when the icon associated with the given radarID was tapped.
 */
- (void)wsiMapSDKSmartRadarTappedLocalRadarID:(NSString*)localRadarID;


- (NSDictionary<NSString*, NSObject*>*)wsiMapSDKStyleForDefaultUserLocationAnnotationView;


@end

/* ----------------------------------------------------------------------------
 Gesture handling.
 
 Client code can use these methods to handle various gestures, to display UI
 for tapped features (callouts), for example.
 The SDK doesn't implement UI for tapped features - your apps must handle this.
 See the SDK demo application for example use -- you can add this code to your
 own apps if you want.
 ---------------------------------------------------------------------------- */

@protocol WSIMapSDKGestureDelegate <NSObject>

@optional

/*
 Called when the user single-taps one or more annotations on the map.
 */
- (void)wsiMapSDKMapAnnotationsTapped:(UIGestureRecognizer *)gestureRecognizer tapCoordinate:(CLLocationCoordinate2D)tapCoordinate annotationInfoList:(WSIMapSDKAnnotationInfoList *)annotationInfoList;

/*
 Called when the user single-taps one or more features on the map.
 Features include location-based items such as storm tracks, earthquakes
 and traffic incidents and also area-based items such as flood and winter alerts.
 The featureInfoList parameter contains dictionaries of information for each
 tapped feature. See the gWSIMapSDKFeature_XXXKey constants for accessing
 individual dictionary entries and see the utility methods in WSIMapSDKGeoInfoUtil
 for fetching specific entries and converting those (strings) to specific types.
 If hasDetails is true, 1 or more of the features in featureInfoList have
 additional details available. This currently only applies to alerts (detailed
 description text) and earthquakes (location information).
 To obtain the detailed information, call featuresRequestDetails:

 See the WSIMapSDK demo apps for example code.
 */
- (void)wsiMapSDKMapFeaturesTapped:(UIGestureRecognizer *)gestureRecognizer featureInfoList:(WSIMapSDKFeatureInfoList *)featureInfoList hasDetails:(BOOL)hasDetails;

/*
 Called when featuresRequestDetails: completes.
 
 As an example of how to use this:
    + user taps an earthquake callout - the wsiMapSDKMapFeaturesTapped delegate
      is called with initial (no details) information
    + your code shows the available information (e.g. magnitude and time) and
      stores a reference to the associated WSIMapSDKFeatureInfoDictionary object
    + your code calls featuresRequestDetails to obtain location information
      which isn't in the "standard" information provided by the server
    + some time later, this delegate is called with updated information (in a new
      WSIMapSDKFeatureInfoList)
    + you can use getUpdatedFeatureInfoDictionary to obtain the corresponding
      (updated) WSIMapSDKFeatureInfoDictionary for the one you displayed earlier
    + use that to update your UI
    + alternatively, you could simply remove your existing UI and recreate it
      using the updated WSIMapSDKFeatureInfoList
      
 See the WSIMapSDK demo apps for example code.
 */
- (void)wsiMapSDKMapFeaturesGotDetails:(WSIMapSDKFeatureInfoList *)featureInfoList;

/*
 Called when the user single-taps the map.
 The tap location is stored within the given gesture recognizer.
 */
- (void)wsiMapSDKMapGestureOneFingerSingleTap:(UIGestureRecognizer *)gestureRecognizer;

@end
