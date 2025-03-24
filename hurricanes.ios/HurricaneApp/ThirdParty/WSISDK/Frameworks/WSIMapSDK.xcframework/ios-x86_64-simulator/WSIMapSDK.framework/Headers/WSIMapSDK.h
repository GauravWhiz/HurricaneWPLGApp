// IBM Confidential
// Copyright IBM Corp. 2016, 2023. Copyright WSI Corporation 1998, 2015.

#import <WSIMapSDK/WSIMapSDKConstants.h>
#import <WSIMapSDK/WSIMapSDKDelegates.h>
#import <WSIMapSDK/WSIMapSDKGeoInfo.h>
#import <WSIMapSDK/WSIMapSDKGeoInfoUtil.h>
#import <WSIMapSDK/WSIMapSDKMapObject.h>
#import <WSIMapSDK/WSIMapSDKMapView.h>

typedef NSArray<WSIMapSDKMapObject*> WSIMapSDKMapObjectList;

@interface WSIMapSDK : NSObject

/*
 Returns a version string for the Map SDK.
 */
+ (nonnull NSString *)getVersionString;

/*
 Use this method to create and initializing the WSIMapSDK object.
     + verifies the validity of clientKey and enables available features
     + sets up the given delegate if provided
     + parses configuration files (maplayers_config.xml, master_config_map.xml etc.)
        + basic settings
        + sets up configured (but not necessarily available) layers and overlays

 To use the map SDK you need to contact WSI to obtain your client key. Note
 that keys for older versions of the map SDK can not be used with 5.0 or later
 versions of the map SDK.
 Calling this method will initiate a remote call to determine which
 raster layers and overlays are available (this could be a subset of
 the *configured* raster layers and overlays). That will take some time
 to complete, although usually less than a few seconds with a good
 internet connection.
 The wsiMapSDKCredentialsValidated delegate is called when authentication
 completes and you can use the -[WSIMapSDKMapObject getAvailabilityStatus]
 methods to determine whether layers are available at that point.
 Any layers that are enabled on the map before authentication completes
 will be removed from the map if they are determined to be unauthenticated.
 Once this method has been successfully called, you can use the sharedInstance
 method to access the WSIMapSDK singleton object if desired.
 */
+ (nullable instancetype)createInstanceWithDelegate:(nullable id<WSIMapSDKDelegate>)delegate // WSIMapSDKDelegate protocol object (can set later via setDelegate:)
                                           mapStyle:(WSIMapSDKMapStyle)mapStyle              // initial map style
                                          clientKey:(nonnull NSString *)clientKey;           // WSI-provided client key used for unlocking available SDK functionality

/*
 Returns YES if the SDK has been successfully initialized, NO otherwise.
 */
+ (BOOL)isInitialized;


/*
 Returns the shared WSIMapSDK object instance.
 This method should only be called after the map SDK has been initialized via
 createInstanceWithDelegate:... otherwise an error will be logged.
 Releasing and reallocating the WSIMapSDK object isn't currently supported.
 */
+ (nonnull id)sharedInstance;


/*
 Same as sharedInstance but will simply return nil if SDK hasn't been initialized
 when this is called instead of asserting / logging an error.
 */
+ (nullable id)sharedInstanceNoCheck;


/*
 Disables the map - should be called before the SDK is initialized.
 Can be used for testing / profiling purposes etc.
 If you use setAccessibilityEnabled to completely disable accessibility
 on the Mapbox map, calling disableMap might not be necessary and the
 map can continue to function during XCUITest / Appium tests.
 */
+ (void)disableMap;


/*
 Enable / disable accessibilty for the map (view).
 
 The support in Mapbox for accessibility / VoiceOver has a number
 of known issues that Mapbox has yet to addres:
    1: Some apps will see significant slowdowns when VoiceOver is
       enabled and possibly Out of Memory (OOM) situations. This
       may also happen when attempting to execute XCUITest tests
       either directly or via Appium.
    2: In general, the accessibility support is fairly poor and
       in some cases there appears to be no way to move or zoom
       the Mapbox map, for example.
       
 We have modified the MGLMapView accessibility handling in our
 MGLMapView subclass to ignore any elements with "(null)" or
 "MGLRoadFeature" in their description as these seem to be the main
 cause of the slowdowns / OOM issues. This might address 1. for
 your app but 2. will still be an issue.
 
 If you are still seeing performance issues, you can use this method
 to *completely* disable accessibility handling for the map view. As
 users interact with the map or as XCUITest-based tests executed, the
 map won't return any elements via the usual UIAccessibilityContainer
 methods:
    accessibilityElementCount() will always return 0
    accessibilityElement(at index:) will always return nil
    index(ofAccessibilityElement element:) will always return nil
 
 If you do this, you will probably want to implement your own custom
 accessibility handling, by responding to tapped locations on the map,
 for example.
 */
