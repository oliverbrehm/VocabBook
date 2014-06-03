//
//  VBChangeSetTVC.m
//  Vocab Book
//
//  Created by Oliver Brehm on 15/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBChangeSetTVC.h"
#import "VBAppDelegate.h"
#import "WordSet.h"
#import "Word.h"

@interface VBChangeSetTVC ()

@property (strong, nonatomic) NSArray *wordSets;

@end

@implementation VBChangeSetTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WordSet *set = self.wordSets[indexPath.row];
    self.word.wordSet = set;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
