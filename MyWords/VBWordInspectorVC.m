//
//  WordsSecondViewController.m
//  MyWords
//
//  Created by Oliver Brehm on 22/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBWordInspectorVC.h"
#import "VBAppDelegate.h"
#import "Word.h"
#import "WordSet.h"
#import "VBWordLookupVC.h"
#import "VBChangeSetTVC.h"
#import "VBHelper.h"
#import "VBPremiumTVC.h"

@interface VBWordInspectorVC () <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) UITextField *wordTextField;
@property (strong, nonatomic) UITextView *translationsTextView;
@property (strong, nonatomic) UIButton *lookUpButton;
@property (strong, nonatomic) UIButton *setButton;
@property (strong, nonatomic) UILabel *levelNumberLabel;
@property (strong, nonatomic) UIButton *levelResetButton;
@property (strong, nonatomic) UIButton *removeWordButton;

@property (weak, nonatomic) IBOutlet UILabel *translationsLabel;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (weak, nonatomic) IBOutlet UILabel *setLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *languageImageView;
@property (weak, nonatomic) IBOutlet UILabel *removePlaceholderLabel;

@property (strong, nonatomic) UIActionSheet *resetLevelActionSheet;
@property (strong, nonatomic) UIActionSheet *removeWordActionSheet;

@property (strong, nonatomic) VBWordLookupVC *lookupVC;

@property (strong, nonatomic) UIAlertView *reallyCreateWordAlertView;

@end

@implementation VBWordInspectorVC

#pragma mark Getters and setters

-(VBWordLookupVC*) lookupVC
{
    if(!_lookupVC) {
        _lookupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VBWordLookupVC"];
    }
    return _lookupVC;
}

#pragma mark Create view

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.95 alpha:1.0];
    //self.view.backgroundColor = [UIColor redColor];
    [self.wordTextField becomeFirstResponder];
}

