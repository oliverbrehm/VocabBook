//
//  VBDocumentManager.h
//  Vocab Book
//
//  Created by Oliver Brehm on 26/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIManagedDocument;

@interface VBDocumentManager : NSObject

@property (strong, nonatomic) UIManagedDocument *document;

-(void) openiCloudDocument;
-(void) openLocalDocument;

@end
