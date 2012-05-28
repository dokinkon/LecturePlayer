//
//  DetailViewController.h
//  LecturePlayer
//
//  Created by chao-chih lin on 12/5/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

- (IBAction)playButtonPressed:(id)sender;
- (IBAction)progressSliderMoved:(id)sender;
- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)prevButtonPressed:(id)sender;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) NSString* bstFilePath;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (strong, nonatomic) IBOutlet UIButton* playButton;

@property (strong, nonatomic) IBOutlet UISlider* progressBar;

@property (strong, nonatomic) IBOutlet UILabel* currentTimeLabel;

@end
