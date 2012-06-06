//
//  DetailViewController.h
//  LecturePlayer
//
//  Created by chao-chih lin on 12/5/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Lecture;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

- (void)setLecture:(Lecture*)lecture withSlideIndex:(int)slideIndex;

- (IBAction)progressSliderMoved:(id)sender;

- (IBAction)playButtonPressed:(id)sender;
- (IBAction)stopButtonPressed:(id)sender;
- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)prevButtonPressed:(id)sender;

@property (strong, nonatomic) id detailItem;

//@property (strong, nonatomic) NSString* bstFilePath;
@property (strong, nonatomic) Lecture* lecture;

@property (strong, nonatomic) IBOutlet UIButton* stopButton;
@property (strong, nonatomic) IBOutlet UIButton* playButton;
@property (strong, nonatomic) IBOutlet UIButton* nextButton;
@property (strong, nonatomic) IBOutlet UIButton* prevButton;

@property (strong, nonatomic) IBOutlet UISlider* progressBar;

@property (strong, nonatomic) IBOutlet UILabel* currentTimeLabel;

@end
