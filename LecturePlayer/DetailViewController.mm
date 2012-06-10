//
//  DetailViewController.m
//  LecturePlayer
//
//  Created by chao-chih lin on 12/5/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "TPlayerMainForm.h"
#import "PlayObject.h"
#import "AudioPlayer.h"
#import "Lecture.h"
#import "Slide.h"

/*!
 * \brief:
 */
int TickTimeToAudioIndex(int tick) 
{
    //1. convert tick time as second
    int sec = tick / 100;
    
    //2. convert second to audio index
    return sec / 10;
}

NSString* FormatTickTime(int tick)
{
    int totalSec = tick / 100;
    int totalMin = totalSec / 60;
    int hour = totalSec / (60*60);
    int min = totalMin % 60;
    int sec = totalSec % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
}

@interface DetailViewController () 
{
    TPlayerMainForm* _playerMainForm;
    NSTimer* _timer;
    
    UIView* _sceneRootView;
    UIImageView* _cursorView; // for mouse cursor (pen)
    UIImageView* _canvasView; // for drawing
    NSMutableArray* _sceneImageViews;
    UIAlertView* _busyIndicator;
    CGPoint _currDrawLocation;
    CGPoint _prevDrawLocation;
    UIColor* _penColor;
    CGFloat _penSize;
    
    UIImage* _pauseImage;
    UIImage* _playImage;
    
    int _totalScriptTime;
    BOOL _isPlaying;
    BOOL _isStarted;
    BOOL _hasLectureLoaded;
    int _countTime;
    int _slideIndex;
    
    AudioPlayer* _audioPlayer;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)createSceneRootView;
- (void)removeSceneRootView;
- (void)createSceneImages;
- (void)removeSceneImages;
- (void)createCanvasView;
- (void)createCursorView;
- (void)doStart;
- (void)doStop;
- (void)update;
- (void)doActionSystemSetPictureVisible;
- (void)doActionSystemSetPictureUseScene;
- (void)doActionSceneDraw;
- (void)doActionSceneMouseMove;
- (void)doActionBeginPen;
- (void)doActionSystemEnd;

/*!
 *
 */
- (BOOL)loadSlide:(NSString*)fileName;

/*!
 * \brief Get drawing location from params
 */
- (void)doGetDrawLocation;

- (void)doEndFluorOpen;
- (void)doOnFluorOpen;
- (void)doBeginFluorOpen;

- (void)setPaintAttributes;
- (NSString*)getActionParameter:(int)index;

- (void)showBusyIndicator;
- (void)hideBusyIndicator;

- (void)dumpResourceRefNames;
- (NSString*)getAudioFileName:(int)index;
- (int)getAudioListSize;
@end

@implementation DetailViewController

//@synthesize detailItem = _detailItem;
@synthesize lecture = _lecture;
@synthesize currentTimeLabel = _currentTimeLabel;
@synthesize totalTimeLabel   = _totalTimeLabel;
@synthesize masterPopoverController = _masterPopoverController;

@synthesize playButton = _playButton;
@synthesize stopButton = _stopButton;
@synthesize nextButton = _nextButton;
@synthesize prevButton = _prevButton;

@synthesize seekBar = _seekBar;

- (void)dealloc
{
    [_currentTimeLabel release];
    [_totalTimeLabel release];
    [_masterPopoverController release];
    
    [_playButton release];
    [_stopButton release];
    [_nextButton release];
    [_prevButton release];
    
    [_seekBar release];
    [_audioPlayer release];
    
    [_playImage release];
    [_pauseImage release];
    
    delete _playerMainForm;
    _playerMainForm = NULL;
    
    [super dealloc];
}

- (void)createCanvasView
{
    CGSize s = self.view.frame.size;
    CGRect f = CGRectMake(0, 0, s.width, s.height);
    _canvasView = [[UIImageView alloc] initWithImage:nil];
    _canvasView.frame = f;
    [_sceneRootView addSubview:_canvasView];
}

- (void)createCursorView
{
    UIImage* image = [UIImage imageNamed:@"pen.png"];
    assert(image);
    _cursorView = [[UIImageView alloc] initWithImage:image];
    [_sceneRootView addSubview:_cursorView];
    
    // let root to handle her lifecycle
    [_cursorView release];
}

- (IBAction)nextButtonPressed:(id)sender
{
    NSLog(@"[DV] NextButtonPressed:");
    [self doNextSlide:NO];
}

- (IBAction)prevButtonPressed:(id)sender
{
    NSLog(@"[DV] PrevButtonPressed:");
    [self doPrevSlide:NO];
}

