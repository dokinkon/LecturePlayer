//
//  Utility.m
//  LecturePlayer
//
//  Created by chao-chih lin on 12/6/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Utility.h"

NSString* GetDownloadPath() 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/download", documentsDirectory];
}

BOOL MakeDownloadDirectory()
{
    NSError *error;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:GetDownloadPath()
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error]){
        NSLog(@"Create directory error: %@", error);
        return NO;
    }
    return YES;
}

BOOL MakeDirectoryInDownload(NSString* name)
{
    NSError *error;
    NSString* fullPath = [NSString stringWithFormat:@"%@/%@", GetDownloadPath(), name];
    if (![[NSFileManager defaultManager] createDirectoryAtPath:fullPath
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error]){
        NSLog(@"Create directory error: %@", error);
        return NO;
    }
    return YES;
}