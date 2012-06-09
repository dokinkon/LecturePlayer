//
//  AudioPlayer.h
//  LecturePlayer
//
//  Created by chao-chih lin on 12/5/22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioPlayer : NSObject
{
    
}

@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, readonly) BOOL isSourceOpened;
@property (nonatomic, retain) NSMutableArray* sourceNames;

+ (void)initFFEngine;

- (void)play;

- (void)stop;

- (void)pause;

- (void)resume;

- (void)seekTo:(int)t;

- (BOOL)nextSource;

@end
