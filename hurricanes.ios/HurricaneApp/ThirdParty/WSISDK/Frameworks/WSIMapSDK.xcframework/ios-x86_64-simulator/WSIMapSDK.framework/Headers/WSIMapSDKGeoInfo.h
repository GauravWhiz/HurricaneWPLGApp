// IBM Confidential
// Copyright IBM Corp. 2016, 2023. Copyright WSI Corporation 1998, 2015.
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

typedef NSArray<NSString*> WSIMapSDKAnnotationInfoList;
typedef NSDictionary<NSString*, NSString*> WSIMapSDKFeatureInfoDictionary;
typedef NSArray<WSIMapSDKFeatureInfoDictionary*> WSIMapSDKFeatureInfoList;

typedef NS_ENUM(NSInteger, WSIMapSDKFeatureType)
{
    WSIMapSDKFeatureType_None = 0,
    WSIMapSDKFeatureType_Alert,
    WSIMapSDKFeatureType_CurrentCondition,
    WSIMapSDKFeatureType_Earthquake,
    WSIMapSDKFeatureType_TropicalTrack,
    WSIMapSDKFeatureType_Lightning,
    WSIMapSDKFeatureType_StormTrack,
    WSIMapSDKFeatureType_TemperaturePlot,
    WSIMapSDKFeatureType_TrafficFlow,
    WSIMapSDKFeatureType_TrafficIncident,
};

typedef NS_ENUM(NSUInteger, WSIMapSDKTrafficIncidentType)
{
    WSIMapSDKTrafficIncidentType_None,
    WSIMapSDKTrafficIncidentType_Construction,
    WSIMapSDKTrafficIncidentType_Event,
    WSIMapSDKTrafficIncidentType_Flow,
    WSIMapSDKTrafficIncidentType_Incident,
    WSIMapSDKTrafficIncidentType_Police,
    WSIMapSDKTrafficIncidentType_Weather,
};

typedef NS_ENUM(NSUInteger, WSIMapSDKTropicalStormType)
{
    WSIMapSDKTropicalStormType_ExtraTropical,
    WSIMapSDKTropicalStormType_Hurricane,
    WSIMapSDKTropicalStormType_PostTropical,
    WSIMapSDKTropicalStormType_Remnant,
    WSIMapSDKTropicalStormType_SubTropicalDepression,
    WSIMapSDKTropicalStormType_SubTropicalStorm,
    WSIMapSDKTropicalStormType_SuperTyphoon,
    WSIMapSDKTropicalStormType_TropicalCyclone,
    WSIMapSDKTropicalStormType_TropicalDepression,
    WSIMapSDKTropicalStormType_TropicalStorm,
    WSIMapSDKTropicalStormType_Typhoon,
    WSIMapSDKTropicalStormType_Unknown,
};

//
// Keys for use with WSIMapSDKFeatureInfoDictionary dictionaries when
// one or more features are tapped.
// Mostly used to fetch values for features for display in a callout.
// The availability of specific entries will depend on the tapped
// feature.
// See https://docs.google.com/spreadsheets/d/1fdQL-yycaJ5s_NnSEJQDLGey0loRLIya3SYIlauHFEY
// for more details.
//

// shared by all features
extern NSString* const gWMSKey_FeatureID;                       // unique id for the feature
extern NSString* const gWMSKey_FeatureLatitude;                 // feature latitude
extern NSString* const gWMSKey_FeatureLongitude;                // feature longitude
extern NSString* const gWMSKey_FeatureType;                     // type name for the feature, e.g. "Alert", "Earthquake"

