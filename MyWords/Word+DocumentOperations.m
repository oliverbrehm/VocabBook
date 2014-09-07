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

-(BOOL) startsWithLetter:(unichar)letter
{
    NSArray *components = [self.name componentsSeparatedByString:@" "];
    for (NSString *component in components) {
        if ([Word componentIsArticle: component]) {
            continue;
        } else {
            return [[component capitalizedString] characterAtIndex:0] == letter;
        }
    }
    
    return [[components[0] capitalizedString] characterAtIndex:0] == letter;
}

-(NSString*) firstLetter
{
    NSArray *components = [self.name componentsSeparatedByString:@" "];
    for (NSString *component in components) {
        if ([Word componentIsArticle: component]) {
            continue;
        } else {
            return [[component substringToIndex:1] capitalizedString];
        }
    }
    
    return [[components[0] substringToIndex:1] capitalizedString];
}

-(NSString*) articleFreeName
{
    NSString *ret = [self.name copy];
    NSArray *components = [self.name componentsSeparatedByString:@" "];
    for (NSString *component in components) {
        if ([Word componentIsArticle: component]) {
            NSInteger index = [component length] + 1;
            if(index >= [ret length]) {
                ret = @"";
            } else {
                ret = [ret substringFromIndex: index];
            }
        } else {
            break;
        }
    }
    
    if([ret isEqualToString:@""]) {
        return self.name;
    }
    
    return ret;
}

+(BOOL) componentIsArticle: (NSString *) component
{
    if ([[component capitalizedString] isEqualToString: [@"the" capitalizedString]] ||
        [[component capitalizedString] isEqualToString: [@"to" capitalizedString]] ||
        [[component capitalizedString] isEqualToString: [@"la" capitalizedString]] ||
        [[component capitalizedString] isEqualToString: [@"le" capitalizedString]] ||
        [[component capitalizedString] isEqualToString: [@"les" capitalizedString]] ||
        [[component capitalizedString] isEqualToString: [@"il" capitalizedString]] ||
        [[component capitalizedString] isEqualToString: [@"el" capitalizedString]]) {
        return YES;
    }
    
    return NO;
}


@end
