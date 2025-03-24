// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoConstants.h"

// The following can be used to identify specific configured layers returned
// by the map SDK or for other purposes but the values used here must match
// the values specified in maplayers_config.xml etc.
NSString* const gWSIMap_LayerLocalRadar                         = @"wsi_LayerLocalRadar";
NSString* const gWSIMap_LayerRadar                              = @"wsi_LayerRadar";
NSString* const gWSIMap_LayerRadarSmooth                        = @"wsi_LayerRadarSmooth";
NSString* const gWSIMap_LayerRadarOverSatellite                 = @"wsi_LayerRadarOverSatellite";
NSString* const gWSIMap_LayerRadarOverSatelliteSmooth           = @"wsi_LayerRadarOverSatelliteSmooth";
NSString* const gWSIMap_LayerSatellite                          = @"wsi_LayerSatellite";
NSString* const gWSIMap_LayerRoadWeather                        = @"wsi_LayerRoadWeather";
NSString* const gWSIMap_LayerSmartRadar                         = @"wsi_LayerSmartRadar";
NSString* const gWSIMap_LayerSnowfall                           = @"wsi_LayerSnowfall";
NSString* const gWSIMap_LayerSurfaceTemperatureAll              = @"wsi_LayerSurfaceTemperatureAll";
NSString* const gWSIMap_LayerSurfaceTemperatureLand             = @"wsi_LayerSurfaceTemperatureLand";
NSString* const gWSIMap_LayerSurfaceTemperatureWater            = @"wsi_LayerSurfaceTemperatureWater";
NSString* const gWSIMap_LayerWindSpeed                          = @"wsi_LayerWindSpeed";

NSString* const gWSIMap_OverlayCurrentConditions                = @"wsi_OverlayCurrentConditions";
NSString* const gWSIMap_OverlayEarthquakes                      = @"wsi_OverlayEarthquakes";
NSString* const gWSIMap_OverlayLightning                        = @"wsi_OverlayLightning";
NSString* const gWSIMap_OverlayStormTracks                      = @"wsi_OverlayStormTracks";
NSString* const gWSIMap_OverlayTemperaturePlots                 = @"wsi_OverlayTemperaturePlots";
NSString* const gWSIMap_OverlayTrafficFlow                      = @"wsi_OverlayTrafficFlow";
NSString* const gWSIMap_OverlayTrafficIncidents                 = @"wsi_OverlayTrafficIncidents";
NSString* const gWSIMap_OverlayTropicalTracks                   = @"wsi_OverlayTropicalTracks";

NSString* const gWSIMap_WeatherAlertsAll                        = @"wsi_WeatherAlertsAll";

NSString* const gWSIMap_AlertCategoryFlood                      = @"wsi_AlertCategoryFlood";
NSString* const gWSIMap_AlertCategoryMarine                     = @"wsi_AlertCategoryMarine";
NSString* const gWSIMap_AlertCategoryOther                      = @"wsi_AlertCategoryOther";
NSString* const gWSIMap_AlertCategorySevere                     = @"wsi_AlertCategorySevere";
NSString* const gWSIMap_AlertCategoryTropical                   = @"wsi_AlertCategoryTropical";
NSString* const gWSIMap_AlertCategoryWinter                     = @"wsi_AlertCategoryWinter";
NSString* const gWSIMap_AlertsEmphasizeOutlines                 = @"wsi_AlertsEmphasizeOutlines";
NSString* const gWSIMap_AlertsPutOverRoads                      = @"wsi_AlertsPutOverRoads";
NSString* const gWSIMap_AlertsShowAllAlerts                     = @"wsi_AlertsShowAllAlerts";
NSString* const gWSIMap_AlertsShowHighPriority                  = @"wsi_AlertsShowHighPriority";

CLLocationDegrees const gInvalidLatLon                          = 99999.9;
CGFloat const gKilometersToMilesMultiplier                      = 0.621371f;

NSString * const gSDKDemoDebugCalloutsChangedNotification       = @"SDKDemoDebugCalloutsChangedNotification";
NSString * const gSDKDemoMapSingleTapNotification               = @"SDKDemoMapSingleTapNotification";
NSString * const gSDKDemoMapGotDetailsForFeaturesNotification   = @"SDKDemoMapGotDetailsForFeaturesNotification";
NSString * const gSDKDemoMapRegionWillChangeNotification        = @"SDKDemoMapRegionWillChangeNotification";
NSString * const gSDKDemoUnitsWillChangeNotification            = @"SDKDemoUnitsWillChangeNotification";
