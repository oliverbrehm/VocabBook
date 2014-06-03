//
//  VBLookupURLHelper.m
//  Vocab Book
//
//  Created by Oliver Brehm on 11/04/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBLookupURLHelper.h"
#import "VBAppDelegate.h"

@implementation VBLookupURLHelper

+(void) prepopulateURLs
{
    // check if lookup urls exist
    NSArray *items = [[[NSUserDefaults standardUserDefaults] objectForKey:@"URLItemsKey"] mutableCopy];
    if(!items || [items count] == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[VBLookupURLHelper defaultItems] forKey:@"URLItemsKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // same for iCloud
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if([appDelegate usingiCloud]) {
        if (![[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"URLItemsKey"]) {
            [[NSUbiquitousKeyValueStore defaultStore] setObject: [VBLookupURLHelper defaultItems] forKey:@"URLItemsKey"];
            [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        }
        
    }
    
    // set default url for new sets
    [VBLookupURLHelper setDefaultURL];
}

+(NSArray*) availableURLS
{
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if([appDelegate usingiCloud]) {
        return [[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"URLItemsKey"];
    } else {
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"URLItemsKey"];
    }
}

+(NSDictionary*) urlItemAtIndex:(NSUInteger)index
{
    return [VBLookupURLHelper availableURLS][index];
}

+(void) addURL: (NSString*) urlString withDescription: (NSString*) description
{
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if([appDelegate usingiCloud]) {
        NSMutableArray *previousItems = [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"URLItemsKey"] mutableCopy];
        NSDictionary *item = @{@"Description": description, @"URL": urlString};
        [previousItems addObject:item];
        NSArray *newItems = [NSArray arrayWithArray:previousItems];
        [[NSUbiquitousKeyValueStore defaultStore] setObject:newItems forKey:@"URLItemsKey"];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    } else {
        NSMutableArray *previousItems = [[[NSUserDefaults standardUserDefaults] objectForKey:@"URLItemsKey"] mutableCopy];
        NSDictionary *item = @{@"Description": description, @"URL": urlString};
        [previousItems addObject:item];
        NSArray *newItems = [NSArray arrayWithArray:previousItems];
        [[NSUserDefaults standardUserDefaults] setObject:newItems forKey:@"URLItemsKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

+(void) updateURLAtIndex: (NSUInteger) index withURL: (NSString*) urlString andDescription: (NSString*) description
{
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if([appDelegate usingiCloud]) {
        NSMutableArray *items = [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"URLItemsKey"] mutableCopy];
        NSDictionary *newItem = @{@"Description": description, @"URL": urlString};
        [items removeObjectAtIndex: index];
        [items insertObject:newItem atIndex:index];
        
        NSArray *newItems = [NSArray arrayWithArray:items];
        [[NSUbiquitousKeyValueStore defaultStore] setObject:newItems forKey:@"URLItemsKey"];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    } else {
        NSMutableArray *items = [[[NSUserDefaults standardUserDefaults] objectForKey:@"URLItemsKey"] mutableCopy];
        NSDictionary *newItem = @{@"Description": description, @"URL": urlString};
        [items removeObjectAtIndex: index];
        [items insertObject:newItem atIndex:index];
        
        NSArray *newItems = [NSArray arrayWithArray:items];
        [[NSUserDefaults standardUserDefaults] setObject:newItems forKey:@"URLItemsKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}

+(NSArray*) deleteURLItemAtIndex: (NSUInteger) index
{
    NSMutableArray *previousItems;
    
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if([appDelegate usingiCloud]) {
        previousItems = [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"URLItemsKey"] mutableCopy];
    } else {
        previousItems = [[[NSUserDefaults standardUserDefaults] objectForKey:@"URLItemsKey"] mutableCopy];
    }
    
    [previousItems removeObjectAtIndex:index];
    NSArray *newItems = [NSArray arrayWithArray:previousItems];
    
    if([appDelegate usingiCloud]) {
        [[NSUbiquitousKeyValueStore defaultStore] setObject:newItems forKey:@"URLItemsKey"];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:newItems forKey:@"URLItemsKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return newItems;
}

+(NSArray*) moveURLItemFromIndex: (NSUInteger) fromIndex toIndex: (NSUInteger) toIndex
{
    NSMutableArray *items;

    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if([appDelegate usingiCloud]) {
        items = [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"URLItemsKey"] mutableCopy];
    } else {
        items = [[[NSUserDefaults standardUserDefaults] objectForKey:@"URLItemsKey"] mutableCopy];
    }
    
    NSDictionary *toMove = [items objectAtIndex:fromIndex];
    [items removeObjectAtIndex:fromIndex];
    [items insertObject:toMove atIndex:toIndex];
    
    NSArray *newItems = [NSArray arrayWithArray:items];
    
    if([appDelegate usingiCloud]) {
        [[NSUbiquitousKeyValueStore defaultStore] setObject:newItems forKey:@"URLItemsKey"];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:newItems forKey:@"URLItemsKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return newItems;
}


+(void) mergeToiCloud
{
    NSArray *localURLs = [[NSUserDefaults standardUserDefaults] objectForKey:@"URLItemsKey"];
    NSMutableArray *iCloudURLs = [[[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"URLItemsKey"] mutableCopy];
    
    for(NSDictionary *item in localURLs) {
        if (![VBLookupURLHelper urlItem:item ExistsInArray:iCloudURLs]) {
            [iCloudURLs addObject:item];
        }
    }
    
    [[NSUbiquitousKeyValueStore defaultStore] setObject: [NSArray arrayWithArray: iCloudURLs] forKey:@"URLItemsKey"];
}

+(void) mergeFromiCloud
{
    NSArray *iCloudURLs = [[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"URLItemsKey"];
    NSMutableArray *localURLs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"URLItemsKey"] mutableCopy];
    
    for(NSDictionary *item in iCloudURLs) {
        if(![VBLookupURLHelper urlItem: item ExistsInArray:localURLs]) {
            [localURLs addObject:item];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject: [NSArray arrayWithArray: localURLs] forKey:@"URLItemsKey"];
}

+(BOOL) urlItem: (NSDictionary *) item ExistsInArray: (NSArray*) array
{
    NSString *itemDescription = item[@"Description"];
    NSString *itemURL = item[@"URL"];

    for(NSDictionary *arrayItem in array) {
        NSString *arrayItemDescription = arrayItem[@"Description"];
        NSString *arrayItemURL = arrayItem[@"URL"];
        
        if([itemDescription isEqualToString:arrayItemDescription] && [itemURL isEqualToString:arrayItemURL]) {
            return YES;
        }
    }
    return NO;
}

+(void) setDefaultURL:(NSString *)urlString
{
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if([appDelegate usingiCloud]) {
        [[NSUbiquitousKeyValueStore defaultStore] setString: urlString forKey:@"DefaultSetURLKey"];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    }
    
    // same locally
    [[NSUserDefaults standardUserDefaults] setObject: urlString forKey:@"DefaultSetURLKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString*) defaultURLString
{
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if([appDelegate usingiCloud]) {
        return [[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"DefaultSetURLKey"];
    } else {
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"DefaultSetURLKey"];
    }
}

+(void) setDefaultURL
{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"DefaultSetURLKey"]) {
        [[NSUserDefaults standardUserDefaults] setObject: @"http://google.com" forKey:@"DefaultSetURLKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // same for iCloud
    if(![[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"DefaultSetURLKey"]) {
        [[NSUbiquitousKeyValueStore defaultStore] setObject: @"http://google.com" forKey:@"DefaultSetURLKey"];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    }
}

+(NSArray*) defaultItems
{
    NSArray *items = @[];
    
    NSString *userLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];

    if([userLanguage isEqualToString:@"de"]) {
        items = @[
                  @{@"Description": @"dict.cc Deutsch - Français", @"URL": @"http://defr.touch.dict.cc"},
                  @{@"Description": @"leo.org Deutsch - Français", @"URL": @"http://pda.leo.org/frde"},
                  ];
    }
    
    // default items for all languages
    NSString *userToEnglish = [NSString stringWithFormat:@"en%@", userLanguage]; // e.g. ruen
    NSString *dictCCEnglish = [NSString stringWithFormat:@"http://%@.touch.dict.cc", userToEnglish];
    NSString *leoEnglish = [NSString stringWithFormat:@"http://pda.leo.org/%@", userToEnglish];
    NSString *google = [NSString stringWithFormat:@"http://www.google.%@", userLanguage];
    NSString *wikipedia = [NSString stringWithFormat:@"http://%@.m.wikipedia.org", userLanguage];
    NSArray *defaultItems = @[
              @{@"Description": @"dict.cc (English)" , @"URL": dictCCEnglish},
              @{@"Description": @"leo.org (English)", @"URL": leoEnglish},
              @{@"Description": @"Google", @"URL": google},
              @{@"Description": @"Wikipedia", @"URL": wikipedia},
              @{@"Description": @"Wolframalpha", @"URL": @"http://m.wolframalpha.com"}
              ];

    
    return [items arrayByAddingObjectsFromArray: defaultItems];
}

@end