// alerts
extern NSString* const gWMSKeyAlert_Category;                   // category (for combo / all alert layers)
extern NSString* const gWMSKeyAlert_CountryCode;                // county code
extern NSString* const gWMSKeyAlert_EffectiveTimeLocal;         // effective time (ISO 8601)
extern NSString* const gWMSKeyAlert_EffectiveTimeLocalTZ;       // time zone for effective time
extern NSString* const gWMSKeyAlert_ExpireTimeLocalTZ;          // time zone for alert expire time
extern NSString* const gWMSKeyAlert_ExpireTimeSeconds;          // expire time (since epoch)
extern NSString* const gWMSKeyAlert_FillColor;                  // color used to fill alert polygon ("RRR,GGG,BBB") - from map_alert_styles.xml
extern NSString* const gWMSKeyAlert_FillOpacity;                // opacity used to fill alert fill (e.g. 0.5) - from map_alert_styles.xmly;
extern NSString* const gWMSKeyAlert_HeadlineText;               // headline text for alert (e.g. Flood Warning until 12:30PM CDT SAT)
extern NSString* const gWMSKeyAlert_ID;                         // unique identifier for the alert
extern NSString* const gWMSKeyAlert_OutlineColor;               // color used to outline alert polygon ("RRR,GGG,BBB") - from map_alert_styles.xml
extern NSString* const gWMSKeyAlert_OutlineOpacity;             // opacity used to outline alert fill (e.g. 0.5) - from map_alert_styles.xml
extern NSString* const gWMSKeyAlert_Phenomena;                  // phenomena (e.g. "FL", "flashFreeze" etc.)
extern NSString* const gWMSKeyAlert_Priority;                   // priority - from map_alert_styles.xml
extern NSString* const gWMSKeyAlert_Significance;               // significance (e.g. "W", "A", "O" etc.)
extern NSString* const gWMSKeyAlert_ValidTimeSeconds;           // valid time
// (details fetch required)
extern NSString* const gWMSKeyAlertDetails_Description;         // (details fetch required) detailed description
extern NSString* const gWMSKeyAlertDetails_EventDescription;    // (details fetch required) event short description
extern NSString* const gWMSKeyAlertDetails_ExpireTimeLocal;     // (details fetch required) expire time (ISO 8601)
extern NSString* const gWMSKeyAlertDetails_Overview;            // (details fetch required) detailed overview text

// current conditions
extern NSString* const gWMSKeyCondition_DateTimeGMTSeconds;     // date time GMT in seconds
extern NSString* const gWMSKeyCondition_DateTimeLocal;          // date time local timezone
extern NSString* const gWMSKeyCondition_DayInd;                 // day index
extern NSString* const gWMSKeyCondition_DewpointF;              // dewpoint in F
extern NSString* const gWMSKeyCondition_Direction;              // direction
extern NSString* const gWMSKeyCondition_FeelsLikeF;             // "feels like" temperature in F
extern NSString* const gWMSKeyCondition_IconCode;               // icon code (based on weather conditions)
extern NSString* const gWMSKeyCondition_IconCodeExt;            // extended icon code (based on weather conditions)
extern NSString* const gWMSKeyCondition_ImageName;              // name of image used to show feature on map
extern NSString* const gWMSKeyCondition_Name;                   // name
extern NSString* const gWMSKeyCondition_TempF;                  // temperature in degrees F
extern NSString* const gWMSKeyCondition_TempFChange1Hour;       // 1 hour temperature change in degrees F
extern NSString* const gWMSKeyCondition_TempFChange24Hour;      // 24 hour temperature change in degrees F
extern NSString* const gWMSKeyCondition_ValidTimeSeconds;       // valid time in seconds
extern NSString* const gWMSKeyCondition_WindSpeedMPH;           // wind speed

// earthquakes
extern NSString* const gWMSKeyEarthquake_DepthKM;               // depth in kilometers
extern NSString* const gWMSKeyEarthquake_ImageName;             // name of image used to show feature on map
extern NSString* const gWMSKeyEarthquake_Magnitude;             // magnitude on Richter scale
extern NSString* const gWMSKeyEarthquake_MagnitudeType;         // magnitude algorithm type
extern NSString* const gWMSKeyEarthquake_ScaleFactor;           // scale factor used with image / icon
extern NSString* const gWMSKeyEarthquake_ValidTimeSeconds;      // valid time in seconds
// (details fetch required)
extern NSString* const gWMSKeyEarthquakeDetails_Place;          // (details fetch required) e.g. "5km east of Moose Lake, CA" etc.
extern NSString* const gWMSKeyEarthquakeDetails_Type;           // (details fetch required) earthquake, explosion, quarry etc.

