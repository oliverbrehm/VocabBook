//
//  VBMenuFooterView.h
//  Vocab Book
//
//  Created by Oliver Brehm on 25/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VBMenuCVC;

@interface VBMenuFooterView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *resetFilterButton;

@property (strong, nonatomic) VBMenuCVC *menuCVC;

@end
