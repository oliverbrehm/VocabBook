//
//  Word+DocumentOperations.h
//  Vocab Book
//
//  Created by Oliver Brehm on 22/05/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "Word.h"

@interface Word (DocumentOperations)

-(BOOL) isDue;
-(NSDate*) dueDate;

@end
