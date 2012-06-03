//
//  LectureDetailViewController.h
//  LecturePlayer
//
//  Created by chao-chih lin on 12/6/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Lecture;
@class DetailViewController;
@interface LectureDetailViewController : UITableViewController
{
    Lecture* _lecture;
    DetailViewController* _detailViewController;
}
- (void)setLecture:(Lecture*)lecture;
- (void)setDetailViewController:(DetailViewController*)controller;
@end
