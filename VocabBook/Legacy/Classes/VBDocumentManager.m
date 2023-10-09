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
    
//#warning reset to .coredata_library_icloud ! this cannot change or users will lose their data!
    NSString *documentName = @".coredata_library_icloud";
    //SString *documentName = @".coredata_library_icloud_TEST";

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

-(NSURL*) localDocumentURL
{
    return [self documentURL:@".coredata_library_local"];
}

-(NSURL*) iCloudDocumentURL
{
    return [self documentURL:@".coredata_library_icloud"];
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
                [self insertObjectsFromDocument: document];
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
        
        NSNotification *n = [NSNotification notificationWithName:@"LegacyCoreDataReceivedICloudUpdate" object:self];
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
            NSPersistentStoreUbiquitousContentNameKey,[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,nil];
}

-(NSDictionary*) persistentStoreOptionLocal
{
    return [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,nil];
}

-(void) insertObjectsFromDocument: (UIManagedDocument*) document
{
    // merge sets first
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WordSet"];
    NSArray *results = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!results) {
        NSLog(@"Error reading sets from source document");
        return;
    }
    for(WordSet *wordSet in results) {
        WordSet *newWordSet = [self wordSetWithName:wordSet.name];
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
        Word *newWord = [self wordWithName:word.name inSet:word.wordSet];
        if(!newWord) { // word does not exist already -> create new word
            newWord = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:self.document.managedObjectContext];
            // set attributes
            newWord.name = word.name;
            newWord.creationDate = word.creationDate;
        }
        
        // set or update attributes
        newWord.wordSet = [self wordSetWithName:word.wordSet.name];
        newWord.lastQuizzedDate = word.lastQuizzedDate;
        newWord.level = word.level;
        newWord.numRight = word.numRight;
        newWord.numWrong = word.numWrong;
        newWord.translations = word.translations;        
    }
}

-(WordSet*) wordSetWithName: (NSString*) name
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WordSet"];
    if(name) {
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
    }

    NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!result || [result count] == 0) {
        return nil;
    }

    return result[0];
}

-(Word*) wordWithName: (NSString*) name inSet:(WordSet*) set
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];

    if (set) {
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@ AND wordSet.name = %@",name, set.name];
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
    }

    NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!result || [result count] == 0) {
        return nil;
    }

    return result[0];
}

@end
