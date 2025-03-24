// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoGeoObjectInfoCell.h"

#import "WSIMapDemoCalloutConstants.h"
#import "WSIMapDemoGeoCalloutView.h"
#import "WSIMapDemoUtil.h"
#import "WSIMapDemoUtilTime.h"
#import "WSIMapDemoUtilGeoCallout.h"

static NSString *kUnavailableDateTime   = @"???";

@implementation WSIMapDemoGeoObjectInfoCell
{
    WSIMapSDKFeatureInfoDictionary *_featureInfoDict;
    CGFloat _contentOffsetY;
    BOOL _haveMixedItems;
}


- (WSIMapSDKFeatureInfoDictionary *)getFeatureInfoDict
{
    return _featureInfoDict;
}


- (id)initWithFeatureInfoDict:(WSIMapSDKFeatureInfoDictionary *)featureInfoDictionary haveMixedItems:(BOOL)haveMixedItems
{
    self = [super init];
    if (self)
    {
        _haveMixedItems = haveMixedItems;
        [self initialize:featureInfoDictionary];

        // init view
        [self initView];
        [self setViewContent];
        [self updateView];
    }
    return self;
}


- (void)initialize:(WSIMapSDKFeatureInfoDictionary *)featureInfoDict
{
    _featureInfoDict = featureInfoDict;
    _contentOffsetY = gSDKDemoCalloutCellMarginY;
}


- (void)initView
{
    //self.frame = CGRectZero;
    self.backgroundColor = [UIColor clearColor];
}


- (BOOL)haveMixedItems
{
    return _haveMixedItems;
}


- (void)setViewContent
{
    // subclasses should implement this
    WMDLogError(@"%s should be implemented in subclass!", __FUNCTION__);
    NSAssert(NO, @"Error!");
}


- (void)updateView
{
    // set up cell frame (based on number of label sub views)
    CGRect cellFrame = CGRectMake(
                        0.0,
                        0.0,
                        [WSIMapDemoSizes getCalloutCellWidth],
                        _contentOffsetY + gSDKDemoCalloutCellMarginY);
    self.frame = cellFrame;
}


- (NSString *)unlocalizedHeaderForSection
{
    return @"error - not implemented!";
}

#pragma mark - misc

- (UIColor *)getTextColorForBackgroundColor:(UIColor *)backgroundColor
{
    const CGFloat brightness = [WSIMapDemoUtil brightnessOfColor:backgroundColor];
    if (brightness > 0.5)
        return [UIColor blackColor];
    else
        return [UIColor whiteColor];
}


- (void)setTextColorForBackgroundColor:(UIColor *)backgroundColor
{
    UIColor *textColor = [self getTextColorForBackgroundColor:backgroundColor];
    for (UIView *label in self.subviews)
    {
        // for all UILabel subviews set contrast text color
        if ([label isKindOfClass:[UILabel class]])
            ((UILabel *)label).textColor = textColor;
    }
}


- (void)setCellBackgroundColor:(UIColor *)backgroundColor
{
    self.backgroundColor = backgroundColor;
    [self setTextColorForBackgroundColor:backgroundColor];
}


- (void)setCellBackgroundColorForKey:(NSString *)key
{
    UIColor *backgroundColor = [WSIMapSDKGeoInfoUtil getRGBColorForFeature:_featureInfoDict key:key];
    [self setCellBackgroundColor:backgroundColor];
}


/*
 See if we can find a matching geoObjectInfo dictionary in the given
 list and if that's no older than what we have now.
 Updates _featureInfoDict and returns YES if that's the case, NO otherwise.
 */
- (BOOL)shouldUpdateViewForDetails:(WSIMapSDKFeatureInfoList *)featureInfoList
{
    if (_featureInfoDict)
    {
        WSIMapSDKFeatureInfoDictionary *updatedGeoObjectInfo = [WSIMapSDKGeoInfoUtil getUpdatedFeatureInfoDictionary:_featureInfoDict fromFeatureInfoList:featureInfoList];
        if (updatedGeoObjectInfo)
        {
            _featureInfoDict = updatedGeoObjectInfo;
            return YES;
        }
    }
    
    return NO;
}


