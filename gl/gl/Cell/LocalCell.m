//
//  LocalCell.m
//  gl
//
//  Created by Yuyangdexue on 15/8/11.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "LocalCell.h"
#import "LCDownloadManager.h"
//#import "VIDVideoPlayerViewController.h"
#import "PanViewController.h"
#define kCellHeight  85

@interface LocalCell ()<UIAlertViewDelegate>
{
    UIView *bgView;
    UIImageView *iconImg;
    UIView  *blackView;
    UIImageView *statusImg;
    UILabel     *statusLable;
    UILabel     *nameLable;
    UILabel     *progressLable;
    UIProgressView  *progressView;
    UIView *line;
    NSMutableDictionary *dict;
   
    BOOL Tap;
    
    UIButton *deleteBtn;
    
   
}

@end
@implementation LocalCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    self.backgroundColor=[UIColor clearColor];
    [self initBasicView];
    if (!self.downLoadOperation) {
        self.downLoadOperation=[[LCDownloadManager alloc]init];
    }
    
    return self;
}

- (void)initBasicView
{
    if (!bgView) {
        bgView=[[UIView alloc]initWithFrame:CGRectMake(5, 5, 130, kCellHeight-10)];
        bgView.backgroundColor=kColor_ImaxBg_Color;
        [self.contentView addSubview:bgView];
    }
    
    if (!iconImg) {
        iconImg=[[UIImageView alloc]initWithFrame:CGRectMake(7, 7, 130-4, kCellHeight-10-4)];
        [self.contentView addSubview:iconImg];
    }
    if (!blackView) {
        blackView=[[UIView alloc]initWithFrame:CGRectMake(5, 5, 130, kCellHeight-10)];
        blackView.alpha=0.7;
        blackView.backgroundColor=[UIColor blackColor];
        [self.contentView  addSubview:blackView];
    }
    if (!statusImg) {
        statusImg=[[UIImageView alloc]initWithFrame:CGRectMake(30, 32, 15, 15)];
        [self.contentView addSubview:statusImg];
    }
    if (!statusLable) {
        statusLable=[[UILabel alloc]initWithFrame:CGRectMake(50, 30, 60, 20)];
        statusLable.font=[UIFont systemFontOfSize:14];
        statusLable.textColor=[UIColor whiteColor];
        [self.contentView addSubview:statusLable];
    }
    if (!progressView) {
        progressView=[[UIProgressView alloc]initWithFrame:CGRectMake(14, 65, 130-24, 4)];
        progressView.progressTintColor=kColor_Selected_Color;
        [self.contentView addSubview:progressView];
    }
    if (!nameLable) {
        nameLable=[[UILabel alloc]initWithFrame:CGRectMake(150, 15, kDeviceWidth-150-10, 20)];
        nameLable.textColor=[UIColor whiteColor];
        nameLable.font=[UIFont systemFontOfSize:16];
        [self.contentView addSubview:nameLable];
    }
    if (!progressLable) {
        progressLable=[[UILabel alloc]initWithFrame:CGRectMake(150, 55, kDeviceWidth-150-10, 16)];
        progressLable.textColor=[UIColor colorForHex:@"#4C538D"];
        progressLable.font=[UIFont systemFontOfSize:14];
        [self.contentView addSubview:progressLable];
    }
    if (!line) {
        line=[[UIView alloc]initWithFrame:CGRectMake(0, 85-0.5, kDeviceWidth, 0.5)];
        line.backgroundColor=[UIColor colorForHex:@"#4C538D"];
        [self.contentView addSubview:line];
    }
    if (!deleteBtn) {
        deleteBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame=CGRectMake(kDeviceWidth-15-40, 55, 40, 30);
        deleteBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteMovie) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteBtn];
    }
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickView)];
    tap.numberOfTapsRequired=1;
    tap.numberOfTouchesRequired=1;
    self.contentView.userInteractionEnabled=YES;
    [self.contentView addGestureRecognizer:tap];
    

}

