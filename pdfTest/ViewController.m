//
//  ViewController.m
//  pdfTest
//
//  Created by Oliver Brehm on 24/05/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "ViewController.h"
#import "PrintView.h"

@interface ViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) NSArray *printViews; // of PrintView*
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSMutableArray *words = [[NSMutableArray alloc] init];
    for (int i = 0; i < 100; i++) {
        [words addObject:[NSString stringWithFormat:@"word %d", i]];
    }
    self.words = [NSArray arrayWithArray:words];
}

#define PAGE_GAP 10.0

-(void) initPrintViews
{
    CGFloat A4Width = 595.0;
    CGFloat A4Height = 842.0;
    
    NSUInteger wordIndex = 0;
    CGFloat currentY = 0.0;
    
    UIView *contentView = [[UIView alloc] initWithFrame: CGRectZero];
    
    NSMutableArray *printViews = [[NSMutableArray alloc] init];
    
    while (wordIndex < [self.words count]) {
        // create new view
        CGRect containerFrame = CGRectMake(0.0, currentY, A4Width, A4Height);
        UIView *printViewContainerView = [[UIView alloc] initWithFrame: containerFrame];
        printViewContainerView.layer.borderWidth = 4.0;
        printViewContainerView.layer.borderColor = [[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3] CGColor];
        
        CGRect frame = CGRectMake(0.0, 0.0, A4Width, A4Height);
        PrintView *printView = [[PrintView alloc] initWithFrame: frame];
        printView.backgroundColor = [UIColor whiteColor];
        [printViews addObject: printView];
        [printViewContainerView addSubview:printView];
        [contentView addSubview: printViewContainerView];
        
        // fill with words and draw
        NSUInteger printViewCapacity = [printView getCapacity];
        [printView drawWithWords: [self wordsSubArrayStartingWithIndex: wordIndex capacity: printViewCapacity]];
        
        currentY += printView.bounds.size.height + PAGE_GAP;
        wordIndex += printViewCapacity;
    }
    
    self.printViews = [NSArray arrayWithArray: printViews];
    
    PrintView *printView = self.printViews[0];
    CGFloat contentWidth = printView.bounds.size.width;
    CGFloat contentHeight = printView.bounds.size.height * [self.printViews count];
    contentView.frame = CGRectMake(0.0, 0.0, contentWidth, contentHeight);
    
    [self.scrollView addSubview: contentView];
    self.scrollView.contentSize = contentView.frame.size;
}

-(NSArray*) wordsSubArrayStartingWithIndex: (NSUInteger) index capacity: (NSUInteger) capacity
{
    NSMutableArray *newWords = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = index; i < index + capacity && i < [self.words count]; i++) {
        [newWords addObject: self.words[i]];
    }
    
    return [NSArray arrayWithArray: newWords];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)createButtonTouched:(id)sender {
    [self drawPDF];
}

-(void) viewDidAppear:(BOOL)animated
{
    [self initPrintViews];
    
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat A4Width = 595.0;
    CGFloat scaleWidth = scrollViewFrame.size.width / A4Width;
    self.scrollView.minimumZoomScale = scaleWidth;
    self.scrollView.maximumZoomScale = 1.0;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}

-(void) drawPDF
{
    NSString *fileName = @"test.pdf";
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent: fileName];
    
    UIGraphicsBeginPDFContextToFile([fileURL path], CGRectZero, nil);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for(PrintView *view in self.printViews) {
        UIGraphicsBeginPDFPageWithInfo(view.bounds, nil);
        [view.layer renderInContext:context];
    }
  
    UIGraphicsEndPDFContext();
}

-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.scrollView.subviews[0];
    
}



@end