-(void) viewWillAppear:(BOOL)animated
{
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    if(self.wordSet) {
        //self.languageImageView.contentMode = UIViewContentModeScaleAspectFill;
        //self.languageImageView.clipsToBounds = YES;
        UIImage *image = [appDelegate imageForLanguage:self.wordSet.language];
        image = [self resizeImage:image imageSize:self.languageImageView.bounds.size];
        self.languageImageView.image = image;
    }
    
    if(self.word) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    // place views
    // text field for word
    if(!self.wordTextField) {
        self.wordTextField = [[UITextField alloc] initWithFrame:[self frameForWordTextField]];
        self.wordTextField.font = self.wordLabel.font;
        self.wordTextField.placeholder = NSLocalizedString(@"EnterWordText", @"Enter word");
        self.wordTextField.delegate = self;
        self.wordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.wordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        [self.view addSubview:self.wordTextField];
    }
    
    // text view for translations
    if(!self.translationsTextView) {
        self.translationsTextView = [[UITextView alloc] initWithFrame:[self frameForTranslationsTextView]];
        self.translationsTextView.font = self.translationsLabel.font;
        self.translationsTextView.delegate = self;
        self.translationsTextView.backgroundColor = [UIColor clearColor];
        self.translationsTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.translationsTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        [self.view addSubview:self.translationsTextView];
    }
    
    // button for lookUp
    if(!self.lookUpButton) {
        self.lookUpButton = [[UIButton alloc] initWithFrame:[self frameForLookUpButton]];
        [self.lookUpButton setTitle: NSLocalizedString(@"LookupText", @"Look up") forState:UIControlStateNormal];
        [self.lookUpButton setTitleColor:[VBHelper globalButtonColor] forState:UIControlStateNormal];
        [self.lookUpButton addTarget:self action:@selector(lookupButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        //self.lookUpButton.alignment?
        [self.view addSubview:self.lookUpButton];
    }
    
    if(self.word) {
        // button for set
        if(!self.setButton) {
            self.setButton = [[UIButton alloc] initWithFrame:[self frameForSetButton]];
            [self.setButton setTitle:self.word.wordSet.name forState:UIControlStateNormal];
            [self.setButton setTitleColor:[VBHelper globalButtonColor] forState:UIControlStateNormal];
            [self.setButton addTarget:self action:@selector(setButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.setButton];
        }
        
        // remove word button
        if(!self.removeWordButton) {
            self.removeWordButton = [[UIButton alloc] initWithFrame:CGRectZero];
            [self.removeWordButton setTitle: NSLocalizedString(@"RemoveOptionText", @"Remove") forState:UIControlStateNormal];
            [self.removeWordButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            self.removeWordButton.frame = [self frameForRemoveWordButton];
            [self.removeWordButton addTarget:self action:@selector(removeWordButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.removeWordButton];
        }
        
        // reset button for level
        if(!self.levelResetButton) {
            self.levelResetButton = [[UIButton alloc] initWithFrame: CGRectZero];
            [self.levelResetButton setTitle: NSLocalizedString(@"ResetOptionText", @"Reset") forState:UIControlStateNormal];
            [self.levelResetButton setTitleColor:[VBHelper globalButtonColor] forState:UIControlStateNormal];
            self.levelResetButton.frame = [self frameForLevelResetButton];
            [self.levelResetButton addTarget:self action:@selector(levelResetButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.levelResetButton];
        }
        
        // label for level
        if(!self.levelNumberLabel) {
            self.levelNumberLabel = [[UILabel alloc] initWithFrame:[self frameForLevelNumberLabel]];
            self.levelNumberLabel.text = [NSString stringWithFormat:@"%d", [self.word.level intValue]];
            [self.view addSubview:self.levelNumberLabel];
        }
        
        //self.setButton.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"SetText", @"Set"), self.word.wordSet.name];
        //self.levelNumberLabel.text = [NSString stringWithFormat:@"%@: %d %%", NSLocalizedString(@"ScoreText", @"Score"), [self.word.level intValue]];
        self.translationsTextView.text = self.word.translations;
        self.wordTextField.text = self.word.name;
    } else {
        [self.wordTextField becomeFirstResponder];
        self.setLabel.hidden = YES;
        self.levelLabel.hidden = YES;
    }
}


-(void) viewDidAppear:(BOOL)animated
{
    if(self.word) {
        [self.setButton setTitle:self.word.wordSet.name forState:UIControlStateNormal];
    }
}

-(CGRect) frameForWordTextField
{
    CGFloat xRight = self.translationsLabel.frame.origin.x + self.translationsLabel.frame.size.width + 8.0;
    CGFloat widthRight = self.view.frame.size.width -  xRight - 8.0;
    return CGRectMake(xRight, self.wordLabel.frame.origin.y, widthRight, self.wordLabel.frame.size.height);
}

-(CGRect) frameForTranslationsTextView
{
    CGFloat xRight = self.translationsLabel.frame.origin.x + self.translationsLabel.frame.size.width + 8.0;
    CGFloat widthRight = self.view.frame.size.width -  xRight - 8.0;
    CGFloat height = (self.setLabel.hidden ?  self.view.frame.size.height : self.setLabel.frame.origin.y)  - 8.0 - self.translationsLabel.frame.origin.y;
    return CGRectMake(xRight, self.translationsLabel.frame.origin.y, widthRight, height);
}

-(CGRect) frameForLookUpButton
{
    CGFloat xRight = self.translationsLabel.frame.origin.x + self.translationsLabel.frame.size.width + 8.0;
    CGFloat widthRight = self.view.frame.size.width -  xRight - 8.0;
    
    //CGFloat centerX = (xRight + self.view.frame.size.width - 8.0) / 2.0;
    //CGFloat x = centerX - self.lookUpButton.frame.size.width / 2.0;
    
    
    return CGRectMake(xRight, self.languageImageView.frame.origin.y, widthRight, self.translationsLabel.frame.size.height);
}

-(CGRect) frameForSetButton
{
    CGFloat xRight = self.translationsLabel.frame.origin.x + self.translationsLabel.frame.size.width + 8.0;
    CGFloat widthRight = self.view.frame.size.width -  xRight - 8.0;
    return CGRectMake(xRight, self.setLabel.frame.origin.y, widthRight, self.setLabel.frame.size.height);
}

-(CGRect) frameForRemoveWordButton
{
    [self.removeWordButton sizeToFit];
    CGFloat width = self.removeWordButton.bounds.size.width;
    CGFloat x = self.view.frame.size.width - 8.0 - width;
    self.removePlaceholderLabel.hidden = YES;
    return CGRectMake(x, self.removePlaceholderLabel.frame.origin.y, width, self.removePlaceholderLabel.frame.size.height);
}

-(CGRect) frameForLevelResetButton
{
    [self.levelResetButton sizeToFit];
    CGFloat width = self.levelResetButton.bounds.size.width;
    CGFloat x = self.view.frame.size.width - 8.0 - width;
    return CGRectMake(x, self.levelLabel.frame.origin.y, width, self.levelLabel.frame.size.height);
}

-(CGRect) frameForLevelNumberLabel
{
    CGFloat xRight = self.translationsLabel.frame.origin.x + self.translationsLabel.frame.size.width + 8.0;
    CGFloat widthRight = self.view.frame.size.width -  xRight - 8.0;
    CGFloat width = widthRight - self.levelResetButton.frame.size.width - 2 * 8.0;
    return CGRectMake(xRight, self.levelLabel.frame.origin.y, width, self.levelLabel.frame.size.height);
}

-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    //here is the scaled image which has been changed to the size specified
    UIGraphicsEndImageContext();
    return newImage;
    
}

#pragma mark View Controller Methods

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[VBChangeSetTVC class]]) {
        VBChangeSetTVC *vc = (VBChangeSetTVC*) segue.destinationViewController;
        vc.word = self.word;
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.translationsTextView resignFirstResponder];
    [self.wordTextField resignFirstResponder];
}

-(void) viewDidLayoutSubviews
{
    self.wordTextField.frame = [self frameForWordTextField];
    self.translationsTextView.frame = [self frameForTranslationsTextView];
    self.lookUpButton.frame = [self frameForLookUpButton];
    self.setButton.frame = [self frameForSetButton];
    self.removeWordButton.frame = [self frameForRemoveWordButton];
    self.levelResetButton.frame = [self frameForLevelResetButton];
    self.levelNumberLabel.frame = [self frameForLevelNumberLabel];
    
    [self.view setNeedsDisplay];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if([self.translationsTextView isFirstResponder]) {
        [self setViewBoundsForTranslationEditing];
    }
}

#pragma mark User actions

-(void) levelResetButtonTouched:(id)sender {
    NSString *resetWordMessageTitle = NSLocalizedString(@"resetWordMessageTitle", @"Really reset progress on this word?");
    self.resetLevelActionSheet = [[UIActionSheet alloc] initWithTitle: resetWordMessageTitle delegate:self cancelButtonTitle:NSLocalizedString(@"CancelOptionText", @"Cancel") destructiveButtonTitle: NSLocalizedString(@"ResetOptionText", @"Reset") otherButtonTitles: nil];
    [self.resetLevelActionSheet showInView:self.view];
}

-(void) removeWordButtonTouched: (id) sender {
    NSString *removeWordMessageTitle = NSLocalizedString(@"removeWordMessageTitle", @"Really remove word?");
    self.removeWordActionSheet = [[UIActionSheet alloc] initWithTitle: removeWordMessageTitle delegate:self cancelButtonTitle: NSLocalizedString(@"CancelOptionTitle", @"Cancel") destructiveButtonTitle: NSLocalizedString(@"RemoveOptionText", @"Remove") otherButtonTitles: nil];
    [self.removeWordActionSheet showInView:self.view];
}

-(void) lookupButtonTouched: (id) sender {
    [self.navigationController pushViewController:self.lookupVC animated:YES];
    self.lookupVC.wordName = self.wordTextField.text;
    self.lookupVC.wordTranslation = [self getFirstLineOfString: self.translationsTextView.text];
    self.lookupVC.wordSet = self.wordSet;
}

- (IBAction)addButtonTouched:(id)sender {
    if([self.wordTextField.text isEqualToString:@""] || [self.translationsTextView.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"EmptyWordOrTranslationMessageTitle", @"New Word") message:NSLocalizedString(@"EmptyWordOrTranslationMessage", @"Please enter a word and a translation") delegate:nil cancelButtonTitle:NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles: nil];
        [alert show];
        return;
    }
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request.predicate = [NSPredicate predicateWithFormat:@"wordSet = %@ AND name = %@", self.wordSet, self.wordTextField.text];
    NSArray *results = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!results) {
        NSLog(@"Error checking if Word already exists");
        return;
    }
    
    if([results count] > 0) {
        NSString *msg = NSLocalizedString(@"WordAlreadyExistsMessage", @"A word with the same name already exists. Do you want to create it anyway?");
        self.reallyCreateWordAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WordAlreadyExistsMessageTitle", @"Word already exists") message:msg delegate: self cancelButtonTitle: NSLocalizedString(@"CancelOptionText", @"Cancel") otherButtonTitles: NSLocalizedString(@"CreateOptionText", @"Create"), nil];
        [self.reallyCreateWordAlertView show];
        return;
    } else {
        [self createWordInDocument: document];
    }
}

