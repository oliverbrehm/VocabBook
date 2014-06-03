//
//  WordsBrowserTVC.h
//  MyWords
//
//  Created by Oliver Brehm on 22/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WordSet;

@interface VBWordBrowserTVC : UITableViewController

@property (strong, nonatomic) WordSet *wordSet;

@end
