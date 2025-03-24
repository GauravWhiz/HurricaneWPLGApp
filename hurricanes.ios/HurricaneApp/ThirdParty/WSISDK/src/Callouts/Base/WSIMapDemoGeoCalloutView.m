// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoGeoCalloutView.h"

#import "WSIMapDemoGeoObjectInfoCell.h"
#import "WSIMapDemoGeoAlertsInfoCell.h"
#import "WSIMapDemoGeoCurrentConditionsInfoCell.h"
#import "WSIMapDemoGeoEarthquakesInfoCell.h"
#import "WSIMapDemoGeoHurricanesInfoCell.h"
#import "WSIMapDemoGeoLightningInfoCell.h"
#import "WSIMapDemoGeoStormTrackInfoCell.h"
#import "WSIMapDemoGeoTrafficIncidentsInfoCell.h"

#import "WSIMapDemoCalloutBackground.h"
#import "WSIMapDemoCalloutConstants.h"

#import "WSIMapDemoSettings.h"
#import "WSIMapDemoUtil.h"

#define SDKDEMO_ROUND_TO_CGFLOAT(A)     ((CGFloat)round(A))

static NSInteger const kSDKDemoCalloutCellContentViewTag   = 1;


@implementation WSIMapDemoGeoCalloutView
{
    UIView      *_mainView;
	UITableView *_calloutsTable;
    BOOL         _haveMixedItems;
	NSInteger    _numTappedItems;
	NSArray<WSIMapSDKFeatureInfoList*> *_featureInfoLists;
    NSMutableDictionary<NSNumber*, WSIMapDemoGeoObjectInfoCell*> *_cachedCalloutViewCells;
}


- (id)initWithMapView:(UIView *)mapView withFeatureInfoLists:(NSArray<WSIMapSDKFeatureInfoList*> *)featureInfoLists
{
    self = [super init];
    if (self)
    {
        self.autoresizesSubviews = YES;

        _featureInfoLists = featureInfoLists;
        _haveMixedItems = (_featureInfoLists.count > 1);
        _numTappedItems = [self getNumTappedItems:_featureInfoLists];
        _cachedCalloutViewCells = [NSMutableDictionary new];
        
        CGRect maxRect = mapView.frame;
        maxRect.origin = CGPointZero;
        CGFloat maxCalloutHeight = [WSIMapDemoSizes getCalloutContainerMaxHeight];

        // place in upper right
        CGSize tableSize = [self tableSizeFromFeatureInfoLists:_featureInfoLists withMaxHeight:maxCalloutHeight];
        maxRect.origin.x = 10.0;
        maxRect.size.width = tableSize.width + gSDKDemoCalloutTableAlignment*2;
        maxRect.origin.y = 10.0;
        maxRect.size.height = tableSize.height + gSDKDemoCalloutTitleHeight + gSDKDemoCalloutBottomAlignment;
        
        self.frame = maxRect;
		maxRect.origin = CGPointZero;        
        
        _mainView = [self createBackgroundViewWithFrame:maxRect];
        _mainView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_mainView];
        
        CGRect mainFrame = _mainView.frame;
        
		// add close button
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[self calloutCloseButtonImage] forState:UIControlStateNormal];
        
        // fudge factors here to get new (larger) button positioned in upper right corner
        CGFloat y = 0.5f*(gSDKDemoCalloutTitleHeight - gSDKDemoCalloutIconHeight);
        CGFloat x = (CGRectGetWidth(mainFrame) - y - gSDKDemoCalloutIconWidth);
        closeButton.frame = CGRectMake( x, y, gSDKDemoCalloutIconWidth, gSDKDemoCalloutIconHeight);
        [closeButton addTarget:self action:@selector(closeCalloutView:) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:closeButton];
		
		// add header label
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(gSDKDemoCalloutTitleMarginX, 0.0, tableSize.width, gSDKDemoCalloutTitleHeight)];
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.textColor = [UIColor whiteColor];
		headerLabel.font = [WSIMapDemoUtil fontOfSizeBold:[WSIMapDemoSizes getCalloutHeaderFontSize]];
		headerLabel.adjustsFontSizeToFitWidth = YES;
		headerLabel.text = [self mainHeaderText];
		[_mainView addSubview:headerLabel];
		
		// add 1-pixel separator if no section header
        if (![self showSectionsHeaders])
        {
            UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(gSDKDemoCalloutTableAlignment, gSDKDemoCalloutTitleHeight, tableSize.width, 1.0)];
            separator.backgroundColor = [self calloutTableSeparatorColor];
            [_mainView addSubview:separator];
        }
        
		_calloutsTable = [[UITableView alloc] initWithFrame:CGRectMake(gSDKDemoCalloutTableAlignment, gSDKDemoCalloutTitleHeight, tableSize.width, tableSize.height)];
		_calloutsTable.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_calloutsTable.allowsSelection = NO;
		_calloutsTable.dataSource = self;
		_calloutsTable.delegate = self;
		_calloutsTable.backgroundColor = [UIColor clearColor];
        _calloutsTable.separatorColor = [self calloutTableSeparatorColor];
        _calloutsTable.bounces = YES;
        _calloutsTable.alwaysBounceVertical = YES;
		[_mainView addSubview:_calloutsTable];
		
        [_calloutsTable layoutIfNeeded];
        [self viewBecomesVisible];
    }
	
    return self;
}


