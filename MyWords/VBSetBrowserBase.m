//
//  VBSetBrowserBase.m
//  Vocab Book
//
//  Created by Oliver Brehm on 27/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBSetBrowserBase.h"
#import "VBAppDelegate.h"
#import "VBHelper.h"
#import "WordSet+DocumentOperations.h"

@interface VBSetBrowserBase ()


@end

@implementation VBSetBrowserBase

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WordSet"];
    request.sortDescriptors = @[[[NSSortDescriptor alloc]
                                  initWithKey:@"name"
                                  ascending:YES
                                  selector:@selector(localizedCaseInsensitiveCompare:)]];
    self.wordSets = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!self.wordSets) {
        NSLog(@"Error getting words for sets");
        return 0;
    }
    
    return [self.wordSets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    WordSet *wordSet = (WordSet*)self.wordSets[indexPath.row];
    cell.textLabel.text = wordSet.name;
    
    NSInteger numWords = [wordSet.words count];
    NSUInteger numDue = [wordSet numberOfDueWords];

    NSString *wordString = numWords > 1 ? NSLocalizedString(@"wordsPlural", @"words") : NSLocalizedString(@"wordsSingular", @"word");
    if(numDue > 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld %@, %lu %@", (long)numWords, wordString, (unsigned long)numDue, NSLocalizedString(@"DueText", @"due")];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld %@", (long)numWords, wordString];
    }
    
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    cell.imageView.image = [appDelegate imageForLanguage:wordSet.language];
    
    return cell;
}

@end
