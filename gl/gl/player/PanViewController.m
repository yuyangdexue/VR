//
//  PanViewController.m
//  gl
//
//  Created by Yuyangdexue on 15/9/1.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "PanViewController.h"
#import <Panframe/Panframe.h>
#import "KNavgationView.h"
#import "Constants.h"
#import "AppInfo.h"
#import <objc/runtime.h>
#define DEFAULT_VIEW_ALPHA 0.6f
#define HIDE_CONTROL_DELAY 5.0f
@interface PanViewController ()<PFAssetObserver, PFAssetTimeMonitor>

{
    PFView * pfView;
    id<PFAsset> pfAsset;
    enum PFNAVIGATIONMODE currentmode;
    bool touchslider;
    NSURL *videoUrl;
    NSTimer *slidertimer;
     NSDateFormatter * _dateFormatter;//播放时间/总时间

    
}
@property (strong, nonatomic) NSString *videoURL;
@property (assign, nonatomic) BOOL  isVideoLocal;
@property (strong, nonatomic) KNavgationView    *navView;
@property (assign, nonatomic) BOOL  isFen;

@property(nonatomic,strong)UIImageView * playView;//操作栏
@property(nonatomic,strong)UIButton * playBtn;//播放/暂停
@property(nonatomic,strong)UISlider *videoSlider;//当前进度条
@property(nonatomic,strong)UIProgressView * videoProgress;//缓存条
@property(nonatomic,strong)UILabel * timeLabel;//当前时间/总时间
@property(nonatomic,strong) NSString * _totalTime;//转换后的播放时间


@property (nonatomic,strong)UIButton *secondPlayBtn;
@property (nonatomic,strong)UISlider *secondVideoSlider;
@property(nonatomic,strong)UILabel * secondtimeLabel;//当前时间/总时间


- (void) onStatusMessage : (PFAsset *) asset message:(enum PFASSETMESSAGE) m;
- (void) onPlayerTime:(id<PFAsset>)asset hasTime:(CMTime)time;

@end

@implementation PanViewController

- (id)initWithUrl:(NSString*)url  local:(BOOL)isLocal Fen:(BOOL) fen
{
    self=[super init];
    if (!self) {
        return nil;
    }
    
    _isVideoLocal=isLocal;
    _isFen=fen;
  
    if (fen) {
        if (pfView) {
            [pfView setViewMode:3 andAspect:16.0/9.0];
        }
    }
    else
    {
        if (pfView) {
            [pfView setViewMode:0 andAspect:16.0/9.0];
        }
    }
    NSString *newPlayUrl=[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (_isVideoLocal) {
        videoUrl=[NSURL fileURLWithPath:newPlayUrl];
    }
    else
    {
        videoUrl=[NSURL URLWithString:newPlayUrl];
    }
    
//   [self createView];
//    

//    // create a Panframe asset
//    
//    
//    

    return self;
}

- (void)tryMemberFunc
{
    
    
    Class class=[pfAsset class];
    unsigned int numIvars; //成员变量个数
    Ivar *vars = class_copyIvarList(class, &numIvars);
    //Ivar *vars = class_copyIvarList([UIView class], &numIvars);
    
    NSString *key=nil;
    for(int i = 0; i < numIvars; i++) {
        
        Ivar thisIvar = vars[i];
        key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];  //获取成员变量的名字
        NSLog(@"variable name :%@", key);
        key = [NSString stringWithUTF8String:ivar_getTypeEncoding(thisIvar)]; //获取成员变量的数据类型
        NSLog(@"variable type :%@", key);
    }
    Method *meth = class_copyMethodList(class, &numIvars);
    //Method *meth = class_copyMethodList([UIView class], &numIvars);
    
    for(int i = 0; i < numIvars; i++) {
        Method thisIvar = meth[i];
        
        SEL sel = method_getName(thisIvar);
        const char *name = sel_getName(sel);
        
        NSLog(@"zp method :%s", name);
        
        
        
    }
    
}

- (UIView *)navView
{
    if (!_navView) {
        _navView=[[KNavgationView alloc]initWithFrame:CGRectMake(0, 0, kDeviceHeight, 44) Targat:self DisSEL:@"goBack"FenSEL:@"dosplitScreen" MotionSEL:@"motionAction"];
    }
    return _navView;
}


