//
//  MovieCell.h
//  gl
//
//  Created by Yuyangdexue on 15/8/4.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieListModel.h"
#import "Constants.h"
@interface MovieCell : UITableViewCell
@property(nonatomic,retain) UIButton     *downloadBtn;
@property(nonatomic,retain)UIProgressView *progressView;
@property (nonatomic,assign)MovieType moveType;
@property (nonatomic,assign)BOOL isLocal;
@property (nonatomic,assign)BOOL isTest;
@property (nonatomic,assign)UIViewController *viewController;
- (void)resetModel:(MovieListModel *)model;
- (void)initDic:(NSDictionary *)dic;
@end
