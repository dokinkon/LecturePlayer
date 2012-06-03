//
//  DownloadSessoin.m
//  LecturePlayer
//
//  Created by chao-chih lin on 12/6/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DownloadSession.h"
#import "Utility.h"
#import "DropboxSDK/DropboxSDK.h"

@implementation DownloadSession

@synthesize title = _title;

- (id) init
{
    if ((self=[super init])) {
        _remotePaths = [[NSMutableArray alloc] initWithCapacity:3];
        _localPaths  = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return self;
    
}

- (void)dealloc
{
    [_remotePaths release];
    [_localPaths release];
    [_title release];
    [super dealloc];
}

- (void)addFile:(NSString*)fileName
{
    NSString* remotePath = [NSString stringWithFormat:@"/%@/%@", _title, fileName];
    [_remotePaths addObject:remotePath];
}

- (void)start:(DBRestClient*)client
{
    MakeDirectoryInDownload(_title);
    for (NSString* remotePath in _remotePaths) {
        NSString* localPath = [NSString stringWithFormat:@"%@%@", GetDownloadPath(), remotePath];
        [client loadFile:remotePath intoPath:localPath];
    }
}

- (BOOL)isDownloaded:(NSString*)localPath
{
    for (NSString* path in _localPaths) {
        if ([path isEqualToString:localPath]) {
            [_localPaths removeObject:path];
            return YES;
        }
    }
    return NO;
}

- (BOOL)isCompleted
{
    return [_localPaths count] == 0;
}

@end





