- (void)deleteMovie
{
    if (!dict) {
        return;
    }
    NSString *nameString=[NSString stringWithFormat:@"确定删除%@",[dict stringForKey:@"name"]];
    UIAlertView *alter=[[UIAlertView alloc]initWithMessage:nameString cancelButtonTitle:@"取消" otherButtonTitle:@"确定"];
    alter.delegate=self;
    [alter show];
}

- (void)removeDownLoadOperation
{
    if (self.operation) {
        [self.operation pause];
        [self.operation cancel];
        self.operation=nil;
    }
}


- (void)dealloc
{
    //self.downLoadOperation=nil;
    //self.downLoadOperation.requestOperation=nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!dict) {
        return;
    }
    if (buttonIndex==1) {
        NSLog(@"确定");
        if (self.operation) {
            [self.operation pause];
            self.operation=nil;
        }
        [AppInfo deleteMovieId:[dict stringForKey:@"id"] MovieName:[dict stringForKey:@"name"]];
    }
}

- (void)isHiddenLoading:(BOOL) isHidden;
{
    if (isHidden) {
        blackView.hidden=YES;
        statusImg.hidden=YES;
        statusLable.hidden=YES;
        progressView.hidden=YES;
        //progressLable.hidden=YES;
    }
    else
    {
        blackView.hidden=NO;
        statusImg.hidden=NO;
        statusLable.hidden=NO;
        progressView.hidden=NO;
        //progressLable.hidden=NO;
    }
}

- (void)clickView
{
    if (!dict) {
        return;
    }
    
    if ([[dict stringForKey:@"isDownLoad"] isEqualToString:@"1"]) {        
         PanViewController *player=[[PanViewController alloc]initWithUrl:[AppInfo pathFromLocalMovieName:[dict stringForKey:@"name"]] local:YES Fen:NO];
        [self.viewController presentViewController:player animated:NO completion:nil];
        return;
    }
   
        [self isHiddenLoading:NO];
        
        if (!Tap)
        {
            statusLable.text=@"暂停";
             [statusImg setImage:[UIImage imageNamed:@"stop.png"]];
            if (self.downLoadOperation) {
                [self.downLoadOperation pauseWithOperation:self.operation];
               // [self.downLoadOperation.requestOperation pause];
            }
            [[AppInfo instance] changeHavDic:dict stopYesOrNo:YES];
        }
        else
        {
              [statusImg setImage:[UIImage imageNamed:@"download.png"]];
         
            statusLable.text=@"缓冲中...";
            nameLable.text=[dict stringForKey:@"name"];
            iconImg.backgroundColor=[UIColor whiteColor];
            __weak LocalCell *weakSelf=self;
       
                [AppInfo getMovieUrlMovieId:[dict stringForKey:@"id"] complete:^(NSString *url) {
                    
                    weakSelf.operation=[LCDownloadManager downloadFileWithURLString:url cachePath: [AppInfo pathFromLocalMovieName:[dict stringForKey:@"name"]] progressBlock:^(CGFloat progress, CGFloat totalMBRead, CGFloat totalMBExpectedToRead) {
                        
                        NSLog(@"1--%f %f %f", progress, totalMBRead, totalMBExpectedToRead);
                        progressView.progress = progress;
                        progressLable.text=[NSString stringWithFormat:@"%.2fM/%.2fM",totalMBRead,totalMBExpectedToRead];
                       
                        if (![dict stringForKey:@"totalSize"]||[[dict stringForKey:@"totalSize"] length]==1) {
                            [dict setValue:[NSString stringWithFormat:@"%.2f",totalMBExpectedToRead] forKey:@"totalSize"];
                            [[AppInfo instance] saveDownLoadData:dict];
                        }
                        
                  
                        if ((int)progress==1) {
                            //                                statusLable.text=@"下载完成";
                            [self isHiddenLoading:YES];
                            [[AppInfo instance]changeHavDic:dict];
                        }
                        
                    } successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        NSLog(@"1--Download finish");
                        [self isHiddenLoading:YES];
                        
                    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                        
                        if (error.code == -999) NSLog(@"1--Maybe you pause download.");
                        
                        NSLog(@"1--%@", error);
                    }];
                }];
                
             [[AppInfo instance] changeHavDic:dict stopYesOrNo:NO];

           
            
        }
        Tap=!Tap;

    
    
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex






- (void)initDic:(NSDictionary *)dic
{
    dict=[NSMutableDictionary dictionaryWithDictionary:dic];
    
    CGFloat progress=[[AppInfo instance] fileSizeForPath:[AppInfo pathFromLocalMovieName:[dict stringForKey:@"name"]]]/[[dict stringForKey:@"totalSize"] floatValue];
    progressView.progress = progress;
    progressLable.text=[NSString stringWithFormat:@"%.2fM/%.2fM",(CGFloat)[[AppInfo instance] fileSizeForPath:[AppInfo pathFromLocalMovieName:[dict stringForKey:@"name"]]],[[dict stringForKey:@"totalSize"] floatValue]];
    // 下载完成
    if ([[dic stringForKey:@"isDownLoad"] isEqualToString:@"1"]) {
        blackView.hidden=YES;
        progressView.hidden=YES;
        [iconImg setImageWithURL:[NSURL URLWithString:[[dic dictionaryForKey:@"img"] stringForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"default360.png"]];
        nameLable.text=[dic stringForKey:@"name"];
        progressLable.text=[NSString stringWithFormat:@"%lluM",[LCDownloadManager fileSizeForPath:[AppInfo pathFromLocalMovieName:[dic stringForKey:@"name"]]]/1024/1024];
        
    }
    else
    {
        [iconImg setImageWithURL:[NSURL URLWithString:[[dic dictionaryForKey:@"img"] stringForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"default360.png"]];
        nameLable.text=[dic stringForKey:@"name"];
        
        if (![[AppInfo instance] isStopFromDb:[dict stringForKey:@"id"]]) {
            
            progressView.hidden=NO;
            nameLable.text=[dict stringForKey:@"name"];
            statusLable.text=@"缓冲中...";
             [statusImg setImage:[UIImage imageNamed:@"download.png"]];
            iconImg.backgroundColor=[UIColor whiteColor];
            __weak LocalCell *weakSelf=self;
            [AppInfo getMovieUrlMovieId:[dict stringForKey:@"id"] complete:^(NSString *url) {
                
                weakSelf.operation=[LCDownloadManager downloadFileWithURLString:url cachePath: [AppInfo pathFromLocalMovieName:[dict stringForKey:@"name"]] progressBlock:^(CGFloat progress, CGFloat totalMBRead, CGFloat totalMBExpectedToRead) {
                    
                    NSLog(@"1--%f %f %f", progress, totalMBRead, totalMBExpectedToRead);
                    progressView.progress = progress;
                    progressLable.text=[NSString stringWithFormat:@"%.2fM/%.2fM",totalMBRead,totalMBExpectedToRead];
                    if (![dict stringForKey:@"totalSize"]||[[dict stringForKey:@"totalSize"] length]==1) {
                        [dict setValue:[NSString stringWithFormat:@"%.2f",totalMBExpectedToRead] forKey:@"totalSize"];
                        [[AppInfo instance] saveDownLoadData:dict];
                    }
             
                    if ((int)progress==1) {
                        //                                statusLable.text=@"下载完成";
                        [self isHiddenLoading:YES];
                        [[AppInfo instance]changeHavDic:dict];
                    }
                    
                } successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSLog(@"1--Download finish");
                    [self isHiddenLoading:YES];
                    
                } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    if (error.code == -999) NSLog(@"1--Maybe you pause download.");
                    
                    NSLog(@"1--%@", error);
                }];
            }];
            

            
        }
        else
        {
            [statusImg setImage:[UIImage imageNamed:@"stop.png"]];
            statusLable.text=@"暂停";
            progressView.hidden=NO;
            Tap=YES;
            nameLable.text=[dict stringForKey:@"name"];
            iconImg.backgroundColor=[UIColor whiteColor];

            
        }

    }
    
}


@end
