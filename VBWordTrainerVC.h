//
//  WordsQuizVC.h
//  MyWords
//
//  Created by Oliver Brehm on 23/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WordSet, Word;

@interface VBWordTrainerVC : UIViewController

@property (nonatomic) BOOL toUserlanguage;

@property (strong, nonatomic) WordSet *wordSet;
@property (strong, nonatomic) NSMutableArray *wordQueue;
@property (strong, nonatomic) Word *currentWord;

@end
