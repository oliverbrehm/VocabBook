//
//  WordSetsCVC.m
//  MyWords
//
//  Created by Oliver Brehm on 22/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBMenuCVC.h"
#import "VBAppDelegate.h"
#import "Word.h"
#import "WordSet+DocumentOperations.h"
#import "VBMenuWordSetCell.h"
#import "VBWordBrowserTVC.h"
#import "VBSetMenuTVC.h"
#import "VBMenuHeaderView.h"
#import "VBMenuNavigationCell.h"
#import "VBCreateSetTVC.h"
#import "VBMenuVocabCell.h"
#import "VBWordInspectorVC.h"
#import "VBMenuEmptyCell.h"
#import "VBMenuFooterView.h"
#import "VBHelper.h"
#import "VBHelpPageVC.h"

#import "VBDocumentManager.h"

#define EMPTYCELL_HEIGHT 96.0

@interface VBMenuCVC () <UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) NSArray *wordSets;
@property (strong, nonatomic) NSArray *recentWords;
@property (strong, nonatomic) NSArray *numDueWords;

@property (strong, nonatomic) UILabel *footerTextLabel;
@property (strong, nonatomic) UIButton *resetFilterButton;

@property (strong, nonatomic) WordSet *selectedWordSet;

@property (nonatomic) NSInteger selectedWordSetIndex;

@property (nonatomic) NSInteger currentPopoverSetIndex;
@property (nonatomic) NSString *popoverAnchorName;
@end

@implementation VBMenuCVC

#pragma mark Initialize

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedWordSetIndex = -1;
    
    // add long press gesture recognizer
    UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    gr.minimumPressDuration = 0.5;
    gr.delegate = self;
    gr.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:gr];
}

-(void) viewWillAppear:(BOOL)animated
{
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector (iCloudDidImportDatabaseChanges:)
     name: @"DocumentManagerImportediCloudChangesNotification"
     object: appDelegate.documentManager];
    
    [self queryData];
}

-(void) viewDidAppear:(BOOL)animated
{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"displayedStartHelp"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"displayedStartHelp"];
        [self performSegueWithIdentifier:@"startupHelp" sender:self];
        return;
    }
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"displayedNewSetAtFirstLaunch"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"displayedNewSetAtFirstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"usingiCloud"]) {
            [self performSegueWithIdentifier:@"newSet" sender:self];
            return;
        }
    }
    
    [self promtForAppRating];
    
    [self restorePopover];
}

-(void) restorePopover
{
    if(self.currentPopoverController) {
        UIView *popoverAnchor = nil;
        if(self.currentPopoverSetIndex >= 0) {
            popoverAnchor = [self.collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForItem: self.currentPopoverSetIndex inSection:0]];
        } else {
            NSInteger popoverIndex = 0;
            for(WordSet *wordSet in self.wordSets) {
                if ([wordSet.name isEqualToString: self.popoverAnchorName]) {
                    popoverIndex = [self.wordSets indexOfObject: wordSet];
                }
            }
            popoverAnchor = [self.collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForItem: popoverIndex inSection: 1]];
        }
        
        [self.currentPopoverController presentPopoverFromRect: popoverAnchor.bounds inView: popoverAnchor permittedArrowDirections:UIPopoverArrowDirectionAny animated: NO];
    }
}

-(void) dismissPopover
{
    [self.currentPopoverController dismissPopoverAnimated:YES];
    [self queryData];
    self.currentPopoverController = nil;
}

-(void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.currentPopoverController = nil;
    [self queryData];
}

#define NEXT_DATE_FOR_APP_RATING_PROMT_KEY @"nextDateForAppRatingPromt"

