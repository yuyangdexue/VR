//
//  GCPlayer.h
//  封装AVPlayer
//
//  Created by 高超 on 15/6/17.
//  Copyright (c) 2015年 高超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
@interface GCPlayer : UIView


@property(nonatomic,strong)AVPlayerItem * playItem;
@property(nonatomic,strong)AVPlayer * playerr;
@property(nonatomic,assign)BOOL bool_FenPing;
@property(nonatomic,assign)MovieType movieType;
@property(nonatomic,strong)UIImageView * playView;//操作栏
@property(nonatomic,copy)void (^tapHidden)(BOOL isHidden);
//SingleTonH(Player)

-(void)getPlayItem:(NSString *)url;




@end
