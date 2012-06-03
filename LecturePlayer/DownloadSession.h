//
//  DownloadSessoin.h
//  LecturePlayer
//
//  Created by chao-chih lin on 12/6/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBRestClient;

@interface DownloadSession : NSObject
{
    NSString* _title;
    NSMutableArray* _remotePaths;
    NSMutableArray* _localPaths;
}

@property (nonatomic, retain) NSString* title;

- (void)addFile:(NSString*)fileName;

- (void)start:(DBRestClient*)client;

- (BOOL)isDownloaded:(NSString*)localPath;

- (BOOL)isCompleted;

@end