-(void) promtForAppRating
{
    NSDate *nextDateForAppRatingPromt = [[NSUserDefaults standardUserDefaults] objectForKey: NEXT_DATE_FOR_APP_RATING_PROMT_KEY];
    if(!nextDateForAppRatingPromt) {
        NSTimeInterval oneWeek = 60 * 60 * 24 * 7; // seconds for one week
        nextDateForAppRatingPromt = [NSDate dateWithTimeIntervalSinceNow: oneWeek];
        [[NSUserDefaults standardUserDefaults] setObject:nextDateForAppRatingPromt forKey:NEXT_DATE_FOR_APP_RATING_PROMT_KEY];
        return;
    }
    
    if([nextDateForAppRatingPromt compare:[NSDate date]] < 0) {
        // promt for app rating
        NSString *rateAppTitle = NSLocalizedString(@"Rate Vocab Book", @"Rate app promt title");
        NSString *rateAppMessage = NSLocalizedString(@"Would you like to rate Vocab Book on the app store? Ratings are very important for other customers who would like to purchase the app and as feedback for developers.", @"Rate app promt message");
        NSString *rateAppOptionNow = NSLocalizedString(@"Rate now", @"Rate app option now");
        NSString *rateAppOptionLater = NSLocalizedString(@"Remind me later", @"Rate app option later");
        NSString *rateAppOptionNever = NSLocalizedString(@"Don't ask again", @"Rate app option don't ask again");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: rateAppTitle message: rateAppMessage delegate:self cancelButtonTitle: rateAppOptionNow otherButtonTitles: rateAppOptionLater, rateAppOptionNever, nil];
        [alertView show];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) { // "Rate now"
        NSTimeInterval sixWeeks = 60 * 60 * 24 * 7 * 6; // seconds for six weeks
        NSDate *nextDateForAppRatingPromt = [NSDate dateWithTimeIntervalSinceNow: sixWeeks];
        [[NSUserDefaults standardUserDefaults] setObject: nextDateForAppRatingPromt forKey:NEXT_DATE_FOR_APP_RATING_PROMT_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [VBHelper linkToRateApp];
    } else if(buttonIndex == 1) { // "Remind me later"
        NSTimeInterval fourDays = 60 * 60 * 24 * 4; // seconds for one week
        NSDate *nextDateForAppRatingPromt = [NSDate dateWithTimeIntervalSinceNow: fourDays];
        [[NSUserDefaults standardUserDefaults] setObject:nextDateForAppRatingPromt forKey:NEXT_DATE_FOR_APP_RATING_PROMT_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if(buttonIndex == 2) { // "Don't ask again"
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate distantFuture] forKey:NEXT_DATE_FOR_APP_RATING_PROMT_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
 
#pragma mark User actions

-(void) handleLongPress: (UILongPressGestureRecognizer*) gr
{
    if (gr.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint position = [gr locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:position];
    if (!indexPath){
        return;
    } else if(indexPath.section == 1) {
        self.selectedWordSet = self.wordSets[indexPath.row];
        self.selectedWordSetIndex = indexPath.item;

        self.footerTextLabel.hidden = YES;
        self.resetFilterButton.hidden = NO;
        
        [self queryData];
    }
}

-(void) resetFilter
{
    self.selectedWordSet = nil;
    self.selectedWordSetIndex = -1;
    
    self.footerTextLabel.hidden = NO;
    self.resetFilterButton.hidden = YES;
    
    [self queryData];
}

#pragma mark Data source

-(void) queryData
{
    NSLog(@"VBMenuCVC querying data...");
    
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    // get favourite sets
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WordSet"];
    request.predicate = [NSPredicate predicateWithFormat:@"isFavourite = YES"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastUsedDate" ascending:NO]];
    self.wordSets = [document.managedObjectContext executeFetchRequest:request error:NULL];
    
    // determine number of due words for set
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    for (WordSet *set in self.wordSets) {
        [tmp addObject:[NSNumber numberWithUnsignedInteger:[set numberOfDueWords]]];
    }
    self.numDueWords = [NSArray arrayWithArray:tmp];
    
    // get recent words
    request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    if(self.selectedWordSet) {
        request.predicate = [NSPredicate predicateWithFormat:@"wordSet = %@", self.selectedWordSet];
    }
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    request.fetchLimit = 30;
    self.recentWords = [document.managedObjectContext executeFetchRequest:request error:NULL];
    
    //[self refreshLayout];
    [self.collectionView reloadData];
    
    // determine number of due words for application icon badge number
    [UIApplication sharedApplication].applicationIconBadgeNumber = [VBHelper numberOfDueWords];
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(section == 0) { // navigation
        return 2;
    } else if(section == 1) { // word sets
        if(!self.wordSets || [self.wordSets count] == 0) {
            return 1;
        }
        return [self.wordSets count];
    } else if(section == 2) { // recent words
        if(!self.recentWords || [self.recentWords count] == 0) {
            return 1;
        }
        return [self.recentWords count];
    }
    
    return 0;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        return [self navigationCellForIndexPath:indexPath];
    } else if(indexPath.section == 1) {
        UICollectionViewCell *cell = [self wordSetCellForIndex:indexPath.row];
            return cell;
    }
    else if(indexPath.section == 2) {
        //return self.recentWordCells[indexPath.row];
        return [self vocabCellForIndexPath:indexPath];
    }
    
    return nil;
}

-(UICollectionViewCell*) navigationCellForIndexPath: (NSIndexPath*) indexPath
{
    VBMenuNavigationCell *cell = (VBMenuNavigationCell*) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"NavigationCell" forIndexPath:indexPath];
    if(indexPath.item == 0) {
        cell.navigationLabel.text = NSLocalizedString(@"AllWordsButtonTitle", @"All words");
        if([VBHelper emptyDatabase]) {
            cell.userInteractionEnabled = NO;
            cell.navigationLabel.textColor = [UIColor lightGrayColor];
        } else {
            cell.userInteractionEnabled = YES;
            cell.navigationLabel.textColor = [VBHelper globalButtonColor];
        }
    } else if(indexPath.item == 1) {
        cell.navigationLabel.text = NSLocalizedString(@"AllSetsButtonTitle", @"All sets");
        cell.userInteractionEnabled = YES;
        cell.navigationLabel.textColor = [VBHelper globalButtonColor];
    }
    
    return cell;
}

-(UICollectionViewCell*) wordSetCellForIndex: (NSUInteger) index
{
    if(!self.wordSets || [self.wordSets count] == 0) {
         VBMenuEmptyCell *cell = (VBMenuEmptyCell*) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"EmptyCell" forIndexPath:[NSIndexPath indexPathForItem:index inSection:1]];
         cell.descriptionTextView.hidden = NO;
         cell.descriptionTextView.text = NSLocalizedString(@"NoFavouriteSetsText", @"No favourite sets. Choose \"+\" in the upper left corner to create a new set. To make a set a favourite, choose a set, then choose \"Info\" and activate the \"In favourites\" switch.");
         return cell;
     } else {
         VBMenuWordSetCell *cell = (VBMenuWordSetCell*) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"FavouriteCell" forIndexPath: [NSIndexPath indexPathForItem:index inSection:1]];
    
         WordSet *set = self.wordSets[index];
         
         
         cell.textLabel.text = set.name;
         cell.infoLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)[set.words count],
                                ([set.words count] != 1) ? NSLocalizedString(@"wordsPlural", @"words") :
                                NSLocalizedString(@"wordsSingular", @"word")];
         
         
         cell.languageLabel.text = set.language;
         
         VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
         cell.imageView.image = [appDelegate imageForLanguage: set.language];
         
         cell.borderView.layer.borderColor = [UIColor blackColor].CGColor;
         cell.borderView.layer.borderWidth = 1.0;
         //cell.borderView.layer.cornerRadius = 15.0;
         //cell.imageView.layer.cornerRadius = 15.0;
         //cell.imageView.layer.masksToBounds = YES;
         
         
         
         if((self.selectedWordSetIndex == index)) {
             cell.layer.cornerRadius = 15.0;
             cell.layer.masksToBounds = YES;
             cell.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.15];
         } else {
             cell.backgroundColor = [UIColor whiteColor];
             //cell.layer.cornerRadius = 0.0;
         }
         
         
         NSUInteger numberOfDueWords = [self.numDueWords[index] unsignedIntegerValue];
         if(numberOfDueWords == 0) {
             cell.dueWordsLabel.hidden = YES;
         } else {
             cell.dueWordsLabel.hidden = NO;
             cell.dueWordsLabel.text = [NSString stringWithFormat:@"%lu  ", (unsigned long)numberOfDueWords];
             cell.dueWordsLabel.layer.cornerRadius = 10.0;
             cell.dueWordsLabel.layer.masksToBounds = YES;
         }
         
         //NSURL *documentsUrl = [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:[NSString stringWithFormat:@"set_%@", [set.language lowercaseString]]] URLByAppendingPathExtension:@"png"];
         //[self imageFromView:cell.borderView toPath: [documentsUrl path]];
         
         return cell;
     }
}

