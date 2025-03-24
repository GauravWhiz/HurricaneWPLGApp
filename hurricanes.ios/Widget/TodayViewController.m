//
//  TodayViewController.m
//  Active Hurricanes
//
//  Created by Swati on 10/9/14.
//  Copyright (c) 2014 PNSDigital. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "HurricaneWidgetCell.h"
#import "CustomDefs.h"

#define kTitleData @"titleData"
#define kCategoryData @"categoryeData"
#define kIdData @"idData"
#define kAPIURL @"API_URL"

@interface TodayViewController () <NCWidgetProviding>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *firstLaunchView;
@property (nonatomic, weak) IBOutlet UILabel *firstLaunchMessage;
@property (nonatomic, weak) IBOutlet UIButton *launchAppButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *categoryArray;
@property (nonatomic, strong) NSArray *idArray;
@property (nonatomic, strong) NSString *dataURL;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"HurricaneWidgetCell" bundle:nil]
         forCellReuseIdentifier:@"HurricaneWidgetCellIdentifier"];
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:kApplicationGroup];
    self.titleArray = [defaults objectForKey:kTitleData];
    self.categoryArray = [defaults objectForKey:kCategoryData];
    self.idArray = [defaults objectForKey:kIdData];
    self.dataURL = [defaults objectForKey:kAPIURL];
    [self downloadData];
    [self adjustHeightOfTableview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    completionHandler(NCUpdateResultNewData);
}

-(void)downloadData{
    NSURL *URL;
    if (self.dataURL){
        self.firstLaunchView.hidden = YES;
        self.tableView.hidden = NO;
        URL = [NSURL URLWithString:self.dataURL];
    }
    else{
        self.firstLaunchView.hidden = NO;
        self.tableView.hidden = YES;
        [self setFirstLaunchText];
        [self adjustHeightOfTableview];
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if (!error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSError *error = nil;
                                              NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:   data
                                                                                                             options:NSJSONReadingAllowFragments
                                                                                                               error:&error];
                                              NSArray *dataArray = [dataDictionary objectForKey:@"storms"];
                                              NSMutableArray *titleData = [[NSMutableArray alloc] init];
                                              NSMutableArray *categoryData = [[NSMutableArray alloc] init];
                                              NSMutableArray *stormId = [[NSMutableArray alloc] init];
                                              
                                              for (NSDictionary *dataDict in dataArray){
                                                  [titleData addObject:[dataDict objectForKey:@"name"]];
                                                  [categoryData addObject:[dataDict objectForKey:@"category"]];
                                                  [stormId addObject:[dataDict objectForKey:@"id"]];
                                              }
                                              
                                              _titleArray = [NSArray arrayWithArray:titleData];
                                              _categoryArray = [NSArray arrayWithArray:categoryData];
                                              _idArray = [NSArray arrayWithArray:stormId];
                                              [self.tableView reloadData];
                                              
                                              NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:kApplicationGroup];
                                              [defaults setObject:self.titleArray forKey:kTitleData];
                                              [defaults setObject:self.categoryArray forKey:kCategoryData];
                                              [defaults setObject:self.idArray forKey:kIdData];
                                              [defaults synchronize];
                                              [self adjustHeightOfTableview];
                                          });
                                      }
                                      else {
                                          [self adjustHeightOfTableview];
                                      }
                                  }];
    [task resume];
}

-(void)setFirstLaunchText{
    self.firstLaunchMessage.text = @"Hurricane App must be opened once before the widget can provide the latest updates on active storms.";
    self.launchAppButton.backgroundColor = [self colorWithHexValue:0x747474];
    [self.launchAppButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[self.launchAppButton layer] setBorderWidth:2.0f];
    [[self.launchAppButton layer] setCornerRadius:8.0f];
    [[self.launchAppButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.titleArray count]){
        return [self.titleArray count];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *hurricaneCellIdentifier = @"HurricaneWidgetCellIdentifier";
    HurricaneWidgetCell *cell = (HurricaneWidgetCell *)[tableView dequeueReusableCellWithIdentifier:hurricaneCellIdentifier];
    cell.hurricaneCategory.text = @"";
    [self configureHurricaneCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];

    if (self.titleArray && indexPath.row < [self.titleArray count]-1){
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0, CGRectGetHeight(cell.frame)-0.5f, self.tableView.frame.size.width, 0.5f);
        bottomBorder.backgroundColor = [UIColor grayColor].CGColor;
        [cell.layer addSublayer:bottomBorder];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.idArray count]>indexPath.row){
        NSString *stormId = [self.idArray objectAtIndex:indexPath.row];
        NSString *urlString = [NSString stringWithFormat:@"%@,?%@",kAppURL,stormId];
        NSURL *url = [NSURL URLWithString:urlString];
        [self.extensionContext openURL:url completionHandler:nil];
    }
    else {
        NSString *urlString = [NSString stringWithFormat:@"%@",kAppURL];
        NSURL *url = [NSURL URLWithString:urlString];
        [self.extensionContext openURL:url completionHandler:nil];
    }
}

- (void)configureHurricaneCell:(HurricaneWidgetCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if(![self.titleArray count]){
        cell.noDataLabel.text = @"No Active Hurricanes";
        cell.noDataLabel.hidden = NO;
        cell.hurricaneCategoryBackground.hidden = YES;
        cell.hurricaneName.hidden = YES;
        cell.noDataLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:16];
        return;
    }
    
    if([self.titleArray count]>indexPath.row){
        cell.noDataLabel.hidden = YES;
        cell.hurricaneName.hidden = NO;
        cell.hurricaneCategoryBackground.hidden = NO;
        cell.hurricaneCategory.font = [UIFont fontWithName:@"AvenirNext-Bold" size:16];
        cell.hurricaneCategoryBackground.backgroundColor = [UIColor redColor];
        cell.hurricaneName.text = [self.titleArray objectAtIndex:indexPath.row];
        NSInteger category = [[self.categoryArray objectAtIndex:indexPath.row] integerValue];
        if(category){
            cell.hurricaneCategory.text = [NSString stringWithFormat:@"%ld",(long)category];
        }
        else{
            cell.hurricaneCategory.text = @"t";
        }
    }
}

- (void)adjustHeightOfTableview
{
    CGFloat height = MAX([self.titleArray count] * 50, 50);
    // set the height constraint
    self.tableViewHeightConstraint.constant = height;
    if(!self.dataURL){
        self.tableViewHeightConstraint.constant = self.firstLaunchView.frame.size.height;
    }
    [self.view needsUpdateConstraints];
}

-(IBAction)launchAppButtonTapped:(id)sender{
    NSURL *url = [NSURL URLWithString:kAppURL];
    [self.extensionContext openURL:url completionHandler:nil];
}


- (UIColor *)colorWithHexValue:(NSInteger)rgbValue {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((float)((rgbValue & 0xFF00) >> 8))/255.0
                            blue:((float)(rgbValue & 0xFF))/255.0
                           alpha:1.0];
}

@end
