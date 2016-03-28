//
//  CatoryCell.m
//  gl
//
//  Created by Yuyangdexue on 15/8/5.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "CatoryCell.h"
#import "Constants.h"
@interface CatoryCell ()
{
   }

@end
@implementation CatoryCell
@synthesize titleLable;
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        UIView *selView = [[UIView alloc] initWithFrame:frame];
//        selView.backgroundColor = kColor_MainBg_Color;
//        self.selectedBackgroundView = selView;
//        self.backgroundColor = [UIColor whiteColor];
        [self pSetup];
    }
    return self;
}

- (void)pSetup
{
    if (!titleLable) {
        titleLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth/4, 40)];
        titleLable.textColor=[UIColor whiteColor];
        [self addSubview:titleLable];
        titleLable.textAlignment=NSTextAlignmentCenter;
    }
    if (!_line) {
         _line=[[UIView alloc]initWithFrame:CGRectMake(10, 40-2, kDeviceWidth/4-20,2)];
        _line.backgroundColor=kColor_Selected_Color;
        [self addSubview:_line];
    }
 
}
- (void)initTitle:(NSString *)title
{
    titleLable.text=title;
}

@end
