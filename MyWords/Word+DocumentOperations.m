//
//  Word+DocumentOperations.m
//  Vocab Book
//
//  Created by Oliver Brehm on 22/05/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "Word+DocumentOperations.h"

@implementation Word (DocumentOperations)

-(BOOL) isDue
{
    NSTimeInterval waitingTime =  [[NSDate date] timeIntervalSinceDate:self.lastQuizzedDate];
    
    if(waitingTime >= [Word waitingTimeForLevel: self.level]) {
        return YES;
    }
    
    return NO;
}

-(NSDate*) dueDate
{
    NSDate *date = self.lastQuizzedDate;
    return [date dateByAddingTimeInterval:[Word waitingTimeForLevel: self.level]];
}

+(NSTimeInterval) waitingTimeForLevel: (NSNumber*) level
{
    /*#warning DEBUG REMOVE
     return 5.0; // 5 seconds*/
    
    switch ([level intValue]) {
        case 0:
            return 0.0; // new word or reset
            break;
        case 1:
            return 1.0 * 60 * 60 * 24; // 1 day
            break;
        case 2:
            return 3.0 * 60 * 60 * 24; // 3 days
            break;
        case 3:
            return 6.0 * 60 * 60 * 24; // 6 dayss
            break;
        case 4:
            return 14.0 * 60 * 60 * 24; // 14 days
            break;
        case 5:
            return 30.0 * 60 * 60 * 24; // 30 days
            break;
        case 6:
            return 3.0 * 60 * 60 * 24 * 30; // about 3 months
            break;
            
        default:
            return 3.0 * 60 * 60 * 24 * 30; // about 3 months
            break;
    }
}


@end
