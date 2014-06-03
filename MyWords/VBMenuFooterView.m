//
//  VBMenuFooterView.m
//  Vocab Book
//
//  Created by Oliver Brehm on 25/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBMenuFooterView.h"
#import "VBMenuCVC.h"

@implementation VBMenuFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (IBAction)resetFilterButtonTouched:(id)sender {
    [self.menuCVC resetFilter];
}

@end
