// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

// convenience constants for layers defined via maplayers_config.xml etc.
extern NSString* const gWSIMap_LayerLocalRadar;
extern NSString* const gWSIMap_LayerRadar;                      // radar
extern NSString* const gWSIMap_LayerRadarSmooth;                // smoothed radar
extern NSString* const gWSIMap_LayerRadarOverSatellite;         // radar + satellite
extern NSString* const gWSIMap_LayerRadarOverSatelliteSmooth;   // radar + satellite (smoothed)
extern NSString* const gWSIMap_LayerSatellite;                  // satellite
extern NSString* const gWSIMap_LayerRoadWeather;
extern NSString* const gWSIMap_LayerSmartRadar;
extern NSString* const gWSIMap_LayerSnowfall;                   // x hour snow fall
extern NSString* const gWSIMap_LayerSurfaceTemperatureAll;      // surface temperature (land+water)
extern NSString* const gWSIMap_LayerSurfaceTemperatureLand;     // surface temperature (land mask)
extern NSString* const gWSIMap_LayerSurfaceTemperatureWater;    // surface temperature (water mask)
extern NSString* const gWSIMap_LayerWaterTemperature;
extern NSString* const gWSIMap_LayerWindSpeed;

extern NSString* const gWSIMap_OverlayCurrentConditions;
extern NSString* const gWSIMap_OverlayEarthquakes;
extern NSString* const gWSIMap_OverlayLightning;
extern NSString* const gWSIMap_OverlayStormTracks;
extern NSString* const gWSIMap_OverlayTemperaturePlots;
extern NSString* const gWSIMap_OverlayTrafficFlow;
extern NSString* const gWSIMap_OverlayTrafficIncidents;
extern NSString* const gWSIMap_OverlayTropicalTracks;

extern NSString* const gWSIMap_WeatherAlertsAll;

extern NSString* const gWSIMap_AlertCategoryFlood;
extern NSString* const gWSIMap_AlertCategoryMarine;
extern NSString* const gWSIMap_AlertCategoryOther;
extern NSString* const gWSIMap_AlertCategorySevere;
extern NSString* const gWSIMap_AlertCategoryTropical;
extern NSString* const gWSIMap_AlertCategoryWinter;
extern NSString* const gWSIMap_AlertsEmphasizeOutlines;
extern NSString* const gWSIMap_AlertsPutOverRoads;
extern NSString* const gWSIMap_AlertsShowAllAlerts;
extern NSString* const gWSIMap_AlertsShowHighPriority;

extern CLLocationDegrees const gInvalidLatLon;
extern CGFloat const gKilometersToMilesMultiplier;

extern NSString * const gSDKDemoDebugCalloutsChangedNotification;
extern NSString * const gSDKDemoMapSingleTapNotification;
extern NSString * const gSDKDemoMapGotDetailsForFeaturesNotification;
extern NSString * const gSDKDemoMapRegionWillChangeNotification;
extern NSString * const gSDKDemoUnitsWillChangeNotification;