-(void) createWordInDocument: (UIManagedDocument*) document
{
    Word *word = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:document.managedObjectContext];
    word.name = self.wordTextField.text;
    word.translations = self.translationsTextView.text;
    word.creationDate = [NSDate date];
    word.lastQuizzedDate = self.wordSet.creationDate;
    word.wordSet = self.wordSet;
    self.wordSet.changesSinceLastTest = [NSNumber numberWithInteger:[self.wordSet.changesSinceLastTest integerValue] + 1];
    self.wordSet.lastUsedDate = [NSDate date];
    word.level = [NSNumber numberWithInt:0];
    word.numRight = [NSNumber numberWithInt:0];
    word.numWrong = [NSNumber numberWithInt:0];
    
    if(!word) {
        NSLog(@"Error creating word");
        return;
    }
    
    
    NSString *msg = [NSString stringWithFormat:@"%@: %@\n%@: %@", NSLocalizedString(@"WordText", @"Word"), self.wordTextField.text, NSLocalizedString(@"SetText", @"Set"),  self.wordSet.name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WordAddedText", @"Word added") message:msg delegate:self cancelButtonTitle: NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles: nil];
    [alert show];
    
    [self.wordTextField becomeFirstResponder];
    
    // clear input
    self.wordTextField.text = @"";
    self.translationsTextView.text = @"";
}