- (IBAction)playButtonPressed:(id)sender
{
    NSLog(@"[DV] PLAY BUTTON PRESSED");
    if (!_isStarted) {
        [self doStart];
    } else {
        if (_isPlaying) {
            [self doPause];
        } else {
            [self doResume];
        }
    }
}

- (IBAction)stopButtonPressed:(id)sender
{
    if (_isStarted)
        [self doStop];
}

- (IBAction)progressSliderMoved:(id)sender
{
    UISlider* s = (UISlider*)sender;
    int val = s.value;
    //_playerMainForm->PlayObject->script->GotoTime(val);
    [self doSeekTime:val];
    _countTime = val;
    //[_audioPlayer stop];
    NSLog(@"[DV] SEEK TO:%d", val);
}

- (int)getAudioListSize
{
    return _playerMainForm->PlayObject->audio_playlist.size();
}

- (NSString*)getAudioFileName:(int)index
{
    std::vector<std::string>& playList = _playerMainForm->PlayObject->audio_playlist;
    if (index >= playList.size()) {
        NSLog(@"[DV][ERROR] audio index out of range");
        return nil;
    }
    
    return [NSString stringWithCString:playList[index].c_str() encoding:NSUTF8StringEncoding];
}

- (void)doSeekTime:(int)tickTime
{
    if (tickTime < 0 || tickTime > _totalScriptTime) 
        return;
    
    [_audioPlayer pause];
    
    _canvasView.image = nil;
    [self playScriptCommandsUntilTime:tickTime fromHead:YES];
    _countTime = tickTime;
    [self updateTimeInfo];
}

- (void)doStart
{
    if (!_lecture) {
        return;
    }
    
    if (_isStarted)
        return;
    
    [_audioPlayer play];
    _playerMainForm->PlayObject->script->GotoBegin();
    _playerMainForm->PlayObject->script->NextAction(_playerMainForm->PlayObject->action);
    _countTime = 0;
    _isStarted = YES;
    
    [self doResume];
    NSLog(@"[DV] START");
}

- (void)doResume
{
    if (!_isStarted)
        return;
    if (_isPlaying)
        return;
    
    [_audioPlayer resume];
    [self.playButton setImage:_pauseImage forState:UIControlStateNormal];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(update) userInfo:nil repeats:YES];
    _isPlaying = YES;
    NSLog(@"[DV] RESUME");
}

- (void)doPause
{
    if (!_isStarted || !_isPlaying)
        return;
    
    _isPlaying = NO;
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    [_audioPlayer pause];
    
    [self.playButton setImage:_playImage forState:UIControlStateNormal];
    NSLog(@"[DV] PAUSE");
}

- (void)doStop
{
    [self doPause];
    
    _countTime = 0;
    
    //if (_hasLectureLoaded) {
        //_playerMainForm->PlayObject->script->GotoBegin();
    //}
    
    [_audioPlayer stop];
    _canvasView.image = nil;
    [self updateTimeInfo];
     _isPlaying = NO;
    _isStarted = NO;
    NSLog(@"[DV] STOP");
}

- (void)doPrevSlide:(BOOL)autoPlay
{
    if (!_lecture) 
        return;
    
    if (_slideIndex - 1 < 0) {
        [self displayAlert:@"提示" withMessage:@"前面沒有了"];
    } else {
        if ([self loadSlideWithIndex:_slideIndex-1]) {
            if (autoPlay) {
                [self doStart];
            }
        }
    }
}

- (void)doNextSlide:(BOOL)autoPlay
{
    if (!_lecture)
        return;
    
    if (_slideIndex + 1 < [_lecture.slides count]) {
        if ([self loadSlideWithIndex:_slideIndex+1]) {
            if (autoPlay) {
                [self doStart];
            }
        }
        //[self playSlidexIndex:_slideIndex+1];
    } else {
        [self displayAlert:@"提示" withMessage:@"課程完畢"];
    }    
}

- (NSString*)getActionParameter:(int)index
{
    vector<string>& params = _playerMainForm->PlayObject->action.Parameters;
    if (index >= params.size())
        return @"";
    return [NSString stringWithCString:params[index].c_str() encoding:NSUTF8StringEncoding];
}

- (void)setPaintAttributes
{
    _penSize = [[self getActionParameter:5] floatValue];
    if (_penColor) {
        [_penColor release];
    }
    
    int c = [[self getActionParameter:4] intValue];
    float r = c % 256; // 255
    float g = (c / 256) % 256; // 0
    float b = ((c / 256) / 256) % 256; // 0
    
    _penColor = [[UIColor alloc] initWithRed:r/255 green:g/255 blue:b/255 alpha:1.0f];
}

