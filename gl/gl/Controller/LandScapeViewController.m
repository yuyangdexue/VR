//
//  LandScapeViewController.m
//  gl
//
//  Created by Yuyangdexue on 15/8/9.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "LandScapeViewController.h"
#import "LandScapeView.h"
#import "Constants.h"
#import "LandScapeListViewController.h"
@interface LandScapeViewController ()
{
    
    
}
@property(nonatomic,strong)LandScapeView *leftView;
@property(nonatomic,strong)LandScapeView *rightView;
@end

@implementation LandScapeViewController
@synthesize leftView,rightView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak LandScapeViewController *weakSelf=self;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    leftView=[[LandScapeView alloc]initWithFrame:CGRectMake(0, 0, kDeviceHeight/2, kDeviceWidth)];
    leftView.viewController=self;
    leftView.transform =CGAffineTransformIdentity;
    leftView.center=CGPointMake(kDeviceWidth/2, kDeviceHeight/4);
    leftView.transform =CGAffineTransformMakeRotation(degreesToRadians(90));
    [self.view addSubview:leftView];
    
    rightView=[[LandScapeView alloc]initWithFrame:CGRectMake(0, 0, kDeviceHeight/2, kDeviceWidth)];
    rightView.viewController=self;
    rightView.transform =CGAffineTransformIdentity;
    rightView.center=CGPointMake(kDeviceWidth/2, kDeviceHeight*3/4);
    rightView.transform =CGAffineTransformMakeRotation(degreesToRadians(90));
    [self.view addSubview:rightView];
    
    leftView.SelectedIndexBlock=^(NSInteger index)
    {
        LandScapeListViewController *lvc=[[LandScapeListViewController alloc]init];
        weakSelf.rightView.selectedIndex=index;
        [weakSelf.rightView.gridView reloadData];
        switch (index) {
            case 0:
            
                lvc.moveType=MovieType360;
                [weakSelf presentViewController:lvc];
                break;
            case 1:
                lvc.moveType=MovieType3D;
                [weakSelf presentViewController:lvc];
                break;
            case 2:
                lvc.moveType=MovieType2D;
                [weakSelf presentViewController:lvc];
                break;
            case 3:
                lvc.moveType=MovieTypeLocal;
                [weakSelf presentViewController:lvc];
                break;
                
            default:
                break;
        }
        
    };
    
    rightView.SelectedIndexBlock=^(NSInteger index)
    {   LandScapeListViewController *lvc=[[LandScapeListViewController alloc]init];
        weakSelf.leftView.selectedIndex=index;
        [weakSelf.leftView.gridView reloadData];
        switch (index) {
            case 0:
                lvc.moveType=MovieType360;
                [weakSelf presentViewController:lvc];
                break;
            case 1:
                lvc.moveType=MovieType3D;
                [weakSelf presentViewController:lvc];
                break;
            case 2:
                lvc.moveType=MovieType2D;
                [weakSelf presentViewController:lvc];
                break;
            case 3:
                lvc.moveType=MovieTypeLocal;
                [weakSelf presentViewController:lvc];

                break;
                
            default:
                break;
        }

    };
    
}

- (void)presentViewController:(UIViewController *)vc
{
    [self presentViewController:vc animated:NO completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
