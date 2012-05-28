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

+ (void)initFFEngine;

- (BOOL)play:(NSString*)fileName;

- (void)stop;

@end
