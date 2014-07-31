//
//  VBDocumentManager.m
//  Vocab Book
//
//  Created by Oliver Brehm on 26/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBDocumentManager.h"
#import "Word.h"
#import "WordSet.h"
#import "VBHelper.h"
#import "VBAppDelegate.h"

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@implementation VBDocumentManager

-(void) migrateToiCloud
{
    UIManagedDocument *localDocument = self.document;
    [self openiCloudDocumentMigrating:localDocument];
}

-(void) migrateToLocalStorage
{
    UIManagedDocument *iCloudDocument = self.document;
    [self openLocalDocumentMigrating: iCloudDocument];
}

-(void) openiCloudDocument
{
    [self openiCloudDocumentMigrating:nil];
}

-(void) openLocalDocument
{
    [self openLocalDocumentMigrating:nil];
}

-(void) openiCloudDocumentMigrating: (UIManagedDocument*) document
{
    // create UIManagedDocument
    NSString *documentName = @".coredata_library_icloud";
    [self createDocument:documentName];
    
    [self setPersistentStoreOptionsiCloud];
    
    if (!self.document) {
        NSLog(@"Error creating UIManagedDocument");
        return;
    }
    
    [self openDocument: document];
}

-(void) openLocalDocumentMigrating: (UIManagedDocument*) document
{
    // create UIManagedDocument
    NSString *documentName = @".coredata_library_local";
    [self createDocument:documentName];
    
    [self setPersistentStoreOptionsLocal];
    
    if (!self.document) {
        NSLog(@"Error creating UIManagedDocument");
        return;
    }
    
    [self openDocument: document];
}

-(void) createDocument: (NSString*) documentName
{
    NSURL *url = [self documentURL:documentName];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    //self.document.managedObjectContext.stalenessInterval = 0.0;
    NSLog(@"Document store url: %@", url);
}

-(NSURL*) documentURL: (NSString*) documentName
{
    NSURL *documentsUrl = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory /*NSLibraryDirectory*/ inDomains:NSUserDomainMask] firstObject];
    return [documentsUrl URLByAppendingPathComponent:documentName];
}

-(void) openDocument: (UIManagedDocument*) document
{
    if([[NSFileManager defaultManager] fileExistsAtPath:self.document.fileURL.path]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (!success) {
                NSLog(@"Error opening the user document at %@, state: %u", self.document.fileURL, (unsigned) self.document.documentState);
                self.document = document;
                
                return;
            }

            NSLog(@"Opening existing document %@ successfull, options: %@", self.document.fileURL, [self.document.persistentStoreOptions description]);
            if(document) {
                [self insertObjectsFroomDocument: document];
                [document closeWithCompletionHandler:nil];
            }
            
            [[NSNotificationCenter defaultCenter]
             addObserver: self
             selector: @selector (iCloudDidImportDatabaseChanges:)
             name: NSPersistentStoreDidImportUbiquitousContentChangesNotification
             object: self.document.managedObjectContext.persistentStoreCoordinator];
        }];
    } else {
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (!success) {
                NSLog(@"Error creating the user document at %@", self.document.fileURL);
                self.document = document;
                return;
            }
            NSLog(@"Creating new document %@ successfull", self.document.fileURL);
            if(document) {
                [document closeWithCompletionHandler:nil];
            }
        }];
    }
}

-(void) setPersistentStoreOptionsiCloud
{
    NSDictionary *options = [self persistentStoreOptionsiCloud];
    self.document.persistentStoreOptions = options;
    
    if(!self.document.persistentStoreOptions) {
        NSLog(@"Error setting persistenStoreOptions");
    } else {
        NSLog(@"Setting persistenStoreOptions successfull");
    }
}

-(void) iCloudDidImportDatabaseChanges: (NSNotification*) notification
{
    NSLog(@"Received ubiquity changes in document manager");
    //[self.document.managedObjectContext reset];
    [self.document.managedObjectContext performBlock:^{
        [self.document.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        
        NSNotification *n = [NSNotification notificationWithName:@"DocumentManagerImportediCloudChangesNotification" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }];
}

-(void) setPersistentStoreOptionsLocal
{
    NSDictionary *options = [self persistentStoreOptionLocal];
    self.document.persistentStoreOptions = options;
    
    if(!self.document.persistentStoreOptions) {
        NSLog(@"Error setting persistenStoreOptions");
    } else {
        NSLog(@"Setting persistenStoreOptions successfull");
    }
    
}
    
-(NSDictionary*) persistentStoreOptionsiCloud
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"vocab_book_iCloud_store",
            NSPersistentStoreUbiquitousContentNameKey, /*ubiquityContentURL, NSPersistentStoreUbiquitousContentURLKey,*/ [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,nil];
}

-(NSDictionary*) persistentStoreOptionLocal
{
    return [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,nil];
}

-(void) insertObjectsFroomDocument: (UIManagedDocument*) document
{
    // merge sets first
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WordSet"];
    NSArray *results = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!results) {
        NSLog(@"Error reading sets from source document");
        return;
    }
    for(WordSet *wordSet in results) {
        WordSet *newWordSet = [VBHelper wordSetWithName:wordSet.name];
        if (!newWordSet) { // set does not exist already -> create new set
            newWordSet = [NSEntityDescription insertNewObjectForEntityForName:@"WordSet" inManagedObjectContext:self.document.managedObjectContext];
            // set attributes
            newWordSet.name = wordSet.name;
            newWordSet.creationDate = wordSet.creationDate;
        }
        
        // set or update attributes
        newWordSet.descriptionText = wordSet.descriptionText;
        newWordSet.isFavourite = wordSet.isFavourite;
        newWordSet.language = wordSet.language;
    }
    
    // merge words
    request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    results = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!results) {
        NSLog(@"Error reading words from source document");
        return;
    }
    for(Word *word in results) {
        Word *newWord = [VBHelper wordWithName:word.name inSet:word.wordSet];
        if(!newWord) { // word does not exist already -> create new word
            newWord = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:self.document.managedObjectContext];
            // set attributes
            newWord.name = word.name;
            newWord.creationDate = word.creationDate;
        }
        
        // set or update attributes
        newWord.wordSet = [VBHelper wordSetWithName:word.wordSet.name];
        newWord.lastQuizzedDate = word.lastQuizzedDate;
        newWord.level = word.level;
        newWord.numRight = word.numRight;
        newWord.numWrong = word.numWrong;
        newWord.translations = word.translations;        
    }
}


/*
#warning debug insert some words
-(void) insertSomeWordsForEachSet
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WordSet"];
    NSArray *sets = [self.document.managedObjectContext executeFetchRequest:request error:NULL];

    for (WordSet *set in sets) {
        
        int n = 10 + (int)(((rand() * 1.0) * 30) / RAND_MAX);
        NSLog(@"n = %d", n);

        for(int i = 0; i < n; i++) {
            Word *word = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:self.document.managedObjectContext];
            word.wordSet = set;
            word.name = @"tmpName";
            word.translations = @"tmpTranslation";
        }
 
    }
}
 */

@end
