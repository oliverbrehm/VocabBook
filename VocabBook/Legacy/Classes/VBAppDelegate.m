//
//  WordsAppDelegate.m
//  MyWords
//
//  Created by Oliver Brehm on 22/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBAppDelegate.h"
#import "VBPremiumTVC.h"
#import "VBDocumentManager.h"
#import "VBLookupURLHelper.h"
#import "VBMenuCVC.h"
#import "VBHelper.h"

@interface VBAppDelegate () <UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *languageImages;

@end

@implementation VBAppDelegate

-(UIManagedDocument*) managedDocument
{
    return self.documentManager.document;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    srand((unsigned)time(NULL));

    
    self.documentManager = [[VBDocumentManager alloc] init];
    
    [self prepareiCloud];
    
    if([self usingiCloud]) {
        [self.documentManager openiCloudDocument];
    } else {
        [self.documentManager openLocalDocument];
       }
    
    /*
#warning REMOVE
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREMIUM_IDENTIFIER];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"usingiCloud"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    */
    
    // check if user has purchased premium
    if([[NSUserDefaults standardUserDefaults]boolForKey:PREMIUM_IDENTIFIER]) {
        NSLog(@"PREMIUM purchased");
    } else {
        NSLog(@"PREMIUM not purchased");
    }

    // initialize lookup urls
    [VBLookupURLHelper prepopulateURLs];

    // create languages
    self.languages = [VBAppDelegate createLanguages];
    [self loadLanguageImages];
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval: 60 * 60 /* 1 hour */];
    NSLog(@"minimum: %f", UIApplicationBackgroundFetchIntervalMinimum);
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Updating application icon batch number in background fetch...");
    NSInteger oldBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
    NSInteger newBadgeNumber = [VBHelper numberOfDueWords];
    if(newBadgeNumber > oldBadgeNumber) {
        NSLog(@"New batch number: %d -> %d", oldBadgeNumber, newBadgeNumber);
        [UIApplication sharedApplication].applicationIconBadgeNumber = newBadgeNumber;
        completionHandler(UIBackgroundFetchResultNewData);
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

-(void) prepareiCloud
{
    // prepare iCloud
    [self getUbiquityToken];
    
    // iCloud availability changed?
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector (iCloudAccountAvailabilityChanged:)
     name: NSUbiquityIdentityDidChangeNotification object: nil];
    
    // prepare iCloud key-value store
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector (storeDidChange:)
     name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification
     object: [NSUbiquitousKeyValueStore defaultStore]];
    // get changes that might have happened while this
    // instance of your app wasn't running
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

-(void) iCloudAccountAvailabilityChanged: (NSNotification*) notification
{
    NSLog(@"iCloud availability changed");
    [self getUbiquityToken];
    if(![self iCloudAvailable]) {
        
        NSString *iCloudAvailabilityChangedTitle = NSLocalizedString(@"iCloudAvailabilityChangedTitle", @"iCloud no longer available");
        NSString *iCloudAvailabilityChangedMessage = NSLocalizedString(@"iCloudAvailabilityChangedMessage", @"iCloud is no longer available. Do you want to merge your cloud data to local storage? (If you choose no, data created in the cloud will no longer be accessible on this device!)");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:iCloudAvailabilityChangedTitle message:iCloudAvailabilityChangedMessage delegate:self cancelButtonTitle:NSLocalizedString(@"YesOptionText", @"Yes") otherButtonTitles: NSLocalizedString(@"NoOptionText", @"No"), nil];
        [alertView show];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { // merge iCloud data? yes
        [self.documentManager migrateToLocalStorage];
    } else if(buttonIndex == 1) { // no
        [self.documentManager openLocalDocument];
    }
    
    UINavigationController *rootVC = (UINavigationController*) self.window.rootViewController;
    [rootVC popToRootViewControllerAnimated:YES];
    
    // refresh root vc
    __block VBMenuCVC *menuCVC = [VBHelper getMenuCVC];
    [self.documentManager.document.managedObjectContext performBlock:^{
        [menuCVC queryData];
    }];
}

-(void) getUbiquityToken
{
    id currentiCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if(currentiCloudToken) {
        NSData *tokenData = [NSKeyedArchiver archivedDataWithRootObject: currentiCloudToken];
        [[NSUserDefaults standardUserDefaults] setObject:tokenData forKey:@"com.vocab-book.vocabbook.UbiquityIdentityToken"];
        NSLog(@"getting iCloudToken successfull: %@", [currentiCloudToken description]);
    } else {
        NSLog(@"iCloud is not available");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"com.vocab-book.vocabbook.UbiquityIdentityToken"];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"usingiCloud"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}

-(BOOL) iCloudAvailable
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"com.vocab-book.vocabbook.UbiquityIdentityToken"] != nil;
}

-(void) storeDidChange: (NSNotification*) notification
{
    NSLog(@"iCloud key-value store changed");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    // refresh main CVC if it is on screen
    UINavigationController *navigationVC = (UINavigationController*) self.window.rootViewController;
    VBMenuCVC *menuCVC = (VBMenuCVC*) navigationVC.viewControllers[0];
    if(menuCVC && menuCVC.view.window) {
        [menuCVC queryData];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL) usingiCloud
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"usingiCloud"];
}

-(void) loadLanguageImages
{
    if(!self.languageImages) {
        self.languageImages = [[NSMutableDictionary alloc] init];
        
        for(NSString *language in self.languages) {
            NSString *imageName = [NSString stringWithFormat:@"flag_%@.png", [language lowercaseString]];
            UIImage *image = [UIImage imageNamed:imageName];
            if(image) {
                [self.languageImages setObject:image forKey: language];
            }
        }
        
        UIImage *unknownImage = [UIImage imageNamed:@"unknown_language.png"];
        [self.languageImages setObject:unknownImage forKey:@"unknown_language"];
    }
}

-(UIImage*) imageForLanguage:(NSString *)language
{
    UIImage *image = self.languageImages[language];
    if(!image) {
        image = self.languageImages[@"unknown_language"];
    }
    return image;
}

+(NSArray*) createLanguages
{
    return @[
             // most common
             @"English",
             @"Español",
             @"Français",
             @"Português",
             @"Deutsch",
             
             // west european
             @"Nederlands", // Niederländisch
             @"Gaeilge", // Irisch
             
             //north european
             @"Dansk", // Dänisch
             @"Suomi", // Finnisch
             @"Svenska", // Schwedisch
             @"Norsk", // Norwegisch
             
             // south european
             @"Italiano",
             @"Greek", // not translated, too many dialects
             @"Türkçe",

             // asiatic
             @"Chinese",
             @"Japanese",
             @"Thai",
             @"South Corean",
             @"Vietnamese",
             
             // arabic/indian
             @"Russian",
             @"Hindi",
             @"Arabic",
             @"Bengali",
             @"Punjabi",

             // east european
             @"Polski",
             @"Shqip", // Albanisch
             @"Hrvatski", // Kroatisch
             @"Bălgarski esik", // Bulgarisch
             @"Magyar", // Ungarisch
             @"Kazakh",
             @"Limba română", // Romänisch
             @"Srpski jezik", // Serbisch
             @"Slovenščina", // Slovenisch
             @"Ukrayins'ka mova", // Ukrainisch
             @"čeština" // Tschechisch
             
             ];
}

@end