- (void)setAccessibilityEnabled:(BOOL)value;


/*
 See WSIMapSDKDebugLogXXX constants.
 Default is WSIMapSDKDebugLogLevelNone.
 Should be called before creating the map SDK instance.
 */
+ (void)setDebugLogLevel:(NSUInteger)logLevel;


/*
 By default, logs in the SDK are handled using print so these will show
 up in the Xcode console logs even if OS_ACTIVITY_MODE is set to disable.
 If you are looking at logs for an actual device (e.g. via Xcode's
 devices console), you need to tell the SDK to use NSLog so those will
 appear.
 */
+ (void)setUseDeviceLogs:(BOOL)useDeviceLogs;


/*
 Returns YES if the map SDK has been successfully authenticated.
 */
- (BOOL)isAuthenticated;

/*
 Returns version string for the PangeaWrapper framework.
 */
- (nonnull NSString *)getPangeaWrapperVersionString;


/*
 Returns version string for the PangeaSDK framework.
 */
- (nonnull NSString *)getPangeaSDKVersionString;

/*
 The SDK may cache some data (e.g. raster layer tiles) to local directories.
 In some cases, such as after an app upgrade, you may want to clear these
 caches by calling this method.
 
 This doesn't currently affect the mapbox cache. Depending on your source,
 there can be a 12 hour or longer delay before changes to map styles show
 up in your app (until cached data is discarded).
 
 Per Mapbox slack:
 "It looks like there’s a 7 day cache on these styles, which means maps will
 load much quicker for your users since the tiles are often cached. It also
 means that if you make changes and we don’t do anything, it can take up to
 7 days for users to see the changes. A way to avoid this next time would be
 to have us invalidate the cache on our end next time you make a style change."
 */
- (void)clearCaches;

//------------------------------------------------------------------------------
// Map (other)
//------------------------------------------------------------------------------

// Update: We believe this issue may be resolved in 5.1.009 or newer in which
// case these methods may be deprecated in the future.
// In some cases a bug in Mapbox causes features (e.g. storm tracks, lightning)
// on the map. These features are visible but can't be tapped etc. This can
// occur when the map location and/or zoom level is changed at the same time
// that multiple layers (including features) are removed/added from/to the map.
// The only workaround so far is to force the map style to change to something
// other than the current map style then back to the original map style which
// is what the following methods do.
// If you are seeing this issue with your apps, you can call forceMapReset to
// immediately attempt to clear bogus features (e.g. after switching between
// "weather" and "traffic" maps) or you can enable a force map reset when the
// app comes into the foreground (either always or just once) which might be
// preferable visually.
- (void)setForceMapResetOnForeground:(BOOL)val; // force map reset every time app comes into the foreground
- (void)setForceMapResetOnForegroundOnce;       // force map reset once, the next time the app comes into the foreground
- (void)forceMapReset;                          // force an immediate map reset.

// Use this before / after map resize (e.g. due to rotation) to temporarily
// hide / unhide the Mapbox attribution items (those won't adjust their position
// correctly during the rotation).
- (void)setAttributionMasked:(BOOL)masked;

// Can be used to disable the Mapbox attribution button so it can't be tapped.
- (void)setMapboxButtonDisabled:(BOOL)disabled;

// Can be used to hide the Mapbox attribution button / logo.
// We are using this to hide the button since the hit area for that is extending
// into our own buttons and there appears to be no way to control that.
- (void)setMapboxButtonHidden:(BOOL)hidden;
- (void)setMapboxLogoHidden:(BOOL)hidden;

/*
 Used to set the frame offsets for the Mapbox attribution items (Mapbox wants
 these to be fully visible at all times).
 By default the logo is in the lower right of the map view and the button is in
 the lower left corner of the map view.
 Often, apps might have some UI (possibly semi-transparent) covering the lower
 part of the map in which case you need to reposition the attribution items. Or,
 you might prefer to put these somewhere else on your UI (there is currently no
 support for putting these outside of the map view though).
 Note there is currently no support for having these views automatically
 position themselves as the view rotates or resizes -- you have to do this in
 your app (usually by 1: masking these views as resizing / rotation begins
 2: reapplying the offsets after resizing / rotation ends 3: unmasking the
 views.
 */
- (void)setMapboxButtonOffset:(CGPoint)buttonOffset logoOffset:(CGPoint)logoOffset;

// return the current mapbox button frame - useful when positioning the view
- (CGRect)getMapboxButtonFrame;

// return the current mapbox logo frame - useful when positioning the view
- (CGRect)getMapboxLogoFrame;

//------------------------------------------------------------------------------
// Raster layers
//------------------------------------------------------------------------------

