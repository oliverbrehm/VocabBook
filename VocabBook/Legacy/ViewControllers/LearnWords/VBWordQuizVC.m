//
//  VBWordQuizVC.m
//  Vocab Book
//
//  Created by Oliver Brehm on 20/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBWordQuizVC.h"
#import "Word.h"
#import "WordSet+DocumentOperations.h"
#import "VBHelper.h"
#import "VBAppDelegate.h"

@interface VBWordQuizVC () <UITextFieldDelegate>

@property (nonatomic) BOOL mustGetNewWord;
@property (weak, nonatomic) IBOutlet UITextField *wordTextField;
@property (weak, nonatomic) IBOutlet UITextView *translationsTextView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lowerBarButton;
@property (weak, nonatomic) IBOutlet UIImageView *languageImageView;

@property (strong, nonatomic) UIAlertView *showResultAlertView;
@property (strong, nonatomic) UIAlertView *cancelTestAlertView;

@property (nonatomic) NSUInteger numWordsGuessed;
@property (nonatomic) NSUInteger numWordsRight;
@property (nonatomic) NSUInteger numWordsTotal;

@end

@implementation VBWordQuizVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.95 alpha:1.0];
    self.currentWord = [self getNewWord];
    [self newWordUI];
    self.mustGetNewWord = NO; self.currentWord = [self getNewWord];
    self.mustGetNewWord = NO;
}

-(NSMutableArray*) wordQueue
{
    if(!_wordQueue) {
        _wordQueue = [[VBHelper shuffledArray: [self.wordSet.words allObjects]] mutableCopy];
        self.numWordsTotal = [_wordQueue count];
        self.numWordsGuessed = 0;
        self.numWordsRight = 0;
    }
    
    return _wordQueue;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(Word*) getNewWord
{
    if([self.wordQueue count] == 0) {
        [self showResults];
        return nil;
    }
    
    return [self.wordQueue firstObject];
}

-(void) newWordUI
{
    self.translationsTextView.editable = YES;
    self.translationsTextView.text = self.currentWord.translations;
    self.wordTextField.textColor = [UIColor blackColor];
    self.wordTextField.text = @"";
    self.infoLabel.text = @"";
    self.wordTextField.userInteractionEnabled = YES;
    
    [self.wordTextField becomeFirstResponder];
    
    // get language image
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UIImage *languageImage = [appDelegate imageForLanguage:self.currentWord.wordSet.language];
    self.languageImageView.image = languageImage;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.wordTextField resignFirstResponder];
}

- (IBAction)checkAnswerButtonTouched:(id) sender {
    [self.wordTextField resignFirstResponder];
    
    if([self.wordTextField.text isEqualToString:@""]) {
        NSString *wordMissingMessageTitle = NSLocalizedString(@"wordMissingMessageTitle", @"Word missing");
        NSString *wordMissingMessage = NSLocalizedString(@"wordMissingMessage", @"Please enter a word");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:wordMissingMessageTitle message: wordMissingMessage delegate:nil cancelButtonTitle: NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles: nil];
        [alertView show];
        [self.wordTextField becomeFirstResponder];
        return;
    }

    if(self.mustGetNewWord) {
        self.currentWord = [self getNewWord];
        [self newWordUI];
        self.mustGetNewWord = NO;
        self.barButton.title = NSLocalizedString(@"CheckText", @"Check");
        self.lowerBarButton.title = NSLocalizedString(@"CheckText", @"Check");
    } else {
        // check answer
        if([self input: self.wordTextField.text isCorrectAnswerFor:self.currentWord.name]) {
            self.wordTextField.text = self.currentWord.name;
            [self.wordQueue removeObject:self.currentWord];
            
            self.wordTextField.textColor = [UIColor greenColor];
            self.infoLabel.text = NSLocalizedString(@"RightAnswerText", @"Right answer!");
            self.numWordsRight++;
        } else {
            [self.wordQueue removeObject:self.currentWord];
            
            self.wordTextField.textColor = [UIColor redColor];
            if (![self.wordTextField.text isEqualToString:@""]) {
                self.infoLabel.text = [NSString stringWithFormat:@"%@ %@)", NSLocalizedString(@"WrongAnswerText", @"Wrong (answer:"), self.currentWord.name ];
            }
        }
        
        self.wordTextField.userInteractionEnabled = NO;
        
        self.currentWord.lastQuizzedDate = [NSDate date];
        self.wordSet.lastUsedDate = [NSDate date];
        
        self.barButton.title = NSLocalizedString(@"NextText", @"Next");
        self.lowerBarButton.title = NSLocalizedString(@"NextText", @"Next");
        self.mustGetNewWord = YES;
        
        self.numWordsGuessed++;
    }
    
    [self.view setNeedsDisplay];
}

-(BOOL) input: (NSString*) input isCorrectAnswerFor: (NSString*) answer
{
    NSString *modInput = [self trimmedSpacesString:[input capitalizedString]];
    NSString *modAnswer = [self trimmedSpacesString:[answer capitalizedString]];
    return [modInput isEqualToString:modAnswer];
}

