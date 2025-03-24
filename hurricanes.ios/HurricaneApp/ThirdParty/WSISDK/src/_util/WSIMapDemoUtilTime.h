// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

@interface WSIMapDemoUtilTime : NSObject

+ (NSString *)getFormattedTime:(NSDate *)layerTime;

+ (NSTimeZone *)getTimeZone;

+ (NSString *)localTimeStringFromDateString:(NSString *)dateString;
+ (NSString *)localTimeStringFromTimeIntervalSince1970:(NSTimeInterval)timeIntervalSince1970;

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format timeZone:(NSTimeZone *)timeZone; // Uses current locale
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format timeZone:(NSTimeZone *)timeZone localizeFormat:(BOOL)localizeFormat;
+ (NSString *)nowTimeStringWithFormat:(NSString *)format;
+ (NSDate *)dateWithTimeIntervalSince1970:(NSTimeInterval)timeIntervalSince1970;

+ (NSTimeInterval)timeIntervalSince1970;

+ (NSLocale *)currentLocale;
+ (NSTimeZone *)timeZone;
+ (NSString *)getDateTimeStringForISODate:(NSString *)dateString
                            dateFormatter:(NSDateFormatter *)dateFormatter
                                  pattern:(NSString *)pattern
                            defaultResult:(NSString *)defaultResult;
+ (NSString *)getDateTimeStringForUTCDate:(NSString *)dateString
                            dateFormatter:(NSDateFormatter *)dateFormatter
                                  pattern:(NSString *)pattern
                            defaultResult:(NSString *)defaultResult;

@end
