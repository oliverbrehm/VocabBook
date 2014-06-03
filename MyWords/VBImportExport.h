//
//  VBImportExport.h
//  Vocab Book
//
//  Created by Oliver Brehm on 25/04/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VBImportExport : NSObject

+(void) importDatabaseFromFile: (NSString*) file;
+(void) exportDatabase;
+(NSArray*) getAvailableImportFileNames;
+(BOOL) deleteFile: (NSString*) file;

@end
