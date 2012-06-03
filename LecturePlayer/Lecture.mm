//
//  Lecture.m
//  LecturePlayer
//
//  Created by chao-chih lin on 12/6/2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Lecture.h"
#import "Slide.h"
#import "TPlayerMainForm.h"
#include <string>
#include <vector>
#include <map>

using namespace std;

@implementation Lecture

@synthesize title = _title;
@synthesize slides = _slides;



- (id)initWithTitle:(NSString*)lectureTitle lectureFolder:(NSString*)lectureFolder
{
    if ((self = [super init])!=nil) {
        _title = [[NSString stringWithString:lectureTitle] retain];
        _slides = [[NSMutableArray alloc] initWithCapacity:3];
        
        NSString* filePath = [NSString stringWithFormat:@"%@/%@/publish.xml",lectureFolder, lectureTitle];
        
        // Load Publish.xml
        std::vector<std::string> trackTitles;
        std::vector<int> trackTimes;
        std::vector<std::string> trackFileNames;
        std::map<std::string, std::string> publishInfo;
        TPlayerMainForm tp;
        if (tp.LoadPublishFile([filePath cStringUsingEncoding:NSUTF8StringEncoding], 
                                   trackTitles,
                                   trackTimes,
                                   trackFileNames,
                               publishInfo,true)) {
            
            for (size_t i=0;i<trackTitles.size();++i) {
                NSString* title = [NSString stringWithCString:trackTitles[i].c_str() encoding:NSUTF8StringEncoding];
                NSLog(@"TRACK TITLE:%@", title);
                Slide* slide = [[Slide alloc] init];
                slide.title = title;
                slide.duration = trackTimes[i];
                slide.filePath = [NSString stringWithFormat:@"%@/%@/%s", lectureFolder, lectureTitle, trackFileNames[i].c_str()];
                [_slides addObject:slide];
                [slide release];
            }
            
            /*
            map<string, string>::const_iterator it = publishInfo.begin();
            for (;it!=publishInfo.end();++it) {
                string key = it->first;
                string value = it->second;
                NSLog(@"[%@:%@]", 
                      [NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding],
                      [NSString stringWithCString:value.c_str() encoding:NSUTF8StringEncoding]);
            }
            */
        }//
    }
    return self;
}

- (void)dealloc
{
    [_title release];
    [_slides release];
    [super dealloc];
}

@end
