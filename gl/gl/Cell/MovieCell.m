//
//  MovieCell.m
//  gl
//
//  Created by Yuyangdexue on 15/8/4.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "MovieCell.h"
#import "Constants.h"
#import "AppInfo.h"
#import "CacheFile.h"
#import "PlayerViewController.h"
#import "PanViewController.h"
#import "SVProgressHUD.h"
@interface MovieCell()
{
    UIImageView *iconImg;
    UILabel     *nameLable;
    UILabel     *statusLable;
    BOOL       Tap;
    AFHTTPRequestOperation *operation;
    MovieListModel *mvModel;
    NSDictionary *dict;
    
}
@end
@implementation MovieCell
@synthesize downloadBtn;


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    [self initSubView];
    return self;
}

- (void)initSubView
{
    if (!iconImg) {
        iconImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceWidth*0.5)];
        //iconImg.contentMode=UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:iconImg];
    }
    if (!nameLable) {
        UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(0, kDeviceWidth*0.5-10-20, kDeviceWidth, 30)];
        bgView.backgroundColor=[UIColor blackColor];
        bgView.alpha=0.7;
        [self.contentView addSubview:bgView];
        
        nameLable=[[UILabel alloc]initWithFrame:CGRectMake(10, kDeviceWidth*0.5-5-20, 200, 20)];
        nameLable.textColor=[UIColor whiteColor];
        nameLable.font=[UIFont systemFontOfSize:16];
        [self.contentView addSubview:nameLable];
    }
    
    if (!downloadBtn) {
        downloadBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        downloadBtn.frame=CGRectMake(kDeviceWidth-30-10,kDeviceWidth*0.5-5-25 , 40, 30);
        //        [downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        [downloadBtn setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
        [downloadBtn setImage:[UIImage imageNamed:@"download_press.png"] forState:UIControlStateHighlighted];
        [downloadBtn setContentMode:UIViewContentModeCenter];
        [downloadBtn addTarget:self action:@selector(downLoad) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:downloadBtn];
    }
    if (!_progressView) {
        _progressView=[[UIProgressView alloc]initWithFrame:CGRectMake(0,0, kDeviceWidth, 10)];
        _progressView.center=CGPointMake(kDeviceWidth/2, kDeviceWidth/4-10);
        [self.contentView addSubview:_progressView];
        _progressView.hidden=YES;
    }
    
    if (!statusLable) {
        statusLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
        statusLable.textColor=[UIColor blackColor];
        statusLable.center=CGPointMake(kDeviceWidth/2, kDeviceWidth/4-10-25);
        [self addSubview:statusLable];
    }
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickView)];
    tap.numberOfTapsRequired=1;
    tap.numberOfTouchesRequired=1;
    self.contentView.userInteractionEnabled=YES;
    [self.contentView addGestureRecognizer:tap];
    
    
    
}

- (void)clickView
{
    //    if (!self.isLocal) {
    if (!mvModel)
    {
        return;
    }
    if (self.moveType==MovieType360) {
        __block BOOL isFromLocal;
        isFromLocal=NO;
        NSArray *arr=[[AppInfo instance]getDicFromMoiveModel];
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([mvModel.id isEqualToString:[(NSDictionary*)(obj) stringForKey:@"id"]]) {
                if ([[(NSDictionary *)obj stringForKey:@"isDownLoad"] isEqualToString:@"1"]) {
                    
                    isFromLocal=YES;
                    
                    
                    
                    PanViewController *player=[[PanViewController alloc]initWithUrl:[AppInfo pathFromLocalMovieName:mvModel.name] local:NO Fen:NO];
                    
                    
                    [self.viewController presentViewController:player animated:NO completion:nil];
                    return ;
                    
                }
            }
            else if ([[(NSDictionary *)obj stringForKey:@"isDownLoad"] isEqualToString:@"0"])
            {
                NSLog(@"正在下载");
            }
        }];
        
        if (isFromLocal) {
            return;
        }
        
        [AppInfo getMovieUrlMovieId:mvModel.id complete:^(NSString *url) {
             PanViewController *player=[[PanViewController alloc]initWithUrl:url local:NO Fen:NO];
            
            [self.viewController presentViewController:player animated:NO completion:nil];
        }];
        
    }
    else if (MovieType3D==self.moveType)
    {
        [AppInfo getMovieUrlMovieId:mvModel.id complete:^(NSString *url) {
            PlayerViewController *player=[[PlayerViewController alloc]init];
            player.movieType=MovieType3D;
            player.url=url;
            [self.viewController presentViewController:player animated:NO completion:nil];
        }];
        
        
    }
    
    
}

- (void)initDic:(NSDictionary *)dic
{
    dict=[NSDictionary dictionaryWithDictionary:dic];
}
- (void)resetModel:(MovieListModel *)model
{
    mvModel=model;
    
    [iconImg setImageWithURL:[NSURL URLWithString:[model.img stringForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"default360.png"]];
    nameLable.text=model.name;
    
    StatusDownLoad statusLoad=[AppInfo statusFromMovieId:model.id];
    
    switch (statusLoad) {
        case StatusDownLoad_NoneDownload:
            //没有下载
            
            break;
        case StatusDownLoad_DownLoading:
            //正在下载
            
            break;
        case StatusDownLoad_HaveDownload:
            //已经下载
            
            break;
            
        default:
            break;
    }
    
    
}

- (void)downLoad
{
    if (!dict) {
        return;
    }
    StatusDownLoad statusLoad=[AppInfo statusFromMovieId:[dict stringForKey:@"id"]];
    
    [SVProgressHUD isVerticalScreen:YES];
    switch (statusLoad) {
        case StatusDownLoad_NoneDownload:
            //没有下载
            NSLog(@"没有下载");
            [[AppInfo instance] setModelToJson:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDownLoadNSNotification object:nil];
            
            [SVProgressHUD showSuccessWithStatus:@"正在下载!"];
            
            break;
        case StatusDownLoad_DownLoading:
            //正在下载
            NSLog(@"正在下载");
            [SVProgressHUD showSuccessWithStatus:@"正在下载!"];
            break;
        case StatusDownLoad_HaveDownload:
            //已经下载
            NSLog(@"已经下载");
            [SVProgressHUD showSuccessWithStatus:@"已经下载"];
            break;
            
        default:
            break;
            
    }
    
    
    
    
}


@end