/*
 Can be used to "validate" the given map object.
 Will return nil if the layer is valid, a string describing the issue(s)
 otherwise.
 Currently this can only return a non-null result for Lightning which is
 only valid once it has a region (lat/lon + radius) configured.
 If a layer isn't valid it won't be visible on the map even if selected.
 */
- (nullable NSString *)validateLayer:(nonnull WSIMapSDKMapObject *)mapObject;

/*
 Returns YES if a layer with the given layerID has been configured, NO
 otherwise.
 Useful if you need to check a layerID's validity after the layer settings
 have been parsed but before the layers have been authenticated.
 */
- (BOOL)verifyLayerWithLayerID:(nonnull NSString *)layerID;


/*
 Returns NSArray of WSIMapSDKMapObject* for all *configured* raster layers.
 This can be called immediately after initializing the SDK.
 These layers aren't necessarily available and that won't be known 
 until the client's credentials have been verified.
 See wsiMapSDKCredentialsValidated delegate and -[WSIMapSDKMapObject
 getAvailabilityStatus] method.
 */
- (nullable WSIMapSDKMapObjectList *)getConfiguredRasterLayers;


/*
 Returns NSArray of WSIMapSDKMapObject* for all *available*
 raster layers.
 Will return an empty array if called before wsiMapSDKCredentialsValidated 
 has been called.
 See wsiMapSDKCredentialsValidated delegate and -[WSIMapSDKMapObject
 getAvailabilityStatus] method.
 */
- (nullable WSIMapSDKMapObjectList *)getAvailableRasterLayers;


/*
 Returns WSIMapSDKMapObject for the active raster layer, if any, nil otherwise.
 */
- (nullable WSIMapSDKMapObject *)getActiveRasterLayer;


/*
 Returns WSIMapSDKMapObject* for raster layer with the matching layerID, if 
 found, nil otherwise.
 */
- (nullable WSIMapSDKMapObject *)getRasterLayerForLayerID:(nonnull NSString *)layerID;

/*
 This call is used to switch on a particular layer on the map view.
 Only one raster layer at a time can be shown. If you call this, the
 previously active layer (if any) will be turned off.
 When the raster layer changes, the time for the layer is set to the
 current (actual) time and the closest frame for that time will be displayed.
 For layers with observed (past) data (this applies to all layers currently)
 this means the most recent observed data will be shown for the raster layer.
 See the wsiMapSDKActiveRasterLayerXXX delegates -- these will be called
 when the layer is set, when the layer's data is loaded or changes and when
 the selected frame for the layer changes (when looping, for example).
 Use nil to remove the active layer, if any.
 */
- (void)setActiveRasterLayer:(nullable WSIMapSDKMapObject *)rasterLayerObject;


/*
 Make the raster layer that has the matching layerID active, if any match
 is found.
 Pass in nil to disable the current raster layer, if any.
 */
- (void)setActiveRasterLayerByLayerID:(nullable NSString *)layerID;

/*
 Use this to enable / disable auto centering + zooming of the map when using
 local radar layers.
 This behavior is enabled by default.
 When enabled, if a local radar layer is selected (e.g. via a list in the UI)
 or tapped (within SmartRadar layer), the map will center itself on that local
 radar layer and zoom in such that the local radar layer mostly fills the map
 view (based on the local radar's range).
 It may be useful to disable this behavior for testing purposes.
 When disabled, if a local radar layer is selected (e.g. via a list in the UI)
 the map won't move or zoom. If a local radar layer within the SmartRadar layer
 is tapped, the map will re-center on the local radar layer but the map zoom
 level won't change. Additionally, with SmartRadar, if this is disabled, local
 radars will become active regardless of the current zoom level (the one closest
 to the center of the map will become active as the map is moved around).
 */
- (void)setLocalRadarAutoZoomAndRecenter:(BOOL)value;
- (BOOL)getLocalRadarAutoZoomAndRecenter;

/*
 Controls whether local radar sweep arms are hidden when looping.
 Must be called prior to starting / stopping looping to work properly.
 Defaults to YES.
 */
- (void)setLocalRadarHideSweepArmWhenLooping:(BOOL)value;


/*
 Controls the offset within which local radar sweep arms are shown when
 when scrubbing.
 Use 1.0 to always show the sweep arms, 0.0 to never show them. Values
 between 1.0 and 0.0 represent the distance from the "now" position at
 0.0 within which the sweep arm will be shown.
 The default is 0.01 so the sweep arm is only shown when very close to
 the "now" position and hidden otherwise.
 Since local radar doesn't generally have future data, the range is
 effectively how much of an offset into the past data is accepted
 before the sweep arm is hidden.
 So 0.1 would mean there's no sweep arm shown unless the data offset
 is 0.1 or less.
 Must be called prior to starting / stopping looping to work properly.
 Defaults to 0.01.
 */
