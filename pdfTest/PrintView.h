//
//  PrintView.h
//  Vocab Book
//
//  Created by Oliver Brehm on 24/05/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrintView : UIView

@property (nonatomic) CGFloat fontSize;

-(NSUInteger) getCapacity;
-(void) drawWithWords: (NSArray*) words;

@end
