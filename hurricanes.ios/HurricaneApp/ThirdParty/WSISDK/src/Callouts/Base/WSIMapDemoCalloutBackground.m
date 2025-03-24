// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#import "WSIMapDemoCalloutBackground.h"

@implementation WSIMapDemoCalloutBackground
{
	CGFloat _rgbComponents[4];
    
    UIColor *_outlineColor;
	CGFloat _outlineSize;
}

- (id)initWithFrame:(CGRect)frame withColorComponents:(CGFloat[4])colorComponents andStrokeColor:(UIColor *)strokeColor
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        
		_rgbComponents[0] = colorComponents[0];
        _rgbComponents[1] = colorComponents[1];
        _rgbComponents[2] = colorComponents[2];
        _rgbComponents[3] = colorComponents[3];
        
        _outlineColor = strokeColor;
		_outlineSize = 1.0;
    }
	
    return self;
}


- (void)drawRect:(CGRect)rect
{
	CGRect rrect = self.bounds;
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat radius = 7.0;
    
    CGFloat minx = CGRectGetMinX(rrect);
    CGFloat midx = CGRectGetMidX(rrect);
    CGFloat maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect);
    CGFloat midy = CGRectGetMidY(rrect);
    CGFloat maxy = CGRectGetMaxY(rrect);

  	// create rounded rect
    CGContextBeginPath(context);
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    
    // Fill & draw stroke outline
    CGContextSetStrokeColorWithColor(context, _outlineColor.CGColor);
	CGContextSetLineWidth(context, _outlineSize);
    CGContextSetRGBFillColor(context, _rgbComponents[0], _rgbComponents[1], _rgbComponents[2], _rgbComponents[3]);
    
	CGContextDrawPath(context, kCGPathFillStroke);
}

@end
