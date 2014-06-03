//
//  WordsLookUpVC.m
//  MyWords
//
//  Created by Oliver Brehm on 23/02/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBWordLookupVC.h"
#import "VBLookupSettings.h"
#import "WordSet.h"
#import "VBLookupURLHelper.h"

@interface VBWordLookupVC () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) BOOL loadingRequest;

@end

@implementation VBWordLookupVC

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
    self.webView.delegate = self;
    self.didLoadWebView = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    if(!self.didLoadWebView) {
        [self loadWebView];
    }
}

-(void) loadWebView
{
    self.webView.hidden = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSURL *url;
    
    if(self.wordSet) {
        url = [NSURL URLWithString: self.wordSet.lookupURL];
    } else {
        url = [NSURL URLWithString:[VBLookupURLHelper defaultURLString]];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    [self.webView loadRequest: request];
    self.loadingRequest = YES;
}

- (IBAction)pasteWord:(id)sender {
    [self pasteWordAction];
    [self submitForm];
}

- (IBAction)pasteTranslation:(id)sender {
    [self pasteTranslationAction];
    [self submitForm];
}

-(void) pasteTranslationAction
{
    NSString *js = [NSString stringWithFormat:@"var inputFields = document.getElementsByTagName('input'); for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = '%@';}", self.wordTranslation];
    [self.webView stringByEvaluatingJavaScriptFromString: js];
}

-(void) pasteWordAction
{
    NSString *js = [NSString stringWithFormat:@"var inputFields = document.getElementsByTagName('input'); for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = '%@';}", self.wordName];
    [self.webView stringByEvaluatingJavaScriptFromString: js];
}

-(void) submitForm
{
    NSString *js = [NSString stringWithFormat:@"var form = document.forms[0]; form.submit()"];
    [self.webView stringByEvaluatingJavaScriptFromString: js];
    self.didLoadWebView = YES;
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    webView.hidden = NO;
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    self.loadingRequest = NO;
    
    if(!self.didLoadWebView) {
        if (![self.wordName isEqualToString:@""]) {
            [self pasteWordAction];
        } else {
            [self pasteTranslationAction];
        }
        [self submitForm];

    }
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code != -999) {
        webView.hidden = NO;
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        
        NSString *badURLMessage = NSLocalizedString(@"badURLMessage", @"Could not open url. <br> Try selecting a different page by tapping \"Settings\".");
        
        NSString *html = [NSString stringWithFormat: @"<html><body>%@</html><body>", badURLMessage];
        [webView loadHTMLString: html baseURL:nil];
    }
    
    self.loadingRequest = NO;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[VBLookupSettings class]]) {
        VBLookupSettings *vc = (VBLookupSettings*) segue.destinationViewController;
        vc.wordSet = self.wordSet;
        self.didLoadWebView = NO;
    }
}

@end
