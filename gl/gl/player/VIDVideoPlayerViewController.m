//
//  VIDVideoPlayerViewController.m
//  Video360
//
//  Created by Jean-Baptiste Rieu on 24/05/13.
//  Copyright (c) 2013 Video360 Developper. All rights reserved.
//

#import "VIDVideoPlayerViewController.h"
#import "VIDGlkViewController.h"
#import "KNavgationView.h"
#import "Constants.h"
#import "AppInfo.h"
#define ONE_FRAME_DURATION 0.03

#define HIDE_CONTROL_DELAY 5.0f
#define DEFAULT_VIEW_ALPHA 0.6f


NSString * const kTracksKey         = @"tracks";
NSString * const kPlayableKey		= @"playable";
NSString * const kRateKey			= @"rate";
NSString * const kCurrentItemKey	= @"currentItem";
NSString * const kStatusKey         = @"status";

static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;

static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface VIDVideoPlayerViewController ()
{
    VIDGlkViewController *_glkViewController;
    VIDGlkViewController *_glkRightViewController;
    AVPlayerItemVideoOutput* _videoOutput;
    
    AVPlayerItem* _playerItem;
    dispatch_queue_t _myVideoOutputQueue;
	id _notificationToken;
    id _timeObserver;
    
    float mRestoreAfterScrubbingRate;
	BOOL seekToZeroBeforePlay;
    BOOL isFen;
    BOOL isPlaying;
    NSDateFormatter * _dateFormatter;//播放时间/总时间
    
}

@property (strong,nonatomic) AVPlayer* player;
@property (strong, nonatomic) KNavgationView    *navView;
@property(nonatomic,strong)UIImageView * playView;//操作栏
@property(nonatomic,strong)UIButton * playBtn;//播放/暂停
@property(nonatomic,strong)UISlider *videoSlider;//当前进度条
@property(nonatomic,strong)UIProgressView * videoProgress;//缓存条
@property(nonatomic,strong)UILabel * timeLabel;//当前时间/总时间
@property(nonatomic,strong) NSString * _totalTime;//转换后的播放时间


@property (nonatomic,strong)UIButton *secondPlayBtn;
@property (nonatomic,strong)UISlider *secondVideoSlider;
@property(nonatomic,strong)UILabel * secondtimeLabel;//当前时间/总时间

@end

@implementation VIDVideoPlayerViewController
@synthesize navView,_totalTime;


- (id)initWithUrl:(NSString*)url  local:(BOOL)isLocal Fen:(BOOL) fen;
{
    self=[super init];
    if (!self) {
        return nil;
    }
    [self setVideoURL:url];
    [self setIsVideoLocal:isLocal];
    isFen=fen;
    isPlaying=NO;
    
    
    return self;
}



-(void)viewDidLoad
{
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.view.transform =CGAffineTransformIdentity;
    self.view.center=CGPointMake(kDeviceWidth/2, kDeviceHeight/2);
    self.view.transform =CGAffineTransformMakeRotation(degreesToRadians(90));
    self.view.backgroundColor=[UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [self addBottomView];
    [self setupVideoPlaybackForURL:_videoURL];
    
    [self configureGLKView];
    
    [self configurePlayButton];
    
    [self configureControleBackgroundView];
    

    [self.view addSubview:self.navView];
  
    [self.view bringSubviewToFront:self.navView];
    
    [AppInfo showLoading:NO];
    
     [self isShowFen:isFen];
    
#if SHOW_DEBUG_LABEL
    self.debugView.hidden = NO;
#endif
}
//

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil)// 是否是正在使用的视图
    {
        // Add code to preserve data stored in the views that might be
        // needed later.
        
        // Add code to clean up other strong references to the view in
        // the view hierarchy.
        self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
    }
}

