//
//  VBLookupSettings.m
//  Vocab Book
//
//  Created by Oliver Brehm on 20/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBLookupSettings.h"
#import "VBLookupAddURLVC.h"
#import "WordSet.h"
#import "VBLookupURLHelper.h"
#import "VBWordLookupVC.h"

@interface VBLookupSettings ()

@property (strong, nonatomic) NSArray *availableURLS; // of NSDictionary {@"Description":, @"URL":}

@end

@implementation VBLookupSettings

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) queryData
{
    self.availableURLS = [[VBLookupURLHelper availableURLS] mutableCopy];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get url items
    [self queryData];
    
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

#pragma mark - Table view delegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        [self performSegueWithIdentifier:@"showURLItem" sender:nil];
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(self.wordSet) {
        self.wordSet.lookupURL = cell.detailTextLabel.text;
    }
    
    [VBLookupURLHelper setDefaultURL:cell.detailTextLabel.text];
    
    self.wordLookupVC.didLoadWebView = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showURLItem" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 1;
    }
    return [self.availableURLS count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"addURLCell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"URLItemCell" forIndexPath:indexPath];
        
        NSDictionary *item = self.availableURLS[indexPath.row];
        
        cell.textLabel.text = [item objectForKey:@"Description"];
        cell.detailTextLabel.text = [item objectForKey:@"URL"];
    }
    
    return cell;
}

- (IBAction)editButtonTouched:(UIBarButtonItem*)sender {
    if(self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        sender.title = NSLocalizedString(@"EditOptionText", @"Edit");
    } else {
        [self.tableView setEditing:YES animated:YES];
        sender.title = NSLocalizedString(@"DoneOptionText", @"Done");
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [self queryData];
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return (indexPath.section == 0) ? NO : YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.availableURLS = [VBLookupURLHelper deleteURLItemAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    self.availableURLS = [VBLookupURLHelper moveURLItemFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if(sourceIndexPath.section != proposedDestinationIndexPath.section) {
        return [NSIndexPath indexPathForRow:0 inSection:1]; // fix at top
    } else {
        return proposedDestinationIndexPath;
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return (indexPath.section == 0) ? NO : YES;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"";
    } else {
        return @"URLS";
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass: [VBLookupAddURLVC class]] && [segue.identifier isEqualToString:@"showURLItem"]) {
        VBLookupAddURLVC *vc = (VBLookupAddURLVC*) segue.destinationViewController;
        UITableViewCell *cell = (UITableViewCell*) sender;
        if(sender) {
            vc.urlItemIndex = (NSInteger) [self.tableView indexPathForCell:cell].row;
        } else {
            vc.urlItemIndex = -1;
        }
    } else {
        
    }
}

@end
