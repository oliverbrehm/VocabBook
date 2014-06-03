//
//  WordSetRecentWordCell.m
//  MyWords
//
//  Created by Oliver Brehm on 01/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBMenuVocabCell.h"

#define LINE_DISTANCE 14.0

@interface VBMenuVocabCell ()

@end

@implementation VBMenuVocabCell

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
    CGRect insetRect = CGRectInset(rect, 2.0, 2.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPathRef path = [[UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:20.0] CGPath];
    
    // background
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:1.0 green:0.98 blue:0.95 alpha:1.0] CGColor]);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    // dashed line
    //CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGFloat dashes[] = {1.0, 1.0};
    CGContextSetLineDash(context, 0.0, dashes, 2.0);
    
    CGFloat y = self.wordLabel.frame.origin.y + self.wordLabel.frame.size.height + 2.0;
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextMoveToPoint(context, 0.0, y);
    CGContextAddLineToPoint(context, self.frame.size.width, y);
    //CGContextMoveToPoint(context, self.wordLabel.frame.origin.x - 2.0, 0.0);
    //CGContextAddLineToPoint(context, self.wordLabel.frame.origin.x - 2.0, self.frame.size.height);
    CGContextStrokePath(context);

    // restore normal line
    CGContextSetLineWidth(context, 1.0);
    CGFloat normalLine[] = {1.0};
    CGContextSetLineDash(context, 0.0, normalLine, 0.0);

    // horizontal lines
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetAlpha(context, 0.3);
    for(CGFloat y2 = y + LINE_DISTANCE; y2 < rect.size.height; y2 += LINE_DISTANCE) {
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGContextMoveToPoint(context, 0.0, y2);
        CGContextAddLineToPoint(context, rect.size.width, y2);
        CGContextStrokePath(context);
    }
}

@end
