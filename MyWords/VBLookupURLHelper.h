//
//  VBLookupURLHelper.h
//  Vocab Book
//
//  Created by Oliver Brehm on 11/04/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VBLookupURLHelper : NSObject

+(void) prepopulateURLs;
+(NSArray*) availableURLS;
+(NSDictionary*) urlItemAtIndex: (NSUInteger) index;
+(void) addURL: (NSString*) urlString withDescription: (NSString*) description;
+(void) updateURLAtIndex: (NSUInteger) index withURL: (NSString*) urlString andDescription: (NSString*) description;
+(NSArray*) deleteURLItemAtIndex: (NSUInteger) index;
+(NSArray*) moveURLItemFromIndex: (NSUInteger) fromIndex toIndex: (NSUInteger) toIndex;
+(void) setDefaultURL:(NSString *)urlString;
+(NSString*) defaultURLString;
+(void) mergeToiCloud;
+(void) mergeFromiCloud;

@end
