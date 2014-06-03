//
//  WordSetCollectionViewCell.h
//  MyWords
//
//  Created by Oliver Brehm on 22/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VBMenuWordSetCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *dueWordsLabel;
@property (weak, nonatomic) IBOutlet UIView *borderView;

@property (nonatomic) NSUInteger numberOfDueWords;

//-(void) initialize;

@end
