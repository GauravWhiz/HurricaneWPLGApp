// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoCalloutConstants.h"
#import "WSIMapDemoConstants.h"
#import "WSIMapDemoUtil.h"

@implementation WSIMapDemoUtil

static NSString * const kUnLocalizedText = @"?????????";
static CGFloat const kWSIKilometersInMile = 1.609344f;

+ (NSString *)getAppName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}


+ (NSString *)getBuildDateTimeString
{
    // NOTE: the __DATE__ and __TIME__ macros are only updated when this file
    // is processed by the pre-processor.
 	return [NSString stringWithFormat:@"%s %s", __DATE__, __TIME__];
}


+ (BOOL)isPhoneIdiom
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}


+ (NSString *)getBundleDisplayName
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    return [info objectForKey:@"CFBundleDisplayName"];
}


+ (NSString *)getVersionString
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    return [info objectForKey:@"CFBundleVersion"];
}


/*
 Returns the current interface orientation based on the status bar orientation.
 If the UI is currently being rotated, this might not match the current device
 orientation.
 */
+ (UIInterfaceOrientation)interfaceOrientation
{
	return [UIApplication sharedApplication].statusBarOrientation;
}


/*
 Returns the device interface orientation.
 If the UI is currently being rotated, this might not match the interface
 orientation.
 */
+ (UIInterfaceOrientation)deviceOrientation
{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    switch (deviceOrientation)
    {
        case UIDeviceOrientationLandscapeLeft:
            return UIInterfaceOrientationLandscapeRight;
        case UIDeviceOrientationLandscapeRight:
            return UIInterfaceOrientationLandscapeLeft;
        case UIDeviceOrientationPortrait:
            return UIInterfaceOrientationPortrait;
        case UIDeviceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationPortraitUpsideDown;
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationUnknown:
            ; // unknown
    }
    
    // unknown -- fall back on interface orientation
    return [self interfaceOrientation];
}


+ (BOOL)deviceOrientationIsPortrait
{
	return UIInterfaceOrientationIsPortrait([self deviceOrientation]);
}


+ (void)logRect:(CGRect)rect prefix:(NSString *)prefix
{
	WMDLog( @"%@: width=%0.0f x height=%0.0f @ x=%0.0f, y=%0.0f", prefix, rect.size.width, rect.size.height, rect.origin.x, rect.origin.y );
}


+ (void)showAlertBoxForError:(NSError *)error completion:(void (^ __nullable)(void))completion
{
    NSString *message = error.userInfo[ NSLocalizedDescriptionKey ];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:[self localizedStringNoWarning:@"OK"] style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                        completion();
                                        }];

    [alert addAction:defaultAction];
    UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootController presentViewController:alert animated:YES completion:nil];
}

// Result is in meters.
+ (CLLocationDistance)getDistanceBetweenLocation1:(CLLocationCoordinate2D)location1 andLocation2:(CLLocationCoordinate2D)location2
{
    if ((location2.latitude == gInvalidLatLon) || (location2.longitude == gInvalidLatLon))
        return 999999.9;

	CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:location1.latitude longitude:location1.longitude];
	CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:location2.latitude longitude:location2.longitude];
	CLLocationDistance distanceBetweenLocations = [loc1 distanceFromLocation:loc2];
	return distanceBetweenLocations;
}


+ (void)shiftView:(UIView *)view shiftX:(CGFloat)shiftX shiftY:(CGFloat)shiftY
{
    CGRect frame = view.frame;
    frame.origin.x += shiftX;
    frame.origin.y += shiftY;
    view.frame = frame;
}


+ (NSString *)stringFromRect:(CGRect)rect
{
	return [NSString stringWithFormat:@"(%.2f,%.2f) W:%.2f H:%.2f",
			rect.origin.x,
			rect.origin.y,
			rect.size.width,
			rect.size.height];
}


+ (CGFloat)brightnessOfColor:(UIColor *)color
{
    if (color)
    {
        // get RGB components from color
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        // calculate brightness of color
        return (components[0] * 299.0f + components[1] * 587.0f + components[2] * 114.0f) / 1000.0f;
    }
    WMDLogWarning(@"missing color!");
    return 1.0f;
}


/*
 Try to load and return image with the given name.
 */
+ (UIImage *)imageNamed:(NSString *)name
{
    UIImage *returnedImage = [UIImage imageNamed:name];
    if (!returnedImage)
        WMDLogWarning(@"couldn't find image named '%@'", name);
    return returnedImage;
}


+ (UIImage *)image:(UIImage *)sourceImage withSize:(CGSize)size scale:(CGFloat)scale
{
	UIGraphicsBeginImageContextWithOptions(size, NO, scale);
	CGRect frame = CGRectMake(0.0, 0.0, size.width, size.height);
	[sourceImage drawInRect:frame];
	UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return resImage;
}


