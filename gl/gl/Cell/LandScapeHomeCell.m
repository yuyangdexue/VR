//
//  LandScapeHomeCell.m
//  gl
//
//  Created by Yuyangdexue on 15/8/9.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "LandScapeHomeCell.h"
#import "Constants.h"

@implementation LandScapeHomeCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self pSetup];
    }
    return self;
}

- (void)pSetup
{
    if (!_iconImg) {
        _iconImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 34, 34)];
       // _iconImg.backgroundColor=[UIColor redColor];
        [self addSubview:_iconImg];
    }
    if (!_titleLab) {
        _titleLab=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 18)];
        _titleLab.font=[UIFont systemFontOfSize:16];
        _titleLab.textAlignment=NSTextAlignmentCenter;
        [self addSubview:_titleLab];
    }
    _iconImg.center=CGPointMake(self.frame.size.width/2, 17+3);
    _titleLab.center=CGPointMake(self.frame.size.width/2, 60-12);
}


@end
