//
//  WordSet+DocumentOperations.m
//  Vocab Book
//
//  Created by Oliver Brehm on 22/05/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "WordSet+DocumentOperations.h"
#import "VBAppDelegate.h"
#import "VBLookupURLHelper.h"
#import "Word+DocumentOperations.h"
#import "VBHelper.h"

@implementation WordSet (DocumentOperations)

+(WordSet*) createWithName: (NSString *) name andLanguage: (NSString*) language andDescription: (NSString*) description andFavourite: (BOOL) favourite
{
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    WordSet *wordSet = [NSEntityDescription insertNewObjectForEntityForName:@"WordSet" inManagedObjectContext:document.managedObjectContext];
    wordSet.name = name;
    wordSet.language = language;
    wordSet.descriptionText = description;
    wordSet.isFavourite = [NSNumber numberWithBool:favourite];
    wordSet.creationDate = [NSDate date];
    wordSet.lastUsedDate = [NSDate date];
    wordSet.lookupURL = [VBLookupURLHelper defaultURLString];
    wordSet.lastTestTotalWords = [NSNumber numberWithInteger:0];
    wordSet.changesSinceLastTest = [NSNumber numberWithInteger:0];
    
    return wordSet;
}

-(NSArray*) getWordsWithSortDescriptor: (NSSortDescriptor*) sortDescriptor;
{
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];

    request.predicate = [NSPredicate predicateWithFormat:@"wordSet = %@", self];
    
    if (sortDescriptor) {
        request.sortDescriptors = @[sortDescriptor];
    }
    
    NSArray *result = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!result) {
        NSLog(@"Error finding words for determining level");
        return nil;
    }
    
    if([result count] == 0) {
        return nil;
    }
    
    return result;
}

-(NSUInteger) numberOfDueWords {
    NSMutableArray *dueWords = [[NSMutableArray alloc] init];
    
    for(Word *word in self.words) {
        if([word isDue]) {
            [dueWords addObject:word];
        }
    }
    
    return [dueWords count];
    
}

-(NSMutableArray*) getDueWords
{
    return [[WordSet getDueWords:self] mutableCopy];
}

+(NSMutableArray*) getDueWordsForAllWords
{
    return [WordSet getDueWords:nil];
}

+(NSMutableArray*) getDueWords: (WordSet*) wordSet
{
    NSMutableSet *dueWords = [[NSMutableSet alloc] init];
    NSArray *words;
    
    if(wordSet) {
        words = [wordSet.words allObjects];
    } else {
        words = [VBHelper getAllWords];
    }
    
    for(Word *word in words) {
        if([word isDue]) {
            [dueWords addObject:word];
        }
    }
    
    if([dueWords count] > 0) {
        return [[VBHelper shuffledArray: [dueWords allObjects]] mutableCopy];
    }
    
    // return all words if there are no due words
    return [[VBHelper shuffledArray: words] mutableCopy];
}

-(NSDate*) nextDueDate
{
    return [WordSet nextDueDate: self];
}

+(NSDate*) nextDueDateForAllWords
{
    return [WordSet nextDueDate:nil];
}

+(NSDate*) nextDueDate: (WordSet*) wordSet
{
    NSDate *date = [NSDate distantFuture];
    NSArray *words;
    
    if(wordSet) {
        words = [wordSet.words allObjects];
    } else {
        words = [VBHelper getAllWords];
    }
    
    for(Word* word in words) {
        NSDate *wordDueDate = [word dueDate];
        if([date compare: wordDueDate] > 0) {
            date = wordDueDate;
        }
    }
    
    return date;
}


@end
