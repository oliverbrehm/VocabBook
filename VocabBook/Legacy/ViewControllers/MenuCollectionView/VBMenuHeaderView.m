//
//  WordSetCollectionViewHeaderView.m
//  MyWords
//
//  Created by Oliver Brehm on 24/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBMenuHeaderView.h"

@implementation VBMenuHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextMoveToPoint(context, 0.0, 0.0);
    CGContextAddLineToPoint(context, self.frame.size.width, 0.0);
    CGContextMoveToPoint(context, 0.0, self.frame.size.height);
    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
    CGContextStrokePath(context);

}

@end