- (void)addBottomView
{
    self.playView.backgroundColor = [UIColor blackColor];
    self.playView.alpha=0.6;
    self.playView.userInteractionEnabled = YES;
    [self.view addSubview:self.playView];
    //播放/暂停
    [self.playBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(playButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.playView addSubview:self.playBtn];
    
    //second
    [self.secondPlayBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    [self.secondPlayBtn addTarget:self action:@selector(playButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.playView addSubview:self.secondPlayBtn];
    
    
    
    
    //缓存条
    //self.videoProgress.backgroundColor = [UIColor redColor];
    //[self.playView addSubview:self.videoProgress];
    
    //second
    //self.videoProgress.backgroundColor = [UIColor redColor];
    //[self.playView addSubview:self.secondProgressView];
    
    
    //当前进度条
     [self.playView addSubview:self.videoSlider];
    
    
    [self.videoSlider addTarget:self action:@selector(videoSlierChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self.videoSlider addTarget:self action:@selector(videoSlierChangeValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoSlider addTarget:self action:@selector(videoSlierChangeValueEnd:) forControlEvents:UIControlEventTouchUpOutside];
    [self.playView addSubview:self.secondVideoSlider];
    [self.secondVideoSlider addTarget:self action:@selector(videoSlierChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self.secondVideoSlider addTarget:self action:@selector(videoSlierChangeValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.secondVideoSlider addTarget:self action:@selector(videoSlierChangeValueEnd:) forControlEvents:UIControlEventTouchUpOutside];
    
    
    
    //自定义进度条滑块
    UIImage * imge =[UIImage imageNamed:@"tiao"];
    [_videoSlider setThumbImage:imge forState:UIControlStateHighlighted];
    [_videoSlider setThumbImage:imge forState:UIControlStateNormal];
    
    [_secondVideoSlider setThumbImage:imge forState:UIControlStateHighlighted];
    [_secondVideoSlider setThumbImage:imge forState:UIControlStateNormal];
    
    
    //当前时间/总时间
    [self.playView addSubview:self.timeLabel];
    [self.playView addSubview:self.secondtimeLabel];
    
    [self.view bringSubviewToFront:self.playView];
    
     [self isShowSecond:NO];
    

}

- (void)isShowSecond:(BOOL)isShow
{
    
    self.secondPlayBtn.hidden=!isShow;
   // self.secondProgressView.hidden=!isShow;
    self.secondtimeLabel.hidden=!isShow;
    self.secondVideoSlider.hidden=!isShow;
}
- (void)splitOneScreenFrame:(BOOL) isFen12
{
    if (isFen12)
    {
        self.playBtn.frame=CGRectMake(0, 0, 50, 50);
        self.videoProgress.frame=CGRectMake(55, 23,kDeviceHeight/2-100, 2);
        self.videoSlider.frame=CGRectMake(55, 23, kDeviceHeight/2-100, 2);
        self.timeLabel.frame=CGRectMake(kDeviceHeight/2-70, 30, 100, 20);
        [self isShowSecond:YES];
    }
    else
    {
        [self isShowSecond:NO];
        self.playBtn.frame=CGRectMake(0, 0, 50, 50);
        self.videoProgress.frame=CGRectMake(55, 23, kDeviceHeight-100, 2);
        self.videoSlider.frame=CGRectMake(55, 23, kDeviceHeight-100, 2);
        self.timeLabel.frame=CGRectMake(kDeviceHeight-70, 30, 100, 20);
    }
}




//当前进度条方法
- (void)videoSlierChangeValue:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSLog(@"value change:%.1f",slider.value);
    self.videoSlider.value=slider.value;
    self.secondVideoSlider.value=slider.value;
    [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.secondPlayBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.player pause];
    if (slider.value == 0.000000) {
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf.player play];
        }];
    }
}

//当前进度条方法
- (void)videoSlierChangeValueEnd:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSLog(@"value end:%.1f",slider.value);
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1);
    self.videoSlider.value=slider.value;
    self.secondVideoSlider.value=slider.value;
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        [weakSelf.player play];
        [weakSelf.playBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        [weakSelf.secondPlayBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    }];
}



//操作栏
-(UIImageView *)playView
{
    if (_playView==nil) {
        _playView = [[UIImageView alloc]initWithFrame:CGRectMake(0, kDeviceWidth-50,kDeviceHeight, 50)];
    }
    
    return _playView;
}
//播放/暂停
-(UIButton *)playBtn
{
    if (_playBtn ==nil) {
        _playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    }
    
    return _playBtn;
}
//缓存条
-(UIProgressView *)videoProgress
{
    if (_videoProgress ==nil) {
        _videoProgress  = [[UIProgressView alloc]initWithFrame:CGRectMake(55, 23, kDeviceHeight-100,4)];
        _videoProgress.progressTintColor=kColor_Selected_Color;
    }
    
    return _videoProgress;
}
//当前进度条
-(UISlider *)videoSlider
{
    if (_videoSlider==nil) {
        _videoSlider = [[UISlider alloc]initWithFrame:CGRectMake(55, 0, kDeviceHeight-100, 50)];
        //_videoSlider.continuous = YES;
        _videoSlider.minimumTrackTintColor=kColor_Selected_Color;
    }
    
    return _videoSlider;
}

//当前时间/总时间
-(UILabel *)timeLabel
{
    if (_timeLabel ==nil) {
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(kDeviceHeight-70, 30, 100, 20)];
        self.timeLabel.text = @"00:00/00:00";
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.font = [UIFont systemFontOfSize:10];
    }
    
    return _timeLabel;
}


