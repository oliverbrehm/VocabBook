//
//  WordsCreateSetTVC.h
//  MyWords
//
//  Created by Oliver Brehm on 23/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WordSet;

@interface VBCreateSetTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createButton;

@property (strong, nonatomic) WordSet *wordSet;
@property (strong, nonatomic) NSString *customLanguage;

@end
