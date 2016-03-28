//
//  KNavgationView.m
//  gl
//
//  Created by Yuyangdexue on 15/8/4.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "KNavgationView.h"
#import "Constants.h"
#import <FXBlurView/FXBlurView.h>
@implementation KNavgationView


- (instancetype)initWithFrame:(CGRect)frame Targat:(id)superTargat DisSEL:(NSString *)selector FenSEL:(NSString *)secondSelector MotionSEL:(NSString *)thirdSelector;
{
    self=[super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
//    FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
//    blurView.dynamic = YES;
//    blurView.blurRadius = 10;
//    blurView.tintColor = [UIColor colorWithHexRGBString:@"191d30"];
//    [self addSubview:blurView];
    self.backgroundColor=[UIColor blackColor];
    self.alpha=0.6;
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(5,5, 34, 34)];
    //[btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"goBack.png"] forState:UIControlStateNormal];
    SEL sel=NSSelectorFromString(selector);
    [btn addTarget:superTargat action:sel forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    btn.showsTouchWhenHighlighted=YES;
    
    if ([secondSelector length]>1) {
        _changeBtn=[[UIButton alloc]initWithFrame:CGRectMake(kDeviceHeight-120,2, 40, 40)];
        //    [_changeBtn setTitle:@"分屏" forState:UIControlStateNormal];
        _changeBtn.showsTouchWhenHighlighted=YES;
        [self.changeBtn setImage:[UIImage imageNamed:@"split.png"] forState:UIControlStateSelected];
        [self.changeBtn setImage:[UIImage imageNamed:@"iphonelook.png"] forState:UIControlStateNormal];
        SEL sel1=NSSelectorFromString(secondSelector);
        [_changeBtn addTarget:superTargat action:sel1 forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_changeBtn];
        _changeBtn.center=CGPointMake(kDeviceHeight-120+20, btn.center.y);
    }
    

    
    if ([thirdSelector length]>1) {
        _motionBtn=[[UIButton alloc]initWithFrame:CGRectMake(kDeviceHeight-60,11, 40, 20)];
        //    [_changeBtn setTitle:@"分屏" forState:UIControlStateNormal];
        [_motionBtn setImage:[UIImage imageNamed:@"ipadmove@2x.png"] forState:UIControlStateSelected];
         _motionBtn.showsTouchWhenHighlighted=YES;
   
        [_motionBtn setImage:[UIImage imageNamed:@"ipadmove_unselected@2x.png"] forState:UIControlStateNormal];
        SEL sel2=NSSelectorFromString(thirdSelector);
        [_motionBtn addTarget:superTargat action:sel2 forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_motionBtn];
        _motionBtn.center=CGPointMake(kDeviceHeight-60+10, btn.center.y);
    }
 



    
    
    return self;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