- (void)setLocalRadarShowSweepArmScrubbingRange:(CGFloat)range;

//------------------------------------------------------------------------------
// Transparency
//------------------------------------------------------------------------------

/*
 Transparency values can be specified for each raster layer individually, via
 setTransparencyPrecentForActiveRasterLayer on the WSIMapSDK object or via the
 setTransparencyPercent method on specific WSIMapSDKMapObject objects. There
 are matching "get" methods for determining the transparency.
 
 Or, a single global transparency value can be specified via the
 xxxGlobalTransparency methods below. As long as a global transparency is set,
 all raster layers will use this value when displayed on the map. If that value
 is cleared, the previous per-layer values will be restored.
 If a global transparency is set, only the xxxGlobalTransparency methods should
 be used - it's an error to call the xxxTransparencyPrecentForActiveRasterLayer
 or xxxTransparencyPercent methods in this case.

 Transparency values are percentages that are >= 0 (fully opaque) and <= 100
 (fully transparent). These default to 0 if not specified, although satellite
 (clouds) layers have built in transparency and can never be full opaque.
 */

/*
 Sets the transparency for the active layer.
 */
- (void)setTransparencyPercentForActiveRasterLayer:(NSUInteger)transparencyPercent;


/*
 Gets the transparency for the active layer.
 */
- (NSUInteger)getTransparencyPercentForActiveRasterLayer;


/*
 Returns YES if global transparency (for all raster layers) is set, NO
 otherwise.
 */
- (BOOL)haveGlobalTransparencyPercent;


/*
 Returns global transparency (for all raster layers) if set.
 Throws an exception if it's not set.
 */
- (NSUInteger)getGlobalTransparencyPercent;


/*
 Clears global transparency (for all raster layers).
 */
- (void)clearGlobalTransparencyPercent;


/*
 Sets global transparency (for all raster layers).
 */
- (void)setGlobalTransparencyPercent:(NSUInteger)transparencyPercent;

//------------------------------------------------------------------------------
// Legends
//------------------------------------------------------------------------------

/*
 Specify the font (e.g. "OpenSans-Bold") and point size to use for legend text.
 Defaults to Arial-BoldMT @ 10.0.
 */
- (void)setLegendFontName:(nonnull NSString *)name size:(CGFloat)size;


/*
 Specify the color to use for legend text.
 Defaults to white.
 */
- (void)setLegendFontColor:(nonnull UIColor *)color;

/*
 Get the legend view for the active raster layer or nil if there is none.
 */
- (nullable UIView *)getLegendViewForActiveRasterLayer;

/*
 Get the legend view for the given map object.
 */
- (nullable UIView *)getLegendViewForMapObject:(nonnull WSIMapSDKMapObject *)mapObject;

//------------------------------------------------------------------------------
// Looping
//------------------------------------------------------------------------------

/*
 Returns current layer data state (see WSIMapSDKLayerDataState).
 For layers which are configured with both past (observed) and future
 (predicted) products, those can be configured such that only the past,
 both the past and future, or only future data is accessible (e.g. shown
 when looping).
 */
- (WSIMapSDKLayerDataState)getLayerDataState;

/*
 Sets the global state for showing layer data. Only applies to raster layers
 currently.
 This will affect any displayed layers even if those aren't currently
 displayed.
 The setting is ignored if it isn't applicable (e.g. if it's set to
 PastAndFuture but the layer only has Past data).
 If this is called when a raster layer is displayed, products for
 that raster layer (e.g. the future layer) will be removed from the
 map and wsiMapSDKActiveRasterLayerDataChanged / wsiMapSDKActiveRasterLayerFrameChanged
 will be called once the layer reloads.
 */
- (void)setLayerDataState:(WSIMapSDKLayerDataState)layerDataState;

/*
 Sets the data offset for displayed layers. The value is in [-1.0..0.0]
 for past data and (0.0..+1.0] for future data.
 The offset is used to calculate a corresponding time within the range
 of available past or future data which is then used to select a specific
 frame (see setActiveRasterLayerTime notes).
 This can be a simpler approach to use when using a slider to scrub through
 the available data than setActiveRasterLayerTime since there is no need
 to keep track of the available time range (the SDK will handle this for
 you).
 This should only be used when the app is scrubbing through data, to update
 the offset used in the map SDK for showing data.
 Should not be called immediately before looping starts (it is no longer
 necessary to modify the data offset so looping doesn't pause at the end of
 data when looping is initiated - the map SDK code will do that for you and
 in a way that doesn't cause local radar layer sweep arms to "reset" if one
 is showing.
 */
- (void)setLayerDataOffset:(double)offset;

