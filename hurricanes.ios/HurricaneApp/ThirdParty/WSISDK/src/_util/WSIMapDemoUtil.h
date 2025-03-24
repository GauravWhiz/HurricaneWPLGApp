// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoCalloutConstants.h"

@interface WSIMapDemoUtil : NSObject

+ (NSString *)getAppName;

+ (NSString *)getBuildDateTimeString;
+ (BOOL)isPhoneIdiom;
+ (NSString *)getBundleDisplayName;
+ (NSString *)getVersionString;

+ (UIInterfaceOrientation)interfaceOrientation;
+ (UIInterfaceOrientation)deviceOrientation;
+ (BOOL)deviceOrientationIsPortrait;

+ (void)logRect:(CGRect)rect prefix:(NSString *)prefix;
+ (void)showAlertBoxForError:(NSError *)error completion:(void (^)(void))completion;
+ (CLLocationDistance)getDistanceBetweenLocation1:(CLLocationCoordinate2D)location1 andLocation2:(CLLocationCoordinate2D)location2;
+ (void)shiftView:(UIView *)view shiftX:(CGFloat)shiftX shiftY:(CGFloat)shiftY;
+ (NSString *)stringFromRect:(CGRect)rect;

+ (CGFloat)brightnessOfColor:(UIColor *)color;
+ (UIImage *)imageNamed:(NSString *)name;
+ (UIImage *)image:(UIImage *)sourceImage withSize:(CGSize)size;

/*
 Get localized text for given string. Returns stringKey if none found.
 */
+ (NSString *)localizedString:(NSString *)stringKey;
/*
 Get localized text for given string. Returns kUnLocalizedText if none found.
 */
+ (NSString *)localizedStringWithDefault:(NSString *)stringKey;
+ (NSString *)localizedString:(NSString *)stringKey withKeys:(NSArray *)keys withValues:(NSArray *)values;
+ (NSString *)localizedStringNoWarning:(NSString *)stringKey;
+ (NSString *)localizedSubString:(NSString *)string withKeys:(NSArray *)keys withValues:(NSArray *)values;

+ (NSString *)localizedWindDirectionStringFromDirectionIndex:(NSUInteger)directionIndex;
+ (NSString *)getStormTypeStringFromStormType:(WSIMapSDKTropicalStormType)stormType stormSubType:(NSInteger)stormSubType;

+ (NSString *)padString:(NSString *)string paddingSize:(NSInteger)paddingSize;
+ (NSString *)padStringOnLeft:(NSString *)string toLength:(NSUInteger)length;
+ (NSString *)padStringOnRight:(NSString *)string toLength:(NSUInteger)length;

+ (UIFont *)fixedFontOfSize:(CGFloat)size;
+ (UIFont *)fixedFontOfSizeBold:(CGFloat)size;
+ (UIFont *)fontOfSize:(CGFloat)size;
+ (UIFont *)fontOfSizeBold:(CGFloat)size;
+ (UIFont *)systemFontOfSizeBold:(CGFloat)size;
+ (UIFont *)systemFontOfSize:(CGFloat)size;

+ (CGSize)text:(NSString *)text sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

+ (NSString *)stringMPH:(CGFloat)mphValue;
+ (NSString *)stringKPH:(CGFloat)kphValue;
+ (NSString *)stringMiles:(CGFloat)mileValue;
+ (NSString *)stringKilometers:(CGFloat)kilometerValue;

+ (CGFloat)kilometersFromMiles:(CGFloat)value;
+ (CGFloat)celciusFromFarenheit:(CGFloat)value;

@end
