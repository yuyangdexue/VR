//
//  LandScapeView.h
//  gl
//
//  Created by Yuyangdexue on 15/8/9.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LandScapeView : UIView

@property (nonatomic,strong)UICollectionView *gridView;
@property (nonatomic,assign)UIViewController *viewController;
@property (nonatomic,copy)void (^SelectedIndexBlock)(NSInteger index);
@property (nonatomic,assign)NSInteger selectedIndex;


@end
