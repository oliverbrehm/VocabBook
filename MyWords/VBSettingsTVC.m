//
//  VBSettingsTVC.m
//  Vocab Book
//
//  Created by Oliver Brehm on 15/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBSettingsTVC.h"
#import "VBAppDelegate.h"
#import "Word.h"
#import "WordSet+DocumentOperations.h"
#import "VBPremiumTVC.h"
#import "VBDocumentManager.h"
#import "VBLookupURLHelper.h"
#import "VBImportExport.h"
#import "VBHelper.h"

#import <StoreKit/StoreKit.h>

@interface VBSettingsTVC () <UIActionSheetDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *premiumCell;
@property (weak, nonatomic) IBOutlet UISwitch *iCloudSwitch;

@property (strong, nonatomic) UIActionSheet *iCloudActionSheet;

@end

@implementation VBSettingsTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:PREMIUM_IDENTIFIER]) {
        NSString *usingPremiumText = NSLocalizedString(@"UsingPremiumText", @"Using premium");
        self.premiumCell.textLabel.text = usingPremiumText;
        self.premiumCell.textLabel.textColor = [UIColor greenColor];
        self.premiumCell.userInteractionEnabled = NO;
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"usingiCloud"]) {
        self.iCloudSwitch.on = YES;
    } else {
        self.iCloudSwitch.on = NO;
    }
    
    [self.tableView reloadData];
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

- (void) resetDatabase {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ResetDatabaseWarning", @"Really reseat database? ALL vocabulary data will be erased by this!") delegate:self cancelButtonTitle:NSLocalizedString(@"CancelOptionText", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"ResetDatabaseOption", @"Reset database") otherButtonTitles: nil];
    
    [actionSheet showInView:self.view];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet == self.iCloudActionSheet) {
        if(buttonIndex == 0) { // Cancel
            self.iCloudSwitch.on = !self.iCloudSwitch.on;
        } else { // change iCloud usage
            VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            VBDocumentManager *documentManager = appDelegate.documentManager;
            
            if(self.iCloudSwitch.on) { // start using iCloud
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"usingiCloud"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if(buttonIndex == 1) { // merge? -> Yes
                    [documentManager migrateToiCloud];
                } else if(buttonIndex == 2) {// merge? -> NO
                    [documentManager openiCloudDocument];
                }
                // merge url settings
                [VBLookupURLHelper mergeToiCloud];
            } else { // stop using iCloud
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"usingiCloud"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if(buttonIndex == 1) { // merge? -> Yes
                    [documentManager migrateToLocalStorage];
                } else if(buttonIndex == 2) {// merge? -> NO
                    [documentManager openLocalDocument];
                }
                [VBLookupURLHelper mergeFromiCloud];
            }
        }
    } else {
        if (buttonIndex == 0) {
            [self databaseReset];
        }
    }
}

-(void) databaseReset
{
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    // delete all words
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    NSArray *results = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!results) {
        NSLog(@"Error getting words for resetting database");
        return;
    }
    
    for(Word *word in results) {
        [document.managedObjectContext deleteObject:word];
    }
    
    // delete all sets
    request = [NSFetchRequest fetchRequestWithEntityName:@"WordSet"];
    results = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!results) {
        NSLog(@"Error getting word sets for resetting database");
        return;
    }
    
    for(WordSet *set in results) {
        [document.managedObjectContext deleteObject:set];
    }
    
    [self.navigationController popViewControllerAnimated:YES];

}

