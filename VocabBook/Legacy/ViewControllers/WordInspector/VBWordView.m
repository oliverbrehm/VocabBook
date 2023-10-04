//
//  VBCreateWordView.m
//  Vocab Book
//
//  Created by Oliver Brehm on 09/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBWordView.h"

@interface VBWordView ()

@property (weak, nonatomic) IBOutlet UILabel *translationsLabel;
@property (weak, nonatomic) IBOutlet UILabel *setLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;


@end

@implementation VBWordView

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
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGFloat x = self.translationsLabel.frame.origin.x + self.translationsLabel.frame.size.width + 4.0;
    CGContextMoveToPoint(context, x, 0.0);
    CGContextAddLineToPoint(context, x, self.frame.size.height);

    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGFloat dashes[] = {1.0, 1.0};
    CGContextSetLineDash(context, 0.0, dashes, 2.0);
    
    [self drawHorizontalLine: self.translationsLabel.frame.origin.y - 4.0 inContext:context];
    
    if(!self.setLabel.hidden) {
        [self drawHorizontalLine: self.setLabel.frame.origin.y - 4.0 inContext:context];
        [self drawHorizontalLine: self.levelLabel.frame.origin.y - 4.0 inContext:context];
        [self drawHorizontalLine: self.levelLabel.frame.origin.y + self.levelLabel.frame.size.height + 4.0 inContext:context];
    }
}

-(void) drawHorizontalLine: (CGFloat) y inContext: (CGContextRef) context
{
    CGContextMoveToPoint(context, 0.0, y);
    CGContextAddLineToPoint(context, self.frame.size.width, y);
    CGContextStrokePath(context);
}


@end
