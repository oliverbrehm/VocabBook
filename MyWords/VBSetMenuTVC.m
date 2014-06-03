//
//  WordsSetActionTVC.m
//  MyWords
//
//  Created by Oliver Brehm on 23/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBSetMenuTVC.h"
#import "VBWordBrowserTVC.h"
#import "VBWordInspectorVC.h"
#import "Word.h"
#import "WordSet+DocumentOperations.h"
#import "VBAppDelegate.h"
#import "VBWordTrainerVC.h"
#import "VBCreateSetTVC.h"
#import "VBHelper.h"
#import "VBPremiumTVC.h"
#import "VBWordQuizVC.h"

@interface VBSetMenuTVC () <UIActionSheetDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *addWordsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *learnCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *quizCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *browseCell;

@property (weak, nonatomic) IBOutlet UILabel *numWordsDueLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastTestInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastTestScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *testLabel;
@property (weak, nonatomic) IBOutlet UILabel *quizLabel;

@property (strong, nonatomic) UIActionSheet *resetStatisticsActionSheet;
@property (strong, nonatomic) UIActionSheet *removeSetActionSheet;
@property (strong, nonatomic) UIActionSheet *chooseLearnDirectionActionSheet;

@property (nonatomic) BOOL toUserLanguage;
@end

@implementation VBSetMenuTVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) resetHidden
{
    self.quizLabel.hidden = NO;
    self.numWordsDueLabel.hidden = NO;
    self.testLabel.hidden = NO;
    self.lastTestInfoLabel.hidden = NO;
    self.lastTestScoreLabel.hidden = NO;
}

-(void) viewWillAppear:(BOOL)animated
{
    [self resetHidden];
    
    // Number of due words text label
    NSUInteger numWordsDue;
    if(self.wordSet) {
        numWordsDue = [self.wordSet numberOfDueWords];
    } else {
        numWordsDue = [VBHelper numberOfDueWords];
    }
    
    if(numWordsDue > 0) {
        NSString *numWordsDueText = numWordsDue == 1 ? NSLocalizedString(@"OneWordDueText", @"word due") : NSLocalizedString(@"NumWordsDueText", @"words due");
        self.numWordsDueLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)numWordsDue, numWordsDueText];
        self.numWordsDueLabel.textColor = [UIColor redColor];
    } else {
        NSString *noDueWordsText = NSLocalizedString(@"NoDueWordsText", @"No due words, next quiz");
        
        NSDate *nextDueDate;
        
        if(self.wordSet) {
            nextDueDate = [self.wordSet nextDueDate];
        } else {
            nextDueDate = [WordSet nextDueDateForAllWords];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMM yyyy"];
        NSString *dateString = [dateFormatter stringFromDate:nextDueDate];
        self.numWordsDueLabel.text = [NSString stringWithFormat:@"%@: %@", noDueWordsText, dateString];
        self.numWordsDueLabel.textColor = [UIColor blackColor];
    }
    
    // Last test text label
    NSString *lastTestText = NSLocalizedString(@"LastTestText", @"Last test");
    NSString *scoreText = NSLocalizedString(@"ScoreText", @"Score");
    NSString *upToDateText = NSLocalizedString(@"UpToDateText", @"Up-to-date");
    if(self.wordSet.lastTestDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMM yyyy"];
        NSString *dateString = [dateFormatter stringFromDate:self.wordSet.lastUsedDate];
        NSString *scoreString = [NSString stringWithFormat:@"%lu %%", (unsigned long)[self.wordSet.lastTestScore unsignedIntegerValue]];
        
        CGFloat lastTestTotalWords = [self.wordSet.lastTestTotalWords integerValue];
        NSUInteger upToDatenessPercent = (NSUInteger)(lastTestTotalWords / (lastTestTotalWords + [self.wordSet.changesSinceLastTest integerValue]) * 100.0);
        NSString *upToDateString = [NSString stringWithFormat:@"%lu %%", (unsigned long) upToDatenessPercent];
        self.lastTestInfoLabel.text = [NSString stringWithFormat:@"%@: %@", lastTestText, dateString];
        self.lastTestInfoLabel.textColor = [UIColor blackColor];
        
        NSString *fullScoreString = [NSString stringWithFormat:@"%@: %@, ", scoreText, scoreString];
        NSString *fullUpToDateString = [NSString stringWithFormat:@"%@: %@", upToDateText, upToDateString];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", fullScoreString, fullUpToDateString]];
        [attString setAttributes:@{NSForegroundColorAttributeName: [self redGreenColorFromScore:[self.wordSet.lastTestScore integerValue]]} range: [[attString string] rangeOfString:fullScoreString]];
        [attString setAttributes:@{NSForegroundColorAttributeName: [self redGreenColorFromScore:upToDatenessPercent]} range: [[attString string] rangeOfString:fullUpToDateString]];
        self.lastTestScoreLabel.attributedText = attString;
    } else {
        NSString *testNotTakenText = NSLocalizedString(@"TestNotTakenText", @"not taken");
        self.lastTestInfoLabel.text = [NSString stringWithFormat:@"%@: %@", lastTestText, testNotTakenText];
        self.lastTestInfoLabel.textColor = [UIColor redColor];
        self.lastTestScoreLabel.text = @"---";
        self.lastTestScoreLabel.textColor = [UIColor redColor];
    }
    
    
    if (self.wordSet) {
        self.title = self.wordSet.name;
    } else {
        self.title = NSLocalizedString(@"AllWordsButtonTitle", @"All words");
    }
    
    [self.tableView reloadData];
}

