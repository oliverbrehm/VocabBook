//
//  WordsBrowserTVC.m
//  MyWords
//
//  Created by Oliver Brehm on 22/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBWordBrowserTVC.h"
#import "VBAppDelegate.h"
#import "Word+DocumentOperations.h"
#import "WordSet.h"
#import "VBWordInspectorVC.h"
#import "VBHelper.h"
#import "WordsStatistcsCell.h"
#import "VBMenuCVC.h"

@interface VBWordBrowserTVC () <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButton;

@property (strong, nonatomic) NSMutableArray *words; // of NSMutableArray* (sections) of Word*
@property (strong, nonatomic) NSArray *sectionTitles; // of NSString*

@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation VBWordBrowserTVC

-(UISegmentedControl *) segmentControl
{
    if(!_segmentControl) {
        UIToolbar *toolbar = self.navigationController.toolbar;
        self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"ScoreText", @"Score"), NSLocalizedString(@"NameText", @"Name"), NSLocalizedString(@"NewestText", @"Newest")]];
        CGFloat x = toolbar.frame.size.width / 2.0 - self.segmentControl.frame.size.width / 2.0;
        CGFloat y = toolbar.frame.size.height / 2.0 - self.segmentControl.frame.size.height / 2.0;
        self.segmentControl.frame = CGRectMake(x, y, self.segmentControl.frame.size.width, self.segmentControl.frame.size.height);
        self.segmentControl.selectedSegmentIndex = 0;
        
        [self.segmentControl addTarget:self action:@selector(segmentControlChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

-(NSMutableArray*) queryDataOrderByLevel: (NSManagedObjectContext*) context
{
    NSMutableArray *wordsMutable = [[NSMutableArray alloc] init]; // sections
    
    NSArray *availableLevels = [VBHelper getAvailableLevelsForWordSet:self.wordSet];
    NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];

    for(NSNumber *level in availableLevels) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
        
        if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
            if(self.wordSet) {
                request.predicate = [NSPredicate predicateWithFormat:@"wordSet = %@ AND name contains %@ AND level = %d", self.wordSet, self.searchBar.text, [level intValue]];
            } else {
                request.predicate = [NSPredicate predicateWithFormat:@"name contains %@ AND level = %d", self.searchBar.text, [level intValue]];
            }
        } else {
            if(self.wordSet) {
                request.predicate = [NSPredicate predicateWithFormat:@"wordSet = %@ AND level = %d", self.wordSet, [level intValue]];
            } else {
                request.predicate = [NSPredicate predicateWithFormat:@"level = %d", [level intValue]];
            }
        }
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSArray *results = [context executeFetchRequest:request error:NULL];
        if(!results) {
            NSLog(@"Error getting words for set %@", self.wordSet);
            return nil;
        }
        
        if(results && [results count] > 0) {
            [wordsMutable addObject:[results mutableCopy]];
            // set sectiontitles
            if([level intValue] == 0) {
                [sectionTitles addObject:@"New words"];
            } else {
                [sectionTitles addObject:[NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"LevelText", @"Level"), [level intValue]]];
            }
        }
    }
    
    self.sectionTitles = sectionTitles;

    return wordsMutable;
}

-(NSMutableArray *) queryDataOrderByMonth: (NSManagedObjectContext*) context
{
    NSMutableArray *wordsMutable = [[NSMutableArray alloc] init]; // sections
    
    NSArray *availableMonths = [VBHelper getAvailableMonthsForWordSet:self.wordSet];
    NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];
    
    for(NSDateComponents *dateComponents in availableMonths) {
        [dateComponents setDay:1];
        NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        
        NSDateComponents *oneMonth = [[NSDateComponents alloc] init];
        [oneMonth setMonth:1];
        NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneMonth toDate:startDate options:0];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
        
        if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
            if(self.wordSet) {
                request.predicate = [NSPredicate predicateWithFormat:@"wordSet = %@ AND name contains %@ AND creationDate >= %@ AND creationDate < %@", self.wordSet, self.searchBar.text, startDate, endDate];
            } else {
                request.predicate = [NSPredicate predicateWithFormat:@"name contains %@ AND creationDate >= %@ AND creationDate < %@", self.searchBar.text, startDate, endDate];
            }
        } else {
            if(self.wordSet) {
                request.predicate = [NSPredicate predicateWithFormat:@"wordSet = %@ AND creationDate >= %@ AND creationDate < %@", self.wordSet, startDate, endDate];
            } else {
                request.predicate = [NSPredicate predicateWithFormat:@"creationDate >= %@ AND creationDate < %@", startDate, endDate];
            }
        }
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        NSArray *results = [context executeFetchRequest:request error:NULL];
        if(!results) {
            NSLog(@"Error getting words for set %@", self.wordSet);
            return nil;
        }
        
        if(results && [results count] > 0) {
            [wordsMutable addObject:[results mutableCopy]];
            // set sectiontitles
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM yyyy"];
            [sectionTitles addObject:[dateFormatter stringFromDate:startDate]];
        }
    }
    
    self.sectionTitles = sectionTitles;
    
    return wordsMutable;
}

