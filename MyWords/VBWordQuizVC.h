//
//  VBWordQuizVC.h
//  Vocab Book
//
//  Created by Oliver Brehm on 20/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

@class Word, WordSet;

@interface VBWordQuizVC : UIViewController

@property (strong, nonatomic) WordSet *wordSet;
@property (strong, nonatomic) NSMutableArray *wordQueue;
@property (strong, nonatomic) Word *currentWord;

-(Word*) getNewWord;

@end