- (void)dealloc
{
    // unsubscribe from closeCalloutNotification observed notiications
  	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (UIView *)createBackgroundViewWithFrame:(CGRect)frame
{
    CGFloat components[4] = {0.137f, 0.137f, 0.137f, 0.9f};
    UIColor *strokeColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    return [[WSIMapDemoCalloutBackground alloc] initWithFrame:frame withColorComponents:components andStrokeColor:strokeColor];
}


- (UIImage *)calloutCloseButtonImage
{
    return [WSIMapDemoUtil imageNamed:@"CloseButtonSmall"];
}


- (UIColor *)calloutTableSeparatorColor
{
    // light gray separators for single item callout
    return (_numTappedItems == 1) ? [UIColor clearColor] : [UIColor lightGrayColor];
}


- (BOOL)showSectionsHeaders
{
    return NO;
}


- (UIView *)headerViewForContent:(UIView *)contentView withWidth:(CGFloat)width
{
    UIImageView *cellView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, contentView.frame.size.height)];
    cellView.image = [[WSIMapDemoUtil imageNamed:@"calloutBackground"] stretchableImageWithLeftCapWidth:0 topCapHeight:3];
    
   	// center contentView to the center of cell
    CGRect subViewFrame = contentView.frame;
    subViewFrame.origin.x = cellView.frame.origin.x + (cellView.frame.size.width - contentView.frame.size.width)/2.0f;
    contentView.frame = subViewFrame;
    
    // add contentView to the cell's view
    [cellView addSubview:contentView];
    
    return cellView;
}


/*
 Force table view to reload itself.
 Also make this view visible and check whether the callout should
 be scrollable.
 */
- (void)update
{
    [_calloutsTable reloadData];
    [self viewBecomesVisible];
}


- (NSInteger)getNumTappedItems:(NSArray<WSIMapSDKFeatureInfoList*> *)geoObjects
{
	NSInteger count = 0;
	for (WSIMapSDKFeatureInfoList *featureInfoList in geoObjects)
		count += featureInfoList.count;
	return count;
}