- (UIButton *)secondPlayBtn
{
    if (!_secondPlayBtn) {
        _secondPlayBtn=[[UIButton alloc]initWithFrame:CGRectMake(kDeviceHeight/2, 0, 50, 50)];
        //_secondPlayBtn.backgroundColor=[UIColor greenColor];
    }
    return _secondPlayBtn;
}

- (UISlider *)secondVideoSlider
{
    if (!_secondVideoSlider) {
        _secondVideoSlider=[[UISlider alloc]initWithFrame:CGRectMake(kDeviceHeight/2+55, -1, kDeviceHeight/2-100, 50)];
        _secondVideoSlider.minimumTrackTintColor=kColor_Selected_Color;
        //_secondVideoSlider.continuous = YES;
    }
    return _secondVideoSlider;
}



- (UILabel *)secondtimeLabel
{
    if (!_secondtimeLabel) {
        _secondtimeLabel=[[UILabel  alloc]initWithFrame:CGRectMake(kDeviceHeight/2+kDeviceHeight/2-70, 30, 100, 20)];
        _secondtimeLabel.text = @"00:00/00:00";
        _secondtimeLabel.textColor = [UIColor whiteColor];
        _secondtimeLabel.font = [UIFont systemFontOfSize:10];
    }
    return _secondtimeLabel;
}





//

- (UIView *)navView
{
    if (!navView) {
        navView=[[KNavgationView alloc]initWithFrame:CGRectMake(0, 0, kDeviceHeight, 44) Targat:self DisSEL:@"goBack"FenSEL:@"dosplitScreen" MotionSEL:@"motionAction"];
    }
    return navView;
}

- (void)goBack
{

        [[AppInfo instance]cancelHttpMethods];
    [self removeAll];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (void)removeAll
{
    [AppInfo hideLoading];
    [_player pause];
    @try{
        [self removePlayerTimeObserver];
        [_playerItem removeObserver:self forKeyPath:kStatusKey];
        [_player removeObserver:self forKeyPath:kCurrentItemKey];
        [_player removeObserver:self forKeyPath:kRateKey];
        [_playerItem removeOutput:_videoOutput];
    }@catch(id anException){
        //do nothing
    }
    
    
    
    [_glkViewController removeDealloc];
    [_glkRightViewController removeDealloc];
    [_glkViewController removeFromParentViewController];
    [_glkRightViewController removeFromParentViewController];
    _glkViewController = nil;
    _glkRightViewController=nil;
    _videoOutput = nil;
    _playerItem = nil;
    _player = nil;
    
  
    navView=nil;
    _playView=nil;
    _playBtn=nil;
    _videoSlider=nil;
    _videoProgress=nil;
    _timeLabel=nil;
    _totalTime=nil;
    _secondVideoSlider=nil;
    _secondPlayBtn=nil;
    _secondtimeLabel=nil;
}



- (void)dosplitScreen
{
    navView.changeBtn.selected=!isFen;

    [self isShowFen:!isFen];
    
    [self splitOneScreenFrame:!isFen];
    isFen=!isFen;
}

- (void)isShowFen:(BOOL)isFenScreen
{
    if (isFenScreen) {
        
        _glkViewController.view.frame=CGRectMake(0, kDeviceWidth/4, kDeviceHeight/2, kDeviceWidth/2);
        
        _glkRightViewController.view.frame=CGRectMake(kDeviceHeight/2, kDeviceWidth/4, kDeviceHeight/2, kDeviceWidth/2);
        //_glkRightViewController.view.hidden=NO;
        _glkRightViewController.fingerRotationX=_glkViewController.mfingerRotationX;
         _glkRightViewController.fingerRotationY=_glkViewController.mfingerRotationY;
        [_glkViewController startDeviceMotion];
        [_glkRightViewController startDeviceMotion];
    
        
     
//         _glkRightViewController.view.frame=CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, self.view.frame.size.width/2, self.view.frame.size.height/2);
    }
    else
    {
        _glkRightViewController.fingerRotationX=_glkViewController.mfingerRotationX;
        _glkRightViewController.fingerRotationY=_glkViewController.mfingerRotationY;
        _glkViewController.view.frame=self.view.bounds;
        //_glkRightViewController.view.hidden=YES;
        [_glkViewController stopDeviceMotion];
        [_glkRightViewController stopDeviceMotion];
    }
    _glkViewController.isFen=isFenScreen;
    _glkRightViewController.isFen=isFenScreen;
}

- (void)motionAction
{
    if (isFen) {
        return;
    }
    if(_glkViewController.isUsingMotion)
    {

        [_glkViewController stopDeviceMotion];
         [_glkRightViewController stopDeviceMotion];
    }else{

        [_glkViewController startDeviceMotion];
        [_glkRightViewController startDeviceMotion];
    }
    
    
    self.navView.motionBtn.selected=_glkViewController.isUsingMotion;
}


- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self pause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self updatePlayButton];
    [_player seekToTime:[_player currentTime]];
}


