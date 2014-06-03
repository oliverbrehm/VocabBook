//
//  Word.h
//  Vocab Book
//
//  Created by Oliver Brehm on 27/04/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WordSet;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * lastQuizzedDate;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numRight;
@property (nonatomic, retain) NSNumber * numWrong;
@property (nonatomic, retain) NSString * translations;
@property (nonatomic, retain) WordSet *wordSet;

@end
