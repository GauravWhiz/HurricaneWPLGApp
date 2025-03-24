// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoUtilTime.h"
#import "WSIMapDemoUtil.h"

NSString * const gTimeFormatISO = @"yyyy-MM-dd'T'HH:mm:ssZ";

@implementation WSIMapDemoUtilTime

+ (NSString *)getFormattedTime:(NSDate *)layerTime
{
    if (!layerTime)
        return nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *formattedTime = [formatter stringFromDate:layerTime];
    return formattedTime;
}


+ (NSString *)getLocalizedFormatFor:(NSString *)format
{
    return [NSDateFormatter dateFormatFromTemplate:format options:0 locale:[NSLocale currentLocale]];
}

/*
 Defaults to EST.
 Apps will likely want to use the time zone for specific location.
 */
+ (NSTimeZone *)getTimeZone
{
    //NSLog(@"%@", [NSTimeZone knownTimeZoneNames]);
    return [NSTimeZone timeZoneWithName:@"America/New_York"];
    //return [NSTimeZone timeZoneForSecondsFromGMT:0];
}


+ (NSString *)localTimeStringFromDateString:(NSString *)dateString
{
    NSTimeInterval timeInterval = dateString.doubleValue;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return [self getFormattedTime:date];
}


+ (NSString *)localTimeStringFromTimeIntervalSince1970:(NSTimeInterval)timeIntervalSince1970
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeIntervalSince1970];
    return [self getFormattedTime:date];
}


+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format timeZone:(NSTimeZone *)timeZone localizeFormat:(BOOL)localizeFormat
{
    NSString *formatToUse = localizeFormat ? [self getLocalizedFormatFor:format] : format;

   	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSLocale *loc = [NSLocale currentLocale];
    
    //workaround for BTOBIOS-3307
    if([loc.localeIdentifier isEqualToString:@"es_MX"] && ([[format lowercaseString] rangeOfString:@"z"].location != NSNotFound)  )
        loc = [NSLocale localeWithLocaleIdentifier:@"es_US"];
    
    
    [dateFormatter setLocale:loc];
    [dateFormatter setDateFormat:formatToUse];
	[dateFormatter setTimeZone:timeZone];
    
    return [dateFormatter stringFromDate:date];
}


+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format
{
    return [self stringFromDate:date format:format timeZone:[NSTimeZone localTimeZone]];
}


+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format timeZone:(NSTimeZone *)timeZone
{
    return [self stringFromDate:date format:format timeZone:timeZone localizeFormat:NO];
}


+ (NSString *)nowTimeStringWithFormat:(NSString *)format
{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0.0];
    return [self stringFromDate:date format:format];
}


+ (NSDate *)dateWithTimeIntervalSince1970:(NSTimeInterval)timeIntervalSince1970
{
    return [NSDate dateWithTimeIntervalSince1970:timeIntervalSince1970];
}


+ (NSTimeInterval)timeIntervalSince1970
{
    NSDate *date = [NSDate date];
    return [date timeIntervalSince1970];
}


+ (NSLocale *)currentLocale
{
    return [NSLocale currentLocale];
}

+ (NSTimeZone *)timeZone
{
    return [WSIMapDemoUtilTime getTimeZone];
}


+ (NSString *)getDateTimeStringForISODate:(NSString *)dateString
                            dateFormatter:(NSDateFormatter *)dateFormatter
                                  pattern:(NSString *)pattern
                            defaultResult:(NSString *)defaultResult
{
    NSString *returnedString = defaultResult;
    
    if (![dateString isEqualToString:@""])
    {
        [dateFormatter setDateFormat:gTimeFormatISO];
        NSDate *dateTime = [dateFormatter dateFromString:dateString];
        if (!dateTime)
        {
            WMDLogError(@" getting time from '%@'", dateString);
        }
        else
        {
            [dateFormatter setDateFormat:[WSIMapDemoUtil localizedString:pattern]];
            returnedString = [dateFormatter stringFromDate:dateTime];
        }
    }
    return returnedString;
}


+ (NSString *)getDateTimeStringForUTCDate:(NSString *)dateString
                            dateFormatter:(NSDateFormatter *)dateFormatter
                                  pattern:(NSString *)pattern
                            defaultResult:(NSString *)defaultResult
{
    NSString *returnedString = defaultResult;
    
    if (![dateString isEqualToString:@""])
    {
        [dateFormatter setDateFormat:gTimeFormatISO];
        NSDate *dateTime = [self dateWithTimeIntervalSince1970:dateString.doubleValue];
        if (!dateTime)
        {
            WMDLogError(@" getting time from '%@'", dateString);
        }
        else
        {
            [dateFormatter setDateFormat:[WSIMapDemoUtil localizedString:pattern]];
            returnedString = [dateFormatter stringFromDate:dateTime];
        }
    }
    return returnedString;
}
@end
