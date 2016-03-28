//
//  PlayerViewController.h
//  gl
//
//  Created by Yuyangdexue on 15/7/28.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "BaseViewController.h"
#import "Constants.h"
typedef NS_ENUM(NSInteger, SLalertViewRemindState) {
    SLalertViewRemindStateNetNotBest = 0,
    SLalertViewRemindStateNetVideoBad,
};




@interface PlayerViewController : BaseViewController
@property (nonatomic)SLalertViewRemindState alertViewRemindState;
@property (nonatomic,assign)BOOL isFen;
@property (nonatomic,assign)MovieType movieType;
@property (nonatomic,strong)NSString *url;

@end