- (WSIMapDemoGeoObjectInfoCell *)allocCalloutViewCellForGeoObject:(WSIMapSDKFeatureInfoDictionary *)featureInfoDict
{
    WSIMapSDKFeatureType calloutType = [WSIMapSDKGeoInfoUtil getTypeForFeature:featureInfoDict];
    switch (calloutType)
    {
        case WSIMapSDKFeatureType_Alert:
            return [[WSIMapDemoGeoAlertsInfoCell alloc] initWithFeatureInfoDict:featureInfoDict haveMixedItems:_haveMixedItems];
        case WSIMapSDKFeatureType_CurrentCondition:
            return [[WSIMapDemoGeoCurrentConditionsInfoCell alloc] initWithFeatureInfoDict:featureInfoDict haveMixedItems:_haveMixedItems];
        case WSIMapSDKFeatureType_Earthquake:
            return [[WSIMapDemoGeoEarthquakesInfoCell alloc] initWithFeatureInfoDict:featureInfoDict haveMixedItems:_haveMixedItems];
        case WSIMapSDKFeatureType_Lightning:
            return [[WSIMapDemoGeoLightningInfoCell alloc] initWithFeatureInfoDict:featureInfoDict haveMixedItems:_haveMixedItems];
        case WSIMapSDKFeatureType_StormTrack:
            return [[WSIMapDemoGeoStormTrackInfoCell alloc] initWithFeatureInfoDict:featureInfoDict haveMixedItems:_haveMixedItems];
        case WSIMapSDKFeatureType_TemperaturePlot:
            return nil; // no callout
        case WSIMapSDKFeatureType_TrafficIncident:
            return [[WSIMapDemoGeoTrafficIncidentsInfoCell alloc] initWithFeatureInfoDict:featureInfoDict haveMixedItems:_haveMixedItems];
        case WSIMapSDKFeatureType_TropicalTrack:
            return [[WSIMapDemoGeoHurricanesInfoCell alloc] initWithFeatureInfoDict:featureInfoDict haveMixedItems:_haveMixedItems];
        case WSIMapSDKFeatureType_TrafficFlow:
            return nil;
        case WSIMapSDKFeatureType_None:
            NSAssert(NO, @"Invalid geo data type!");
            return nil;
    }
}

/*
 Not sure why but featureInfoDict.hash is returning the same value for any
 WSIMapSDKFeatureInfoDictionary* even if those are different according
 to isEqual.
 Just use the object's address as a hash value for now?
 */
- (NSNumber *)makeHashForFeatureInfo:(WSIMapSDKFeatureInfoDictionary *)featureInfoDict
{
    NSUInteger featureInfoHashValue = (NSUInteger)featureInfoDict;
    NSNumber *featureInfoHashNumber = [NSNumber numberWithUnsignedLong:featureInfoHashValue];
    return featureInfoHashNumber;
}

/*
 A single callout view can be created for multiple tapped geoobjects (e.g. 2
 earthquakes over a winter alert over a flood alert).
 Here, we return the associated WSIMapDemoGeoObjectInfoCell* for the given
 WSIMapSDKFeatureInfoDictionary* if it's already been created, otherwise we
 create one, store it in a dictionary then return that.
 */
- (WSIMapDemoGeoObjectInfoCell *)getCalloutViewCellForGeoObject:(WSIMapSDKFeatureInfoDictionary *)featureInfoDict
{
    id featureInfoHash = [self makeHashForFeatureInfo:featureInfoDict];
    WSIMapDemoGeoObjectInfoCell *calloutViewCell = [_cachedCalloutViewCells objectForKey:featureInfoHash];
    if (calloutViewCell)
        return calloutViewCell;
    calloutViewCell = [self allocCalloutViewCellForGeoObject:featureInfoDict];
    [_cachedCalloutViewCells setObject:calloutViewCell forKey:featureInfoHash];
    return calloutViewCell;
}


- (WSIMapDemoGeoObjectInfoCell *)getCellInSection:(NSInteger)section atIndex:(NSUInteger)index
{
	WSIMapSDKFeatureInfoList *featureInfoList = [_featureInfoLists objectAtIndex:section];
    WSIMapSDKFeatureInfoDictionary *featureInfoDict = featureInfoList[index];
	return [self getCalloutViewCellForGeoObject:featureInfoDict];
}

