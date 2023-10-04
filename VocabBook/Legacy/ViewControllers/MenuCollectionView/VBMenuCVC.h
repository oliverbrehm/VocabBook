//
//  WordSetsCVC.h
//  MyWords
//
//  Created by Oliver Brehm on 22/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VBMenuCVC : UICollectionViewController

@property (strong, nonatomic) UIPopoverController *currentPopoverController;

-(void) resetFilter;
-(void) queryData;
-(void) dismissPopover;

@end