-(void)dealloc
{
    NSLog(@"%@",self.description);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _myVideoOutputQueue=nil;
    

}



-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    

}

-(void)viewWillAppear:(BOOL)animated
{
    [self updatePlayButton];
}

#pragma mark video communication

- (CVPixelBufferRef) retrievePixelBufferToDraw
{
    CVPixelBufferRef pixelBuffer = [_videoOutput copyPixelBufferForItemTime:[_playerItem currentTime] itemTimeForDisplay:nil];
    
    return pixelBuffer;
}

#pragma mark video setting

-(void)setupVideoPlaybackForURL:(NSString*)url
{
    
	NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
	_videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
	_myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
	[_videoOutput setDelegate:self queue:_myVideoOutputQueue];
    
    _player = [[AVPlayer alloc] init];
    
    // Do not take mute button into account
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory:AVAudioSessionCategoryPlayback
                    error:&error];
    if (!success) {
        NSLog(@"Could not use AVAudioSessionCategoryPlayback", nil);
    }
    
    
    NSString *newPlayUrl=[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *urlplay;
    if (_isVideoLocal) {
        urlplay=[NSURL fileURLWithPath:newPlayUrl];
    }
    else
    {
        urlplay=[NSURL URLWithString:newPlayUrl];
    }
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:urlplay options:nil];
    
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[[asset URL] path]]) {
        NSLog(@"file does not exist");
    }
    
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
    
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        
        dispatch_async( dispatch_get_main_queue(),
                       ^{
                           /* Make sure that the value of each key has loaded successfully. */
                           for (NSString *thisKey in requestedKeys)
                           {
                               NSError *error = nil;
                               AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
                               if (keyStatus == AVKeyValueStatusFailed)
                               {
                                   [self assetFailedToPrepareForPlayback:error];
                                   return;
                               }
                           }
                           
                           NSError* error = nil;
                           AVKeyValueStatus status = [asset statusOfValueForKey:kTracksKey error:&error];
                           if (status == AVKeyValueStatusLoaded)
                           {
                               _playerItem = [AVPlayerItem playerItemWithAsset:asset];
                               
                               
                               [_playerItem addOutput:_videoOutput];
                               [_player replaceCurrentItemWithPlayerItem:_playerItem];
                               [_videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ONE_FRAME_DURATION];
                               
                               /* When the player item has played to its end time we'll toggle
                                the movie controller Pause button to be the Play button */
                               [[NSNotificationCenter defaultCenter] addObserver:self
                                                                        selector:@selector(playerItemDidReachEnd:)
                                                                            name:AVPlayerItemDidPlayToEndTimeNotification
                                                                          object:_playerItem];
                               
                               seekToZeroBeforePlay = NO;
                               
                               [_playerItem addObserver:self
                                             forKeyPath:kStatusKey
                                                options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                                context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
                               
                               [_player addObserver:self
                                         forKeyPath:kCurrentItemKey
                                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                            context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
                               
                               [_player addObserver:self
                                         forKeyPath:kRateKey
                                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                            context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
                               
                               
                               //[self initScrubberTimer];
                               
                              // [self syncScrubber];
                               [self play];
                               
                           }
                           else
                           {
                               NSLog(@"%@ Failed to load the tracks.", self);
                           }
                       });
    }];
}

