// IBM Confidential
// Copyright IBM Corp. 2016, 2023. Copyright WSI Corporation 1998, 2015.

@class UIView;

#import "WSIMapSDKTypes.h"

typedef NS_ENUM(NSInteger, WSIMapSDKAvailabilityStatus)
{
    WSIMapSDKAvailabilityStatusUnknown          = 0,  // unknown -- credentials check not yet done
    WSIMapSDKAvailabilityStatusAvailable        = 1,  // layer is available -- can enable
    WSIMapSDKAvailabilityStatusUnavailable      = 2,  // layer is unavailable -- can't enable
};


@interface WSIMapSDKMapObject : NSObject

/*
 Returns the availability status for the map object (whether the layer or
 overlay can be used in apps).
 This is initially set to WSIMapSDKAvailabilityStatusUnknown.
 Once credentials have been processed the status will be updated to either
 WSIMapSDKAvailabilityStatusAvailable (object is available) or
 WSIMapSDKAvailabilityStatusUnavailable (object is unavailable).
 See the wsiMapSDKCredentialsValidated delegate.
 Typically, apps should only configure layers and overlays that are 
 know to be available for the credentials that are being used. You 
 can control this via the app's master_config_map.xml file.
 If you think that some of the layers or overlays in master_config_map.xml
 might become unavailable for a released app, you should set up the
 wsiMapSDKCredentialsValidated delegate in your app and, once that's
 called, use getAvailabilityStatus to identify layers and overlays that
 are actually available and set up or update your UI (e.g. buttons or
 a list used to select layers and/or overlays) accordingly.
 */
- (WSIMapSDKAvailabilityStatus)getAvailabilityStatus;

/*
 Returns YES if the map object is available, NO otherwise.
 This will always return NO if authentication hasn't yet completed.
 */
- (BOOL)isAvailable;


/*
 Returns YES if the map object is unavailable, NO otherwise.
 This will always return NO if authentication hasn't yet completed.
 */
- (BOOL)isUnavailable;


/*
 By default, the localized name for a map object is set by localizing
 the raw (config file) name.
 Use this method if your app wants to use a different name. This will
 modify the value that getLocalizedName returns (used to display the
 layer name in the app UI, for example).
 */
- (void)overrideLocalizedName:(nonnull NSString *)localizedName;


/*
 Returns a localized name for the map object.
 Use this method if you want to obtain a displayable name for the map object,
 and provided that your app includes localization for the name.
 The name will be localized based on whether the name appears in the app's
 Localizable.strings table.
 The demo applications include default localization that you can copy into your
 own app's Localizable.strings.
 If no localization is found, the unlocalized (raw) name will be returned.
 */
- (nonnull NSString *)getLocalizedName;


/*
 Normally returns the same value as getLocalizedName.
 If the map object is a SmartRadar layer, returns the localized name for the
 selected layer which will either be the default (national) radar layer or one
 of the local radar layers if one is selected.
 */
- (nonnull NSString *)getLocalizedNameSelected;


/*
 Returns a string that can be used to identify a map object by name. For 
 example, apps might use this method to identify the traffic layer when the
 list of available overlay objects is returned to set the location and/or 
 radius for that. Not affected by localization.
 Compare this value to the above gWSIMapSDK_ values to identify map objects.
 */
- (nonnull NSString *)getLayerID;


/*
 Normally returns the same value as getLayerID.
 If the map object is a SmartRadar layer, returns the id for the selected layer
 which will either be the default (national) radar layer or one of the local
 radar layers if one is selected.
 */
- (nonnull NSString *)getLayerIDSelected;


/*
 Returns the transparency for the map object.
 The returned value will be between 0 (full opaque) and 100 (fully transparent)
 inclusive.
 Only applies to raster layers (like Temperature) -- for overlay objects 0
 will be returned.
 */
- (NSUInteger)getTransparencyPercent;


/*
 Sets the transparency of the map object to the given value.
 The given value should be between 0 and 100 inclusive.
 Has no effect on overlay map objects.
 */
- (void)setTransparencyPercent:(NSUInteger)transparencyPercent;


/*
 Returns YES if the map object is currently active.
 Overlays can be active but hidden so they won't be visible.
 Lightning can be active but not visible if the region isn't set.
 */
- (BOOL)isActive;


/*
 Returns YES if the map object has observed (past) data.
 Only applies to raster layers (like Temperature) -- for overlay
 objects NO will be returned.
 If the map object is a SmartRadar layer, returns true if either the
 active (default=NWS or local radar) layer or the default layer has
 observed (past) data. So generally returns true for SmartRadar.
 */
- (BOOL)hasObservedData;


/*
 Returns YES if the map object has predicted (future) data.
 Only applies to raster layers (like Temperature) -- for overlay
 objects NO will be returned.
 If the map object is a SmartRadar layer, returns true if either the
 active (default=NWS or local radar) layer or the default layer has
 predicted (future) data. So generally returns true for SmartRadar.
 */
- (BOOL)hasPredictedData;


