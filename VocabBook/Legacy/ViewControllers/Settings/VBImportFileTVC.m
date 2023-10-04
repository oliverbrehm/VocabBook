//
//  VBImportFileTVC.m
//  Vocab Book
//
//  Created by Oliver Brehm on 25/04/14.
//  Copyright (c) 2014 Oliver Brehm. All rights reserved.
//

#import "VBImportFileTVC.h"
#import "VBImportExport.h"

@interface VBImportFileTVC ()

@property (strong, nonatomic) NSMutableArray *fileNames; // of NSString*

@end

@implementation VBImportFileTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated
{
    self.fileNames = [[VBImportExport getAvailableImportFileNames] mutableCopy];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.fileNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ([self.fileNames count] == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell" forIndexPath:indexPath];
        cell.textLabel.text = self.fileNames[indexPath.row];
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [VBImportExport importDatabaseFromFile:self.fileNames[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if([VBImportExport deleteFile:self.fileNames[indexPath.row]]) {
            [self.fileNames removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

-(NSString*) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ([self.fileNames count] == 0) {
        return NSLocalizedString(@"ImportInfoText", @"No files to import. Exported files will show up here. You can also import a previously exported file if you move it to iTunes File Sharing (iTunes -> iOS devie -> Apps -> File Sharing).");
    }
    return @"";
}

@end