- (void)doGetDrawLocation
{
    _prevDrawLocation = _currDrawLocation;
    _currDrawLocation.x = [[self getActionParameter:0] floatValue];
    _currDrawLocation.y = [[self getActionParameter:1] floatValue];
    //NSLog(@"Draw.Loc:(%f, %f)", _drawLocation.x, _drawLocation.y);
}

- (void)doActionSystemSetPictureVisible
{
    // TODO
}

- (void)doActionSystemSetPictureUseScene
{
    // TODO
}

- (void)doActionSystemEnd
{
    NSLog(@"[DV] System.End");
    [self doStop];
    //[self doNextSlide];
}

- (void)doActionBeginPen
{
    [self setPaintAttributes];
}

- (void)doBeginFluorOpen
{
    [self setPaintAttributes];
}

- (void)doOnFluorOpen
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [_canvasView.image drawInRect:CGRectMake(0, 0, _canvasView.frame.size.width, _canvasView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), _penSize);
    
    CGFloat r, g, b, a;
    [_penColor getRed:&r green:&g blue:&b alpha:&a];
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), r, g, b, a);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), _prevDrawLocation.x, _prevDrawLocation.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), _currDrawLocation.x, _currDrawLocation.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    _canvasView.image = UIGraphicsGetImageFromCurrentImageContext();
    _canvasView.alpha = 0.7;
    UIGraphicsEndImageContext();
}

- (void)doEndFluorOpen
{
    
}

- (void)doActionSceneDraw
{
    NSString* param2 = [self getActionParameter:2];
    //NSLog(@"Sceen.Draw.%@", param2);
    if ([param2 isEqualToString:@"BeginPen"]) {
        // TODO
    } else if ([param2 isEqualToString:@"OnPen"]) {
        // TODO
    } else if ([param2 isEqualToString:@"EndPen"]) {
        // TODO
    } else if ([param2 isEqualToString:@"BeginFluoropen"]) {
        [self doBeginFluorOpen];
    } else if ([param2 isEqualToString:@"OnFluoropen"]) {
        [self doOnFluorOpen];
    } else if ([param2 isEqualToString:@"EndFluoropen"]) {
        [self doEndFluorOpen];
    } else if ([param2 isEqualToString:@"BeginEraser"]) {
    } else if ([param2 isEqualToString:@"OnEraser"]) {
    } else if ([param2 isEqualToString:@"EndEraser"]) {
    } else if ([param2 isEqualToString:@"EndText"]) {
    } else if ([param2 isEqualToString:@"BeginLine"]) {
    } else if ([param2 isEqualToString:@"OnLine"]) {
    } else if ([param2 isEqualToString:@"EndLine"]) {
    } else if ([param2 isEqualToString:@"BeginGeometryGraph"]) {
    } else if ([param2 isEqualToString:@"OnGeometryGraph"]) {
    } else if ([param2 isEqualToString:@"EndGeometryGraph"]) {
    } else if ([param2 isEqualToString:@"Clear"]) {
    } else {
        NSLog(@"[DV][COMMAND] Unknown Draw Command:%@", param2);
    }
}

- (void)doActionSceneMouseMove
{
    int x = [[self getActionParameter:0] intValue];
    int y = [[self getActionParameter:1] intValue];
    CGRect rect = _cursorView.frame;
    rect.origin = CGPointMake(x, y);
    _cursorView.frame = rect;
}

- (void)playScriptCommandsUntilTime:(int)tickTime fromHead:(BOOL)fromHead
{
    if (!_isPlaying) {
        return;
    }
    
    if (fromHead) {
        _playerMainForm->PlayObject->script->GotoBegin();
    }
    
    int actionTime = _playerMainForm->PlayObject->script->QueryTime();
    while (actionTime < tickTime) {
        NSString* action = [NSString stringWithCString:_playerMainForm->PlayObject->action.Action.c_str() encoding:NSUTF8StringEncoding];
        
        if ([action isEqualToString:@"System.SetPictureVisible"]) {
            [self doActionSystemSetPictureVisible];
        } else if ([action isEqualToString:@"System.SetPictureUseScene"]) {
            [self doActionSystemSetPictureUseScene];
        } else if ([action isEqualToString:@"Scene.MouseMove"]) {
            [self doActionSceneMouseMove];
        } else if ([action isEqualToString:@"Scene.Draw"]) {
            [self doGetDrawLocation];
            [self doActionSceneDraw];
        } else if ([action isEqualToString:@"System.End"]) {
            [self doActionSystemEnd];
            break;
        }
        
        //NSLog(@"TIME:%d ACTION:%@",actionTime, action);
        _playerMainForm->PlayObject->script->NextAction(_playerMainForm->PlayObject->action);
        actionTime = _playerMainForm->PlayObject->script->QueryTime();
    }
}