-(UIColor*) redGreenColorFromScore: (NSUInteger) score
{
    CGFloat r = (100.0 - score) / 100.0;
    CGFloat g = score / 100.0;
    return [UIColor colorWithRed:r green:g blue:0.0 alpha:1.0];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 1) { // "Learn"
        self.chooseLearnDirectionActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose learn direction" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"cover set language" otherButtonTitles:@"cover my language", nil];
        [self.chooseLearnDirectionActionSheet showInView:self.tableView];
        
        // "normalize" button colors
        for(UIView *view in self.chooseLearnDirectionActionSheet.subviews) {
            if([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton*) view;
                [button setTitleColor:[VBHelper globalButtonColor] forState:UIControlStateNormal];
            }
        }
    } else if(indexPath.section == 0 && indexPath.row == 0) { // "Add words"
        NSUInteger numWords = [VBHelper countAllWords];
        if(![[NSUserDefaults standardUserDefaults] boolForKey:PREMIUM_IDENTIFIER] && numWords >= WORD_LIMIT) {
            NSString *msg = [NSString stringWithFormat: @"Without PREMIUM, you cannot create more than %ld words", (unsigned long) WORD_LIMIT];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not available" message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles: nil];
            [alertView show];
        } else {
            [self performSegueWithIdentifier:@"addWords" sender:self];
        }
    } else if(indexPath.section == 1) {
        if (indexPath.row == 1) {
            [self resetStatistics];
        } else if(indexPath.row == 2) {
            [self removeSet];
        }
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self performSegueWithIdentifier:@"showPremium" sender:self];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *hiddenCells = @[];
    if (!self.wordSet) {
        hiddenCells = [VBSetMenuTVC hiddenCellsForAllWords];
    } else if([self.wordSet.words count] == 0) {
        hiddenCells = [VBSetMenuTVC hiddenCellsForEmptySet];
    }
    
    NSInteger row = (indexPath.section) * 4 + indexPath.row;
    
    if([hiddenCells containsObject:[NSNumber numberWithInteger:row]]) {
        if(indexPath.section == 0 && indexPath.row == 0) { // add words
            self.addWordsCell.textLabel.hidden = YES;
        } else if(indexPath.section == 0 && indexPath.row == 1) { // quiz
            self.quizLabel.hidden = YES;
            self.numWordsDueLabel.hidden = YES;
        } else if(indexPath.section == 0 && indexPath.row == 2) { // test
            self.lastTestInfoLabel.hidden = YES;
            self.lastTestScoreLabel.hidden = YES;
            self.testLabel.hidden = YES;
        } else if(indexPath.section == 1 && indexPath.row == 1) { // reset statistics
            //self.resetStatisticsButton.hidden = YES;
        } else if(indexPath.section == 1 && indexPath.row == 2) { // remove set
            //self.removeSetButton.hidden = YES;
        }
        
        return 0;
    }
    return [super tableView: tableView heightForRowAtIndexPath:indexPath];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.wordSet) {
        return 2;
    } else {
        return 1;
    }
}


