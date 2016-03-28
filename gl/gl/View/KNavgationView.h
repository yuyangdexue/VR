//
//  KNavgationView.h
//  gl
//
//  Created by Yuyangdexue on 15/8/4.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KNavgationView : UIView

- (instancetype)initWithFrame:(CGRect)frame Targat:(id)superTargat DisSEL:(NSString *)selector FenSEL:(NSString *)secondSelector MotionSEL:(NSString *)thirdSelector;
@property (nonatomic,strong) UIButton *changeBtn;
@property (nonatomic,strong) UIButton *motionBtn;
//@property (nonatomic,strong) UIButton *touluoyiBtn;
@end
