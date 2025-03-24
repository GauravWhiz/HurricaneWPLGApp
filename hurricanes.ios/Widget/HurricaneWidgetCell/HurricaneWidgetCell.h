//
//  HurricaneWidgetCell.h
//  Trailblazer
//
//  Created by Swati Verma on 10/13/14.
//  Copyright (c) 2014 PNS Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HurricaneWidgetCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *hurricaneName;
@property (nonatomic, weak) IBOutlet UILabel *hurricaneCategory;
@property (nonatomic, weak) IBOutlet UIView *hurricaneCategoryBackground;
@property (nonatomic, weak) IBOutlet UILabel *noDataLabel;
@end
