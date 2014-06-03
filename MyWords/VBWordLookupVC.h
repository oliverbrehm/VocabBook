//
//  WordsLookUpVC.h
//  MyWords
//
//  Created by Oliver Brehm on 23/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WordSet;

@interface VBWordLookupVC : UIViewController

@property (strong, nonatomic) NSString *wordName;
@property (strong, nonatomic) NSString *wordTranslation;

@property (strong, nonatomic) WordSet *wordSet;

@property (nonatomic) BOOL didLoadWebView;

@end
