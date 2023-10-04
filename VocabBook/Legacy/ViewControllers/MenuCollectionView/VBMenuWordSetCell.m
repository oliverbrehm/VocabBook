//
//  WordSetCollectionViewCell.m
//  MyWords
//
//  Created by Oliver Brehm on 22/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBMenuWordSetCell.h"

@interface VBMenuWordSetCell()

@end

@implementation VBMenuWordSetCell

/*
-(void) initialize
{
    //NSLog(@"SET CELL REDRAW");
    self.borderView.layer.borderColor = [UIColor blackColor].CGColor;
    self.borderView.layer.borderWidth = 1.0;
    //self.borderView.layer.cornerRadius = 15.0;
    //self.imageView.layer.cornerRadius = 15.0;
    //self.imageView.layer.masksToBounds = YES;
    
    
    if(self.selected) {
        //self.layer.cornerRadius = 15.0;
        //self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.15];
    } else {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 0.0;
    }
    
    if(self.numberOfDueWords == 0) {
        self.dueWordsLabel.hidden = YES;
    } else {
        self.dueWordsLabel.hidden = NO;
        self.dueWordsLabel.text = [NSString stringWithFormat:@"%u  ", self.numberOfDueWords];
        self.dueWordsLabel.layer.cornerRadius = 10.0;
        self.dueWordsLabel.layer.masksToBounds = YES;
        //self.dueWordsLabel.frame = CGRectMake(self.superview.frame.size.width - self.frame.size.width/2.0, -self.frame.size.height/2.0, self.frame.size.width, self.frame.size.height);
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
     
    }
    return self;
}


 
#define ELLIPSE_EDGE_X 7.0
#define ELLIPSE_EDGE_Y 3.0
-(void) drawDueCircle: (CGPoint) position inContext: (CGContextRef) context {
    NSString *dueString = [NSString stringWithFormat:@"%u", self.numberOfDueWords];
    
    UIFont *font = [UIFont fontWithName:@"System" size:14.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
#warning sizeWithAttributes not ios 6 compatible
    CGSize stringSize = [dueString sizeWithAttributes:attributes];
    
    // draw red ellipse
    CGRect circleRect = CGRectMake(position.x - stringSize.width / 2.0 - ELLIPSE_EDGE_X, position.y - stringSize.height / 2.0 - ELLIPSE_EDGE_Y, stringSize.width + 2 * ELLIPSE_EDGE_X, stringSize.height + 2 * ELLIPSE_EDGE_Y);
    CGContextAddEllipseInRect(context, circleRect);
    CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextFillPath(context);

    // draw string
#warning text color should be white but is black
    //CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGRect stringRect = CGRectMake(position.x - stringSize.width / 2.0, position.y - stringSize.height / 2.0, stringSize.width, stringSize.height);
    [dueString drawInRect: stringRect withAttributes: attributes];
}

#define FLAG_INSET 10.0

- (void)drawRect:(CGRect)rect
{
    
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    if(self.selected) {
        UIColor *bgColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.15];
        CGContextSetFillColorWithColor(context, [bgColor CGColor]);
        CGContextAddPath(context, [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:15.0] CGPath]);
        CGContextFillPath(context);
    }
    
    CGFloat flagX = 2.5 * FLAG_INSET;
    CGFloat flagWidth = rect.size.width - 4.5 * FLAG_INSET;
    CGRect flagRect = CGRectMake(flagX, 3 * FLAG_INSET, flagWidth, rect.size.height - 4 * FLAG_INSET);
    
    CGPathRef path = [[UIBezierPath bezierPathWithRoundedRect:flagRect cornerRadius:15.0] CGPath];
    
    //CGContextSaveGState(context);
    if(self.image) {
        //CGAffineTransform transform =CGAffineTransformMakeTranslation(0.0, rect.size.height);
        //transform = CGAffineTransformScale(transform, 1.0, -1.0);
        //CGContextConcatCTM(context, transform);
        
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGContextSetAlpha(context, 0.175);
        //CGContextDrawImage(context, flagRect, [self.image CGImage]);
        CGContextSetAlpha(context, 1.0);
        
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        
    }
    
    //CGContextRestoreGState(context);
    
    if(self.numberOfDueWords > 0) {
        CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
        CGPoint circlePosition = CGPointMake(flagX + flagWidth, 14.0);
        [self drawDueCircle: circlePosition inContext: context];
    }
}
*/

@end