#pragma mark rendering glk view management
-(void)configureGLKView
{

    
    
    _glkRightViewController = [[VIDGlkViewController alloc] init];
    
    _glkRightViewController.videoPlayerController = self;
    
    [self.view insertSubview:_glkRightViewController.view belowSubview:_playView];
    [self addChildViewController:_glkRightViewController];
    [_glkRightViewController didMoveToParentViewController:self];
    NSLog(@"self.view.frame.size.width====%f  height==%f",self.view.frame.size.width,self.view.frame.size.height);
    NSLog(@"%f  ,     %f",kDeviceWidth,kDeviceHeight);
    _glkRightViewController.view.frame=CGRectMake(kDeviceHeight/2, kDeviceWidth/4, kDeviceHeight/2, kDeviceWidth/2);
      //_glkRightViewController.view.hidden=YES;
    //_glkViewController.view.backgroundColor=[UIColor redColor];
    
    
    _glkViewController = [[VIDGlkViewController alloc] init];
    
    _glkViewController.videoPlayerController = self;
    
    [self.view insertSubview:_glkViewController.view belowSubview:_playView];
    [self addChildViewController:_glkViewController];
    [_glkViewController didMoveToParentViewController:self];
    
    _glkViewController.view.frame = self.view.bounds;
    
    
    // [self ]    //_glkRightViewController.view.frame = self.view.bounds;
}




#pragma mark play button management
-(void)configurePlayButton
{
    
    self.playBtn.backgroundColor = [UIColor clearColor];
    self.playBtn.showsTouchWhenHighlighted = YES;
    self.secondPlayBtn.backgroundColor = [UIColor clearColor];
    self.secondPlayBtn.showsTouchWhenHighlighted = YES;
    [self disablePlayerButtons];
    
    [self updatePlayButton];
}

- (void)playButtonTouched{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if([self isPlaying]){
        [self pause];
    }else{
        [self play];
    }
}

- (void) updatePlayButton
{
    
    [self.playBtn setImage:[UIImage imageNamed:[self isPlaying] ? @"stop" : @"play"]
                 forState:UIControlStateNormal];
    [self.secondPlayBtn setImage:[UIImage imageNamed:[self isPlaying] ? @"stop" : @"play"]
                  forState:UIControlStateNormal];
}

-(void) play
{
//    if ([self isPlaying])
//        return;
    isPlaying=YES;
    /* If we are at the end of the movie, we must seek to the beginning first
     before starting playback. */
    if (YES == seekToZeroBeforePlay)
    {
        seekToZeroBeforePlay = NO;
        [_player seekToTime:kCMTimeZero];
    }
    
    [self updatePlayButton];
    [_player play];
    
    [self scheduleHideControls];
}

- (void) pause
{
//    if (![self isPlaying])
//        return;
    isPlaying=NO;
    [self updatePlayButton];
    [_player pause];
    
    [self scheduleHideControls];
}








#pragma mark controls management

-(void)enablePlayerButtons
{
    self.playBtn.enabled = YES;
    self.secondPlayBtn.enabled = YES;
}

-(void)disablePlayerButtons
{
    self.playBtn.enabled = NO;
    self.secondPlayBtn.enabled = NO;
}
-(void)configureControleBackgroundView
{
    
    
}

-(void) toggleControls
{
    if(self.playView.hidden){
        [self showControlsFast];
    }else{
        [self hideControlsFast];
    }
    
    
    [self scheduleHideControls];
}

-(void) scheduleHideControls
{
    if(!self.playView.hidden)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(hideControlsSlowly) withObject:nil afterDelay:HIDE_CONTROL_DELAY];
    }
}

-(void) hideControlsWithDuration:(NSTimeInterval)duration
{
    self.playView.alpha = DEFAULT_VIEW_ALPHA;
    self.navView.alpha=DEFAULT_VIEW_ALPHA;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         
                         self.playView.alpha = 0.0f;
                         self.navView.alpha=0;
                     }
                     completion:^(BOOL finished){
                         if(finished)
                             self.playView.hidden = YES;
                         self.navView.hidden=YES;
                     }];
    
}

