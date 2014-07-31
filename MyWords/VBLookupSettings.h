//
//  VBLookupSettings.h
//  Vocab Book
//
//  Created by Oliver Brehm on 20/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WordSet, VBWordLookupVC;

@interface VBLookupSettings : UITableViewController

@property (strong, nonatomic) WordSet *wordSet;
@property (weak, nonatomic) VBWordLookupVC *wordLookupVC;

@end
