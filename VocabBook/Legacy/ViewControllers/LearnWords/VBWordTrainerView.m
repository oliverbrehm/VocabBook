//
//  VBWordTrainerView.m
//  Vocab Book
//
//  Created by Oliver Brehm on 04/04/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBWordTrainerView.h"

@interface VBWordTrainerView ()

@property (weak, nonatomic) IBOutlet UITextView *translationsTextView;

@end

@implementation VBWordTrainerView

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
     
     CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
     CGFloat dashes[] = {1.0, 1.0};
     CGContextSetLineDash(context, 0.0, dashes, 2.0);
     
     [self drawHorizontalLine:self.translationsTextView.frame.origin.y - 5.0 inContext:context];
     [self drawHorizontalLine: self.translationsTextView.frame.origin.y + self.translationsTextView.frame.size.height + 4.0 inContext:context];
 }
 
 -(void) drawHorizontalLine: (CGFloat) y inContext: (CGContextRef) context
 {
     CGContextMoveToPoint(context, 0.0, y);
     CGContextAddLineToPoint(context, self.frame.size.width, y);
     CGContextStrokePath(context);
}

@end
