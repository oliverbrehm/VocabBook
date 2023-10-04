//
//  WordsCreateSetTVC.m
//  MyWords
//
//  Created by Oliver Brehm on 23/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBCreateSetTVC.h"
#import "VBAppDelegate.h"
#import "VBCreateSetNameCell.h"
#import "VBCreateSetDescriptionCell.h"
#import "VBCreateSetFavouritesCell.h"
#import "VBCreateSetAddLanguageVC.h"
#import "VBHelper.h"
#import "WordSet+DocumentOperations.h"
#import "VBMenuCVC.h"

@interface VBCreateSetTVC () <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) UITextField *createSetTextField;
@property (weak, nonatomic) UITextView *descriptionTextView;

@property (nonatomic) NSInteger selectedRow;
@property (strong, nonatomic) NSMutableArray *languages;

@property (strong, nonatomic) UIAlertView *reallyCreateAlertView;

@end

@implementation VBCreateSetTVC

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
}

-(void) viewWillAppear:(BOOL)animated
{
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.languages = [appDelegate.languages mutableCopy];
    [self.tableView reloadData];
    
    if(self.wordSet) {
        [self selectLanguage: self.wordSet.language];
        self.createSetTextField.text = self.wordSet.name;
        self.descriptionTextView.text = self.wordSet.descriptionText;
        self.navigationItem.rightBarButtonItem = nil;
    } else if(self.customLanguage) {
        [self selectLanguage: self.customLanguage];
    } else {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    if(!self.wordSet) {
        [self.createSetTextField becomeFirstResponder];
    }
}

-(void) selectLanguage: (NSString*) language
{
    for(int i = 0; i < [self.languages count]; i++) {
        if([self.languages[i] isEqualToString:language]) {
            self.selectedRow = i;
            if (self.customLanguage) {
                self.selectedRow += 1;
            }
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
            return;
        }
    }
    self.customLanguage = language;
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
    self.selectedRow = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createButtonTouched:(id)sender {
    if([self.createSetTextField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmptyNameMessageTitle", @"Empty name") message:NSLocalizedString(@"EmptyNameMessage", @"Please enter a name for the set") delegate:nil cancelButtonTitle:NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles:nil];
        [alertView show];
        [self.createSetTextField becomeFirstResponder];
        
        return;
    }
    
    VBAppDelegate *appDelegate = (VBAppDelegate*) [UIApplication sharedApplication].delegate;
    UIManagedDocument *document = appDelegate.managedDocument;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WordSet"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", self.createSetTextField.text];
    NSArray *results = [document.managedObjectContext executeFetchRequest:request error:NULL];
    if(!results) {
        NSLog(@"Error checking if WordSet already exists");
        return;
    }
    
    if([results count] > 0) {
        NSString *msg = NSLocalizedString(@"SetAlreadyExistsMessage", @"A set with the same name already exists. Do you want to create it anyway?");
        self.reallyCreateAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SetAlreadyExistsMessageTitle", @"Set already exists") message:msg delegate: self cancelButtonTitle:NSLocalizedString(@"CancelOptionText", @"Cancel") otherButtonTitles: NSLocalizedString(@"CreateOptionText", @"Create"), nil];
        [self.reallyCreateAlertView show];
    } else {
        [self createSetInDocument];
    }
}

-(void) createSetInDocument
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    WordSet *wordSet = [WordSet createWithName:self.createSetTextField.text andLanguage:cell.textLabel.text andDescription:self.descriptionTextView.text andFavourite: YES];
    
    NSString *msg = [NSString stringWithFormat: @"%@ %@ %@", NSLocalizedString(@"NewSetCreatedMessage_1", @"New set"), wordSet.name, NSLocalizedString(@"NewSetCreatedMessage_2", @"has been created")];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"", @"Set created") message:msg delegate: self cancelButtonTitle:NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles: nil];
    [alert show];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.createSetTextField) {
        [self.descriptionTextView becomeFirstResponder];
    }
    
    return NO;
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    if(self.wordSet) {
        if(textField == self.createSetTextField) {
            self.wordSet.name = self.createSetTextField.text;
        }
    }
    
    return YES;
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.createSetTextField resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
}

-(BOOL) textViewShouldEndEditing:(UITextView *)textView
{
    self.wordSet.descriptionText = self.descriptionTextView.text;
    return YES;
}

#pragma mark UITableView Data Source

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1) {
        if(indexPath.row == [tableView numberOfRowsInSection:1] - 1) {
            [self performSegueWithIdentifier:@"otherLanguage" sender:self];
        } else {
            self.selectedRow = indexPath.row;
            if(self.wordSet) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                self.wordSet.language = cell.textLabel.text;
            }
        }
    } else {
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else
    {
        return [self.languages count] + (self.customLanguage ? 2 : 1);
    }
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"InfoText", @"Info");
    } else {
        return NSLocalizedString(@"LanguageText", @"Language");
    }
}

#define ROW_HEIGHT 44.0

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return ROW_HEIGHT * 1.5;
        }
        if(indexPath.row == 1) {
            return ROW_HEIGHT * 4;
        }
    }
    
    return ROW_HEIGHT;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VBAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UITableViewCell *cell;
    
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"setNameCell" forIndexPath:indexPath];
            self.createSetTextField = ((VBCreateSetNameCell*) cell).nameTextField;
        } else if(indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"setDescriptionCell" forIndexPath:indexPath];
            self.descriptionTextView = ((VBCreateSetDescriptionCell*) cell).descriptionTextView;
        }
    } else if(indexPath.section == 1) {
        if(indexPath.row == [tableView numberOfRowsInSection:1] - 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"otherLanguageCell" forIndexPath:indexPath];

        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"setLanguageCell" forIndexPath:indexPath];
            
            NSString *language;
            if (self.customLanguage && indexPath.row == 0) {
                language = self.customLanguage;
            } else {
                language = self.languages[indexPath.row - (self.customLanguage ? 1 : 0)];
            }
            
            cell.textLabel.text = language;
            cell.imageView.image = [appDelegate imageForLanguage:language];
        }
    }
    
    return cell;
}

-(BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return YES;
    }
    
    return NO;
}

-(void) textViewDidBeginEditing:(UITextField *)textField
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VBCreateSetAddLanguageVC *vc = (VBCreateSetAddLanguageVC*) segue.destinationViewController;
    vc.createSetTVC = self;
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.reallyCreateAlertView) {
        if(buttonIndex == 1) {
            [self createSetInDocument];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [[VBHelper getMenuCVC] dismissPopover];
    }
}

@end
