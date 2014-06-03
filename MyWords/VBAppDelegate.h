//
//  WordsAppDelegate.h
//  MyWords
//
//  Created by Oliver Brehm on 22/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordSet.h"

@class VBDocumentManager;

@interface VBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (weak, nonatomic) UIManagedDocument *managedDocument;
@property (strong, nonatomic) VBDocumentManager *documentManager;
@property (strong, nonatomic) NSArray *languages;

-(BOOL) usingiCloud;
-(BOOL) iCloudAvailable;
-(UIImage*) imageForLanguage: (NSString*) language;


@end
