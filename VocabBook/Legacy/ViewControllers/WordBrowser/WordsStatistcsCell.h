//
//  WordsStatistcsCell.h
//  MyWords
//
//  Created by Oliver Brehm on 26/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordsStatistcsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *wrongLabel;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;

@property (strong, nonatomic) UIView *scoreView;

@end
