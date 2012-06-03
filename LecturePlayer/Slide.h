//
//  Slide.h
//  LecturePlayer
//
//  Created by chao-chih lin on 12/6/2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Slide : NSObject
{
    NSString* _title;
    NSString* _filePath;
    int _duration;
}
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* filePath;
@property (nonatomic, assign) int duration;


@end
