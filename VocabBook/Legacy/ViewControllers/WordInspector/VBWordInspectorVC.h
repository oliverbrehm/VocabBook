//
//  WordsSecondViewController.h
//  MyWords
//
//  Created by Oliver Brehm on 22/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WordSet, Word;

@interface VBWordInspectorVC : UIViewController

@property (strong, nonatomic) WordSet *wordSet;
@property (strong, nonatomic) Word *word;

@end