/*
 Returns YES if the map object supports looping.
 Only applies to raster layers (like Temperature) -- for overlay
 objects NO will be returned.
 */
- (BOOL)supportsLooping;


/*
 Returns the configured observed range for the map object (this comes
 from the settings in master_config_map.xml and controls what subset
 of the actual available observed data is available such as for
 looping).
 Only applies to raster layers (like Temperature) -- for overlay
 objects 0 will be returned.
 If the map object is a SmartRadar layer, returns the range for the
 active (NWS or local radar) layer.
 */
- (NSInteger)getRangeObservedMinutes;


/*
 Returns the configured predicted range for the map object (this comes
 from the settings in master_config_map.xml and controls what subset
 of the actual available predicted data is available such as for
 looping).
 Only applies to raster layers (like Temperature) -- for overlay
 objects 0 will be returned.
 If the map object is a SmartRadar layer, returns the range for the
 default (national radar) layer whether or not that is active.
 */
- (NSInteger)getRangePredictedMinutes;


/*
 Returns YES if the map object is an alerts layer, NO otherwise.
 */
- (BOOL)isAlert;


/*
 Returns YES if the map object is a feature (earthquake, storm track etc.), NO otherwise.
 */
- (BOOL)isFeature;


/*
 Returns YES if the map object is a local radar layer, NO otherwise.
 */
- (BOOL)isLocalRadarLayer;


/*
 Returns YES if the map object is an overlay (Feature or Alert), NO otherwise.
 */
- (BOOL)isOverlay;


/*
 Returns YES if the map object is a raster layer (e.g. Temperature, Radar), NO otherwise.
 Note that local radar and SmartRadar map objects are also raster layers.
 */
- (BOOL)isRasterLayer;


/*
 Returns YES if the map object is a smart radar layer, NO otherwise.
 */
- (BOOL)isSmartRadarLayer;

/*
 Should be called immediately after calling addSmartRadarWithLayerID to add
 local radars to the given SmartRadar layer.
 If this is never called, the SmartRadar layer will only contain the configured
 national radar layer and no local radars.
 The given localRadarID should correspond to a localRadarID that was configured
 via map_local_radars.xml.
 If sweepImageName is nil, will use the name from map_local_radars.xml or the
 default if none was given for the specified localRadarID.
 Has no effect on layers that aren't a SmartRadar layer.
 */
- (void)addLocalRadarID:(nonnull NSString *)localRadarID
       sweepTimeSeconds:(NSTimeInterval)sweepTimeSeconds
        sweepArmOpacity:(CGFloat)sweepArmOpacity
      sweepArmImageName:(nullable NSString *)sweepArmImageName;


/*
 Returns map ID being used with SmartRadar objects, nil otherwise;
 */
- (nullable NSString *)getMapID;


/*
 Returns member ID being used with SmartRadar objects, nil otherwise;
 */
- (nullable NSString *)getMemberID;


/*
 Clip Regions.
 For some types of overlays, a circular clip region defined by a location and
 radius can be set up and items outside of this region won't be displayed.
 These only apply to map objects for which "hasClipRegion" returns YES which is
 only the case for lightning currently.
 Calling the clip region methods for any other type of map object will have
 no effect.
 */


/*
 Returns YES if the map object uses a location and radius to control the region
 within which data is displayed.
 */
- (BOOL)hasClipRegion;


/*
 Sets the clip region's location and radius for the map object to the given
 values and forces a refresh if the map object is currently active.
 */
- (void)setClipRegionLocation:(CLLocationCoordinate2D)location radiusMiles:(CLLocationDistance)radiusMiles;


/*
 Once a clip region has been set up (see above), this method can be used to
 modify only the location for the clip region.
 Forces a refresh if the map object is currently active.
 */
- (void)updateClipRegionLocation:(CLLocationCoordinate2D)location;


/*
 Once a clip region has been set up (see above), this method can be used to
 modify only the radius for the clip region.
 Forces a refresh if the map object is currently active.
 */
- (void)updateClipRegionRadiusMiles:(CLLocationDistance)radiusMiles;


/*
 Returns the clip region location for the map object.
 */
- (CLLocationCoordinate2D)getClipRegionLocation;


/*
 Returns the clip region radius for the map object.
 */
- (CLLocationDistance)getClipRegionRadiusMiles;


/*
 Regions (not used for clipping).
 Some map layers are associated with a location and region.
 Only applies to local radar currently.
 */


/*
 Returns YES if the map object uses a region.
 */
- (BOOL)hasRegion;


/*
 Returns the region location for the map object.
 */
- (CLLocationCoordinate2D)getRegionLocation;


/*
 Returns the region radius for the map object.
 */
- (CLLocationDistance)getRegionRadiusMiles;


/*
 Returns the legendID that is being used for the given layer id or nil
 if there is none.
 The returned ID will match one of the IDs defined in legends_config.xml
 and associated with layers via master_config_map.xml.
 */
- (nullable NSString *)getLegendID;


/*
 Validates the layer / overlay and, if invalid, returns an error string that 
 describes the problem, otherwise returns nil.
 */
- (nullable NSString *)validate;

@end
