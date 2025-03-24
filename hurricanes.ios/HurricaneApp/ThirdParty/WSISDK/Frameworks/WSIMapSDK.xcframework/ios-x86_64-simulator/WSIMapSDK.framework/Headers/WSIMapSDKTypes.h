// IBM Confidential
// Copyright IBM Corp. 2016, 2023. Copyright WSI Corporation 1998, 2015.
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, WSIMapSDKUnitPreferences)
{
    WSIMapSDKUnitPreferencesImperial  = 0,
    WSIMapSDKUnitPreferencesMetric    = 1
};

typedef NSDictionary<NSString*, NSString*> WSIMapSDKStringsDictionary;
typedef NSDictionary<NSString*,NSArray<NSNumber*>*> WSIMapSDKTimeStampsDictionary;
typedef NSDictionary<NSString*,WSIMapSDKTimeStampsDictionary*> WSIMapSDKDataInfoDictionary;
typedef NSDictionary<NSString*,NSString*> WSIMapSDKFrameInfoDictionary;

/*
 WSIMapSDKSmartRadarServiceData dictionary
 The keys are the layer (Tesssera) ids for each local radar (e.g. "0123") and
 the values are WSIMapSDKSmartRadarLayerData* objects.
 
 WSIMapSDKSmartRadarLayerData dictionary
 The keys are one of the gWSIMapSDKLocalRadarDataXXX keys (see WSIMapSDKConstants.h)
 and the values are always NSString* objects.

 Note that the site and layerID values aren't ever expected to change but are
 provided in the available data for convenience.
*/
typedef NSDictionary<NSString*,NSString*> WSIMapSDKSmartRadarLayerData;
typedef NSDictionary<NSString*,WSIMapSDKSmartRadarLayerData*> WSIMapSDKSmartRadarServiceData;

typedef struct {
    CLLocationCoordinate2D centerCoordinate;
    double zoomLevel;
} WSIMapSDKRegion;

NS_INLINE WSIMapSDKRegion WSIMapSDKRegionMake(CLLocationCoordinate2D centerCoordinate, double zoomLevel)
{
    WSIMapSDKRegion region;
    region.centerCoordinate = centerCoordinate;
    region.zoomLevel = zoomLevel;
    return region;
}

NS_INLINE WSIMapSDKRegion WSIMapSDKRegionInvalidMake(void)
{
    return WSIMapSDKRegionMake(kCLLocationCoordinate2DInvalid, 0.0);
}
