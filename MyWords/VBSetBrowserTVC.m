//
//  WordsSetsTVC.m
//  MyWords
//
//  Created by Oliver Brehm on 24/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBSetBrowserTVC.h"
#import "WordSet.h"
#import "VBSetMenuTVC.h"

@interface VBSetBrowserTVC ()


@end

@implementation VBSetBrowserTVC

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
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[VBSetMenuTVC class]]) {
        VBSetMenuTVC *vc = (VBSetMenuTVC*) segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *) sender];
        vc.wordSet = self.wordSets[indexPath.row];
        
        vc.title = vc.wordSet.name;
    }
}

@end
