// IBM Confidential
// Copyright IBM Corp. 2016, 2023. Copyright WSI Corporation 1998, 2015.

#import <Foundation/Foundation.h>

// layer frame data keys
extern NSString* const gWSIMapSDKLayerObservedTimes;
extern NSString* const gWSIMapSDKLayerPredictedTimes;

// layer frame info keys
extern NSString* const gWSIMapSDKLayerFrameCurrentTime;
// for closest frame to current time if more than one raster layer is enabled
extern NSString* const gWSIMapSDKLayerFrameIndex;
extern NSString* const gWSIMapSDKLayerFrameOffset;
extern NSString* const gWSIMapSDKLayerFrameTime;

// layer looping info keys
extern NSString* const gWSIMapSDKLayerLoopingDwell;
extern NSString* const gWSIMapSDKLayerLoopingEnabled;
extern NSString* const gWSIMapSDKLayerLoopingPeriodPerFrame;
extern NSString* const gWSIMapSDKLayerLoopingPlayRate;
extern NSString* const gWSIMapSDKLayerLoopingTimeStart;
extern NSString* const gWSIMapSDKLayerLoopingTimeEnd;

// smart radar data dictionary keys
extern NSString* const gWSIMapSDKLocalRadarDataSiteIDKey;
extern NSString* const gWSIMapSDKLocalRadarDataStatusKey;
extern NSString* const gWSIMapSDKLocalRadarDataRangeKey;
extern NSString* const gWSIMapSDKLocalRadarDataLatitudeKey;
extern NSString* const gWSIMapSDKLocalRadarDataLongitudeKey;
extern NSString* const gWSIMapSDKLocalRadarDataLastUpdatedKey;

typedef NS_ENUM(NSInteger, WSIMapSDKMapStyle)
{
    WSIMapSDKMapStyleMin = 0,                           // min sentinal
    WSIMapSDKMapStyleCustom,                            // user provided map style url and layer name info
    WSIMapSDKMapStyleCustom2,                           // user provided map style url and layer name info
    WSIMapSDKMapStyleCustom3,                           // user provided map style url and layer name info
    WSIMapSDKMapStyleNone,                              // ignored
    WSIMapSDKMapStyleB2BSatelliteDarkWithLabels,        // B2B - similar to MKMapView terrain (dark)
    WSIMapSDKMapStyleB2BSatelliteLightWithLabels,       // B2B - similar to MKMapView terrain (light)
    WSIMapSDKMapStyleB2BTerrainDarkWithLabels,          // B2B
    WSIMapSDKMapStyleB2BTerrainLightWithLabels,         // B2B
    WSIMapSDKMapStyleMax // max sentinal

    
};

typedef NS_ENUM(NSInteger, WSIMapSDKLayerDataState)
{
    WSIMapSDKLayerDataStatePastOnly,
    WSIMapSDKLayerDataStatePastAndFuture,
    WSIMapSDKLayerDataStateFutureOnly,
};


// Debug log levels. Uses a bitfield - can be combined.         // controls
extern NSUInteger const WSIMapSDKDebugLogLevelNone;             //
extern NSUInteger const WSIMapSDKDebugLogLevelAnimation;        // animation logs (start/stop looping)
extern NSUInteger const WSIMapSDKDebugLogLevelAnnotations;      // annotation add/remove logs
extern NSUInteger const WSIMapSDKDebugLogLevelBasic;            // basic logs
extern NSUInteger const WSIMapSDKDebugLogLevelLayers;           // layer processing logs
extern NSUInteger const WSIMapSDKDebugLogLevelMap;              // map layer logs
extern NSUInteger const WSIMapSDKDebugLogLevelSpam;             // spammy logs
extern NSUInteger const WSIMapSDKDebugLogLevelTime;             // time logs
extern NSUInteger const WSIMapSDKDebugLogLevelUpdates;          // product update logs
extern NSUInteger const WSIMapSDKDebugLogLevelAll;              // all logs enabled (spammy)

// smart radar status flags (bitfield)

typedef NS_ENUM(NSInteger, WSIMapSDKLocalRadarState)
{
    /*
     At most one local radar can be active.
     The closest "CanActivate" local radar to the center of the current map
     view is always the active local radar, if the map is zoomed in sufficiently
     for the range of the local radar (or if autozoom+recenter is disabled --
     see setLocalRadarAutoZoomRecenter).
     If a local radar is active and it's online, the data (tiles) for that local
     radar will be shown and its sweep arm will be turned on. If no local radar
     is active, the national radar data (tiles) will be shown (assuming the
     SmartRadar layer is selected via the application).
     It's possible for multiple local radar layers to have WSIMapSDKLocalRadarStateOnline /
     WSIMapSDKLocalRadarStateInView / WSIMapSDKLocalRadarStateZoomed but at most one local
     radar layer can have WSIMapSDKLocalRadarStateSelected.
     */
    WSIMapSDKLocalRadarStateNone             = 0x00000000,
    WSIMapSDKLocalRadarStateContainsMap      = 0x00000001,   // local radar contains the map view (could be selected)
    WSIMapSDKLocalRadarStateOnline           = 0x00000002,   // local radar is online
    WSIMapSDKLocalRadarStateSelected         = 0x00000004,   // local radar is selected (active)
    WSIMapSDKLocalRadarStateZoomed           = 0x00000010,   // map zoom level is less than the value specified via setSmartRadarZoomedLevel
};

extern NSString *const WSIMapSDKUserLocationFillColor;
extern NSString *const WSIMapSDKUserLocationBorderColor;
extern NSString *const WSIMapSDKUserLocationFillOpacity;
extern NSString *const WSIMapSDKUserLocationBorderWidth;