// incidents (traffic)
extern NSString* const gWMSKeyIncident_DescriptionBrief;        // brief description
extern NSString* const gWMSKeyIncident_DescriptionLong;         // long description
extern NSString* const gWMSKeyIncident_DescriptionOther;        // other description
extern NSString* const gWMSKeyIncident_ScaleFactor;             // scale factor used with image / icon
extern NSString* const gWMSKeyIncident_Severity;                // severity type (0:Minimal, 1:Low, 2:Moderate, 3:High, 4:Severe)
extern NSString* const gWMSKeyIncident_ImageName;               // name of image used to show feature on map
extern NSString* const gWMSKeyIncident_OccurenceEndTime;        // incident end time
extern NSString* const gWMSKeyIncident_OccurenceStartTime;      // incident start time
extern NSString* const gWMSKeyIncident_Type;                    // type (1:Construction, 2:Event, 3:Flow, 4:Incident, 5:Road Weather, 6:Police)
extern NSString* const gWMSKeyIncident_ValidTimeSeconds;        // valid time in seconds

//lightning
extern NSString* const gWMSKeyLightning_Amplitude;              // signed peak amplitude in kA (>0: cloud to ground, <0: ground to cloud)
extern NSString* const gWMSKeyLightning_ImageName;              // name of image used to show feature on map
extern NSString* const gWMSKeyLightning_ValidTimeSeconds;       // valid time in seconds

// storm tracks
extern NSString* const gWMSKeyStorm_Direction;                  // heading (azimuth) in degrees (need to flip 180 degrees)
extern NSString* const gWMSKeyStorm_HailMaxSizeInches;          // max hail size in inches
extern NSString* const gWMSKeyStorm_HailProbability;            // probability of hail (0-100 %)
extern NSString* const gWMSKeyStorm_ImageName;                  // name of image used to show feature on map
extern NSString* const gWMSKeyStorm_Impact;                     // storm track overall impact (0-10)
extern NSString* const gWMSKeyStorm_ImpactFlood;                // storm track flood impact (0-10)
extern NSString* const gWMSKeyStorm_ImpactHail;                 // storm track hail impact (0-10)
extern NSString* const gWMSKeyStorm_ImpactTornado;              // storm track tornado impact (0-10)
extern NSString* const gWMSKeyStorm_ImpactWind;                 // storm track wind impact (0-10)
extern NSString* const gWMSKeyStorm_PrecipRateMMPerHour;        // precipitation rate for a storm track in mm per hour
extern NSString* const gWMSKeyStorm_RangeKM;                    // storm track range from radar location in kilometers
extern NSString* const gWMSKeyStorm_SpeedMetersPerSecond;       // speed in meters per second
extern NSString* const gWMSKeyStorm_StartTimeSeconds;           // start time in seconds since epoch
extern NSString* const gWMSKeyStorm_StormID;                    // storm id
extern NSString* const gWMSKeyStorm_Type;                       // type
extern NSString* const gWMSKeyStorm_ValidTimeSeconds;           // valid time in seconds

// tropical tracks
extern NSString* const gWMSKeyTropical_DateTimeLocal;           // date time local timezone
extern NSString* const gWMSKeyTropical_Direction;               // heading (azimuth) in degrees
extern NSString* const gWMSKeyTropical_DirectionCardinal;       // cardinal direction (e.g. SE)
extern NSString* const gWMSKeyCondition_ImageName;              // name of image used to show feature on map
extern NSString* const gWMSKeyTropical_ImageName;               // name of image used to show feature on map
extern NSString* const gWMSKeyTropical_MaxSustainedWindMPH;     // max sustained wind in MPH
extern NSString* const gWMSKeyTropical_SpeedMPH;                // ground speed in mph
extern NSString* const gWMSKeyTropical_StormFeatureType;        // feature type (CurrentPosition / ForecastPosition / HistoryPosition / ProjectedTrack)
extern NSString* const gWMSKeyTropical_StormID;                 // storm id
extern NSString* const gWMSKeyTropical_StormName;               // storm name
extern NSString* const gWMSKeyTropical_SubType;                 // tropical track sub type
extern NSString* const gWMSKeyTropical_Type;                    // tropical track type
extern NSString* const gWMSKeyTropical_ValidTimeSeconds;        // valid time in seconds
extern NSString* const gWMSKeyTropical_WindGustMPH;             // max wind gust speed in mph