-(UICollectionViewCell*) vocabCellForIndexPath: (NSIndexPath*) indexPath
{
    if(!self.recentWords || [self.recentWords count] == 0) {
         VBMenuEmptyCell *cell = (VBMenuEmptyCell*) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"EmptyCell" forIndexPath:indexPath];
         cell.descriptionTextView.hidden = NO;
         cell.descriptionTextView.text = NSLocalizedString(@"NoRecentWordsText", @"No recent words. Select a set and choose \"Add words\"");
         return cell;
    }
    else {
         VBMenuVocabCell *cell = (VBMenuVocabCell*) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"RecentWordCell" forIndexPath:indexPath];
         Word *word = self.recentWords[indexPath.row];
         cell.wordLabel.text = word.name;
         cell.translationsTextView.text = word.translations;
         return cell;
     }
}


-(UICollectionReusableView*) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *supplementaryView = nil;
    
    if(kind == UICollectionElementKindSectionHeader) {
        VBMenuHeaderView *headerView = (VBMenuHeaderView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        if(indexPath.section == 0) {
            headerView.label.text = NSLocalizedString(@"NavigationLabel", @"Navigation");
        } else if(indexPath.section == 1) {
            headerView.label.text = NSLocalizedString(@"FavouritesLabel", @"Favourites");
        } else if(indexPath.section == 2) {
            if(self.selectedWordSet) {
                headerView.label.text = [NSString stringWithFormat: @"%@ (%@)", NSLocalizedString(@"RecentWordsLabel", @"Newest Words"), self.selectedWordSet.name];
            } else {
                headerView.label.text = NSLocalizedString(@"RecentWordsLabel", @"Newest Words");
            }
        }
        supplementaryView = headerView;
    } else if(kind == UICollectionElementKindSectionFooter) {
        VBMenuFooterView *footerView = (VBMenuFooterView*) [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        self.footerTextLabel = footerView.textLabel;
        self.resetFilterButton = footerView.resetFilterButton;
        footerView.menuCVC = self;
        supplementaryView = footerView;
    }
    
    return supplementaryView;
}

#pragma mark UICollectionViewDelegate

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL usingIPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    UIView *selectedItem = [collectionView cellForItemAtIndexPath:indexPath];
    
    if(indexPath.section == 0) {
        if (indexPath.item == 0) { // all words
            if(usingIPad) {
                self.currentPopoverSetIndex = indexPath.row;

                VBSetMenuTVC *setMenuTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VBSetMenuTVC"];
                UINavigationController *setMenuNVC = [[UINavigationController alloc] initWithRootViewController:setMenuTVC];
                
                self.currentPopoverController = [[UIPopoverController alloc] initWithContentViewController: setMenuNVC];
                self.currentPopoverController.delegate = self;
                [self.currentPopoverController presentPopoverFromRect:selectedItem.bounds inView:selectedItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                [self performSegueWithIdentifier:@"setMenu" sender:self];
            }
        } else if(indexPath.row == 1) { // all sets
            if(usingIPad) {
                VBSetMenuTVC *setBrowserTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VBSetBrowserTVC"];
                UINavigationController *setBroserNVC = [[UINavigationController alloc] initWithRootViewController:setBrowserTVC];

                self.currentPopoverController = [[UIPopoverController alloc] initWithContentViewController: setBroserNVC];
                self.currentPopoverController.delegate = self;
                [self.currentPopoverController presentPopoverFromRect:selectedItem.bounds inView:selectedItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                [self performSegueWithIdentifier:@"allSets" sender:self];
            }
        }
    } else if(indexPath.section == 1) {
        if(self.wordSets && [self.wordSets count] > 0) {
            if(usingIPad) {
                self.popoverAnchorName = [((WordSet*) self.wordSets[indexPath.row]).name copy];
                self.currentPopoverSetIndex = -1;
                
                VBSetMenuTVC *setMenuTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VBSetMenuTVC"];
                UINavigationController *setMenuNVC = [[UINavigationController alloc] initWithRootViewController:setMenuTVC];

                setMenuTVC.wordSet = self.wordSets[indexPath.row];
                setMenuTVC.title = setMenuTVC.wordSet.name;
                
                self.currentPopoverController = [[UIPopoverController alloc] initWithContentViewController: setMenuNVC];
                self.currentPopoverController.delegate = self;
                [self.currentPopoverController presentPopoverFromRect:selectedItem.bounds inView:selectedItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                [self performSegueWithIdentifier:@"setMenu" sender:[collectionView cellForItemAtIndexPath:indexPath]];
            }
        }
    } else if(indexPath.section == 2) {
        if(self.recentWords && [self.recentWords count] > 0) {
            [self performSegueWithIdentifier:@"wordInspector" sender:[collectionView cellForItemAtIndexPath:indexPath]];
        }
    }
    
}

-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
    
    if(indexPath.section == 0) {
        size = CGSizeMake(self.collectionView.frame.size.width / 2.0 - 20.0, 64.0);
    } else if(indexPath.section == 1) {
        if(!self.wordSets || [self.wordSets count] == 0) {
            size = CGSizeMake(self.view.frame.size.width - 50.0, EMPTYCELL_HEIGHT);
        } else {
            size = CGSizeMake(135.0, 100.0);
        }
    } else if(indexPath.section == 2) {
        if(!self.recentWords || [self.recentWords count] == 0) {
            size = CGSizeMake(self.view.frame.size.width - 50.0, EMPTYCELL_HEIGHT);
        } else {
            size = CGSizeMake(130.0, 128.0);
        }
    }
    
    return size;
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if(section == 0) {
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return UIEdgeInsetsMake(20, 20, 30, 20);
}

-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return CGSizeMake(collectionView.frame.size.width, 32.0);
    } else {
        return CGSizeMake(0.0, 0.0);
    }
}

#pragma mark ViewController methods

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue isKindOfClass: [UIStoryboardPopoverSegue class]]) {
        self.currentPopoverController = ((UIStoryboardPopoverSegue*) segue).popoverController;
        self.currentPopoverController.delegate = self;
    }
    
    if([segue.destinationViewController isKindOfClass:[VBSetMenuTVC class]]) {
        if([sender isKindOfClass:[VBMenuWordSetCell class]]) {
            VBSetMenuTVC *vc = (VBSetMenuTVC*) segue.destinationViewController;
            VBMenuWordSetCell *cell = (VBMenuWordSetCell*) sender;
            
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            
            vc.wordSet = self.wordSets[indexPath.row];
            vc.title = vc.wordSet.name;
        }
    } else if([segue.destinationViewController isKindOfClass:[VBWordInspectorVC class]]) {
        VBMenuVocabCell *cell = (VBMenuVocabCell*) sender;
        NSIndexPath *ip = [self.collectionView indexPathForCell:cell];
        VBWordInspectorVC *vc = (VBWordInspectorVC*) segue.destinationViewController;
        Word *word = self.recentWords[ip.row];
        vc.title = word.name;
        vc.word = word;
        vc.wordSet = word.wordSet;
    } else if ([segue.destinationViewController isKindOfClass:[VBHelpPageVC class]]) {
        VBHelpPageVC *vc = (VBHelpPageVC*) segue.destinationViewController;
        vc.pageName = @"Getting started";
    }
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    //[self refreshLayout];
}


#pragma mark iCloud

-(void) iCloudDidImportDatabaseChanges: (NSNotification*) notification
{
    NSLog(@"Updating main collection view for iCloud changes");
    
    // surrounding method is called by a notification, so not running on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self queryData];
    });
}

@end