/*
 For the main title, if there's only one section, show "Earthquakes (2)" etc.
 If there's more than one section show "Callouts (3)" then "Earthquakes (2)"
 then "Weather Alerts (1)" etc.
 */
- (NSString *)mainHeaderText
{
    NSString *headerTextString = nil;
    if (!_haveMixedItems)
    {
        WSIMapSDKFeatureInfoList *firstGeoInfoList = [_featureInfoLists objectAtIndex:0];
        WSIMapSDKFeatureInfoDictionary *featureInfoDict = [firstGeoInfoList objectAtIndex:0];
        WSIMapDemoGeoObjectInfoCell *firstcellInSection = [self getCalloutViewCellForGeoObject:featureInfoDict];
        headerTextString = [firstcellInSection unlocalizedHeaderForSection];

    }
    else
    {
        headerTextString = @"geo_callouts_title";
    }

    if ([[WSIMapDemoSettings sharedInstance] getDebugCallouts])
        return [NSString stringWithFormat:@"%@ (%zd)", [WSIMapDemoUtil localizedString:headerTextString], _numTappedItems];
    else
        return [WSIMapDemoUtil localizedString:headerTextString];
}


- (CGSize)tableSizeFromFeatureInfoLists:(NSArray<WSIMapSDKFeatureInfoList*> *)featureInfoLists withMaxHeight:(CGFloat)maxHeight
{
    CGSize size = CGSizeZero;
	int sectionIndex = 0;
	for (WSIMapSDKFeatureInfoList *featureInfoList in featureInfoLists)
    {
        for (WSIMapSDKFeatureInfoDictionary *featureInfoDict in featureInfoList)
        {
            WSIMapDemoGeoObjectInfoCell *infoCell = [self getCalloutViewCellForGeoObject:featureInfoDict];
            if (infoCell)
            {
                CGSize tmpSize = infoCell.frame.size;
                
                // update the table size
                size.height += tmpSize.height;
                size.width = (size.width >= tmpSize.width) ? size.width : tmpSize.width;
            }
        }
        // add height of sections
        sectionIndex++;
        
        if (maxHeight < size.height)
            size.height = maxHeight;
	}
    return size;
}


/*
 Make this view visible and check whether the callout should
 be scrollable.
 */
- (void)viewBecomesVisible
{
    self.hidden = NO;
    BOOL enableScrolling = YES;
    _calloutsTable.scrollEnabled = enableScrolling;
}


- (void)closeCalloutView:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:gSDKDemoCloseCalloutNotification object:nil];
}


- (UIImageView *)iconWithFrame:(UIImage *)image frame:(CGRect)frame
{
	UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
	imgView.image = image;
	return imgView;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //WMDLog(@"%zd sections", _featureInfoLists.count);
	return _featureInfoLists.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *array = [_featureInfoLists objectAtIndex:section];
    //WMDLog(@"%zd rows in section %zd", array.count, section);
    return array.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *kCalloutCell = @"geoObjectCalloutCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCalloutCell];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCalloutCell];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    UIView *prevContView = [cell viewWithTag:kSDKDemoCalloutCellContentViewTag];
    if (prevContView)
        [prevContView removeFromSuperview];

    WSIMapDemoGeoObjectInfoCell *newContentCell = [self getCellInSection:indexPath.section atIndex:indexPath.row];
    // Update contentView width to fit table width
    CGRect frame = newContentCell.frame;
    frame.size.width = tableView.frame.size.width;
    newContentCell.frame = frame;

    [newContentCell setTag:kSDKDemoCalloutCellContentViewTag];
    [cell.contentView addSubview:newContentCell];

    // In iOS 7 cell has white background color by default
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSIMapDemoGeoObjectInfoCell *cell = [self getCellInSection:indexPath.section atIndex:indexPath.row];
    return cell.frame.size.height;
}


- (void)updateCalloutTable
{
    [_calloutsTable beginUpdates];
    [_calloutsTable endUpdates];
}

@end