- (void)update
{
    if (!_isPlaying)
        return;
    
    [self playScriptCommandsUntilTime:_countTime fromHead:NO];
    
    _countTime += 1;
    [self updateTimeInfo];
    //NSLog(@"NEXT TIME:%d", actionTime);
}

- (void)showBusyIndicator
{
    if (_busyIndicator)
        return;
    _busyIndicator = [[UIAlertView alloc] initWithTitle:@"請稍候..."
                                                message:nil
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:nil];
    [_busyIndicator show];
    
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]
                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(_busyIndicator.bounds.size.width/2,
                                   _busyIndicator.bounds.size.height-40);
    [indicator startAnimating];
    [_busyIndicator addSubview:indicator];
    [indicator release];
}
- (void)hideBusyIndicator
{
    if (!_busyIndicator)
        return;
    
    [_busyIndicator dismissWithClickedButtonIndex:0 animated:NO];
    _busyIndicator = nil;
}

#pragma mark - Managing the detail item

- (void)setLecture:(Lecture *)lecture withSlideIndex:(int)slideIndex
{
    [self doStop];
    
    if (_lecture == lecture && slideIndex == _slideIndex) {
        return;
    }
    
    _lecture = lecture;
    [self loadSlideWithIndex:slideIndex];
    //[self doStop];
    
    //[self playSlidexIndex:slideIndex];
}

- (void)dumpResourceRefNames;
{
    vector<string> imageRefNames;
    _playerMainForm->PlayObject->resource->GetImageRefName(imageRefNames);

    NSLog(@"try to dump imageRefNames");
    for (size_t i=0;i<imageRefNames.size();++i) {
        NSString* s = [NSString stringWithCString:imageRefNames[i].c_str() encoding:NSUTF8StringEncoding];
        NSLog(@"%@", s);
    }
    
    NSLog(@"Dump Audios");
    for (size_t i=0;i<_playerMainForm->PlayObject->audio_playlist.size();++i) {
        NSString* s = [NSString stringWithCString:_playerMainForm->PlayObject->audio_playlist[i].c_str() encoding:NSUTF8StringEncoding];
        NSLog(@"%@", s);
    }
}

using std::string;

- (void)createSceneRootView
{
    _sceneRootView = [[UIView alloc] initWithFrame:CGRectMake(152, 54, 720, 540)];
    [self.view addSubview:_sceneRootView];
}

- (void)removeSceneRootView
{
    [_sceneRootView removeFromSuperview];
    [_sceneRootView release];
    _sceneRootView = nil;
}

- (void)createSceneImages
{
    _sceneImageViews = [[NSMutableArray alloc] init];
    std::vector<std::string> sceneInfos;
    _playerMainForm->getSceneInfo(sceneInfos);
    int i = 0;
    while (i < sceneInfos.size()) {
        NSString* imagePath = [NSString stringWithCString:sceneInfos[i].c_str() encoding:NSUTF8StringEncoding];
        
        if ([imagePath hasSuffix:@"png"] ||
            [imagePath hasSuffix:@"jpg"] ||
            [imagePath hasSuffix:@"bmp"] ||
            [imagePath hasSuffix:@"emf"])
        {
            int x = [[NSString stringWithCString:sceneInfos[i+1].c_str() encoding:NSUTF8StringEncoding] intValue];
            int y = [[NSString stringWithCString:sceneInfos[i+2].c_str() encoding:NSUTF8StringEncoding] intValue];
            int w = [[NSString stringWithCString:sceneInfos[i+3].c_str() encoding:NSUTF8StringEncoding] intValue];
            int h = [[NSString stringWithCString:sceneInfos[i+4].c_str() encoding:NSUTF8StringEncoding] intValue];
            
            string key = string([imagePath cStringUsingEncoding:NSUTF8StringEncoding]);
            unsigned char * buffer = _playerMainForm->PlayObject->resource->m_ImageBuffer[key].buffer;
            int size = _playerMainForm->PlayObject->resource->m_ImageBuffer[key].size;
            
            NSData* data = [NSData dataWithBytes:buffer length:size];
            UIImage* image = [UIImage imageWithData:data];
            assert(image);
            UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(x, y, w, h);
            [_sceneRootView addSubview:imageView];
            
            // keep these scene imageview, we will remove later.
            [_sceneImageViews addObject:imageView];
            i += 5;
        } else {
            i += 1;
        }
    }
}

