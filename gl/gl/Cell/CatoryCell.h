//
//  CatoryCell.h
//  gl
//
//  Created by Yuyangdexue on 15/8/5.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CatoryCell : UICollectionViewCell
@property (nonatomic,strong) UILabel *titleLable;
@property (nonatomic,strong) UIView  *line;
- (void)initTitle:(NSString *)title;
@end