+(NSArray*) hiddenCellsForEmptySet
{
    return @[@1, @2, @3, @5];
}

+(NSArray*) hiddenCellsForAllWords
{
    return @[@0, @2, @4, @5, @6];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[VBWordBrowserTVC class]]) {
        VBWordBrowserTVC *vc = (VBWordBrowserTVC*) segue.destinationViewController;
        vc.title = self.title;
        vc.wordSet = self.wordSet;
    } else if([segue.destinationViewController isKindOfClass:[VBWordInspectorVC class]]) {
        VBWordInspectorVC *vc = (VBWordInspectorVC*) segue.destinationViewController;
        vc.wordSet = self.wordSet;
    } else if([segue.destinationViewController isKindOfClass:[VBWordTrainerVC class]]) {
        VBWordTrainerVC *vc = (VBWordTrainerVC*) segue.destinationViewController;
        vc.title = self.title;
        vc.wordSet = self.wordSet;
        
        // determine language direction
        if(self.toUserLanguage) {
            // setlang -> userlang
            vc.toUserlanguage = YES;
        } else {
            vc.toUserlanguage = NO;
        }
       
    } else if([segue.destinationViewController isKindOfClass:[VBWordQuizVC class]]) {
        VBWordQuizVC *vc = (VBWordQuizVC*) segue.destinationViewController;
        vc.title = self.title;
        vc.wordSet = self.wordSet;
    }else if([segue.destinationViewController isKindOfClass:[VBCreateSetTVC class]]) {
        VBCreateSetTVC *vc = (VBCreateSetTVC*) segue.destinationViewController;
        vc.title = self.wordSet.name;
        vc.wordSet = self.wordSet;
    } 
}

- (void)removeSet {
    if(self.wordSet) {
        self.removeSetActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"RemoveSetWarning", @"Really remove set? This set and ALL words it contains will be removed permanently!") delegate:self cancelButtonTitle:NSLocalizedString(@"CancelOptionText", @"Cancel") destructiveButtonTitle:@"Remove" otherButtonTitles:nil];
        [self.removeSetActionSheet showInView:self.tableView];
    }
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet == self.resetStatisticsActionSheet && buttonIndex == 0) {
        NSSet *toReset;
        
        if(self.wordSet) {
            toReset = self.wordSet.words;
        } else {
            VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
            UIManagedDocument *document = appDelegate.managedDocument;
            
            // get all words
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
            NSArray *results = [document.managedObjectContext executeFetchRequest:request error:NULL];
            if(!results) {
                NSLog(@"Error getting words for resetting statistics");
                return;
            }
            toReset = [NSSet setWithArray:results];
        }
        
        for(Word *word in toReset) {
            word.level = [NSNumber numberWithInt:0];
            word.lastQuizzedDate = word.wordSet.creationDate;
            if(!word.lastQuizzedDate) {
                word.lastQuizzedDate = [NSDate date];
            }
            word.numRight = [NSNumber numberWithDouble:0.0];
            word.numWrong = [NSNumber numberWithDouble:0.0];
        }
    } else if(actionSheet == self.removeSetActionSheet && buttonIndex == 0){
        VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
        UIManagedDocument *document = appDelegate.managedDocument;
        
        // remove all words in set
        for(Word *word in self.wordSet.words) {
            [document.managedObjectContext deleteObject:word];
        }
        // remove set itself
        [document.managedObjectContext deleteObject:self.wordSet];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else if(actionSheet == self.chooseLearnDirectionActionSheet) {
        if (buttonIndex == 0) { // cover
            self.toUserLanguage = NO;
        } else if(buttonIndex == 1) {
            self.toUserLanguage = YES;
        } else {
            return;
        }
        [self performSegueWithIdentifier:@"learn" sender:self];
    }
}
- (void) resetStatistics {
    self.resetStatisticsActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ResetStatisticsWarning", @"Really reset statistics? Your score and number of guesses will be reset!") delegate:self cancelButtonTitle:NSLocalizedString(@"CancelOptionText", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"ResetOptionText", @"Reset") otherButtonTitles:nil];
    [self.resetStatisticsActionSheet showInView:self.tableView];
}

@end
