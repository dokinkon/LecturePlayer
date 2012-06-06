//
//  RemoteLectureViewController.m
//  LecturePlayer
//
//  Created by chao-chih lin on 12/6/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RemoteLectureViewController.h"
#import "DropboxSDK/DropboxSDK.h"
#import "Utility.h"
#import "DownloadSession.h"

typedef enum {
    kNoOperation,
    kLoadLectureList,
    kPrepareDownloadList,
} OpCode;

@interface RemoteLectureViewController ()
{
    DBRestClient* _restClient;
    NSMutableArray* _lectures;
    NSString* _tobeDownload;
    OpCode _opCode;
    NSMutableArray* _downloading;
    NSMutableArray* _downloadSessions;
    UIAlertView* _busyIndicator;
}

- (void)refreshButtonPressed:(id)sender;
- (void)doRefresh;

@end

@implementation RemoteLectureViewController

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
    [_restClient release];
    [_lectures release];
    [_downloading release];
    [_downloadSessions release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"@Dropbox";
    
    _opCode = kNoOperation;
    _downloading = [[NSMutableArray alloc] initWithCapacity:3];
    _downloadSessions = [[NSMutableArray alloc] initWithCapacity:3];
    
    // add refresh button
    UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"重新整理" style: UIBarButtonItemStylePlain target:self action:@selector(refreshButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem = refreshButton;
    [refreshButton release];
    
    _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    _restClient.delegate = self;
    _lectures = [[NSMutableArray alloc] initWithCapacity:3];
    
    [self doRefresh];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_lectures count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = (NSString*)[_lectures objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _tobeDownload = (NSString*)[_lectures objectAtIndex:indexPath.row];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"確認" message:@"確認下載？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好", nil];
    [alert show];
    [alert release];
}

#pragma mark - DBRestClient delegate

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    for (DownloadSession* session in _downloadSessions) {
        if ([session isDownloaded:localPath]) {
            [self updateDownloadSession];
        }
    }
    NSLog(@"File loaded into path: %@", localPath);
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    NSLog(@"There was an error loading the file - %@", error);
}

- (void)prepareDownloadList:(DBMetadata*)metadata
{
    if (!metadata.isDirectory) {
        _opCode = kNoOperation;
        return;
    }
    
    DownloadSession* session = [[DownloadSession alloc] init];
    session.title = _tobeDownload;
    
    for (DBMetadata* file in metadata.contents) {
        [session addFile:file.filename];
    }
    [session start:_restClient];
    [_downloadSessions addObject:session];
    [session release];
    _tobeDownload = nil;
    _opCode = kNoOperation;

    
}

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata
{
    switch (_opCode) {
        case kLoadLectureList:
            if (!metadata.isDirectory) {
                _opCode = kNoOperation;
                return;
            }
            
            for (DBMetadata* file in metadata.contents) {
                if (!file.isDirectory)
                    continue;
                
                [_lectures addObject:file.filename];
            }
            [self.tableView reloadData]; 
            _opCode = kNoOperation;
            break;
        case kPrepareDownloadList:
            [self prepareDownloadList:metadata];
            break;
        default:
            break;
    }
    
}
//- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path;
- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
    NSLog(@"loadMetadataFailed:%@", [error description]);
    
}

- (void)doRefresh
{
    [_lectures removeAllObjects];
    _opCode = kLoadLectureList;
    [_restClient loadMetadata:@"/"];
    
}

- (void)updateDownloadSession
{
    for (DownloadSession* session in _downloadSessions) {
        if ([session isCompleted]) {
            [self hideBusyIndicator];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"恭喜" 
                                                           message:@"下載已完成" 
                                                          delegate:nil 
                                                 cancelButtonTitle:@"好" 
                                                 otherButtonTitles:nil];
            [alert show];
            [alert release];
            [_downloadSessions removeObject:session];
        }
    }
}


- (void)refreshButtonPressed:(id)sender
{
    [self doRefresh];
}

- (void)doStartDownload
{
    if (!_tobeDownload) 
        return;
    
    [self showBusyIndicator];
    
    _opCode = kPrepareDownloadList;
    [_restClient loadMetadata:[NSString stringWithFormat:@"/%@", _tobeDownload]];
    
    NSLog(@"tobeDownload:%@", _tobeDownload);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Index:%d", buttonIndex);
    if (buttonIndex!=1)
        return;
    
    [self doStartDownload];
}

- (void)showBusyIndicator
{
    if (_busyIndicator)
        return;
    _busyIndicator = [[UIAlertView alloc] initWithTitle:@"請稍候..."
                                                message:nil
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:nil];
    [_busyIndicator show];
    
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]
                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(_busyIndicator.frame.size.width/2, _busyIndicator.frame.size.height-40);
    //indicator.center = CGPointMake(_busyIndicator.bounds.size.height-40, _busyIndicator.bounds.size.width/2);
    //indicator.center = CGPointMake(100, 0);
    [indicator startAnimating];
    [_busyIndicator addSubview:indicator];
    [indicator release];
}
- (void)hideBusyIndicator
{
    if (!_busyIndicator)
        return;
    
    [_busyIndicator dismissWithClickedButtonIndex:0 animated:NO];
    _busyIndicator = nil;
}

@end






