/*
 Sets the time to use for displayed layers via the given UTC time in
 seconds (epoch time = time interval since 01/01/1970).
 This will cause a specific past or future layer frame to be selected.
 In general, the frame with the closest available timestamp to the given
 time is selected, although the delta can be significant (usually less
 than 5/15 minutes but possibly hours for infrequently updated data).
 In some cases, expected data might not be available for some period of
 time and frames aren't always available at exactly the expected rate
 at which those are updated on the data servers.
 */
// not available currently -- use setLayerDataOffset:
//- (void)setActiveRasterLayerTime:(NSTimeInterval)timeIntervalSince1970;

/*
 Returns a dictionary containing observed and/or predicted data information.
 See the gWSIMapSDKLayerXXX keys to index into the given dictionary.
 */
- (nullable WSIMapSDKDataInfoDictionary *)getActiveRasterLayerData;

/*
 Returns a dictionary containing information about the current frame. Use
 the gWSIMapSDKLayerXXX keys to index into the given dictionary, to obtain
 the frame / sample time for the current frame, for example.
 Note that the time strings defaults to GMT so you will have to convert
 this for your local time zone if that is desired instead.
 Returns nil if there's no active raster layer.
 See also mapSDK:frameInfo: delegate method.
 */
- (nullable WSIMapSDKFrameInfoDictionary *)getActiveRasterLayerFrameInfo;


/*
 Returns the timestamp for the active layer.
 The returned value defaults to GMT so you may want to convert this for
 your local time zone.
 Returns nil if there is no active raster layer.
 */
- (NSTimeInterval)getActiveRasterLayerFrameTime;


/*
 Returns the current looping dwell time (how long looping pauses when the
 end of the available data is reached) in milliseconds.
 Default is 2000 milliseconds.
 */
- (NSUInteger)getLoopingDwellTimeMS;


/*
 Sets the looping dwell time (how long looping pauses when the end of the
 available data is reached) in milliseconds.
 */
- (void)setLoopingDwellTimeMS:(NSUInteger)loopingDwellTimeMS;


/*
 Returns YES if there is an active (raster) layer and that's currently
 looping, NO otherwise.
 */
- (BOOL)getIsLooping;


/*
 Starts/stops looping the active raster layer.
 Has no effect if there is no active layer or if the layer was already
 looping / not looping.
 If the current data offset (after scrubbing and/or looping stops) is
 at the most recent (closest to now) past time or most in the future
 future time, the data offset will be "wrapped" to the start of the
 data. Otherwise, the looping would immediately pause for 2.0 seconds
 (default - see getLoopingDwellTimeMS/setLoopingDwellTimeMS).
 For example, if showing FutureOnly data and the layer data offset is
 1.0, the layer data offset will be set to 0.0 before looping starts.
 If showing PastAndFuture data and the layer data offset is 1.0, the
 layer data offset will be set to -1.0 before looping starts.
 */
- (void)setIsLooping:(BOOL)newValue;

- (void)pauseLooping:(CGFloat)durationSeconds; // use durationSeconds <= 0.0 to pause "forever"
- (void)unPauseLooping;

//------------------------------------------------------------------------------
// Overlays
//------------------------------------------------------------------------------

/*
 We refer to any layers which aren't raster layers as "overlays".
 These can include "features" which are based on specific point locations such
 as earthquakes, storm tracks, tropical tracks and "alerts" which are based
 on areas.
 Methods below which fetch overlays will include both alerts and features.
 */

/*
 This call is used to switch the given overlay on or off.
 It is possible to have multiple overlays on at the same time.
 */
- (void)setStateForOverlay:(nonnull WSIMapSDKMapObject *)overlayObject active:(BOOL)active;


/*
 Returns NSArray of WSIMapSDKMapObject* for all *configured* alert /
 feature layers / both.
 This can be called immediately after initializing the SDK.
 These overlays aren't necessarily available and that won't be known 
 until the client's credentials have been verified.
 See wsiMapSDKCredentialsValidated delegate and -[WSIMapSDKMapObject
 getAvailabilityStatus] method.
 */
- (nonnull WSIMapSDKMapObjectList *)getConfiguredAlerts;
- (nonnull WSIMapSDKMapObjectList *)getConfiguredFeatures;
- (nonnull WSIMapSDKMapObjectList *)getConfiguredOverlays;


/*
 Returns NSArray of WSIMapSDKMapObject* for all *available* alert /
 feature layers / both.
 Will return an empty array if called before wsiMapSDKCredentialsValidated
 has been called.
 See wsiMapSDKCredentialsValidated delegate and -[WSIMapSDKMapObject
 getAvailabilityStatus] method.
 */