/*
-(NSMutableArray *) queryDataOrderByFirstLetter: (NSManagedObjectContext*) context
{
    NSMutableArray *wordsMutable = [[NSMutableArray alloc] init]; // sections
    
    NSArray *availableLetters = [VBHelper getAvailableLettersForWordSet:self.wordSet];
    NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];
    
    for(NSString *letter in availableLetters) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
        
        if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
            if(self.wordSet) {
                request.predicate = [NSPredicate predicateWithFormat:@"wordSet = %@ AND name contains %@ AND name BEGINSWITH[c] %@", self.wordSet, self.searchBar.text, letter];
            } else {
                request.predicate = [NSPredicate predicateWithFormat:@"name contains %@ AND name BEGINSWITH[c] %@", self.searchBar.text, letter];
            }
        } else {
            if(self.wordSet) {
                request.predicate = [NSPredicate predicateWithFormat:@"wordSet = %@ AND name BEGINSWITH[c] %@", self.wordSet, letter];
            } else {
                request.predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[c] %@", letter];
            }
        }
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        
        NSArray *results = [context executeFetchRequest:request error:NULL];
        if(!results) {
            NSLog(@"Error getting words for set %@", self.wordSet);
            return nil;
        }
        
        if(results && [results count] > 0) {
            [wordsMutable addObject:[results mutableCopy]];
            [sectionTitles addObject: letter];
        }
    }
    
    self.sectionTitles = sectionTitles;
    
    return wordsMutable;
}
 */

-(NSMutableArray *) queryDataOrderByFirstLetter: (NSManagedObjectContext*) context
{
    NSMutableArray *wordsMutable = [[NSMutableArray alloc] init]; // sections
    
    NSArray *availableLetters = [VBHelper getAvailableLettersForWordSet:self.wordSet];
    NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];
    
    // get all words first
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    
    if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
        if(self.wordSet) {
            request.predicate = [NSPredicate predicateWithFormat:@"wordSet = %@ AND name contains %@", self.wordSet, self.searchBar.text];
        } else {
            request.predicate = [NSPredicate predicateWithFormat:@"name contains %@", self.searchBar.text];
        }
    } else {
        if(self.wordSet) {
            request.predicate = [NSPredicate predicateWithFormat:@"wordSet = %@", self.wordSet];
        }
    }
    
    NSArray *results = [context executeFetchRequest:request error:NULL];
    if(!results) {
        NSLog(@"Error getting words for set %@", self.wordSet);
        return nil;
    }
    
    if(results && [results count] > 0) {
        NSMutableArray *remainingWords = [results mutableCopy];
        
        for(NSString *letter in availableLetters) {
            NSMutableArray *wordsStartingWithLetter = [[NSMutableArray alloc] init];
            NSMutableArray *wordsToRemove = [[NSMutableArray alloc] init];
            
            for (Word *word in remainingWords) {
                if([word startsWithLetter: [letter characterAtIndex:0]]) {
                    [wordsStartingWithLetter addObject: word];
                    [wordsToRemove addObject: word];
                }
            }
            
            for (Word *word in wordsToRemove) {
                [remainingWords removeObject: word];
            }
            
            wordsStartingWithLetter = [[wordsStartingWithLetter sortedArrayUsingComparator:^NSComparisonResult(Word *obj1, Word *obj2) {
                return  [[obj1 articleFreeName] compare:[obj2 articleFreeName]];
            }] mutableCopy];
            
            [wordsMutable addObject: wordsStartingWithLetter];
            [sectionTitles addObject: letter];
        }
        
        assert([remainingWords count] == 0);
    }
    
    self.sectionTitles = sectionTitles;
    
    return wordsMutable;
}

