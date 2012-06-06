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
#import "LectureDetailViewController.h"

#import "DropboxSDK/DropboxSDK.h"

#include <vector>
#include <string>
#include <map>

@interface MasterViewController () {
    NSMutableArray* _localLectures;
    NSMutableArray* _remoteLectures;
}

- (void)readLectureList;

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
    [_remoteLectures release];
    [_localLectures release];
    [super dealloc];
}

- (void)readLectureList
{
    [_localLectures release];
    
    NSString* lecturesPath = [[NSBundle mainBundle] pathForResource:@"Lectures" ofType:@""];
    assert(lecturesPath);
    NSArray* bstDirectories = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:lecturesPath error:nil];
    
    _localLectures = [[NSMutableArray alloc] init];
    
    for (id bstDirectory in bstDirectories)
    {
        Lecture* lecture = [[Lecture alloc] initWithTitle:bstDirectory lectureFolder:lecturesPath];
        [_localLectures addObject:lecture];
    }
}

- (void)readRemoteLectureList
{
    NSString* downloadPath = GetDownloadPath();
    NSArray* lectureDirectories = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadPath error:nil];
    [_remoteLectures release];
    _remoteLectures = [[NSMutableArray alloc] initWithCapacity:3];
    
    for (NSString* lectureTitle in lectureDirectories) {
        Lecture* remoteLecture = [[Lecture alloc] initWithTitle:lectureTitle lectureFolder:downloadPath];
        [_remoteLectures addObject:remoteLecture];
    }
}

- (void)refresh
{
    [self readLectureList];
    [self readRemoteLectureList];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *dropBoxButton = [[[UIBarButtonItem alloc] initWithTitle:@"Dropbox" style:UIBarButtonItemStylePlain target:self action:@selector(openDropbox:)] autorelease];
    self.navigationItem.rightBarButtonItem = dropBoxButton;
    MakeDownloadDirectory();
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return [_localLectures count];
    } else {
        return [_remoteLectures count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"本地端";
    } else {
        return @"下載資料夾";
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.section==0) {
        Lecture* lecture = (Lecture*)[_localLectures objectAtIndex:indexPath.row];
        cell.textLabel.text = lecture.title;
    } else if (indexPath.section==1) {
        Lecture* lecture = (Lecture*)[_remoteLectures objectAtIndex:indexPath.row];
        cell.textLabel.text = lecture.title;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray* lectures = nil;
    
    if (indexPath.section==0) {
        lectures = _localLectures;
    } else if (indexPath.section==1) {
        lectures = _remoteLectures;
    }
    
    if (lectures) {
        LectureDetailViewController* controller = [[LectureDetailViewController alloc] initWithNibName:@"LectureDetailViewController" bundle:nil];
        Lecture* lecture = [lectures objectAtIndex:indexPath.row];
        [controller setLecture:lecture];
        [controller setDetailViewController:self.detailViewController];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
        
}












@end




















