//
//  WordSet+DocumentOperations.h
//  Vocab Book
//
//  Created by Oliver Brehm on 22/05/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "WordSet.h"

@interface WordSet (DocumentOperations)

+(WordSet*) createWithName: (NSString *) name andLanguage: (NSString*) language andDescription: (NSString*) description andFavourite: (BOOL) favourite;
+(NSDate*) nextDueDateForAllWords;
+(NSMutableArray*) getDueWordsForAllWords;
-(NSArray*) getWordsWithSortDescriptor: (NSSortDescriptor*) sortDescriptor;
-(NSMutableArray*) getDueWords;
-(NSUInteger) numberOfDueWords;
-(NSDate*) nextDueDate;

@end