- (void)goBack
{
    if (slidertimer.isValid) {
        [slidertimer invalidate];
    }
    [[AppInfo instance]cancelHttpMethods];
    slidertimer=nil;
    [self deleteAsset];
    [self deleteView];
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (void)motionAction
{
    if (pfView != nil)
    {
        if (currentmode == PF_NAVIGATION_MOTION)
        {
            currentmode = PF_NAVIGATION_TOUCH;
             self.navView.motionBtn.selected=NO;
           
        }
        else
        {
            currentmode = PF_NAVIGATION_MOTION;
             self.navView.motionBtn.selected=YES;
           
        }
        [pfView setNavigationMode:currentmode];
    }
    
}

- (void)dosplitScreen
{
    _navView.changeBtn.selected=!_isFen;
    
    [self isShow:!_isFen];
    
    [self splitOneScreenFrame:!_isFen];
    _isFen=!_isFen;
}

- (void)isShow:(BOOL)fen
{
    if (fen) {
        if (pfView) {
            [pfView setViewMode:3 andAspect:16.0/9.0];
        }
    }
    else
    {
        if (pfView) {
            [pfView setViewMode:0 andAspect:16.0/9.0];
        }
    }
   
}



- (void) createHotspots
{
    // create some sample hotspots on the view and register a callback
    
    id<PFHotspot> hp1 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp2 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp3 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp4 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp5 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp6 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    
    [hp1 setCoordinates:0 andX:0 andZ:0];
    [hp2 setCoordinates:40 andX:5 andZ:0];
    [hp3 setCoordinates:80 andX:1 andZ:0];
    [hp4 setCoordinates:120 andX:-5 andZ:0];
    [hp5 setCoordinates:160 andX:-10 andZ:0];
    [hp6 setCoordinates:220 andX:0 andZ:0];
    
    [hp3 setSize:2];
    [hp3 setAlpha:0.5f];
    
    [hp1 setTag:1];
    [hp2 setTag:2];
    [hp3 setTag:3];
    [hp4 setTag:4];
    [hp5 setTag:5];
    [hp6 setTag:6];
    
    [hp1 addTarget:self action:@selector(onHotspot:)];
    [hp2 addTarget:self action:@selector(onHotspot:)];
    [hp3 addTarget:self action:@selector(onHotspot:)];
    [hp4 addTarget:self action:@selector(onHotspot:)];
    [hp5 addTarget:self action:@selector(onHotspot:)];
    [hp6 addTarget:self action:@selector(onHotspot:)];
}

- (void) onHotspot:(id<PFHotspot>) hotspot
{
    // log the hotspot triggered
    NSLog(@"Hotspot triggered. Tag: %d", [hotspot getTag]);
    
    // animate the hotspot to show the user it was clicked
    [hotspot animate];
}

- (void)addBottomView:(UIView *)bgView
{
    self.playView.backgroundColor = [UIColor blackColor];
    self.playView.alpha=0.6;
    self.playView.userInteractionEnabled = YES;
    [bgView addSubview:self.playView];
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
    [self.videoSlider addTarget:self action:@selector(videoSlierChangeValueUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoSlider addTarget:self action:@selector(videoSlierChangeValueUp:) forControlEvents:UIControlEventTouchUpOutside];
     [self.videoSlider addTarget:self action:@selector(videoSlierChangeValueDown:) forControlEvents:UIControlEventTouchDown];
    [self.playView addSubview:self.secondVideoSlider];
    [self.secondVideoSlider addTarget:self action:@selector(videoSlierChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self.secondVideoSlider addTarget:self action:@selector(videoSlierChangeValueUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.secondVideoSlider addTarget:self action:@selector(videoSlierChangeValueUp:) forControlEvents:UIControlEventTouchUpOutside];
    [self.secondVideoSlider addTarget:self action:@selector(videoSlierChangeValueDown:) forControlEvents:UIControlEventTouchDown];
    
    
    
    self.videoSlider.value=0;
    self.videoSlider.enabled=false;
    
    self.secondVideoSlider.value=0;
    self.secondVideoSlider.enabled=false;
    
    //自定义进度条滑块
    UIImage * imge =[UIImage imageNamed:@"tiao"];
    [_videoSlider setThumbImage:imge forState:UIControlStateHighlighted];
    [_videoSlider setThumbImage:imge forState:UIControlStateNormal];
    
    [_secondVideoSlider setThumbImage:imge forState:UIControlStateHighlighted];
    [_secondVideoSlider setThumbImage:imge forState:UIControlStateNormal];
    
    
    //当前时间/总时间
    [self.playView addSubview:self.timeLabel];
    [self.playView addSubview:self.secondtimeLabel];
    //self.playView.backgroundColor=[UIColor redColor];
    [bgView bringSubviewToFront:self.playView];
    
    currentmode = PF_NAVIGATION_MOTION;
    self.navView.motionBtn.selected=YES;
    self.navView.changeBtn.selected=_isFen;
    [self splitOneScreenFrame:_isFen];
    
    
}
-(void)onPlaybackTime:(NSTimer *)timer
{
    // retrieve the playback time from an asset and update the slider
    
    if (pfAsset == nil)
        return;
    if (!touchslider && [pfAsset getStatus] != PF_ASSET_SEEKING)
    {
        CMTime t = [pfAsset getPlaybackTime];
        
        _videoSlider.value = CMTimeGetSeconds(t);
        _secondVideoSlider.value = CMTimeGetSeconds(t);
        CGFloat currentSecond = t.value/t.timescale;// 计算当前在第几秒
 
        NSString *timeString = [self convertTime:currentSecond];
        self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeString,self._totalTime];
        self.secondtimeLabel.text = [NSString stringWithFormat:@"%@/%@",timeString,self._totalTime];
        

 
        
    }
}

- (void) createView
{
    
    // initialize an PFView
    self.view.backgroundColor=[UIColor whiteColor];
    UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kDeviceHeight, kDeviceWidth)];
    bgView.backgroundColor=[UIColor whiteColor];
    
    pfView = [PFObjectFactory viewWithFrame:CGRectMake(0, 0, kDeviceHeight, kDeviceWidth)];
    pfView.transform=CGAffineTransformIdentity;
    //pfView.backgroundColor=[UIColor greenColor];
    bgView.center=self.view.center;
    bgView.transform=CGAffineTransformMakeRotation(degreesToRadians(90));
    //    pfView.autoresizingMask = (UIViewAutore sizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    //[pfView setInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    // set the appropriate navigation mode PFView
    [pfView setNavigationMode:currentmode];
    
    [bgView addSubview:pfView];
    // [self ClassLog:[pfView class]];
    
    // pfView.center=self.view.center;
    // pfView.transform =CGAffineTransformMakeRotation(degreesToRadians(90));
    
    
    // set an optional blackspot image
    //[pfView setBlindSpotImage:@"blackspot.png"];
    [pfView setBlindSpotLocation:PF_BLINDSPOT_BOTTOM];
    
    
    
    // add the view to the current stack of views
    [self.view addSubview:bgView];
    [self.view sendSubviewToBack:bgView];
    
    //[pfView setViewMode:3 andAspect:16.0/9.0];
    
    
    // Set some parameters
    [self resetViewParameters];
    
    // start rendering the view
    [pfView run];
    
    [bgView addSubview:self.navView];
    [self addBottomView:bgView];
  
    
    if ([pfAsset getStatus] == PF_ASSET_ERROR)
        [self stop];
    else
        [pfAsset play];


    
   
    
}




- (void)singleTap
{
    [self toggleControls];
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




- (void)viewDidLoad {
    [super viewDidLoad];
    
     [[UIApplication sharedApplication] setStatusBarHidden:YES];
    slidertimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                   target: self
                                                 selector:@selector(onPlaybackTime:)
                                                 userInfo: nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [self createView];
    [self createHotspots];
    [self createAssetWithUrl:videoUrl];
    if ([pfAsset getStatus] == PF_ASSET_ERROR)
        [self stop];
    else
        [pfAsset play];
    [AppInfo showLoading:NO];
    
    
    UITapGestureRecognizer *tap2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap)];
    tap2.numberOfTapsRequired=1;
    tap2.numberOfTouchesRequired=1;
    pfView.userInteractionEnabled=YES;
    [pfView addGestureRecognizer:tap2];
    
     [self scheduleHideControls];
    // Do any additional setup after loading the view.
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if (pfAsset) {
        [pfAsset pause];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (pfAsset) {
        [pfAsset play];
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) resetViewParameters
{
    // set default FOV
    [pfView setFieldOfView:75.0f];
    
    // register the interface orientation with the PFView
    [pfView setInterfaceOrientation:UIInterfaceOrientationLandscapeRight];

}

- (void) deleteView
{
    // stop rendering the view
    [pfView halt];
    
    // remove and destroy view
    [pfView removeFromSuperview];
    pfView = nil;
}

- (void) createAssetWithUrl:(NSURL *)url
{
    touchslider = false;
    
    // load an PFAsset from an url
    pfAsset = (id<PFAsset>)[PFObjectFactory assetFromUrl:url observer:(PFAssetObserver*)self];
    [pfAsset setTimeMonitor:self];
    // connect the asset to the view
    [pfView displayAsset:(PFAsset *)pfAsset];
}

- (void) deleteAsset
{
    if (pfAsset == nil)
        return;
    
    // disconnect the asset from the view
    [pfAsset setTimeMonitor:nil];
    [pfView displayAsset:nil];
    // stop and destroy the asset
    [pfAsset stop];
    pfAsset  = nil;
}

- (void) onPlayerTime:(id<PFAsset>)asset hasTime:(CMTime)time
{
}



- (void) onStatusMessage : (id<PFAsset>) asset message:(enum PFASSETMESSAGE) m
{
    switch (m) {
        case PF_ASSET_SEEKING:
            NSLog(@"Seeking");
            //seekindicator.hidden = FALSE;
            break;
        case PF_ASSET_PLAYING:
            NSLog(@"Playing");
            [AppInfo hideLoading];
           
            
            
            //seekindicator.hidden = TRUE;
            CMTime t = [asset getDuration];
            _videoSlider.maximumValue = CMTimeGetSeconds(t);
            _videoSlider.minimumValue = 0.0;
            
            
            CGFloat totalSecond = t.value /t.timescale;// 转换成秒
            __totalTime = [self convertTime:totalSecond];// 转换成播放时间
            _secondVideoSlider.maximumValue = CMTimeGetSeconds(t);
            _secondVideoSlider.minimumValue = 0.0;
            [self.playBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
            [self.secondPlayBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
            _videoSlider.enabled = true;
            _secondVideoSlider.enabled=true;
//            if (pfAsset != nil)
//                [pfAsset setTimeRange:CMTimeMakeWithSeconds(0.1, 1000) duration:kCMTimePositiveInfinity onKeyFrame:NO];
            break;
        case PF_ASSET_PAUSED:
            NSLog(@"Paused");

             [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
             [self.secondPlayBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            break;
        case PF_ASSET_COMPLETE:
            NSLog(@"Complete");
            [asset setTimeRange:CMTimeMakeWithSeconds(0, 1000) duration:kCMTimePositiveInfinity onKeyFrame:NO];
            break;
        case PF_ASSET_STOPPED:
            NSLog(@"Stopped");
            [self stop];
            _videoSlider.value = 0;
            _videoSlider.enabled = false;
            
            _secondVideoSlider.value = 0;
            _secondVideoSlider.enabled = false;
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
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

- (void) stop
{
    // stop the view
    [pfView halt];
    
    // delete asset and view
    [self deleteAsset];
    [self deleteView];
    
    [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.secondPlayBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

- (void) playButtonTouched
{
   
    
    if (pfAsset != nil)
    {
        [pfAsset pause];
        //[pfView injectImage:pauseImage];
        return;
    }
    
    // create a Panframe view
    [self createView];
    
    [self createHotspots];
    // create a Panframe asset
    [self createAssetWithUrl:videoUrl];
    
    
    if ([pfAsset getStatus] == PF_ASSET_ERROR)
        [self stop];
    else
        [pfAsset play];
 
    
    [self.playBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    [self.secondPlayBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];

    
 
    
}

- (void)videoSlierChangeValue:(UISlider *)slider
{
    self.videoSlider.value=slider.value;
    self.secondVideoSlider.value=slider.value;
}

- (void)videoSlierChangeValueUp:(UISlider *)slider
{
    if (pfAsset != nil)
        [pfAsset setTimeRange:CMTimeMakeWithSeconds(slider.value, 1000) duration:kCMTimePositiveInfinity onKeyFrame:NO];
    touchslider = false;
    self.videoSlider.value=slider.value;
    self.secondVideoSlider.value=slider.value;
}

- (void)videoSlierChangeValueDown:(UISlider *)slider
{
     touchslider = true;
}

//


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


//=============

-(void) toggleControls
{
    if(self.playView.hidden){
        [self showControlsFast];
    }else{
        [self hideControlsFast];
    }
    
    
    [self scheduleHideControls];
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

-(void) scheduleHideControls
{
    if(!self.playView.hidden&&!self.navView.hidden)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(hideControlsSlowly) withObject:nil afterDelay:HIDE_CONTROL_DELAY];
    }
}

-(void) hideControlsSlowly
{
    [self hideControlsWithDuration:1.0];
}

-(void) hideControlsFast
{
    [self hideControlsWithDuration:0.2];
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





@end
