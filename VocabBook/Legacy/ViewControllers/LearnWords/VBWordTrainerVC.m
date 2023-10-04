//
//  WordsQuizVC.m
//  MyWords
//
//  Created by Oliver Brehm on 23/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBWordTrainerVC.h"
#import "WordSet+DocumentOperations.h"
#import "Word+DocumentOperations.h"
#import "VBAppDelegate.h"
#import "VBWordInspectorVC.h"
#import "VBHelper.h"

@interface VBWordTrainerVC () <UIAlertViewDelegate>

@property (strong, nonatomic) UIButton *showAnswerButton;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerTextView;
@property (weak, nonatomic) IBOutlet UIButton *wrongButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *wordInfoButton;

@property (strong,nonatomic) UIAlertView *continueLearningAlertView;

@end

@implementation VBWordTrainerVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.95 alpha:1.0];
    
    Word *newWord = [self getNewWord];
    
    self.currentWord = newWord;
    
    [self newWordUI];
    
    self.showAnswerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.showAnswerButton.backgroundColor = [UIColor darkGrayColor];
    [self.showAnswerButton setTitle:NSLocalizedString(@"ShowAnswerButtonText", @"Show answer") forState:UIControlStateNormal];
    self.showAnswerButton.titleLabel.font = [UIFont fontWithName:@"System" size:20];
    [self.view addSubview:self.showAnswerButton];
    
    [self updateUI];
    
    [self.showAnswerButton addTarget:self action:@selector(showAnswerButtonTouched) forControlEvents:UIControlEventTouchUpInside];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self updateUI];
    self.wordLabel.text = self.currentWord.name;
    self.answerTextView.text = self.currentWord.translations;
}


-(NSMutableArray*) wordQueue
{
    if(!_wordQueue) {
        if(self.wordSet) {
            _wordQueue = [self.wordSet getDueWords];
        } else {
            _wordQueue = [WordSet getDueWordsForAllWords];
        }
        if((self.wordSet && [self.wordSet numberOfDueWords] <= 0) || [VBHelper numberOfDueWords] <= 0) {
            NSString *noWordsDueMessageTitle = NSLocalizedString(@"NoWordsDueMessageTitle", @"No due words");
            NSString *noWordsDueMessage = NSLocalizedString(@"NoWordsDueMessage", @"There are currently no due words. You are now learning all the words of this set. Note that in this mode, right answers will not get the word to the next level.");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:noWordsDueMessageTitle message:noWordsDueMessage delegate:self cancelButtonTitle: NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles: nil];
            [alertView show];
        }
    }
    
    return _wordQueue;
}

-(void) newWordUI
{
    self.wordLabel.text = self.currentWord.name;
    self.answerTextView.text = self.currentWord.translations;
    self.showAnswerButton.hidden = NO;
    self.wrongButton.enabled = NO;
    [self.wrongButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.rightButton.enabled = NO;
    [self.rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.wordInfoButton.hidden = YES;
    
    // add language image
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UIImage *image = [appDelegate imageForLanguage: self.currentWord.wordSet.language];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0.0, 0.0, 30.0, 20.0);
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem = item;
    
    [self updateUI];
}

-(Word*) getNewWord
{
    if([self.wordQueue count] == 0) {
        NSString *finishedLearningMessage = NSLocalizedString(@"FinishedLearningMessage", @"You have learned all words neccessary for now. Do you still want to continue?");
        self.continueLearningAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"FinishedText", "Finished") message: finishedLearningMessage delegate:self cancelButtonTitle: NSLocalizedString(@"DoneOptionText", @"Done") otherButtonTitles: NSLocalizedString(@"KeepLearningOption", @"Keep learning"), nil];
        
        [self.continueLearningAlertView show];
        return nil;
    }
    
    return [self.wordQueue firstObject];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == self.continueLearningAlertView) {
        if(buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if(buttonIndex == 1) {
            self.wordQueue = nil;
            self.currentWord = [self getNewWord];
            [self newWordUI];
        }
    }
}


-(void) updateUI
{
    if(self.toUserlanguage) {
        CGFloat y = self.wordLabel.frame.origin.y + self.wordLabel.bounds.size.height + 35.0;
        CGFloat height = self.view.frame.size.height - y;
        self.showAnswerButton.frame = CGRectMake(0.0, y, self.view.bounds.size.width, height);
    } else {
        CGFloat y = self.navigationController.navigationBar.bounds.size.height;
        CGFloat height = self.wordLabel.frame.origin.y + self.wordLabel.bounds.size.height + 35.0 - self.navigationController.navigationBar.bounds.size.height;
        self.showAnswerButton.frame = CGRectMake(0.0, y, self.view.bounds.size.width, height);
    }
}

-(void) viewDidLayoutSubviews
{
    [self updateUI];
}

-(void)showAnswerButtonTouched {
    self.showAnswerButton.hidden = YES;
    self.wrongButton.enabled = YES;
    [self.wrongButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.rightButton.enabled = YES;
    [self.rightButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    self.wordInfoButton.hidden = NO;
}

- (IBAction)wrongButtonTouched:(id)sender {
    if ([self.currentWord isDue]) {
        // reset level to 0
        self.currentWord.level = [NSNumber numberWithInt: 0];
        self.currentWord.lastQuizzedDate = [NSDate date];
    }
    
    self.wordSet.lastUsedDate = [NSDate date];

    self.currentWord.numWrong = [NSNumber numberWithInteger:[self.currentWord.numWrong integerValue] + 1];
    [self.wordQueue removeObject:self.currentWord];

    self.currentWord = [self getNewWord];
    if (self.currentWord) {
        [self newWordUI];
    }
}

- (IBAction)rightButtonTouched:(id)sender {
    if([self.currentWord isDue]) {
        if([self.currentWord.level intValue] < 7) {
            self.currentWord.level = [NSNumber numberWithInt: [self.currentWord.level intValue] + 1];
        }
        self.currentWord.lastQuizzedDate = [NSDate date];
        // decrease app icon batch number
        NSInteger oldNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
        [UIApplication sharedApplication].applicationIconBadgeNumber = oldNumber - 1;
    }
    
    self.wordSet.lastUsedDate = [NSDate date];
    
    self.currentWord.numRight = [NSNumber numberWithInteger:[self.currentWord.numRight integerValue] + 1];
    [self.wordQueue removeObject:self.currentWord];

    self.currentWord = [self getNewWord];
    if (self.currentWord) {
        [self newWordUI];
    }
}

- (IBAction)doneButtonTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VBWordInspectorVC *vc = (VBWordInspectorVC*) segue.destinationViewController;
    vc.title = self.currentWord.name;
    vc.word = self.currentWord;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.view setNeedsDisplay];
}

@end