- (CGFloat)getMetersPerSecondSpeedWithKey:(NSString *)speedKey
{
    return [WSIMapSDKGeoInfoUtil getSpeedForFeature:_featureInfoDict metersPerSecondKey:speedKey];
}


- (CGFloat)getMilesPerHourSpeedWithKey:(NSString *)speedKey
{
    return [WSIMapSDKGeoInfoUtil getSpeedForFeature:_featureInfoDict milesPerHourKey:speedKey];
}


- (NSString *)getDirectionAndSpeedString
{
    WSIMapSDKFeatureType featureType = [WSIMapSDKGeoInfoUtil getTypeForFeature:_featureInfoDict];
    BOOL isMetric = NO;
    BOOL shouldFlip = NO;
    NSString *directionKey = @"";
    NSString *speedKey = @"";
    switch (featureType)
    {
        case WSIMapSDKFeatureType_CurrentCondition:
            directionKey = gWMSKeyCondition_Direction;
            speedKey = gWMSKeyCondition_WindSpeedMPH;
            shouldFlip = YES;
            break;
        case WSIMapSDKFeatureType_StormTrack:
            isMetric = YES;
            shouldFlip = YES;
            directionKey = gWMSKeyStorm_Direction;
            speedKey = gWMSKeyStorm_SpeedMetersPerSecond;
            break;
        case WSIMapSDKFeatureType_TropicalTrack:
            directionKey = gWMSKeyTropical_Direction;
            speedKey = gWMSKeyTropical_SpeedMPH;
            break;
        default:
            WMDLogError(@"%s unsupported feature type!", __FUNCTION__);
            NSAssert(NO, @"Error!");
    }
    
    NSUInteger directionIndex = [WSIMapSDKGeoInfoUtil getDirectionIndexForFeature:_featureInfoDict key:directionKey shouldFlip:shouldFlip];
    NSString *windDirectionString = [WSIMapDemoUtil localizedWindDirectionStringFromDirectionIndex:directionIndex];
    CGFloat speed = isMetric ? [self getMetersPerSecondSpeedWithKey:speedKey] : [self getMilesPerHourSpeedWithKey:speedKey];
    WSIMapSDKUnitPreferences distanceUnits = [[WSIMapSDK sharedInstance] getDistanceUnits];
    NSString *unitsLocalizeKey = (distanceUnits == WSIMapSDKUnitPreferencesMetric) ? @"settings_speed_unit_kph" : @"settings_speed_unit_mph";
    NSString *units = [WSIMapDemoUtil localizedString:unitsLocalizeKey];
    return [NSString stringWithFormat:@"%@ %.0f %@", windDirectionString, speed, units];
}


// key should return an ISO format date/time string (e.g. 2019-10-09T21:00:00+09:00)
- (NSString *)getDateTimeStringForISOKey:(NSString *)key
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [WSIMapDemoUtilTime currentLocale];
    dateFormatter.timeZone = [WSIMapDemoUtilTime timeZone];
    
    NSString *dateStr = [self getStringForKey:key];
    if (!dateStr || (dateStr.length < 5))
        return nil;
    NSString *dateText = [WSIMapDemoUtilTime getDateTimeStringForISODate:dateStr dateFormatter:dateFormatter pattern:@"geo_callout_date_pattern" defaultResult:kUnavailableDateTime];
    if (!dateText || (dateText.length < 5))
        return nil;
    NSString *timeText = [WSIMapDemoUtilTime getDateTimeStringForISODate:dateStr dateFormatter:dateFormatter pattern:@"geo_callout_time_pattern" defaultResult:kUnavailableDateTime];
    if (!timeText || (timeText.length < 5))
        return nil;
    return [NSString stringWithFormat:@"%@ %@", dateText, timeText];
}


// key should return a UTC (seconds from 1970) string (e.g. 1505404110)
- (NSString *)getDateTimeStringForUTCKey:(NSString *)key
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [WSIMapDemoUtilTime currentLocale];
    dateFormatter.timeZone = [WSIMapDemoUtilTime timeZone];
    
    NSString *dateStr = [self getStringForKey:key];
    if (!dateStr || (dateStr.length < 10))
        return nil;
    NSString *dateText = [WSIMapDemoUtilTime getDateTimeStringForUTCDate:dateStr dateFormatter:dateFormatter pattern:@"geo_callout_date_pattern" defaultResult:kUnavailableDateTime];
    if (!dateText || (dateText.length < 5))
        return nil;
    NSString *timeText = [WSIMapDemoUtilTime getDateTimeStringForUTCDate:dateStr dateFormatter:dateFormatter pattern:@"geo_callout_time_pattern" defaultResult:kUnavailableDateTime];
    if (!timeText || (timeText.length < 5))
        return nil;
    return [NSString stringWithFormat:@"%@ %@", dateText, timeText];
}


