//
//  RemoteLectureViewController.h
//  LecturePlayer
//
//  Created by chao-chih lin on 12/6/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxSDK/DropboxSDK.h"

@class DetailViewController;

@interface RemoteLectureViewController : UITableViewController<DBRestClientDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) DetailViewController* detailViewController;

@end
