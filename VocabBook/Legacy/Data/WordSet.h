//
//  WordSet.h
//  Vocab Book
//
//  Created by Oliver Brehm on 27/04/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word;

@interface WordSet : NSManagedObject

@property (nonatomic, retain) NSNumber * changesSinceLastTest;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * descriptionText;
@property (nonatomic, retain) NSNumber * isFavourite;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSDate * lastTestDate;
@property (nonatomic, retain) NSNumber * lastTestScore;
@property (nonatomic, retain) NSNumber * lastTestTotalWords;
@property (nonatomic, retain) NSDate * lastUsedDate;
@property (nonatomic, retain) NSString * lookupURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *words;
@end

@interface WordSet (CoreDataGeneratedAccessors)

- (void)addWordsObject:(Word *)value;
- (void)removeWordsObject:(Word *)value;
- (void)addWords:(NSSet *)values;
- (void)removeWords:(NSSet *)values;

@end
