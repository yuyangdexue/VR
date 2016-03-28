//
//  LandMovieListCell.m
//  gl
//
//  Created by Yuyangdexue on 15/8/9.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "LandMovieListCell.h"
#import "Constants.h"
@interface LandMovieListCell ()
{
    UIView *bgView;
    UIImageView *iconImg;
    UILabel *titleLable;
    UILabel *upTitleLab;
    UIView *downBgView;
}

@end
@implementation LandMovieListCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self pSetup];
    }
    return self;
}

- (void)pSetup
{
    
    if (!bgView) {
        bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 22, 80, 120)];
        bgView.backgroundColor=kColor_ImaxBg_Color;
        [self addSubview:bgView];
    }
    
    if (!iconImg) {
        iconImg=[[UIImageView alloc]initWithFrame:CGRectMake(5,22+5,70, 105)];
        // _iconImg.backgroundColor=[UIColor redColor];
        [self addSubview:iconImg];
    }
    
    
    
    if (!downBgView) {
        downBgView=[[UIView alloc]initWithFrame:CGRectMake(5, 22+5+105+5-25, 70, 25)];
        downBgView.backgroundColor=[UIColor blackColor];
        downBgView.alpha=0.7;
        [self addSubview:downBgView];
    }
    
    
    if (!titleLable) {
        titleLable=[[UILabel alloc]initWithFrame:CGRectMake(5+5, 22+5+105+5-25+5, 60, 10)];
        titleLable.font=[UIFont systemFontOfSize:8];
        titleLable.textColor=[UIColor whiteColor];
        [self addSubview:titleLable];
    }
}

- (void)initModel:(MovieListModel *)model
{
    [iconImg setImageWithURL:[NSURL URLWithString:[model.img stringForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"defaultImax.png"]];
    titleLable.text=model.name;
    if (self.moveType!=MovieType2D) {
        bgView.frame=CGRectMake(0, 22, 240, 120);
        iconImg.frame=CGRectMake(5,22+5,230, 105);
        downBgView.frame=CGRectMake(5, 22+5+105+5-25, 230, 25);
        titleLable.frame=CGRectMake(5+5, 22+5+105+5-25+5, 220, 10);
    }
}

@end
