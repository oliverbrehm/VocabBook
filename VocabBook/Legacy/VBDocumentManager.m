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
                [document closeWithCompletionHandler:nil];
            }
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

@end
