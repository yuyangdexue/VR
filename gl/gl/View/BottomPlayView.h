//
//  BottomPlayView.h
//  gl
//
//  Created by Yuyangdexue on 15/8/10.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomPlayView : UIView
@property(nonatomic,strong)UIImageView * playView;//操作栏
@property (nonatomic ,strong) id playbackTimeObserver;//监听播放状态
@property(nonatomic,strong)UIButton * playBtn;//播放/暂停
@property(nonatomic,strong)UISlider *videoSlider;//当前进度条
@property(nonatomic,strong)UIProgressView * videoProgress;//缓存条
@property(nonatomic,strong)UILabel * timeLabel;//当前时间/总时间
@property(nonatomic,assign)CGRect fremm;
@property(nonatomic,strong) NSString * _totalTime;//转换后的播放时间
@end