- (void)removeSceneImages
{
    for (UIView* view in _sceneImageViews) {
        [view removeFromSuperview];
    }
    
    [_sceneImageViews release];
    _sceneImageViews = nil;
}

- (void)enableUIControls:(BOOL)enabled
{
    self.seekBar.enabled = enabled;
    self.playButton.enabled = enabled;
    self.stopButton.enabled = enabled;
    self.nextButton.enabled = enabled;
    self.prevButton.enabled = enabled;
}

- (BOOL)loadSlide:(NSString*)fileName
{
    [self enableUIControls:NO];
    [self doStop];
    if (_playerMainForm->LoadFile([fileName cStringUsingEncoding:NSUTF8StringEncoding])) {
        
        
        _hasLectureLoaded = YES;
        _totalScriptTime = _playerMainForm->PlayObject->script->m_TotalScriptTime;
        int t = [self getAudioListSize];
        
        NSLog(@"----------------------------------------------");
        NSLog(@"[DV] LOAD SLIDE SUCESSFUL");
        NSLog(@"[DV] TOTAL SCRIPT TIME:%@", FormatTickTime(_totalScriptTime));
        NSLog(@"[DV] TOTAL AUDIO SOURCES:%d", t);
        NSLog(@"[DV] ESTIMATE AUDIO TIME:%@", FormatTickTime(t*10*100));
        NSLog(@"----------------------------------------------");
        
        NSMutableArray* sources = [NSMutableArray arrayWithCapacity:3];
        for (int i=0;i<t;++i) {
            [sources addObject:[self getAudioFileName:i]];
        }
        _audioPlayer.sourceNames = sources;
        
        self.seekBar.minimumValue = 0;
        self.seekBar.maximumValue = _totalScriptTime;
        self.totalTimeLabel.text = FormatTickTime(_totalScriptTime);
        [self enableUIControls:YES];
        return YES;
    }
    return NO;
}

- (void)displayAlert:(NSString*)title withMessage:(NSString*)message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (BOOL)loadSlideWithIndex:(int)index
{
    if (!_lecture) {
        [self displayAlert:@"錯誤" withMessage:@"請先選取課程投影片"];
        return NO;
    }
    
    if (index >= [_lecture.slides count]) {
        [self displayAlert:@"內部錯誤" withMessage:@"Index ouf of range"];
        return NO;
    }
    
    if (_isStarted) {
        [self doStop];
    }
    
    Slide* slide = (Slide*)[_lecture.slides objectAtIndex:index];
    if (![self loadSlide:slide.filePath]) {
        [self displayAlert:@"內部錯誤" withMessage:@""];
    }
    
    [self removeSceneRootView];
    [self removeSceneImages];
    [self createSceneRootView];
    [self createSceneImages];
    [self createCanvasView];
    [self createCursorView];
    _slideIndex = index;
    return YES;
}

- (BOOL)playSlidexIndex:(int)index
{
    if (_slideIndex != index) {
        if ([self loadSlideWithIndex:index]) {
            [self doStart];
            return YES;
        }
    } else {
        [self doStart];
        return YES;
    }
    return NO;
}

- (void)updateTimeInfo
{
    self.currentTimeLabel.text = FormatTickTime(_countTime);
    self.seekBar.value = _countTime;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.seekBar.value = 0.0f;
    self.seekBar.enabled = NO;
    self.playButton.enabled = NO;
    self.stopButton.enabled = NO;
    self.nextButton.enabled = NO;
    self.prevButton.enabled = NO;
    
    // Load Images
    _playImage = [[UIImage imageNamed:@"play_blue1.png"] retain];
    _pauseImage = [[UIImage imageNamed:@"pause_blue.png"] retain];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.playButton = nil;
    self.stopButton = nil;
    self.nextButton = nil;
    self.prevButton = nil;
    
    self.seekBar = nil;
    self.currentTimeLabel = nil;
    self.totalTimeLabel   = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _hasLectureLoaded = NO;
        _totalScriptTime = 0;
        self.title = @"LecturePlayer";//NSLocalizedString(@"Detail", @"Detail");
        _playerMainForm = new TPlayerMainForm;
        [AudioPlayer initFFEngine];
        _audioPlayer = [[AudioPlayer alloc] init];

    }
    return self;
}
							
#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"目錄";//NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
