-(NSString *) trimmedSpacesString: (NSString*) string
{
    NSArray *components = [string componentsSeparatedByString:@" "];
    NSMutableString *ret = [[NSMutableString alloc] initWithString:@""];
    
    if([components count] == 1) {
        return [components lastObject];
    }
    
    for(NSString *component in components) {
        if([component length] > 3) { // leave out articles, prepositions etc.
            [ret appendFormat:@"%@", component];
        }
    }
    
    if ([ret isEqualToString:@""]) {
        // there where just short words -> return all words
        for(NSString *component in components) {
            if(![component isEqualToString:@""]) {
                [ret appendString:component];
            }
        }
    }
    
    return [NSString stringWithString:ret];
}

- (IBAction)doneButtonTouched:(id)sender {
    CGFloat completeness = (CGFloat) self.numWordsGuessed / self.numWordsTotal;

    if((self.numWordsGuessed >= 5 && completeness >= 0.5) || self.numWordsGuessed >= 20) {
        NSString *stopTextMessageTitle = NSLocalizedString(@"stopTextMessageTitle", @"Stop test");
        NSString *stopTextMessage = NSLocalizedString(@"stopTextMessage", @"Really stop test? Words remaining");
        NSString *msg = [NSString stringWithFormat:@"%@: %lu", stopTextMessage, (unsigned long) (self.numWordsTotal - self.numWordsGuessed)];
        self.cancelTestAlertView = [[UIAlertView alloc] initWithTitle:stopTextMessageTitle message:msg delegate:self cancelButtonTitle: NSLocalizedString(@"DoneOptionText", @"Done") otherButtonTitles: NSLocalizedString(@"ContinueOptionText", @"Continue"), nil];
    } else {
        NSUInteger numWordsRemaining;
        if(self.numWordsTotal <= 5) {
            numWordsRemaining = self.numWordsTotal - self.numWordsGuessed;
        } else if(self.numWordsTotal <= 10) {
            numWordsRemaining = 5 - self.numWordsGuessed;
        } else if(self.numWordsTotal >= 40){
            numWordsRemaining = 20 - self.numWordsGuessed;
        } else {
            numWordsRemaining = [self roundUp: self.numWordsTotal/2.0] - self.numWordsGuessed;
        }
        
        NSString *cancelTestMessageTitle = NSLocalizedString(@"cancelTestMessageTitle", @"Cancel test");
        NSString *cancelTestMessage = NSLocalizedString(@"cancelTestMessage", @"Really cancel test? You must answere more of the set's words so the test is valid. (remaining");
        NSString *msg = [NSString stringWithFormat:@"%@: %lu)", cancelTestMessage, (unsigned long)numWordsRemaining];
        self.cancelTestAlertView = [[UIAlertView alloc] initWithTitle:cancelTestMessageTitle message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"CancelOptionText", @"Cancel")otherButtonTitles: NSLocalizedString(@"ContinueOptionText", @"Continue"), nil];
    }
    
    [self.cancelTestAlertView show];
}

-(NSInteger) roundUp: (CGFloat) n
{
    if(n - (NSInteger) n < 0.0000001) {
        return (NSInteger) n;
    }
    NSInteger i = (NSInteger) n;
    return i + 1;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.view setNeedsDisplay];
}

#pragma mark UITextfieldDelegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self checkAnswerButtonTouched:nil];
    return YES;
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

-(void) showResults
{
    NSUInteger score = (NSUInteger) (((CGFloat) self.numWordsRight / self.numWordsGuessed) * 100);

    // save results
    self.wordSet.lastTestDate = [NSDate date];
    self.wordSet.lastTestScore = [NSNumber numberWithUnsignedInteger:score];
    self.wordSet.lastTestTotalWords = [NSNumber numberWithInteger:[self.wordSet.words count]];
    self.wordSet.changesSinceLastTest = [NSNumber numberWithInteger:0];
    
    NSString *resultsText = NSLocalizedString(@"resultsText", @"Result");
    NSString *finishedText = NSLocalizedString(@"FinishedText", @"Finished");
    NSString *testFinishedText = NSLocalizedString(@"testFinishedText", @"Test finished");
    
    NSString *msg = [NSString stringWithFormat:@"%@\n\n%@: %lu/%lu (%lu %%)", testFinishedText, resultsText, (unsigned long)self.numWordsRight, (unsigned long)self.numWordsGuessed, (unsigned long)score];
    self.showResultAlertView = [[UIAlertView alloc] initWithTitle:finishedText message: msg delegate:self cancelButtonTitle: NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles: nil];
    [self.showResultAlertView show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == self.showResultAlertView) {
        if(buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (alertView == self.cancelTestAlertView) {
        if (buttonIndex == 0) {
            CGFloat completeness = (CGFloat) self.numWordsGuessed / self.numWordsTotal;
            if(completeness > 0.5) {
                [self showResults];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

@end
