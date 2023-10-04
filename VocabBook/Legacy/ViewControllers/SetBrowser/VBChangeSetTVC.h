//
//  VBChangeSetTVC.h
//  Vocab Book
//
//  Created by Oliver Brehm on 15/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBSetBrowserBase.h"

@class Word;

@interface VBChangeSetTVC : VBSetBrowserBase

@property (strong, nonatomic) Word *word;

@end
