//
//  LandMovieListCell.h
//  gl
//
//  Created by Yuyangdexue on 15/8/9.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieListModel.h"
#import "Constants.h"
@interface LandMovieListCell : UICollectionViewCell

@property (nonatomic,assign)MovieType moveType;
- (void)initModel:(MovieListModel *)model;


@end
