//
//  Lecture.h
//  LecturePlayer
//
//  Created by chao-chih lin on 12/6/2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lecture : NSObject
{
    NSString* _title;
    NSMutableArray* _slides;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSMutableArray* slides;

- (id) initWithTitle:(NSString*)title lectureFolder:(NSString*)folder;

@end
