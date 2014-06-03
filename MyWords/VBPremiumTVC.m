//
//  VBPremiumTVC.m
//  Vocab Book
//
//  Created by Oliver Brehm on 26/03/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBPremiumTVC.h"
#import "VBAppDelegate.h"
#import "VBHelper.h"

#import <StoreKit/StoreKit.h>

@interface VBPremiumTVC () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *buyActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *restoreActivityIndicator;
@property (weak, nonatomic) IBOutlet UITableViewCell *buyCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *restoreCell;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (strong, nonatomic) SKProduct *product;

@end

@implementation VBPremiumTVC

+(void) unpremium
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREMIUM_IDENTIFIER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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
    
    // observe payment transactions
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:PREMIUM_IDENTIFIER]) {
        [self changeUIUsingPremium];
    } else {
        self.buyCell.textLabel.text = NSLocalizedString(@"BuyPremiumText", @"Buy Premium");
        self.buyCell.textLabel.textColor = [VBHelper globalButtonColor];
        self.buyCell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        self.restoreCell.textLabel.text = NSLocalizedString(@"RestorePremiumText", @"Restore purchase");
        self.restoreCell.textLabel.textColor = [VBHelper globalButtonColor];
        self.restoreCell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        self.buyCell.textLabel.hidden = YES;
        self.buyActivityIndicator.hidden = NO;
        [self.buyActivityIndicator startAnimating];
        self.restoreCell.textLabel.hidden = YES;
        self.restoreActivityIndicator.hidden = NO;
        [self.restoreActivityIndicator startAnimating];
        [self getProduct];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) startActivity
{
    self.buyCell.textLabel.hidden = YES;
    self.buyActivityIndicator.hidden = NO;
    [self.buyActivityIndicator startAnimating];
    self.restoreCell.textLabel.hidden = YES;
    self.restoreActivityIndicator.hidden = NO;
    [self.restoreActivityIndicator startAnimating];
}

-(void) stopActivity
{
    self.buyCell.textLabel.hidden = NO;
    self.buyActivityIndicator.hidden = YES;
    [self.buyActivityIndicator stopAnimating];
    self.restoreCell.textLabel.hidden = NO;
    self.restoreActivityIndicator.hidden = YES;
    [self.restoreActivityIndicator stopAnimating];
}

-(void) changeUIUsingPremium
{
    [self stopActivity];
    [self.tableView reloadData];
    
    self.buyCell.userInteractionEnabled = NO;
    self.buyCell.textLabel.text = NSLocalizedString(@"UsingPremiumText", @"Using premium");
    self.buyCell.textLabel.textColor = [UIColor greenColor];
}

- (void) buyPremiumTouched {
    [self startActivity];
    [self buyPremium];
}
- (void) restoreTouched {
    [self startActivity];
    [self restorePurchase];
}


#define ROW_HEIGHT 44.0

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:PREMIUM_IDENTIFIER]) {
        if(indexPath.section == 0 && indexPath.row == 1) { // price row
            self.priceLabel.hidden = YES;
            return 0.0;
        } else  if(indexPath.section == 0 && indexPath.row == 2) { // restore row
            self.restoreCell.textLabel.hidden = YES;
            return 0.0;
        }
    }
    
    return ROW_HEIGHT;
}

-(void) getProduct
{
    SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PREMIUM_IDENTIFIER]];
    productRequest.delegate = self;
    [productRequest start];
}

-(void) buyPremium
{
    if(self.product) {
        SKPayment *payment = [SKPayment paymentWithProduct: self.product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if([response.products count] > 0) {
        SKProduct *product = response.products[0];
        self.product = product;
        self.buyCell.textLabel.hidden = NO;
        self.buyActivityIndicator.hidden = YES;
        [self.buyActivityIndicator stopAnimating];
        self.restoreCell.textLabel.hidden = NO;
        self.restoreActivityIndicator.hidden = YES;
        [self.restoreActivityIndicator stopAnimating];
        self.priceLabel.text = [NSString stringWithFormat:@"(%@)", [product.price stringValue]];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Error requesting product");
}

-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        if(transaction.transactionState == SKPaymentTransactionStatePurchased || transaction.transactionState == SKPaymentTransactionStateRestored) {
            NSLog(@"Premium purchase successfull");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREMIUM_IDENTIFIER];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
            [self changeUIUsingPremium];
        } else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            [self stopActivity];
            
            if (transaction.error.code != SKErrorPaymentCancelled) {
                NSLog(@"Premium purchase failed");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorText", @"Error") message:transaction.error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OKOptionText", @"OK") otherButtonTitles: nil];
                [alertView show];
                NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
            } else {
                NSLog(@"Premium purchase cancelled");
            }
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self buyPremiumTouched];
        } else if(indexPath.row == 2) {
            [self restoreTouched];
        }
    }
}

-(void) restorePurchase
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}



@end
