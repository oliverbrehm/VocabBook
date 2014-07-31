//
//  VBImportExport.m
//  Vocab Book
//
//  Created by Oliver Brehm on 25/04/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBImportExport.h"
#import "VBAppDelegate.h"
#import "Word.h"
#import "WordSet+DocumentOperations.h"
#import "VBHelper.h"
#import "VBPremiumTVC.h"

@implementation VBImportExport

+(void)importDatabaseFromFile:(NSString *)file {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbImport = [NSString stringWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:file] encoding:NSUTF8StringEncoding error:NULL];
    if(!dbImport) {
        NSLog(@"Error importing text file");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorText", @"Error") message:
                                  NSLocalizedString(@"ErrorOpeningTextFileForImporting", @"Error opening the import file.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    int numSkipped = 0;
    int numAdded = 0;
    int numExisted = 0;
    
    BOOL usingPremium = [[NSUserDefaults standardUserDefaults] boolForKey:PREMIUM_IDENTIFIER];
    NSUInteger numberOfWords = [VBHelper countAllWords];

    NSArray *words = [dbImport componentsSeparatedByString:@"\n"];
    for(NSString *word in words) {
        // check if WORD_LIMIT is reached
        if(!usingPremium && numberOfWords >= WORD_LIMIT) {
            NSString *importSuccessfullTitle = NSLocalizedString(@"ImportSuccessfullTitle", @"Import successfull");
            NSString *numWordsSuccessfullyAdded = NSLocalizedString(@"NumWordsSuccessfullyAdded", @"words successfully added.");
            NSString *numWordsAlreadyExisted = NSLocalizedString(@"NumWordsAlreadyExisted", @"words already existed.");
            NSString *wordsNotImportedBecauseNoPremium = NSLocalizedString(@"wordsNotImportedBecauseNoPremium", @"Some words were not imported because you can only have 60 words at a time without using PREMIUM. Please consider buying PREMIUM for a unlimited number of words and more features.");
            
            NSString *msg = [NSString stringWithFormat:@"%d %@ %d %@ %@", numAdded,numWordsSuccessfullyAdded, numExisted, numWordsAlreadyExisted, wordsNotImportedBecauseNoPremium];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: importSuccessfullTitle message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles:nil];
            [alertView show];

            return;
        }
        
        NSArray *components = [word componentsSeparatedByString:@","];
        
        if([components count] < 4) {
            numSkipped++;
            continue;
        }
        
        // skip if word already exists in set
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@ AND wordSet.name = %@", components[0], components[1]];
        NSArray *result = [document.managedObjectContext executeFetchRequest:request error:NULL];
        if (!result) {
            NSLog(@"Error checking if set %@ word exists", components[1]);
            return;
        }
        
        if([result count] != 0) {
            numExisted++;
            continue;
        }
        
        
        Word *word = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:document.managedObjectContext];
        if(!word) {
            NSLog(@"Error creating word");
            return;
        }
        word.name = components[0];
        word.creationDate = [NSDate date];
        word.lastQuizzedDate = [NSDate date];
        word.level = [NSNumber numberWithInt:0];
        word.numRight = [NSNumber numberWithInt:0];
        word.numWrong = [NSNumber numberWithInt:0];
        
        // create set if it does not exist
        request = [NSFetchRequest fetchRequestWithEntityName:@"WordSet"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", components[1]];
        NSArray *wordSets = [document.managedObjectContext executeFetchRequest:request error:NULL];
        if (!wordSets) {
            NSLog(@"Error checking if set %@ already exists", components[1]);
            return;
        }
        
        WordSet *set;
        
        if([wordSets count] == 0) {
            set = [WordSet createWithName:components[1] andLanguage:components[2] andDescription:@"" andFavourite:YES];
        } else {
            set = wordSets[0];
        }
        
        word.wordSet = set;
        
        // get translations
        NSMutableString *translations = [[NSMutableString alloc] init];
        
        for(int i = 3; i < [components count]; i++) {
            if (![components[i] isEqualToString:@""]) {
                [translations appendString:components[i]];
                [translations appendString:@"\n"];
            }
        }
        
        word.translations = translations;
        numAdded++;
        numberOfWords++;
    }
    
    NSString *importSuccessfullTitle = NSLocalizedString(@"ImportSuccessfullTitle", @"Import successfull");
    NSString *numWordsSuccessfullyAdded = NSLocalizedString(@"NumWordsSuccessfullyAdded", @"words successfully added.");
    NSString *numWordsAlreadyExisted = NSLocalizedString(@"NumWordsAlreadyExisted", @"words already existed.");
    
    NSString *msg = [NSString stringWithFormat:@"%d %@ %d %@", numAdded,numWordsSuccessfullyAdded, numExisted, numWordsAlreadyExisted];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: importSuccessfullTitle message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles:nil];
    [alertView show];
}
+(void) exportDatabase {
    
    NSMutableString *dbExport = [[NSMutableString alloc] init];
    
    // get words
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    int count = 0;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSArray *words = [document.managedObjectContext executeFetchRequest:request error:NULL];
    
    for(Word *word in words) {
        [dbExport appendFormat:@"%@,%@,%@", word.name, word.wordSet.name, word.wordSet.language];
        NSArray *translations = [word.translations componentsSeparatedByString:@"\n"];
        for(NSString *s in translations) {
            if(![s isEqualToString:@""]) {
                [dbExport appendFormat:@",%@", s];
            }
        }
        [dbExport appendString:@"\n"];
        count++;
    }
    
    NSString *path = [VBImportExport getAvailableExportPath];
    BOOL success = [dbExport writeToFile: path atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    if (!success){
        NSLog(@"Error exporting text file");
        return;
    }
    
    NSString *exportSuccessfullTitle = NSLocalizedString(@"ExportSuccessfullTitle", @"Export successfull");
    NSString *numWordsSuccessfullyExported = NSLocalizedString(@"NumWordsSuccessfullyExported", @"words successfully exported.");
    NSString *msg = [NSString stringWithFormat:@"%d %@", count, numWordsSuccessfullyExported];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:exportSuccessfullTitle message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles:nil];
    [alertView show];
}

+(NSString*) getAvailableExportPath
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
    NSString *path = [documentsDirectory stringByAppendingFormat:@"/export-%@.txt", [dateFormatter stringFromDate:date]];

    for (NSUInteger tryNo = 1; tryNo < 100 && [[NSFileManager defaultManager] fileExistsAtPath:path]; tryNo++) {
        path = [documentsDirectory stringByAppendingFormat:@"/export-%@_%lu.txt", [dateFormatter stringFromDate:date], (unsigned long) tryNo];
    }
    
    return path;
}

+(NSArray*) getAvailableImportFileNames
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *availablePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:NULL];

    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    
    // take only files, not folders
    BOOL isDir;
    for (NSString* path in availablePaths) {
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
        if ([[NSFileManager defaultManager] fileExistsAtPath: fullPath isDirectory:&isDir] && !isDir) {
            [filePaths addObject:path];
        }
    }
    
    return [NSArray arrayWithArray: filePaths];
}

+(BOOL) deleteFile:(NSString *)file
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:file] error:NULL];
}

@end