- (nonnull WSIMapSDKMapObjectList *)getAvailableAlerts;
- (nonnull WSIMapSDKMapObjectList *)getAvailableFeatures;
- (nonnull WSIMapSDKMapObjectList *)getAvailableOverlays;


/*
 Returns NSArray of WSIMapSDKMapObject* for all *active* alert /
 feature layers / both.
 */
- (nonnull WSIMapSDKMapObjectList *)getActiveAlerts;
- (nonnull WSIMapSDKMapObjectList *)getActiveFeatures;
- (nonnull WSIMapSDKMapObjectList *)getActiveOverlays;


/*
 Returns WSIMapSDKMapObject* for overlay with the matching id, if found,
 nil otherwise. 
 */
- (nullable WSIMapSDKMapObject *)getOverlayForLayerID:(nonnull NSString *)layerID;


/*
 If masked=true, marks all overlays as masked and makes sure
 any visible overlays are removed from the map.
 visible overlays.
 If masked=false, marks all overlays as unmasked and makes sure
 any visible overlays are added to the map.
 */
- (void)setOverlaysMasked:(BOOL)masked;

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------

/*
 There are 6 "categories" of alerts that can be shown.
 These are "flood", "marine", "other", "severe", "tropical" and
 "winter".
 In order for any alerts to show up you have to enable one or more
 categories (and there has to be data actually available for those
 alerts - often there are no tropical alerts available during the
 winter, for example).
 You also need to enable the alerts layer as you would any other
 layer.
 A good practice is to always enable multiple categories *before*
 enabling the alert layer since each category change will cause
 an enabled layer to reload itself which will currently*** cause
 data to be downloaded.
 *** We hope to address this issue in an upcoming release.
 */
- (void)enableAlertCategory:(nonnull NSString *)category;
- (void)disableAlertCategory:(nonnull NSString *)category;
- (BOOL)isAlertCategoryEnabled:(nonnull NSString *)category;
- (NSInteger)getNumEnabledAlertCategories;

/*
 Returns "raw" category name (e.g. flood) used in SDK.
 Any category strings passed in to the above methods
 must contain the raw category (they'll be lower-cased
 before checking).
 */
- (nullable WSIMapSDKStringsDictionary *)getAlertCategories;


/*
 The alerts in map_alert_styles.xml have an associated (WSI) priority
 with 0 representing high priority (severe) alerts and higher values
 (up to 9999 atm) representing lower priority alerts.
 By default we will enable showing any alerts defined in map_alert_styles.xml
 regardless of their priority.
 Use setAlertMinimumPriority to set the cutoff value to, say, 400, so only
 alerts with a priority value of <= 400 will be shown.
 The default alerts minimum priority is -1 so all priorities are shown.
 This can be useful in cases where there are many lower priority alerts,
 making it hard to see important ones.
 */
- (NSInteger)getAlertMinimumPriority; // returns current value
- (void)resetAlertMinimumPriority; // restores default (all priorities shown)
- (void)setAlertMinimumPriority:(NSInteger)priority; // sets value

/*
 For testing purposes.
 If enabled, make the outlines for alerts easier to see (show in black with
 full opacity).
 */
- (BOOL)getEmphasizeOutlines;
- (void)setEmphasizeOutlines:(BOOL)val;
- (void)toggleEmphasizeOutlines;

/*
 For testing purposes.
 If enabled, put alert layers on top of roads rather than under them. You can
 accomplish the same thing by modifying the order in master_config_ordering.xml.
 */
- (BOOL)getPutOverRoads;
- (void)setPutOverRoads:(BOOL)val;
- (void)togglePutOverRoads;

/*
 For testing purposes.
 If enabled, *all* alerts of all types are shown "globally" using 1 of 4 colors
 based on the alert significance instead of using map_alert_styles.xml to control
 which alerts are shown, how those are colored, and how those are prioritized.
 Mostly used for testing purposes, to identify alerts which need to be added to
 map_alert_styles.xml.
 Alerts outside of the US and Canada aren't currently supported.
 */
- (BOOL)getShowAllAlerts;           // returns YES if all alerts enabled
- (void)setShowAllAlerts:(BOOL)val; // enable / disable showing all alerts
- (void)toggleShowAllAlerts;

//------------------------------------------------------------------------------
// SmartRadar
//------------------------------------------------------------------------------

/*
 Returns YES if SmartRadar is available, NO otherwise.
 For SmartRadar to be enabled, you must provide an appropriate client key and
 the layers must have been successfully authenticated.
 */
- (BOOL)smartRadarFeatureEnabled;

/*
 Should be called immediately after creating the map SDK to add a SmartRadar
 layer.
    layerID: an ID to associate with the SmartRadar layer
    nationalRadarID: the layer ID for national radar (usually wsi_LayerRadar)
    defaultMapID: default to use until authentication completes
    defaultMemberID: default to use until authentication completes
 */
