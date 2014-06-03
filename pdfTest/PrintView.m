//
//  PrintView.m
//  Vocab Book
//
//  Created by Oliver Brehm on 24/05/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "PrintView.h"

@interface PrintView ()

@property (strong, nonatomic) NSArray *words;

@end

@implementation PrintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void) initialize
{
    self.fontSize = 12.0;
}

-(NSUInteger) getCapacity
{
    CGFloat lineSize = self.fontSize + 5.0;
    return self.bounds.size.height / lineSize;
}

-(void) drawWithWords:(NSArray *)words
{
    self.words = [NSArray arrayWithArray:words];
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    self.clipsToBounds = NO;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat lineSize = self.fontSize + 5.0;
    
    NSUInteger lineIndex = 0;
    for (CGFloat y = 0.0; y < self.bounds.size.height && lineIndex < [self.words count]; y += lineSize) {
        [self drawHorizontalLine: y + lineSize inContext: context];
        NSString *lineString = self.words[lineIndex];
        [lineString drawAtPoint: CGPointMake(10.0, y + 1.0) withAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor], NSBackgroundColorAttributeName: [UIColor whiteColor]}];
        lineIndex++;
    }
    
    [self drawVerticalSplitInContext:context];
    
    //[self drawCageRectInContext:context];
}

-(void) drawVerticalSplitInContext: (CGContextRef) context
{
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextSetLineWidth(context, 2.0);
    CGFloat xPos = self.bounds.size.width / 2.0;
    CGContextMoveToPoint(context, xPos, 0.0);
    CGContextAddLineToPoint(context, xPos, self.bounds.size.height);
    CGContextStrokePath(context);
}

-(void) drawHorizontalLine: (CGFloat) y inContext: (CGContextRef) context
{
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 0.0, y);
    CGContextAddLineToPoint(context, self.bounds.size.width, y);
    CGContextStrokePath(context);
}

#define CAGE_SIZE 7.0
-(void) drawCageRectInContext: (CGContextRef) context
{
    UIColor *color = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGContextSetLineWidth(context, CAGE_SIZE);
    CGFloat dashes[] = {10.0, 10.0};
    CGContextSetLineDash(context, 0.0, dashes, 2.0);
    CGContextAddRect(context, CGRectInset(self.bounds, 0.0, 0.0));
    CGContextStrokePath(context);
}

@end




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
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

*/