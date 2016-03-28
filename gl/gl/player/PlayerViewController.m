//
//  PlayerViewController.m
//  gl
//
//  Created by Yuyangdexue on 15/7/28.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//


#import "PlayerViewController.h"
#import <CoreMedia/CoreMedia.h>
#import "Constants.h"
#import "KNavgationView.h"
#import "GCPlayer.h"
#import "AppInfo.h"

#define DEFAULT_VIEW_ALPHA 0.6f
#define HIDE_CONTROL_DELAY 5.0f

@interface PlayerViewController ()
{

    UIImageView *_playButton;
    BOOL _checkPlaying;
     BOOL isFirst;
    

}
@property (nonatomic,strong)GCPlayer *player;
@property (nonatomic,strong)KNavgationView *navView;

@end
@implementation PlayerViewController
@synthesize alertViewRemindState,navView;
#pragma mark - UIResponder

#pragma mark - viewDidLoad
- (BOOL)shouldAutorotate
{
    return NO;
}
- (BOOL) shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationLandscapeRight;
}

- (CGSize)fixedScreenSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    } else {
        return screenSize;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
    //UIStatusBarStyleDefault = 0 黑色文字，浅色背景时使用
    //UIStatusBarStyleLightContent = 1 白色文字，深色背景时使用
}

- (BOOL)prefersStatusBarHidden
{
    return YES; // 返回NO表示要显示，返回YES将hiden
}





- (void)dealloc
{
    NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)init3D
{
   

    if (!self.player) {
        self.player=[[GCPlayer alloc]initWithFrame:CGRectMake(0, 0, kDeviceHeight,kDeviceWidth)];
        self.player.transform =CGAffineTransformIdentity;
        self.player.center=CGPointMake(kDeviceWidth/2, kDeviceHeight/2);
        self.player.transform =CGAffineTransformMakeRotation(degreesToRadians(90));
        self.player.movieType=MovieType3D;
        [self.view addSubview:self.player];
    }
    
    [self.player getPlayItem:self.url];
  
//
    
    if(!self.isFen)
    {
        [navView.changeBtn setImage:[UIImage imageNamed:@"split.png"] forState:UIControlStateNormal];

        isFirst=YES;
    }
    else
    {
        [navView.changeBtn setImage:[UIImage imageNamed:@"iphonelook.png"] forState:UIControlStateNormal];
        isFirst=NO;
    }
    self.player.bool_FenPing=self.isFen;
    navView=[[KNavgationView alloc]initWithFrame:CGRectMake(0, 0, kDeviceHeight, 44) Targat:self DisSEL:@"goBack"FenSEL:@"dosplitScreen" MotionSEL:@""];
    navView.transform =CGAffineTransformIdentity;
    navView.center=CGPointMake(kDeviceWidth-22, kDeviceHeight/2);
    navView.transform =CGAffineTransformMakeRotation(degreesToRadians(90));
    [self.view addSubview:navView];
    
    __weak PlayerViewController *weakSelf=self;
    self.player.tapHidden=^(BOOL hidden)
    {
     
            //weakSelf.navView.hidden=hidden;
        [weakSelf toggleControls];
        
    };
      navView.changeBtn.hidden=YES;
}

- (void)dosplitScreen
{
    if (self.movieType==MovieType3D) {
        return;
    }
   
    if (isFirst) {
        self.player.bool_FenPing=YES;
       
        
   
    }
    else
    {
        self.player.bool_FenPing=NO;
       
    }
    navView.changeBtn.selected=isFirst;
    isFirst=!isFirst;
  
}



- (void)init2D
{
    if (!self.player) {
        self.player=[[GCPlayer alloc]initWithFrame:CGRectMake(0, 0, kDeviceHeight,kDeviceWidth)];
        self.player.transform =CGAffineTransformIdentity;
        self.player.center=CGPointMake(kDeviceWidth/2, kDeviceHeight/2);
        self.player.transform =CGAffineTransformMakeRotation(degreesToRadians(90));
        self.player.movieType=MovieType2D;
        [self.view addSubview:self.player];
    }
 

    [self.player getPlayItem:self.url];


   
    self.player.bool_FenPing=self.isFen;
    navView=[[KNavgationView alloc]initWithFrame:CGRectMake(0, 0, kDeviceHeight, 44) Targat:self DisSEL:@"goBack"FenSEL:@"dosplitScreen" MotionSEL:@""];
    navView.transform =CGAffineTransformIdentity;
    navView.center=CGPointMake(kDeviceWidth-22, kDeviceHeight/2);
    navView.transform =CGAffineTransformMakeRotation(degreesToRadians(90));
    [self.view addSubview:navView];
    
    __weak PlayerViewController *weakSelf=self;
    self.player.tapHidden=^(BOOL hidden)
    {
       
            [weakSelf toggleControls];
        
      
    };
    navView.changeBtn.selected=self.isFen;
    isFirst=!self.isFen;
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   
    
    
  
 
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blackColor];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    self.view.userInteractionEnabled=YES;
    if (_movieType==MovieType2D) {
        [self init2D];
    }
    else if(MovieType3D==_movieType)
    {
        [self init3D];
        navView.changeBtn.hidden=YES;
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidBecomeActive:)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
    [self toggleControls];
    
}
- (void)applicationDidBecomeActive:(NSNotification *) notification
{
    printf("按理说是重新进来后响应\n");
    if (self.player) {
        [self.player.playerr play];
    }
}

- (void)goBack
{
    
    [AppInfo hideLoading];
    [self.player.playerr pause];
    [self dismissViewControllerAnimated:NO completion:nil];
}



-(void) toggleControls
{
    if(self.player.playView.hidden){
        [self showControlsFast];
    }else{
        [self hideControlsFast];
    }
    
    
    [self scheduleHideControls];
}

-(void) showControlsFast
{
    self.player.playView.alpha = 0.0;
    
    self.player.playView.hidden = NO;
    self.navView.hidden=NO;
    self.navView.alpha=0.0;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         
                         self.player.playView.alpha = DEFAULT_VIEW_ALPHA;
                         self.navView.alpha=DEFAULT_VIEW_ALPHA;
                     }
                     completion:nil];
}

-(void) scheduleHideControls
{
    if(!self.player.playView.hidden&&!self.navView.hidden)
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
    self.player.playView.alpha = DEFAULT_VIEW_ALPHA;
    self.navView.alpha=DEFAULT_VIEW_ALPHA;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         
                         self.player.playView.alpha = 0.0f;
                         self.navView.alpha=0;
                     }
                     completion:^(BOOL finished){
                         if(finished)
                             self.player.playView.hidden = YES;
                         self.navView.hidden=YES;
                     }];
    
}






@end