- (nullable WSIMapSDKMapObject *)addSmartRadarWithLayerID:(nonnull NSString *)layerID 
                                     nationalRadarLayerID:(nonnull NSString *)nationalRadarLayerID;

/*
 Returns a WSISmartRadarServiceData object containing radar status data for
 each of the local radars added previously via addSmartRadarLocalRadarLayer:...
 You must call this on the main thread.
 See the typedef for WSISmartRadarServiceData for details.
 See also the mapSDK:smartRadarServiceDataChanged: delegate in WSIMapSDKDelegates.h.
 If you implement that method, it will be called whenever data changes for a local 
 radar layer.
 Note that the status data for local radars within a SmartRadar layer is only
 updates if the SmartRadar layer is active (selected). The data is updated every
 15 minutes (or after 5 minutes if the last update failed).
 */
- (nullable WSIMapSDKSmartRadarServiceData *)getSmartRadarServiceData;


/*
 Sets the zoomLevel above which the SmartRadar layer is considered to be "zoomed".
 Note that zoom levels increase as the map is zoomed in (to show more detail).
 If the map is zoomed to >= zoomLevel (e.g. while tap or pinch zooming) the state
 flags for local radar layers will include WSIMapSDKLocalRadarStateZoomed.
 If the map is below this zoom level (e.g. while tap or pinch zooming) any
 local radar layers will be modified so their state flags exclude WSIMapSDK_Zoomed.
 Whenever the state flags for a local radar layer change the SDK will call the 
 iconForSmartRadarID:... delegate method for the layer and update annotations
 accordingly based on what the app returns for that method.
 For example, the app can return a nil UIImage* for layers when they have
 WSIMapSDKLocalRadarStateZoomed in their state flags so these icons disappear when the 
 user zooms in close to ground level.
 The default zoomLevel threshold is 7.0.
 Larger values can be used to allow users to zoom in more closely before local
 radar annotations disappear, smaller values will make these disappear from further
 away.
 Each degree of latitude span is about 111km on the ground.
 */
- (void)setSmartRadarZoomedLevel:(double)zoomLevel;


/*
 Forces the SmartRadar layer to update itself, if it's enabled.
 Use this, for example, if some app setting has changed that will affect the
 SmartRadar layer (e.g. if your app supports toggling the icons for offline 
 radars on and off you will want to call this whenever that option is toggled).
 Causes all SmartRadar annotiations to be updated which will result in calls to 
 the iconForSmartRadarID:... delegate method on your app.
 */
- (void)refreshSmartRadar;

//------------------------------------------------------------------------------
// Miscellaneous API methods.
//------------------------------------------------------------------------------

/*
 Returns the units to use for distances and wind speed labels.
 */
- (WSIMapSDKUnitPreferences)getDistanceUnits;


/*
 Sets the units to use for distances and wind speed labels.
 */
- (void)setDistanceUnits:(WSIMapSDKUnitPreferences)units;


/*
 Returns the units to use for temperature and pressure labels.
 */
- (WSIMapSDKUnitPreferences)getWeatherUnits;


/*
 Sets the units to use for temperature and pressure labels.
 */
- (void)setWeatherUnits:(WSIMapSDKUnitPreferences)units;


/*
 Returns NSArray of WSIMapSDKMapObject* for all configured layers and overlays.
 This can be called immediately after initializing the SDK.
 These layers aren't necessarily available and that won't be known 
 until the client's credentials have been verified.
 See wsiMapSDKCredentialsValidated delegate and -[WSIMapSDKMapObject
 getAvailabilityStatus] method.
 */
- (nullable WSIMapSDKMapObjectList *)getConfiguredMapObjects;


/*
 Returns NSArray of WSIMapSDKMapObject* for all *available*
 map objects (raster layers and overlays).
 Will return an empty array if called before wsiMapSDKCredentialsValidated 
 has been called.
 See wsiMapSDKCredentialsValidated delegate and -[WSIMapSDKMapObject
 getAvailabilityStatus] method.
 */
- (nullable WSIMapSDKMapObjectList *)getAvailableMapObjects;

/*
 Returns WSIMapSDKMapObject* with matching id.
 */
- (nullable WSIMapSDKMapObject *)getMapObjectForLayerID:(nonnull NSString *)layerID;

/*
 This will fetch applicable feature details in a background thread. This is an
 asynchronous network call. With a good network connection, this often returns
 in under 1 second depending on how many features are being processed.
 The results are passed back to the app (in the main thread) in a new
 WSIMapSDKFeatureInfoList via the wsiMapSDKMapFeaturesGotDetails delegate.
 */
- (void)featuresRequestDetails:(nonnull WSIMapSDKFeatureInfoList *)featureInfoList;

