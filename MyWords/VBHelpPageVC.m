//
//  VBHelpPageVC.m
//  Vocab Book
//
//  Created by Oliver Brehm on 23/05/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBHelpPageVC.h"

@interface VBHelpPageVC () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation VBHelpPageVC

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
    NSString *userLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *resourceName = [NSString stringWithFormat:@"%@_%@", self.pageName, userLanguage];

    NSString *urlPath = [[NSBundle mainBundle] pathForResource: resourceName ofType:@"html"];
    if(!urlPath) {
        [self loadErrorPage];
        return;
    }
    
    NSURL *url = [NSURL fileURLWithPath:urlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    [self.webView loadRequest:request];
    
    NSString *key = [NSString stringWithFormat:@"%@PageTitle", self.pageName];
    self.title = NSLocalizedString(key, @"Page name");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebViewDelegate
-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self loadErrorPage];
}

#pragma custom methods
-(void) loadErrorPage
{
    NSString *htmlString = @"<html><head>Error loading help page</head></html>";
    [self.webView loadHTMLString: htmlString baseURL:nil];
}

@end
