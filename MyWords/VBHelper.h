//
//  VBHelper.h
//  Vocab Book
//
//  Created by Oliver Brehm on 11/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WORD_LIMIT 15

@class WordSet, Word, VBMenuCVC;

@interface VBHelper : NSObject

+(NSMutableArray*) getAvailableLevelsForWordSet: (WordSet*) wordSet;
+(NSMutableArray*) getAvailableLettersForWordSet: (WordSet*) wordSet;
+(NSMutableArray*) getAvailableMonthsForWordSet: (WordSet*) wordSet;
+(NSUInteger) countAllWords;
+(WordSet*) wordSetWithName: (NSString*) name;
+(Word*) wordWithName: (NSString*) name inSet: (WordSet*) set;
+(NSUInteger) numberOfWordSets;
+(UIColor*) globalButtonColor;
+(NSArray*) shuffledArray: (NSArray*) source;
+(BOOL) emptyDatabase;
+(NSUInteger) numberOfDueWords;
+(NSArray*) getAllWordsWithSortDescriptor: (NSSortDescriptor*) sortDescriptor;
+(void) linkToRateApp;
+(VBMenuCVC*) getMenuCVC;

@end