-(void) queryData
{
        VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
        UIManagedDocument *document = appDelegate.managedDocument;
        
        if(self.segmentControl.selectedSegmentIndex == 1) { // oder by first letter
            self.words = [self queryDataOrderByFirstLetter: document.managedObjectContext];
        } else if(self.segmentControl.selectedSegmentIndex == 2) { // oder by month
            self.words = [self queryDataOrderByMonth: document.managedObjectContext];
        } else if(self.segmentControl.selectedSegmentIndex == 0) { // oder by level
            self.words = [self queryDataOrderByLevel: document.managedObjectContext];
        }
        
        [self.tableView reloadData];
}

-(void) segmentControlChanged
{
    [self queryData];
}

-(void) viewWillAppear:(BOOL)animated
{    
    [self.navigationController.toolbar addSubview:self.segmentControl];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self queryData];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.segmentControl removeFromSuperview];
}

-(void) viewWillLayoutSubviews
{
    UIToolbar *toolbar = self.navigationController.toolbar;
    CGFloat x = toolbar.frame.size.width / 2.0 - self.segmentControl.frame.size.width / 2.0;
    CGFloat y = toolbar.frame.size.height / 2.0 - self.segmentControl.frame.size.height / 2.0;
    self.segmentControl.frame = CGRectMake(x, y, self.segmentControl.frame.size.width, self.segmentControl.frame.size.height);
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [self queryData];
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self queryData];
}

#pragma mark - Table view data source

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.sectionTitles) {
        return self.sectionTitles[section];
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.words count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.words[section] count];
}

#define ROW_HEIGHT 44.0

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentControl.selectedSegmentIndex == 0) {
        return ROW_HEIGHT * 2;
    } else {
        return ROW_HEIGHT;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(self.segmentControl.selectedSegmentIndex == 0) {
        Word* word = (Word*)self.words[indexPath.section][indexPath.row];
        
        static NSString *CellIdentifier = @"StatisticsCell";
        WordsStatistcsCell *statisticsCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        statisticsCell.wordLabel.text = word.name;
        statisticsCell.wrongLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)[word.numWrong unsignedIntegerValue], NSLocalizedString(@"WrongText", @"wrong")];
        statisticsCell.rightLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)[word.numRight unsignedIntegerValue], NSLocalizedString(@"RightText", @"right")];
        if ([word isDue]) {
            statisticsCell.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.07];
        } else {
            statisticsCell.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.07];
        }
        
        cell = (UITableViewCell*) statisticsCell;
    } else {
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Word* word = (Word*)self.words[indexPath.section][indexPath.row];
        
        cell.textLabel.text = word.name;
        
        if(self.segmentControl.selectedSegmentIndex == 1) {
            cell.detailTextLabel.text = word.translations;
        } else if(self.segmentControl.selectedSegmentIndex == 2) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd MMM yyyy"];
            cell.detailTextLabel.text = [dateFormatter stringFromDate:word.creationDate];
        } else {
            cell.detailTextLabel.text = @"";
        }
    }
    
    return cell;
}

-(NSArray*) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    /*if(self.segmentControl.selectedSegmentIndex == 0) {
        return self.sectionTitles;
    }*/
    return nil;
}

-(NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // make root VC segue on iPad (because browser is a popover)
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        VBMenuCVC *menuCVC = [VBHelper getMenuCVC];
        VBWordInspectorVC *wordVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VBWordInspectorVC"];
        Word *word = self.words[indexPath.section][indexPath.row];
        wordVC.title = word.name;
        wordVC.word = word;
        wordVC.wordSet = word.wordSet;
        [menuCVC.currentPopoverController dismissPopoverAnimated:YES];
        [menuCVC.navigationController pushViewController: wordVC animated: YES];
    } else {
        [self performSegueWithIdentifier:@"addWords" sender:self];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VBWordInspectorVC *vc = (VBWordInspectorVC*) segue.destinationViewController;
    UITableViewCell *cell = (UITableViewCell*) sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    Word *word = self.words[indexPath.section][indexPath.row];
    
    vc.title = word.name;
    vc.word = word;
    vc.wordSet = word.wordSet;
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (IBAction)editCells:(id)sender {
    if(self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        self.barButton.title = NSLocalizedString(@"EditOptionText", @"Edit");
    } else {
        [self.tableView setEditing:YES animated:YES];
        self.barButton.title = NSLocalizedString(@"DoneOptionText", @"Done");
    }
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSUInteger section = indexPath.section;
        Word *toDelete = self.words[section][indexPath.row];
        [self.words[section] removeObjectAtIndex:indexPath.row];
        [document.managedObjectContext deleteObject:toDelete];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if ([self.words[section] count] == 0) {
            [self.words removeObjectAtIndex:section];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

@end
