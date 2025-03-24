//
//  HurricaneCell.m
//  Trailblazer
//
//  Created by Swati Verma on 10/13/14.
//  Copyright (c) 2014 PNS Digital. All rights reserved.
//

#import "HurricaneWidgetCell.h"

@implementation HurricaneWidgetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)awakeFromNib {
    self.hurricaneName.font = [UIFont fontWithName:@"Helvetica" size:15];;
    self.hurricaneName.textColor = [UIColor whiteColor];
    self.hurricaneName.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.hurricaneCategory.font = [UIFont fontWithName:@"AvenirNext-Bold" size:16];
    self.hurricaneCategory.textColor = [UIColor whiteColor];
    
    self.hurricaneCategoryBackground.backgroundColor = [UIColor redColor];
    self.hurricaneCategoryBackground.layer.cornerRadius = self.hurricaneCategoryBackground.frame.size.width/2;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted)
        self.alpha = 0.5;
    else
        self.alpha = 1.0;
}

@end