-(void) hideControlsFast
{
    [self hideControlsWithDuration:0.2];
}

-(void) hideControlsSlowly
{
    [self hideControlsWithDuration:1.0];
}

-(void) showControlsFast
{
    self.playView.alpha = 0.0;
    
    self.playView.hidden = NO;
    self.navView.hidden=NO;
    self.navView.alpha=0.0;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         
                         self.playView.alpha = DEFAULT_VIEW_ALPHA;
                         self.navView.alpha=DEFAULT_VIEW_ALPHA;
                     }
                     completion:nil];
}

- (void)removeTimeObserverFro_player
{
    if (_timeObserver)
    {
        [_player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}


#pragma mark slider progress management




- (CMTime)playerItemDuration
{
    
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        /*
         NOTE:
         Because of the dynamic nature of HTTP Live Streaming Media, the best practice
         for obtaining the duration of an AVPlayerItem object has changed in iOS 4.3.
         Prior to iOS 4.3, you would obtain the duration of a player item by fetching
         the value of the duration property of its associated AVAsset object. However,
         note that for HTTP Live Streaming Media the duration of a player item during
         any particular playback session may differ from the duration of its asset. For
         this reason a new key-value observable duration property has been defined on
         AVPlayerItem.
         
         See the AV Foundation Release Notes for iOS 4.3 for more information.
         */
        
        return([_playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}





/* The user is dragging the movie controller thumb to scrub through the movie. */



- (BOOL)isScrubbing
{
    return mRestoreAfterScrubbingRate != 0.f;
}



- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    
    /* AVPlayerItem "status" property value observer. */
    if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext)
    {
        [self updatePlayButton];
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                [self removePlayerTimeObserver];
                //[self syncScrubber];
                
                               [self disablePlayerButtons];
                [AppInfo hideLoading];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                //[self initScrubberTimer];
                
                
                [self enablePlayerButtons];
                [AppInfo hideLoading];
                CMTime duration = _playerItem.duration;// 获取视频总长度
                CGFloat totalSecond = _playerItem.duration.value / _playerItem.duration.timescale;// 转换成秒
                _totalTime = [self convertTime:totalSecond];// 转换成播放时间
                 [self monitoringPlayback:_playerItem];// 监听播放状态
                self.videoSlider.maximumValue = CMTimeGetSeconds(duration);
                self.secondVideoSlider.maximumValue = CMTimeGetSeconds(duration);

      
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
                [AppInfo hideLoading];
                NSLog(@"Error fail : %@", playerItem.error);
            }
                break;
        }
    }else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext)
    {
        [self updatePlayButton];
       // NSLog(@"AVPlayerDemoPlaybackViewControllerRateObservationContext");
    }
    /* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
    else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext)
    {
        //NSLog(@"AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext");
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}
//监听播放状态执行方法
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    __weak typeof(self) weakSelf = self;
    static BOOL hasAddOb = NO;
    
    if (!hasAddOb) {
        _timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
            CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
            //            NSLog(@"%.2f  ==  %@",currentSecond,playerItem);
            
            
            [weakSelf.videoSlider setValue:currentSecond animated:YES];
            [weakSelf.secondVideoSlider setValue:currentSecond animated:YES];
            NSString *timeString = [weakSelf convertTime:currentSecond];
            weakSelf.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeString,weakSelf._totalTime];
            weakSelf.secondtimeLabel.text = [NSString stringWithFormat:@"%@/%@",timeString,weakSelf._totalTime];
        }];
        //        hasAddOb = !hasAddOb;
    }
    
}




//当前时间和总时间
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    
    NSString *showtimeNew = [_dateFormatter stringFromDate:d];
    return showtimeNew;
}
//dateFormatter懒加载 开辟空间
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
    }
    return _dateFormatter;
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    //[self syncScrubber];
    [self disablePlayerButtons];
    
    /* Display the error. */
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
//                                                        message:[error localizedFailureReason]
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//    [alertView show];
}



- (BOOL)isPlaying
{
    return isPlaying;
}

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    /* After the movie has played to its end time, seek back to time zero
     to play it again. */
    seekToZeroBeforePlay = YES;
}





/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
    if (_timeObserver)
    {
        [_player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}




@end
