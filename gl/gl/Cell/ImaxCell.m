//
//  ImaxCell.m
//  gl
//
//  Created by Yuyangdexue on 15/8/5.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "ImaxCell.h"
#import "Constants.h"
#import "Constants.h"
// 100 140 5
@interface ImaxCell ()
{
    UIView      *bgView;
    UIImageView *iconImg;
    UILabel     *titleLable;
}
@end
@implementation ImaxCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self pSetup];
    }
    return self;
}

- (void)pSetup
{
    if (!bgView) {
        bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 100*kDeviceFactor, 140*kDeviceFactor)];
        bgView.backgroundColor=kColor_ImaxBg_Color;
        [self addSubview:bgView];
    }
    
    if (!iconImg) {
        iconImg=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5,100*kDeviceFactor-10, 140*kDeviceFactor-10)];
        iconImg.backgroundColor=[UIColor greenColor];
        [self addSubview:iconImg];
    }
    
    if (!titleLable) {
        titleLable=[[UILabel alloc]initWithFrame:CGRectMake(10, 140*kDeviceFactor-40, 100*kDeviceFactor-5, 20)];
        titleLable.textColor=[UIColor whiteColor];
        titleLable.text=@"123123";
        titleLable.font=[UIFont systemFontOfSize:12];
        [self addSubview:titleLable];
    }
}

- (void) resetModel:(MovieListModel *)model
{
    [iconImg setImageWithURL:[NSURL URLWithString:[model.img stringForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"defaultImax.png"]];
    titleLable.text=model.name;
}

@end