- (void)maybeAddDateTimeStringForLabelISO:(NSString *)label key:(NSString *)key
{
    NSString *valueString = [self getDateTimeStringForISOKey:key];
    if (valueString && (valueString.length > 5))
    {
        NSString *labelString = [WSIMapDemoUtil localizedStringWithDefault:label];
        NSString *finalString = [NSString stringWithFormat:@"%@: %@", labelString, valueString];
        [self addLabelString:nil valueString:finalString];
    }
}


- (void)addDateTimeStringForLabelISO:(NSString *)label key:(NSString *)key
{
    NSString *valueString = [self getDateTimeStringForISOKey:key];
    if (!valueString || (valueString.length <= 5))
        valueString = [WSIMapDemoUtil localizedString:@"geo_callout_active_now"];
    {
        NSString *labelString = [WSIMapDemoUtil localizedStringWithDefault:label];
        NSString *finalString = [NSString stringWithFormat:@"%@: %@", labelString, valueString];
        [self addLabelString:nil valueString:finalString];
    }
}


- (void)addDateTimeStringForLabelUTC:(NSString *)label key:(NSString *)key
{
    NSString *valueString = [self getDateTimeStringForUTCKey:key];
    if (valueString && (valueString.length > 5))
    {
        NSString *labelString = [WSIMapDemoUtil localizedStringWithDefault:label];
        NSString *finalString = [NSString stringWithFormat:@"%@: %@", labelString, valueString];
        [self addLabelString:nil valueString:finalString];
    }
}


- (NSString *)getStringForKey:(NSString *)key
{
    return [WSIMapSDKGeoInfoUtil getStringForFeature:_featureInfoDict key:key withDefault:@"???"];
}


#pragma mark - label creation

- (void)addLabelString:(NSString *)labelString
{
    CGFloat labelHeight = [WSIMapDemoSizes getCalloutLabelHeight];
    CGRect labelFrameLeft = CGRectMake(
                                gSDKDemoCalloutCellMarginX,
                                _contentOffsetY,
                                [WSIMapDemoSizes getCallouLabelWidthLeft] + [WSIMapDemoSizes getCallouLabelWidthRight],
                                labelHeight);
    NSString *localizedLabelString = [WSIMapDemoUtil localizedStringWithDefault:labelString];
    [WSIMapDemoUtilGeoCallout addLeftText:localizedLabelString leftFrame:labelFrameLeft toView:self bold:NO];

    _contentOffsetY += labelHeight;
}


- (UILabel *)addLabelString:(NSString *)labelString valueString:(NSString *)valueString
{
    UILabel *valueLabel = nil;
    CGFloat labelHeight = [WSIMapDemoSizes getCalloutLabelHeight];
    CGRect labelFrameLeft = CGRectMake(
                                gSDKDemoCalloutCellMarginX,
                                _contentOffsetY,
                                [WSIMapDemoSizes getCallouLabelWidthLeft],
                                labelHeight);
    if (labelString)
    {
        CGRect labelFrameRight = CGRectMake(
                                    labelFrameLeft.origin.x+labelFrameLeft.size.width,
                                    _contentOffsetY,
                                    [WSIMapDemoSizes getCallouLabelWidthRight],
                                    labelHeight);
        NSString *localizedLabelString = [WSIMapDemoUtil localizedStringWithDefault:labelString];
        valueLabel = [WSIMapDemoUtilGeoCallout addLeftText:localizedLabelString rightText:valueString leftFrame:labelFrameLeft rightFrame:labelFrameRight toView:self];
    }
    else
    {
        labelFrameLeft.size.width += [WSIMapDemoSizes getCallouLabelWidthRight];
        valueLabel = [WSIMapDemoUtilGeoCallout addLeftText:valueString leftFrame:labelFrameLeft toView:self bold:NO];
    }

    _contentOffsetY += labelHeight;
    return valueLabel;
}