+ (UIImage *)image:(UIImage *)sourceImage withSize:(CGSize)size
{
    return [self image:sourceImage withSize:size scale:[UIScreen mainScreen].scale];
}


+ (NSString *)localizedString:(NSString *)stringKey
{
    NSString *localizedString = NSLocalizedString(stringKey, comment);
    if (!localizedString || [localizedString isEqualToString:stringKey])
    {
        WMDLogError(@"no localization found for '%@'", stringKey);
        return stringKey;
    }
    return localizedString;
}


+ (NSString *)localizedStringWithDefault:(NSString *)stringKey
{
    NSString *localizedString = [self localizedString:stringKey];
    if (!localizedString || [localizedString isEqualToString:stringKey])
        return kUnLocalizedText;
    return localizedString;
}


+ (NSString *)localizedString:(NSString *)stringKey withKeys:(NSArray *)keys withValues:(NSArray *)values
{
	NSUInteger indexOfObject = [keys indexOfObject:stringKey];
	
	if ((indexOfObject == NSNotFound) || (indexOfObject >= values.count))
	{
		// returns passed value
		return stringKey;
	}
	// returns localized string
	return [self localizedString:[values objectAtIndex:indexOfObject]];
}


// Work around warnings about unlocalized "user-facing" text needing to be localized.
+ (NSString *)localizedStringNoWarning:(NSString *)stringKey
{
    return NSLocalizedString(stringKey, nil);
}


+ (NSString *)localizedWindDirectionStringFromDirectionIndex:(NSUInteger)directionIndex
{
    NSArray *directionsArray = @[
        [WSIMapDemoUtil localizedString:@"wind_direction_n"],
        [WSIMapDemoUtil localizedString:@"wind_direction_nne"],
        [WSIMapDemoUtil localizedString:@"wind_direction_ne"],
        [WSIMapDemoUtil localizedString:@"wind_direction_ene"],
        [WSIMapDemoUtil localizedString:@"wind_direction_e"],
        [WSIMapDemoUtil localizedString:@"wind_direction_ese"],
        [WSIMapDemoUtil localizedString:@"wind_direction_se"],
        [WSIMapDemoUtil localizedString:@"wind_direction_sse"],
        [WSIMapDemoUtil localizedString:@"wind_direction_s"],
        [WSIMapDemoUtil localizedString:@"wind_direction_ssw"],
        [WSIMapDemoUtil localizedString:@"wind_direction_sw"],
        [WSIMapDemoUtil localizedString:@"wind_direction_wsw"],
        [WSIMapDemoUtil localizedString:@"wind_direction_w"],
        [WSIMapDemoUtil localizedString:@"wind_direction_wnw"],
        [WSIMapDemoUtil localizedString:@"wind_direction_nw"],
        [WSIMapDemoUtil localizedString:@"wind_direction_nnw"],
        [WSIMapDemoUtil localizedString:@"wind_direction_none"]
    ];

    if (directionIndex >= 16)
        directionIndex = 16;
    
    return [NSString stringWithString:[directionsArray objectAtIndex:directionIndex]];
}


+ (NSString *)getStormTypeStringFromStormType:(WSIMapSDKTropicalStormType)stormType stormSubType:(NSInteger)stormSubType
{
    NSString *result = @"";
    
    switch (stormType)
    {
        case WSIMapSDKTropicalStormType_ExtraTropical:
            result = [WSIMapDemoUtil localizedString:@"map_trop_type_extra_tropical"];
            break;

        case WSIMapSDKTropicalStormType_Hurricane:
            result = [NSString stringWithFormat:@"%@ %d %@",
                       [WSIMapDemoUtil localizedString:@"map_trop_type_category"],
                       (int)stormSubType,
                       [WSIMapDemoUtil localizedString:@"map_trop_type_hurricane"]];
            break;
            
        case WSIMapSDKTropicalStormType_PostTropical:
            result = [WSIMapDemoUtil localizedString:@"map_trop_type_post_tropical"];
            break;
            
        case WSIMapSDKTropicalStormType_Remnant:
            result = [WSIMapDemoUtil localizedString:@"map_trop_type_remnant"];
            break;
            
        case WSIMapSDKTropicalStormType_SubTropicalDepression:
            result = [WSIMapDemoUtil localizedString:@"map_trop_type_subtropical_depression"];
            break;
            
        case WSIMapSDKTropicalStormType_SubTropicalStorm:
            result = [WSIMapDemoUtil localizedString:@"map_trop_type_subtropical_storm"];
            break;
            
        case WSIMapSDKTropicalStormType_SuperTyphoon:
            result = [WSIMapDemoUtil localizedString:@"map_trop_type_super_typhoon"];
            break;
            
        case WSIMapSDKTropicalStormType_TropicalCyclone:
            result = [WSIMapDemoUtil localizedString:@"map_trop_type_tropical_cyclone"];
            break;
            
        case WSIMapSDKTropicalStormType_TropicalDepression:
            result = [WSIMapDemoUtil localizedString:@"map_trop_type_tropical_depression"];
            break;
            
        case WSIMapSDKTropicalStormType_TropicalStorm:
            result = [WSIMapDemoUtil localizedString:@"map_trop_type_tropical_storm"];
            break;
            
        case WSIMapSDKTropicalStormType_Typhoon:
            result = [WSIMapDemoUtil localizedString:@"map_trop_type_typhoon"];
            break;
            
        case WSIMapSDKTropicalStormType_Unknown:
            result = [WSIMapDemoUtil localizedString:@"map_trop_type_unknown"];
            break;
    }
    
    return result;
}


