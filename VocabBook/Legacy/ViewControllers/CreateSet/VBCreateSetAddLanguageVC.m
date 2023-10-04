//
//  VBCreateSetAddLanguageVC.m
//  Vocab Book
//
//  Created by Oliver Brehm on 20/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBCreateSetAddLanguageVC.h"
#import "WordSet.h"
#import "VBCreateSetTVC.h"

@interface VBCreateSetAddLanguageVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *languageTextField;

@end

@implementation VBCreateSetAddLanguageVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.languageTextField becomeFirstResponder];
    self.languageTextField.text = self.createSetTVC.wordSet.language;
}

- (IBAction)addButtonTouched:(id)sender {
    if([self.languageTextField.text isEqualToString:@""]) {
        NSString *enterLanguageTitle = NSLocalizedString(@"EnterLanguageTitle", @"Enter language");
        NSString *enterLanguageText = NSLocalizedString(@"EnterLanguageText", @"Please enter a language");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:enterLanguageTitle message:enterLanguageText delegate:nil cancelButtonTitle:NSLocalizedString(@"CancelOptionText", @"Cancel") otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    if(self.createSetTVC.wordSet) {
        self.createSetTVC.wordSet.language = self.languageTextField.text;
    } else {
        self.createSetTVC.customLanguage = self.languageTextField.text;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self addButtonTouched:self];
    return YES;
}

@end
