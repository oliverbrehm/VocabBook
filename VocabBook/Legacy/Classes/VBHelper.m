//
//  VBHelper.m
//  Vocab Book
//
//  Created by Oliver Brehm on 11/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBHelper.h"
#import "WordSet+DocumentOperations.h"
#import "VBAppDelegate.h"
#import "Word+DocumentOperations.h"
#import "VBLookupURLHelper.h"
#import "VBMenuCVC.h"

@implementation VBHelper

+(NSArray*) getAllWordsWithSortDescriptor: (NSSortDescriptor*) sortDescriptor
{
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    
    if(sortDescriptor) {
        request.sortDescriptors = @[sortDescriptor];
    }
    
    NSArray* result = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!result) {
        NSLog(@"Error getting all words");
    }
    
    return result;
}

+(UIColor*) globalButtonColor
{
    return [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
}

+(BOOL) emptyDatabase
{
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request.fetchLimit = 1;
    if ([document.managedObjectContext countForFetchRequest:request error:NULL] == 0) {
        return YES;
    };
    
    return NO;
}

+(WordSet*) wordSetWithName: (NSString*) name
{
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WordSet"];
    if(name) {
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
    }
    
    NSArray *result = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!result || [result count] == 0) {
        return nil;
    }
    
    return result[0];
}

+(NSUInteger) numberOfWordSets
{
    
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WordSet"];
    
    NSArray *result = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!result || [result count] == 0) {
        return 0;
    }
    
    return [result count];
}

+(NSUInteger) numberOfDueWords
{
    NSMutableArray *dueWords = [[NSMutableArray alloc] init];
    
    NSArray *words = [VBHelper getAllWordsWithSortDescriptor:nil];
    
    for(Word *word in words) {
        if([word isDue]) {
            [dueWords addObject:word];
        }
    }
    
    return [dueWords count];
}

+(Word*) wordWithName: (NSString*) name inSet:(WordSet*) set
{
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    
    if (set) {
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@ AND wordSet.name = %@",name, set.name];
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
    }
    
    NSArray *result = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!result || [result count] == 0) {
        return nil;
    }
    
    return result[0];
}

+(NSUInteger) countAllWords
{
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    return [document.managedObjectContext countForFetchRequest:request error:NULL];
}

+(NSMutableArray*) getAvailableLevelsForWordSet: (WordSet*) wordSet
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"level" ascending:YES];
    NSArray *words;
    if (wordSet) {
        words    = [wordSet getWordsWithSortDescriptor:sortDescriptor];
    } else {
        words = [VBHelper getAllWordsWithSortDescriptor:sortDescriptor];
    }
    
    // determine all available levels
    NSMutableArray *levels = [[NSMutableArray alloc] init]; // of NSNumber*
    for(Word *word in words) {
        if (![levels containsObject:word.level]) {
            [levels addObject:word.level];
        }
    }
    
    return levels;
}

+(NSMutableArray*) getAvailableLettersForWordSet: (WordSet*) wordSet
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *words;
    if (wordSet) {
        words    = [wordSet getWordsWithSortDescriptor:sortDescriptor];
    } else {
        words = [VBHelper getAllWordsWithSortDescriptor:sortDescriptor];
    }
    
    // determine all available start letters
    NSMutableArray *letters = [[NSMutableArray alloc] init]; // of NSString
    for(Word *word in words) {
        NSString *firstLetter = [word firstLetter];
        if (![letters containsObject:firstLetter]) {
            [letters addObject:firstLetter];
        }
    }
    
    return [[letters sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)] mutableCopy];
}

+(NSMutableArray*) getAvailableMonthsForWordSet: (WordSet*) wordSet
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    NSArray *words;
    if (wordSet) {
        words    = [wordSet getWordsWithSortDescriptor:sortDescriptor];
    } else {
        words = [VBHelper getAllWordsWithSortDescriptor:sortDescriptor];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // determine all available months
    NSMutableArray *months = [[NSMutableArray alloc] init]; // of NSDateComponents*
    for(Word *word in words) {
        NSDate *date = word.creationDate;
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
        
        if (![months containsObject:components]) {
            [months addObject:components];
        }
    }
    
    return months;
}

+(NSArray*) shuffledArray: (NSArray*) source;
{
    NSMutableArray *sourceArray = [source  mutableCopy];
    NSMutableArray *shuffled = [[NSMutableArray alloc] init];
    
    while ([sourceArray count] > 0) {
        NSUInteger randomIndex = [VBHelper randomIndexWithMax: [sourceArray count]];
        NSObject *obj = sourceArray[randomIndex];
        [shuffled addObject:obj];
        [sourceArray removeObject:obj];
    }
    
    return [NSArray arrayWithArray:shuffled];
}

+(NSUInteger) randomIndexWithMax: (NSUInteger) max
{
    double r = ((rand() * 1.0) / RAND_MAX) * max;
    return (NSUInteger) r;
}

+(void) linkToRateApp
{
    NSString *reviewURLString = @"itms-apps://itunes.apple.com/app/id837610347";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURLString]];
}

+(VBMenuCVC*) getMenuCVC
{
    UINavigationController *rootVC = (UINavigationController*) ((UIWindow*) [UIApplication sharedApplication].windows[0]).rootViewController;

    for(UIViewController *vc in rootVC.viewControllers) {
        if([vc class] == [VBMenuCVC class]) {
            return (VBMenuCVC*) vc;
        }
    }

    return nil;
}

@end