-(NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return ([[NSUserDefaults standardUserDefaults] boolForKey:PREMIUM_IDENTIFIER]) ? @"" : @"Buy premium and unlock all features forever!";
        case 1:
            return NSLocalizedString(@"UseiCloudInfoText", @"Use iCloud to share your words across your iPhone, iPod touch or iPad");
        case 2:
            return NSLocalizedString(@"FileSharingInfoText", @"In iTunes, select your iOS device, choose Apps and add a file called \"import.txt\".\nEach line in this file shoud have the following format: \"word name; set name; translation1; translation2; ...\". If you click on \"Import from file\", Vocab Book will import all these words into your database. Click on \"Export to file\" to create a similar file called \"export.txt\" which can be downloaded via iTunes filesharing.");
        case 4:
            return NSLocalizedString(@"ResetDatabaseInfoText", @"Use this option only if you want to delete your whole words database from all your devices. It will remove all data  so you can start a fresh vocab book. If you are using iCloud, your local storage will not be erased. Also if you are using local storage, your iCloud data stays.");
        default:
            return @"";
    }
}
- (IBAction)iCloudSwitchChanged:(UISwitch*)sender {
    if (sender.on && ![[NSUserDefaults standardUserDefaults] boolForKey:PREMIUM_IDENTIFIER]) {
        // feature not available without premium
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NotAvailableTitles", @"Not available") message:NSLocalizedString(@"iCloudNotAvailablePlainText", @"iCloud is only available in Vocab Book PREMIUM") delegate:self cancelButtonTitle: NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles: nil];
        [alertView show];
        sender.on = NO;
        return;
    }
    
    NSString *msg;
    if(!sender.on) { // to local
        msg = NSLocalizedString(@"MergeDatabaseToLocalText", @"Do you want to mere iCloud data to your local device Store? If you select yes, all iCloud words that don't exist on the device will be copied to local storage. In any case iCloud data will be the same if you turn it back on.");
    } else { // to iCloud
        // check availability
        VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        if(![appDelegate iCloudAvailable]) {
            NSString *iCloudNotAvailableTitle = NSLocalizedString(@"iCloudNotAvailableTitle", @"iCloud not available");
            NSString *iCloudNotAvailableMessage = NSLocalizedString(@"iCloudNotAvailableMessage", @"iCloud is currently not available. Turn on iCloud in Settings->iCloud.");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:iCloudNotAvailableTitle message:iCloudNotAvailableMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles: nil];
            [alertView show];
            sender.on = NO;
            return;
        }

        msg = NSLocalizedString(@"MergeDatabaseToiCloudText", @"Do you want to merge your local data to iCloud? If you select yes, all words on your device that don't exist in iCloud will be copied to iCloud. In any case your local data will be the same if you turn iCloud off again.");
    }
    self.iCloudActionSheet = [[UIActionSheet alloc] initWithTitle:msg delegate:self cancelButtonTitle:nil destructiveButtonTitle: NSLocalizedString(@"CancelOptionText", @"Cancel") otherButtonTitles: NSLocalizedString(@"YesOptionText", @"Yes"), NSLocalizedString(@"NoOptionText", @"No"), nil];
    [self.iCloudActionSheet showInView:self.view];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self performSegueWithIdentifier:@"showPremium" sender:self];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"showPremium" sender:self];
        }
    } else if(indexPath.section == 2) {
        if(indexPath.row == 1) {
            [VBImportExport exportDatabase];
        }
    } else if(indexPath.section == 4) {
        if (indexPath.row == 0) {
            [self resetDatabase];
        }
    }
    
    else if (indexPath.section == 5) {
        if(indexPath.row == 0) {
            [self stressTest];
        } else if(indexPath.row == 1) {
            [self createAllLanguages];
        }
    }
}

#define STRESSTEST_SETS 1000
#define STRESSTEST_WORDS 10

-(void)stressTest
{
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    for (unsigned int i = 0; i < STRESSTEST_SETS; i++) {
        NSString *newSetName = [NSString stringWithFormat:@"testSet%u", i];
        BOOL favourite = (i % 10 == 0);
        WordSet *newSet = [WordSet createWithName:newSetName andLanguage:newSetName andDescription:@"---TEST---" andFavourite: favourite];
        
        for (unsigned int j = 0; j < STRESSTEST_WORDS; j++) {
            Word *word = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:document.managedObjectContext];
            word.name = [NSString stringWithFormat:@"word%u-set%u", j, i];
            word.translations = @"aaaaa\nbbbbb\nccccc\nddddd";
            word.creationDate = [NSDate date];
            word.lastQuizzedDate = [NSDate date];
            word.wordSet = newSet;
            word.level = [NSNumber numberWithInt:0];
            word.numRight = [NSNumber numberWithInt:0];
            word.numWrong = [NSNumber numberWithInt:0];

        }
    }
    
    NSLog(@"Added %u words in %u sets", STRESSTEST_SETS * STRESSTEST_WORDS, STRESSTEST_SETS);
}

-(void) createAllLanguages
{
    [self databaseReset];
    
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    for(NSString *language in appDelegate.languages) {
        [WordSet createWithName:@"" andLanguage:language andDescription:@"" andFavourite:YES];
    }
}

@end