+ (NSString *)localizedSubString:(NSString *)string withKeys:(NSArray *)keys withValues:(NSArray *)values
{
    #if defined(DEBUG_RETURN_QUESTION_MARKS)
    return @"?";
    #endif

    NSString *resultString = [NSString stringWithString:string];
	NSUInteger indexOfObject = 0;
	
	while (indexOfObject < keys.count)
	{
		resultString = [resultString stringByReplacingOccurrencesOfString:[keys objectAtIndex:indexOfObject]
															   withString:[self localizedString:[values objectAtIndex:indexOfObject]]];
		indexOfObject++;
	}
	return resultString;
}


+ (NSString *)getBlankStringWithLength:(NSUInteger)length
{
    NSString *blankString = @" ";
    blankString = [blankString stringByPaddingToLength:length withString:@" " startingAtIndex:0];
    return blankString;
}


+ (NSString *)padStringOnLeft:(NSString *)string toLength:(NSUInteger)length
{
    if ([string length] < length)
    {
        NSString *padString = [self getBlankStringWithLength:length-[string length]];
        return [NSString stringWithFormat:@"%@%@", padString, string];
    }
    return string;
}


+ (NSString *)padStringOnRight:(NSString *)string toLength:(NSUInteger)length
{
    if ([string length] < length)
    {
        NSString *padString = [self getBlankStringWithLength:length-[string length]];
        return [NSString stringWithFormat:@"%@%@", string, padString];
    }
    return string;
}


+ (NSString *)padString:(NSString *)string paddingSize:(NSInteger)paddingSize
{
    if ([string length] < paddingSize)
    {
        NSString *padString = @" ";
        padString = [padString stringByPaddingToLength:paddingSize-[string length] withString:@" " startingAtIndex:0];
        if (YES)
            return [NSString stringWithFormat:@"%@%@", string, padString]; // pad on right
        else
            return [NSString stringWithFormat:@"%@%@", padString, string]; // pad on left
    }
    return string;
}


+ (UIFont *)fixedFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Courier" size:size];
}


+ (UIFont *)fixedFontOfSizeBold:(CGFloat)size
{
    return [UIFont fontWithName:@"Courier-Bold" size:size];
}


+ (UIFont *)fontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Helvetica" size:size];
}


+ (UIFont *)fontOfSizeBold:(CGFloat)size
{
    return [UIFont fontWithName:@"Helvetica-Bold" size:size];
}


+ (UIFont *)systemFontOfSizeBold:(CGFloat)size
{
    return [UIFont boldSystemFontOfSize:size];
}


+ (UIFont *)systemFontOfSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size];
}


+ (CGSize)text:(NSString *)text sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    if (text == nil || font == nil)
        return CGSizeZero;
    
    return [text boundingRectWithSize:size
                options:NSStringDrawingUsesLineFragmentOrigin
                attributes:@{NSFontAttributeName:font}
                context:nil].size;
}

+ (NSString *)stringMPH:(CGFloat)mileValue
{
	return [NSString stringWithFormat:@"%.0f%@", mileValue, [self localizedString:@"mph_sign"]];
}

+ (NSString *)stringKPH:(CGFloat)kmValue
{
    return [NSString stringWithFormat:@"%.0f%@", kmValue, [self localizedString:@"kph_sign"]];
}

+ (NSString *)stringMiles:(CGFloat)mileValue
{
	return [NSString stringWithFormat:@"%.0f%@", mileValue, [self localizedString:@"miles_sign"]];
}

+ (NSString *)stringKilometers:(CGFloat)kmValue
{
	return [NSString stringWithFormat:@"%.0f%@", kmValue, [self localizedString:@"km_sign"]];
}

+ (CGFloat)kilometersFromMiles:(CGFloat)value
{
	return value * kWSIKilometersInMile;
}


+ (CGFloat)celciusFromFarenheit:(CGFloat)value
{
    return (5.0/9.0)*(value - 32.0);
}

@end
