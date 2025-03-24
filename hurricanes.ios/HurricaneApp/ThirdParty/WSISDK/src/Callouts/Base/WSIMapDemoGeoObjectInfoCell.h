// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

@interface WSIMapDemoGeoObjectInfoCell : UIView

- (id)initWithFeatureInfoDict:(WSIMapSDKFeatureInfoDictionary *)featureInfoDictionary haveMixedItems:(BOOL)haveMixedItems;

/*
 If true, items of different types (e.g. flood alerts and earthquakes) were
 tapped so we may put info into the cells for each tapped item to indicate
 the type of the item (since the header will just say "tapped items" or
 something generic instead of "Earthquakes" etc.).
 */
- (BOOL)haveMixedItems;

- (WSIMapSDKFeatureInfoDictionary *)getFeatureInfoDict;

/* Creates content view from geo object.
 * This method is overriden in subclasses of this class
 * to construct the view for particular geo object.
 */
- (void)setViewContent;

- (NSString *)unlocalizedHeaderForSection;

#pragma mark - misc

- (void)setCellBackgroundColor:(UIColor *)backgroundColor;
- (void)setCellBackgroundColorForKey:(NSString *)key;
- (BOOL)shouldUpdateViewForDetails:(WSIMapSDKFeatureInfoList *)featureInfoList;
- (NSString *)getDirectionAndSpeedString;
- (NSString *)getDateTimeStringForISOKey:(NSString *)key;
- (NSString *)getDateTimeStringForUTCKey:(NSString *)key;
- (void)maybeAddDateTimeStringForLabelISO:(NSString *)label key:(NSString *)key;
- (void)addDateTimeStringForLabelISO:(NSString *)label key:(NSString *)key;
- (void)addDateTimeStringForLabelUTC:(NSString *)label key:(NSString *)key;

/*
 Fetch string value for the given key.
 */
- (NSString *)getStringForKey:(NSString *)key;

#pragma mark - label creation

/*
 The value label font will be autoscaled to fit the available space if necessary.
 Where applicable returns the valueLabel so that can be modified.
 */

- (void)addLabelString:(NSString *)labelString;

- (UILabel *)addLabelString:(NSString *)labelString valueString:(NSString *)valueString;

/*
 Same as above but takes a value string key.
 */
- (UILabel *)addLabelString:(NSString *)labelString valueStringKey:(NSString *)valueStringKey;
- (UILabel *)addLabelString:(NSString *)labelString valueStringKey:(NSString *)valueStringKey defaultValue:(NSString *)defaultValue;

- (UILabel *)addElapsedTimeWithLabelString:(NSString *)labelString forKey:(NSString *)key;

- (void)updateLabel:(UILabel *)label valueString:(NSString *)valueString;
- (void)updateLabel:(UILabel *)label valueStringKey:(NSString *)valueStringKey;

- (UILabel *)addText:(NSString *)text localize:(BOOL)localize bold:(BOOL)bold;
- (void)addTextSectionWithHeader:(NSString *)headerText bodyText:(NSString *)bodyText bold:(BOOL)bold;

@end
