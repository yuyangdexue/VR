//
//  LandScapeListViewController.m
//  gl
//
//  Created by Yuyangdexue on 15/8/9.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "LandScapeListViewController.h"
#import "LandListView.h"

@interface LandScapeListViewController ()
{
    
}

@property (nonatomic,strong)LandListView *leftView;
@property (nonatomic,strong)LandListView *rightView;

@end

@implementation LandScapeListViewController
@synthesize leftView,rightView;
- (void)viewDidLoad {
    [super viewDidLoad];
    __weak LandScapeListViewController *weakSelf=self;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    leftView=[[LandListView alloc]initWithFrame:CGRectMake(0, 0, kDeviceHeight/2, kDeviceWidth)];
    leftView.viewController=self;
    leftView.transform =CGAffineTransformIdentity;
    leftView.center=CGPointMake(kDeviceWidth/2, kDeviceHeight/4);
    leftView.transform =CGAffineTransformMakeRotation(degreesToRadians(90));
    [self.view addSubview:leftView];
    leftView.moveType=self.moveType;
    [leftView requsetUrl];
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    rightView=[[LandListView alloc]initWithFrame:CGRectMake(0, 0, kDeviceHeight/2, kDeviceWidth)];
    rightView.viewController=self;
    rightView.transform =CGAffineTransformIdentity;
    rightView.center=CGPointMake(kDeviceWidth/2, kDeviceHeight*3/4);
    rightView.transform =CGAffineTransformMakeRotation(degreesToRadians(90));
    [self.view addSubview:rightView];
    rightView.moveType=self.moveType;
    [rightView requsetUrl];
    
    __block BOOL isLeft=NO;
    leftView.ScrollViewPoint=^(CGPoint point)
    {
        isLeft=YES;
        if (isLeft) {
              [weakSelf.rightView.gridView setContentOffset:point animated:NO];
        }
      
    };
    
    rightView.ScrollViewPoint=^(CGPoint point)
    {
        isLeft=NO;
        if (!isLeft) {
           [weakSelf.leftView.gridView setContentOffset:point animated:NO];
        }
    
    };
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
