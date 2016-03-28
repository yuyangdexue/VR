//
//  GCPlayer.m
//  封装AVPlayer
//
//  Created by 高超 on 15/6/17.
//  Copyright (c) 2015年 高超. All rights reserved.
//

#import "GCPlayer.h"
#import "Constants.h"
#import <FXBlurView/FXBlurView.h>
#import "AppInfo.h"
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface GCPlayer ()
{
    BOOL  Tap;//记录隐藏操作栏
    BOOL  Play;//记录播放Btn
        NSDateFormatter * _dateFormatter;//播放时间/总时间
    long _oldDirection;//旧方向
    long _currentDirection;//当前方向
    CGFloat hight;//记录竖屏高
    
    AVPlayerLayer *playerLayerLeft;
    AVPlayerLayer *playerLayerRight;
    NSString *viUrl;
    BOOL isFail;
}
//@property(nonatomic,strong)AVPlayer * playerr;
//@property(nonatomic,strong)AVPlayer * player;


@property (nonatomic ,strong) id playbackTimeObserver;//监听播放状态
@property(nonatomic,strong)UIButton * playBtn;//播放/暂停
@property(nonatomic,strong)UISlider *videoSlider;//当前进度条
@property(nonatomic,strong)UIProgressView * videoProgress;//缓存条
@property(nonatomic,strong)UILabel * timeLabel;//当前时间/总时间
@property(nonatomic,assign)CGRect fremm;
@property(nonatomic,strong) NSString * _totalTime;//转换后的播放时间

//===============================new================================
@property (nonatomic,strong)UIButton *secondPlayBtn;
@property (nonatomic,strong)UISlider *secondVideoSlider;
@property (nonatomic,strong)UIProgressView *secondProgressView;
@property(nonatomic,strong)UILabel * secondtimeLabel;//当前时间/总时间




//=====================================================================
@end


@implementation GCPlayer
@synthesize _totalTime;
//SingleTonM(Player)
//============================already=================================
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
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-70, 30, 100, 20)];
        self.timeLabel.text = @"00:00/00:00";
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.font = [UIFont systemFontOfSize:10];
    }
    
    return _timeLabel;
}

//====================================================================================
//@property (nonatomic,strong)UIButton *secondBtn;
//@property (nonatomic,strong)UISlider *secondVideoSlider;
//@property (nonatomic,strong)UIProgressView *secondProgressView;
//@property(nonatomic,strong)UILabel * secondtimeLabel;//当前时间/总时间
//===============================new==================================================


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

