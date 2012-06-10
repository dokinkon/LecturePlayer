//
//  LectureDetailViewController.m
//  LecturePlayer
//
//  Created by chao-chih lin on 12/6/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LectureDetailViewController.h"
#import "DetailViewController.h"
#import "Lecture.h"
#import "Slide.h"

@interface LectureDetailViewController ()

@end

@implementation LectureDetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_lecture release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *deleteButton = [[[UIBarButtonItem alloc] initWithTitle:@"刪除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteLecture:)] autorelease];
    self.navigationItem.rightBarButtonItem = deleteButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)deleteLecture:(id)sender
{
    if (!_lecture)
        return;
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"確認刪除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好", nil];
    [alert show];
    [alert release];
}

- (void)doDeleteLecture
{
    if (![[NSFileManager defaultManager] removeItemAtPath:_lecture.path error:nil]) {
        // Something error
        NSLog(@"Failed to remove directory");
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setDetailViewController:(DetailViewController*)controller;
{
    _detailViewController = controller;
}

- (void)setLecture:(Lecture *)lecture
{
    _lecture = [lecture retain];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_lecture)
        return 0;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_lecture.slides count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!_lecture) 
        return @"";
    return _lecture.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Slide* slide = (Slide*)[_lecture.slides objectAtIndex:indexPath.row];
    cell.textLabel.text = slide.title;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"[LDV] SELECT LECTURE:%@ WITH INDEX:%d", _lecture.title, indexPath.row);
    [_detailViewController setLecture:_lecture withSlideIndex:indexPath.row];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [self doDeleteLecture];
    }
    
}

@end