-(void) setButtonTouched: (id) sender
{
    [self performSegueWithIdentifier:@"changeSet" sender:self];
}

#pragma mark UIAlertViewDelegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == self.reallyCreateWordAlertView && buttonIndex == 1) {
        VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        UIManagedDocument *document = appDelegate.managedDocument;
        [self createWordInDocument:document];
    } else {
        if(![[NSUserDefaults standardUserDefaults] boolForKey:PREMIUM_IDENTIFIER]) {
            // check if WORD_LIMIT is reached
            NSUInteger numWords = [VBHelper countAllWords];
            if(numWords >= WORD_LIMIT) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

#pragma mark UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0 && self.word) {
        if(actionSheet == self.resetLevelActionSheet) {
            self.word.level = [NSNumber numberWithInt:0];
            self.word.numRight = [NSNumber numberWithInt:0];
            self.word.numWrong = [NSNumber numberWithInt:0];
            self.levelNumberLabel.text = @"0";
        } else if(actionSheet == self.removeWordActionSheet) {
            VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate.managedDocument.managedObjectContext deleteObject:self.word];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark UITextViewDelegate

-(BOOL) textViewShouldEndEditing:(UITextView *)textView
{
    if(self.word) {
        self.word.translations = textView.text;
    }
    
    self.view.bounds = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);

    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    self.lookupVC.didLoadWebView = NO;
}

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    [self setViewBoundsForTranslationEditing];
}

#pragma mark UITextFieldDelegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.translationsTextView becomeFirstResponder];
    return NO;
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    if(self.word) {
        self.word.name = textField.text;
    }
    
    return YES;
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.lookupVC.didLoadWebView = NO;
    return YES;
}

#pragma Helper methods

-(NSString*) getFirstLineOfString: (NSString*) string
{
    NSArray *components = [string componentsSeparatedByString:@"\n"];
    return components[0];
}

-(void) setViewBoundsForTranslationEditing
{
    CGFloat statusBarHeight;
    
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(statusBarOrientation == UIInterfaceOrientationLandscapeLeft || statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.width;
    } else {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height;
    
    CGFloat newYOrigin = self.translationsTextView.frame.origin.y - statusBarHeight - navigationBarHeight - 4.0;
    self.view.bounds = CGRectMake(0.0, newYOrigin, self.view.bounds.size.width, self.view.bounds.size.height);
}

@end