- (UIProgressView *)secondProgressView
{
    if (!_secondProgressView) {
        _secondProgressView=[[UIProgressView alloc]initWithFrame:CGRectMake(kDeviceHeight/2+55, 23, kDeviceHeight/2-100, 4)];
        _secondProgressView.progressTintColor=kColor_Selected_Color;
        
    }
    return _secondProgressView;
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










//====================================================================================

-(instancetype)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    if (self) {
        
        
        self.backgroundColor = [UIColor blackColor];
        _fremm = frame;
        //操作栏
        
        self.playView.backgroundColor = [UIColor blackColor];
        self.playView.alpha=0.6;
        self.playView.userInteractionEnabled = YES;
        [self addSubview:self.playView];
        //播放/暂停
        [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.playBtn addTarget:self action:@selector(playBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.playView addSubview:self.playBtn];
        
        //second
        [self.secondPlayBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.secondPlayBtn addTarget:self action:@selector(playBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.playView addSubview:self.secondPlayBtn];
        
        
        
        
        //缓存条
        //self.videoProgress.backgroundColor = [UIColor redColor];
        [self.playView addSubview:self.videoProgress];
        self.videoProgress.hidden=YES;
        //second
        //self.videoProgress.backgroundColor = [UIColor redColor];
        [self.playView addSubview:self.secondProgressView];
         self.secondProgressView.hidden=YES;
        
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
        [self isShowSecond:NO];
        //添加手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
        
        [AppInfo showLoading:NO];
        }

    
    
    return self;
}

- (UIImage *)imageWithColorCircle:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (void)isShowSecond:(BOOL)isShow
{

        self.secondPlayBtn.hidden=!isShow;
        self.secondProgressView.hidden=!isShow;
        self.secondtimeLabel.hidden=!isShow;
        self.secondVideoSlider.hidden=!isShow;
}




//判断Play or stop
-(void)playBtnTouched
{
    if (!Play) {
        
        [self.playerr play];
        [self.playBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        [self.secondPlayBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    }else{
        
        [self.playerr pause];
        [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.secondPlayBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
    
    
    Play = !Play;
}

//判断隐藏操作栏方法
-(void)tap
{
    if (!Tap) {
        if (self.tapHidden) {
            self.tapHidden(NO);
        }
        //self.playView.hidden = NO;
        
    }else{
        if (self.tapHidden) {
            self.tapHidden(YES);
        }
        //self.playView.hidden = YES;
        
    }
    
    Tap = !Tap;
}

#pragma mark - 私有方法

/**
 *  根据视频索引取得AVPlayerItem对象
 *
 *  @param videoIndex 视频顺序索引
 *
 *  @return AVPlayerItem对象
 */
-(void)getPlayItem:(NSString *)url
{
    viUrl=url;
    if (self.movieType==MovieType3D) {
                if (self.playerr) {
            [self.playerr.currentItem removeObserver:self forKeyPath:@"status"];
            [self.playerr.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
            self.playerr=nil;
            
        }
        NSURL * videoUrl = [NSURL URLWithString:url];
        AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
        
        [self listener:playerItem];
        [self playEnd:playerItem];
        self.playItem =playerItem;
        self.playerr = [AVPlayer playerWithPlayerItem:playerItem];
        self.player = _playerr;
        Play = !Play;
        [self.player play];
        [self.playBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        [self.secondPlayBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        [self splitOneScreenFrame:YES];

    }
    else
    {
        [self resetVideoUrl];
        [self splitOneScreen];
         [self bringSubviewToFront:self.playView];
    }
   
   
}

-(void)removePlayerTimeObserver
{
    if (_playbackTimeObserver)
    {
        [_playerr removeTimeObserver:_playbackTimeObserver];
        _playbackTimeObserver = nil;
    }
}

- (void)dealloc
{
    NSLog(@"%@",[self description]);
   [self removeKVO];
   [self removePlayerTimeObserver];
    _playView=nil;
    _playBtn=nil;
    _videoProgress=nil;
    _videoSlider=nil;
    _timeLabel=nil;
    _totalTime=nil;
    _secondPlayBtn=nil;
    _secondProgressView=nil;
    _secondtimeLabel=nil;
    _secondVideoSlider=nil;
    
}

- (void)resetVideoUrl
{
    if (self.playerr) {
        [self.playerr.currentItem removeObserver:self forKeyPath:@"status"];
        [self.playerr.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        self.playerr=nil;
    }
  
    
    NSURL * videoUrl = [NSURL URLWithString:viUrl];
    AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    
    [self listener:playerItem];
    [self playEnd:playerItem];
    self.playItem =playerItem;
    self.playerr = [AVPlayer playerWithPlayerItem:playerItem];
    
    Play = !Play;
    [self.playerr play];
    [self.playBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    [self.secondPlayBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
}

- (void)setBool_FenPing:(BOOL)bool_FenPing
{
    
    if (self.movieType==MovieType2D) {
        if (bool_FenPing) {
            
            [self splitTwoScreen];
            [self splitOneScreenFrame:YES];
        }
        else
        {
            [self splitOneScreen];
            [self splitOneScreenFrame:NO];
        }
    }
    

    //[self bringSubviewToFront:self.playView];

}

- (void)removeKVO
{
    [self.playerr pause];
    if (self.playerr) {
        [self.playerr.currentItem removeObserver:self forKeyPath:@"status"];
        [self.playerr.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        self.playerr=nil;
    }
  
}



- (void)splitOneScreen
{
    
    //[self resetVideoUrl];
     if (_movieType==MovieType2D)
     {
         
         if (!playerLayerRight) {
             playerLayerRight =[AVPlayerLayer playerLayerWithPlayer:self.playerr];
             playerLayerRight.videoGravity=AVLayerVideoGravityResizeAspectFill;
             [self.layer addSublayer:playerLayerRight];
         }
         playerLayerRight.frame=CGRectMake(kDeviceHeight/2,kDeviceWidth/4, kDeviceHeight/2, kDeviceWidth/2);

     }
 
    
        if (!playerLayerLeft) {
            playerLayerLeft =[AVPlayerLayer playerLayerWithPlayer:self.playerr];
            playerLayerLeft.videoGravity=AVLayerVideoGravityResizeAspectFill;
            [self.layer addSublayer:playerLayerLeft];
        }
        playerLayerLeft.frame=CGRectMake(0,0, kDeviceHeight, kDeviceWidth);
     [self bringSubviewToFront:self.playView];
    
}

- (void)splitOneScreenFrame:(BOOL) isFen
{
    if (isFen)
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

- (void)splitTwoScreen
{
    //[self resetVideoUrl];
  
     if (!playerLayerLeft) {
        playerLayerLeft =[AVPlayerLayer playerLayerWithPlayer:self.playerr];
        playerLayerLeft.videoGravity=AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:playerLayerLeft];
    }
  
    playerLayerLeft.frame=CGRectMake(0,kDeviceWidth/4, kDeviceHeight/2, kDeviceWidth/2);
    if (!playerLayerRight) {
        playerLayerRight =[AVPlayerLayer playerLayerWithPlayer:self.playerr];
        playerLayerRight.videoGravity=AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:playerLayerRight];
    }
    playerLayerRight.frame=CGRectMake(kDeviceHeight/2,kDeviceWidth/4, kDeviceHeight/2, kDeviceWidth/2);
    
    
    [self bringSubviewToFront:self.playView];
}





//给AVPlayerItem添加监听者
-(void)listener:(AVPlayerItem *)playerItem
{
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];//监听status属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];//监听loadedTimeRanges属性
    
    
    
}


//播放完毕执行方法
-(void)playEnd:(AVPlayerItem *)playerItem
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    
}

//当前进度条方法
- (void)videoSlierChangeValue:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSLog(@"value change:%.1f",slider.value);
    self.videoSlider.value=slider.value;
    self.secondVideoSlider.value=slider.value;
    [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.secondPlayBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playerr pause];
    if (slider.value == 0.000000) {
        __weak typeof(self) weakSelf = self;
        [self.playerr seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf.playerr play];
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
    [self.playerr seekToTime:changedTime completionHandler:^(BOOL finished) {
        [weakSelf.playerr play];
        [weakSelf.playBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        [weakSelf.secondPlayBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    }];
}


//添加监视者后，播放完毕执行方法
- (void)moviePlayDidEnd:(NSNotification *)notification {
    NSLog(@"Play end");
    
    __weak typeof(self) weakSelf = self;
    [self.playerr seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.videoSlider setValue:0.0 animated:YES];
        [weakSelf.secondVideoSlider setValue:0.0 animated:YES];
        [weakSelf.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [weakSelf.secondPlayBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [AppInfo hideLoading];
            NSLog(@"AVPlayerStatusReadyToPlay");
            self.playBtn.enabled = YES;
            self.secondPlayBtn.enabled=YES;
            CMTime duration = self.playItem.duration;// 获取视频总长度
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒
          _totalTime = [self convertTime:totalSecond];// 转换成播放时间
            [self customVideoSlider:duration];// 自定义UISlider外观
            NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
            [self removeKVO];
            [AppInfo showToast:@"播放失败！"];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
                NSLog(@"Time Interval:%.0f",timeInterval);
        CMTime duration = self.playItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self monitoringPlayback:self.playItem];// 监听播放状态
        [self.secondProgressView setProgress:timeInterval / totalDuration animated:YES];
        [self.videoProgress setProgress:timeInterval / totalDuration animated:YES];
    }
}

//计算缓存进度方法
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.playerr currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

//监听播放状态执行方法
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    __weak typeof(self) weakSelf = self;
    static BOOL hasAddOb = NO;
    
    if (!hasAddOb) {
        _playbackTimeObserver = [self.playerr addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
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
//自定义UISlider外观
- (void)customVideoSlider:(CMTime)duration {
    
    self.videoSlider.maximumValue = CMTimeGetSeconds(duration);
    self.secondVideoSlider.maximumValue=CMTimeGetSeconds(duration);
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIGraphicsEndImageContext();

}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}




+(Class)layerClass
{
    return [AVPlayerLayer class];
    
}





-(AVPlayer *)player
{
    
    return [(AVPlayerLayer *)[self layer]player];
}

-(void)setPlayer:(AVPlayer *)player
{
    
    [(AVPlayerLayer *)[self layer]setPlayer:player];
    
}


@end