- (UILabel *)addLabelString:(NSString *)labelString valueStringKey:(NSString *)valueStringKey
{
    NSString *valueString = [WSIMapSDKGeoInfoUtil getStringForFeature:_featureInfoDict key:valueStringKey];
    return [self addLabelString:labelString valueString:valueString];
}


- (UILabel *)addLabelString:(NSString *)labelString valueStringKey:(NSString *)valueStringKey defaultValue:(NSString *)defaultValue
{
    NSString *valueString = [WSIMapSDKGeoInfoUtil getStringForFeature:_featureInfoDict key:valueStringKey withDefault:defaultValue];
    return [self addLabelString:labelString valueString:valueString];
}


- (UILabel *)addElapsedTimeWithLabelString:(NSString *)labelString forKey:(NSString *)key
{
    NSTimeInterval validTimeInterval = [WSIMapSDKGeoInfoUtil getDoubleForFeature:_featureInfoDict key:key];
    NSString *elapsedTimeString = [WSIMapDemoUtilGeoCallout getElapsedTimeStringForTime:validTimeInterval];
    return [self addLabelString:labelString valueString:elapsedTimeString];
}


- (void)updateLabel:(UILabel *)label valueString:(NSString *)valueString
{
    label.text = valueString;
}

- (void)updateLabel:(UILabel *)label valueStringKey:(NSString *)valueStringKey
{
    NSString *valueString = [WSIMapSDKGeoInfoUtil getStringForFeature:_featureInfoDict key:valueStringKey withDefault:@"???"];
    label.text = valueString;
}


- (UILabel *)addText:(NSString *)text localize:(BOOL)localize bold:(BOOL)bold
{
    if (!text)
        return nil;
    
    CGFloat labelHeight = [WSIMapDemoSizes getCalloutLabelHeight];
    CGRect labelFrameLeft = CGRectMake(
                                gSDKDemoCalloutCellMarginX,
                                _contentOffsetY,
                                [WSIMapDemoSizes getCallouLabelWidthLeft] + [WSIMapDemoSizes getCallouLabelWidthRight],
                                labelHeight);
    NSString *localizedText = localize ? [WSIMapDemoUtil localizedStringWithDefault:text] : text;
    UILabel *label = [WSIMapDemoUtilGeoCallout addLeftText:localizedText leftFrame:labelFrameLeft toView:self bold:bold];

    _contentOffsetY += labelHeight;
    return label;
}


- (void)addTextSectionWithHeader:(NSString *)headerText bodyText:(NSString *)bodyText bold:(BOOL)bold
{
    CGFloat cellWidth = [WSIMapDemoSizes getCalloutCellWidth];
    CGFloat headerWidth = cellWidth - 2*gSDKDemoCalloutCellMarginX;
    
    if (headerText)
        [self addLabelString:headerText valueString:@""];
    
    UIFont *bodyTextFont = nil;
    CGFloat bodyTextFontSize = [WSIMapDemoSizes getCalloutTextSectionFontSize];
    if (bold)
        bodyTextFont = [WSIMapDemoUtil fixedFontOfSizeBold:bodyTextFontSize];
    else
        bodyTextFont = [WSIMapDemoUtil fixedFontOfSize:bodyTextFontSize];

    CGSize stringSize = [WSIMapDemoUtil text:bodyText
                                sizeWithFont:bodyTextFont
                           constrainedToSize:CGSizeMake(headerWidth, NSIntegerMax)];

    CGRect bodyFrame = CGRectMake(
                            gSDKDemoCalloutCellMarginX,
                            _contentOffsetY,
                            stringSize.width,
                            stringSize.height);

    UILabel *label = [[UILabel alloc] initWithFrame:bodyFrame];
    label.font = bodyTextFont;
    label.textAlignment = NSTextAlignmentLeft;// | NSTextAlignmentNatural;
    label.contentMode = UIViewContentModeTop | UIViewContentModeLeft;
    label.textColor = [UIColor whiteColor];
    //label.backgroundColor = [UIColor yellowColor];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.text = bodyText;
    [self addSubview:label];

    _contentOffsetY += stringSize.height;
}

@end
