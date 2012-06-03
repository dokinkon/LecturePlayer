//
//  MasterViewController.m
//  LecturePlayer
//
//  Created by chao-chih lin on 12/5/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "RemoteLectureViewController.h"
#import "TPlayerMainForm.h"
#import "Utility.h"
#import "Lecture.h"
#import "Slide.h"

#import "DropboxSDK/DropboxSDK.h"

#include <vector>
#include <string>
#include <map>

@interface MasterViewController () {
    NSMutableArray* _lectures;
}

- (void)readLectureList;

- (NSString *)makeFilePathWithLecture:(NSString *)lectureName andBst:(NSString *)bstName; 

@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"目錄";//NSLocalizedString(@"Master", @"Master");
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(480.0, 600.0);
    }
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    [super dealloc];
}

- (NSString *)makeFilePathWithLecture:(NSString *)lectureName andBst:(NSString *)bstName
{
    NSString* lecturesPath = [[NSBundle mainBundle] pathForResource:@"Lectures" ofType:@""];
    return [lecturesPath stringByAppendingFormat:@"/%@/%@", lectureName, bstName];
}

- (void)readLectureList
{
    NSString* lecturesPath = [[NSBundle mainBundle] pathForResource:@"Lectures" ofType:@""];
    assert(lecturesPath);
    NSArray* bstDirectories = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:lecturesPath error:nil];
    
    _lectures = [[NSMutableArray alloc] init];
    
    for (id bstDirectory in bstDirectories)
    {
        Lecture* lecture = [[Lecture alloc] initWithTitle:bstDirectory lectureFolder:lecturesPath];
        [_lectures addObject:lecture];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self readLectureList];
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *dropBoxButton = [[[UIBarButtonItem alloc] initWithTitle:@"Dropbox" style:UIBarButtonItemStylePlain target:self action:@selector(openDropbox:)] autorelease];
    self.navigationItem.rightBarButtonItem = dropBoxButton;
    MakeDownloadDirectory();
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)openDropbox:(id)sender
{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self.splitViewController];
    } 
    
    RemoteLectureViewController* controller = [[RemoteLectureViewController alloc] initWithNibName:@"RemoteLectureViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger c = [_lectures count];
    return c;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Lecture* lecture = (Lecture*)[_lectures objectAtIndex:section];
    return [lecture.slides count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Lecture* lecture = (Lecture*)[_lectures objectAtIndex:section];
    return lecture.title;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    Lecture* lecture = (Lecture*)[_lectures objectAtIndex:indexPath.section];
    Slide* slide = (Slide*)[lecture.slides objectAtIndex:indexPath.row];
    cell.textLabel.text = slide.title;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Lecture* lecture = [_lectures objectAtIndex:indexPath.section];
    [self.detailViewController setLecture:lecture withSlideIndex:indexPath.row];
}












@end




















