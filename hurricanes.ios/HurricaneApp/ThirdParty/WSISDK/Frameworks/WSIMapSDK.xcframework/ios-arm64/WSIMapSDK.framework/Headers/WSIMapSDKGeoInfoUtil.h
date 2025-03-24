// IBM Confidential
// Copyright IBM Corp. 2016, 2023. Copyright WSI Corporation 1998, 2015.

#import "WSIMapSDKGeoInfo.h"

@interface WSIMapSDKGeoInfoUtil : NSObject

/*
 Methods for fetching values for the given key / feature info dictionary as
 a specific type.
 Mostly used for callouts.
 */
+ (nonnull NSString *)getStringForFeature:(nonnull WSIMapSDKFeatureInfoDictionary *)featureInfo key:(nonnull NSString *)key;
+ (nullable NSString *)getStringForFeature:(nonnull WSIMapSDKFeatureInfoDictionary *)featureInfo key:(nonnull NSString *)key withDefault:(nullable NSString *)defaultValue;
+ (nullable NSString *)getStringForFeatureSanitized:(nonnull WSIMapSDKFeatureInfoDictionary *)featureInfo key:(nonnull NSString *)key withDefault:(nullable NSString *)defaultValue; // removes leading whitespace, '$$' and converts '\n" to ' ' etc.
+ (nullable UIColor *)getRGBColorForFeature:(nonnull WSIMapSDKFeatureInfoDictionary *)featureInfo key:(nonnull NSString *)key;
+ (nullable NSDate *)getDateForFeature:(nonnull WSIMapSDKFeatureInfoDictionary *)featureInfo key:(nonnull NSString *)key;
+ (double)getDoubleForFeature:(nonnull WSIMapSDKFeatureInfoDictionary *)featureInfo key:(nonnull NSString *)key;
+ (CGFloat)getFloatForFeature:(nonnull WSIMapSDKFeatureInfoDictionary *)featureInfo key:(nonnull NSString *)key;
+ (nullable NSString *)getImageNameForFeature:(nonnull WSIMapSDKFeatureInfoDictionary *)featureInfo key:(nonnull NSString *)key;
+ (nullable UIImage *)getImageForFeature:(nonnull WSIMapSDKFeatureInfoDictionary *)featureInfo key:(nonnull NSString *)key fallbackImageName:(nullable NSString *)fallbackImageName;
+ (NSInteger)getIntegerForFeature:(nonnull WSIMapSDKFeatureInfoDictionary *)featureInfo key:(nonnull NSString *)key;
+ (WSIMapSDKTrafficIncidentType)getTrafficIncidentTypeForFeature:(nonnull WSIMapSDKFeatureInfoDictionary*)featureInfo;
+ (WSIMapSDKTropicalStormType)getTropicalTypeForFeature:(nonnull WSIMapSDKFeatureInfoDictionary*)featureInfo;

/*
 Return the type for a feature (info dictionary).
 See WSIMapSDKFeatureType.
 */
+ (WSIMapSDKFeatureType)getTypeForFeature:(nonnull WSIMapSDKFeatureInfoDictionary *)featureInfo;

/*
 Creates a WSIMapSDKFeatureInfoList containing geo objects from geoObjects
 matching the given type and limited to at most maxObjects objects (if > 0).
 */
+ (nonnull WSIMapSDKFeatureInfoList *)getObjectsOfType:(WSIMapSDKFeatureType)geoObjectType fromArray:(nonnull WSIMapSDKFeatureInfoList *)geoObjects maxObjects:(NSUInteger)maxObjects;

/*
 Creates a WSIMapSDKFeatureInfoList containing geo objects from geoObjects
 NOT matching the given type.
 */
+ (nonnull WSIMapSDKFeatureInfoList *)getObjectsNotOfType:(WSIMapSDKFeatureType)geoObjectType fromArray:(nonnull WSIMapSDKFeatureInfoList *)geoObjects maxObjects:(NSUInteger)maxObjects;

/*
 Looks in featureInfoList for a WSIMapSDKFeatureInfoDictionary that matches
 geoObjectInfo (by comparing FeatureIDs).
 If found, the matching (updated) entry is returned, otherwise nil is returned.
 
 Use this in your UI and other code when the wsiMapSDKMapFeaturesGotDetails
 delegate method is called after you request details for one or more features.
 If an updated entry is found for the feature you are interested in you may
 want to update your UI etc.
 
 See wsiMapSDKMapFeaturesGotDetails for more information.
 */
+ (nullable WSIMapSDKFeatureInfoDictionary *)getUpdatedFeatureInfoDictionary:(nonnull WSIMapSDKFeatureInfoDictionary *)geoObjectInfo fromFeatureInfoList:(nonnull WSIMapSDKFeatureInfoList *)featureInfoList;

/*
 Returns a value in 0..15 with 0=N, 1=NNE, 2=NE, 3=ENE, 4=E, 5=ESE, 6=SE,
 7=SSE, 8=S, 9=SSW, 10=SW, 11=WSW, 12=W, 13=WNW, 14=NW, 15=NNW. Callers
 might want to convert the returned value to localized text.
 */
+ (NSUInteger)getDirectionIndexForFeature:(nonnull WSIMapSDKFeatureInfoDictionary *)geoInfo key:(nonnull NSString *)key shouldFlip:(BOOL)shouldFlip;

/*
 Returns the speed associated with the given key in MPH or KPH
 depending on the SDK's current distance units.
 */
+ (CGFloat)getSpeedForFeature:(nonnull WSIMapSDKFeatureInfoDictionary *)geoInfo metersPerSecondKey:(nonnull NSString *)metersPerSecondKey;
+ (CGFloat)getSpeedForFeature:(nonnull WSIMapSDKFeatureInfoDictionary *)geoInfo milesPerHourKey:(nonnull NSString *)milesPerHourKey;

+ (nonnull NSString *)getStringForFeatureType:(WSIMapSDKFeatureType)featureType;

@end
