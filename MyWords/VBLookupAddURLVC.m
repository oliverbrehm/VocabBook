//
//  VBLookupAddURLVC.m
//  Vocab Book
//
//  Created by Oliver Brehm on 20/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBLookupAddURLVC.h"
#import "VBLookupURLHelper.h"

@interface VBLookupAddURLVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end

@implementation VBLookupAddURLVC

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

-(void) viewWillAppear:(BOOL)animated
{
    if(self.urlItemIndex != -1) {
        
        NSDictionary *item = [VBLookupURLHelper urlItemAtIndex:self.urlItemIndex];
        self.descriptionTextField.text = item[@"Description"];
        self.urlTextField.text = item[@"URL"];
        self.addButton.hidden = YES;
    }
    
    [self.descriptionTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addButtonTouched:(id)sender {
    if(![self.descriptionTextField.text isEqualToString:@""] && [self.urlTextField.text hasPrefix:@"http://"]) {
        [VBLookupURLHelper addURL:self.urlTextField.text withDescription:self.descriptionTextField.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.descriptionTextField resignFirstResponder];
    [self.urlTextField resignFirstResponder];
}


-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    if(self.urlItemIndex != -1 && ![self.descriptionTextField.text isEqualToString:@""] && [self.urlTextField.text hasPrefix:@"http://"]) {
        // save data
        [VBLookupURLHelper updateURLAtIndex:self.urlItemIndex withURL:self.urlTextField.text andDescription:self.descriptionTextField.text];
    }
    
    return YES;
}

@end