/*
 Cancels any ongoing details requests initiated via featuresRequestDetails:.
 */
- (void)featuresCancelRequestDetails;

/*
 Get / set the touch sizes for annotations.
 The touch size is used to create a touch rect that is touchSize
 units high and wide and centered on the touch location.
 An annotation is considered to have been touched if the coordinate
 (point location) of the annotation is inside the touch rect.
 Default is 30.0.
 */
- (CGFloat)getTouchSizeAnnotation;
- (void)setTouchSizeAnnotation:(CGFloat)touchSize;

/*
 Get / set the touch sizes for features.
 The touch size is used to create a touch rect that is touchSize
 units high and wide and centered on the touch location.
 A feature is considered to have been touched if the rect for the
 feature intersects with the touch rect.
 Default is 2.0.
 */
- (CGFloat)getTouchSizeFeature;
- (void)setTouchSizeFeature:(CGFloat)touchSize;

//------------------------------------------------------------------------------
// map coordinates and zoom level
//------------------------------------------------------------------------------

// Note: It's generally more efficient to get / set the map location
// and zoom level at the same time.
- (WSIMapSDKRegion)getMapRegion;
- (void)setMapRegion:(WSIMapSDKRegion)region animated:(BOOL)animated;
- (void)setMapCenterCoordinate:(CLLocationCoordinate2D)coordinate
                     zoomLevel:(double)zoomLevel
                      animated:(BOOL)animated;
- (void)setMapCenterCoordinate:(CLLocationCoordinate2D)coordinate
                      animated:(BOOL)animated;
- (CLLocationCoordinate2D)getMapCenterCoordinate;
- (double)getMapZoomLevel;
- (void)setMapZoomLevel:(double)zoomLevel animated:(BOOL)animated;
- (CLLocationCoordinate2D)getCoordinateFromMapWithPoint:(CGPoint)point;

//------------------------------------------------------------------------------
// map style
//------------------------------------------------------------------------------

- (WSIMapSDKMapStyle)getMapStyle;
- (void)setMapStyle:(WSIMapSDKMapStyle)mapStyle;

//------------------------------------------------------------------------------
// map annotations
//------------------------------------------------------------------------------

- (void)addImageAnnotationWithUniqueID:(nonnull NSString *)uniqueID coordinate:(CLLocationCoordinate2D)coordinate image:(nonnull UIImage *)image;
- (void)removeImageAnnotationWithUniqueID:(nonnull NSString *)uniqueID;
- (void)updateImageAnnotationWithUniqueID:uniqueID coordinate:(CLLocationCoordinate2D)coordinate image:(nonnull UIImage *)image;

- (void)addViewAnnotationWithUniqueID:(nonnull NSString *)uniqueID coordinate:(CLLocationCoordinate2D)coordinate view:(nonnull UIView *)view;
- (void)removeViewAnnotationWithUniqueID:(nonnull NSString *)uniqueID;
- (void)updateViewAnnotationWithUniqueID:(nonnull NSString *)uniqueID coordinate:(CLLocationCoordinate2D)coordinate;
- (CLLocationCoordinate2D)getLocationForViewAnnotationWithUniqueID:(nonnull NSString *)uniqueID;

/*
 Use these methods to temporarily hide / show view-based annotations
 (sweep arm and text annotations) while the map is being resized or
 rotated or these annotations will appear at the wrong location until
 the resizing / rotation completes.
 */
- (void)hideViewBasedAnnotations;
- (void)showViewBasedAnnotations;

/*
 Recreates the sweeping arm annotation. Call this method when the app returns from the background or the map view is re-added to the hierarchy.
 */
- (void)resetSweepArmAnnotations;

//------------------------------------------------------------------------------
// Properties
//------------------------------------------------------------------------------

/*
 Use this property to obtain / set the WSIMapSDKDelegate delegate used by the
 SDK. The delegate can also be specified via the above initialization method.
 This is required (at a minimum, the wsiMapSDKError delegate method must be
 implemented) and it must be set before the map SDK is activated via the
 activate method.
 When deallocating the delegate object, delegate should be cleared by setting it
 to nil so the delegate object is no longer retained.
 */
@property (nonatomic, retain, nullable) id<WSIMapSDKDelegate> delegate;

/*
 Set / get the delegate object for handling gestures.
 See WSIMapSDKGestureDelegate for more information.
 See SDK demo app for example use.
 */
@property (nonatomic, retain, nullable) id<WSIMapSDKGestureDelegate> appGestureDelegate;

/*
 Use this property to add the map view to your own view hierarchy.
 */
@property (nonatomic, readonly, nonnull) WSIMapSDKMapView *mapView;

@property(nonatomic, assign) BOOL showUserLocation;

@end
