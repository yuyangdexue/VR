//
//  LandScapeView.m
//  gl
//
//  Created by Yuyangdexue on 15/8/9.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "LandScapeView.h"
#import "Constants.h"
#import "LandScapeHomeCell.h"
#define IDENTIFIER_CELL @"IDENTIFIER_CELL"
@interface LandScapeView ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    
    
}

@property (nonatomic,strong)NSArray *imgSelectedArr;
@property (nonatomic,strong)NSArray *imgUnSelectedArr;
@property (nonatomic,strong)NSArray *titleArr;

@end
@implementation LandScapeView
@synthesize gridView,selectedIndex;

- (instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    UIImageView *bgImg=[[UIImageView alloc]initWithFrame:self
                        .frame];
    bgImg.image=[UIImage imageNamed:@"landbg.png"];
    [self addSubview:bgImg];
    
    [self initView];
    return self;
}


- (void)initView
{
     _imgUnSelectedArr=[[NSArray alloc]initWithObjects:@"360_unselected.png",@"3d_unselected.png",@"imax_unselected.png",@"local_unselected.png" ,nil];
    _titleArr=[[NSArray alloc]initWithObjects:@"全景视频",@"3d视频",@"imax影片",@"本地视频",nil];
    _imgSelectedArr=[[NSArray alloc]initWithObjects:@"360_selected.png",@"3d_selected.png",@"imax_selected.png",@"local_selected.png" ,nil];

    [self initGridView];
    
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 37, 37)];
    [btn setImage:[UIImage imageNamed:@"iphone.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    btn.center=CGPointMake(self.frame.size.width/2, self.frame.size.height-15-15);
    [self addSubview:btn];
}

- (void)dismiss
{
    [self.viewController dismissViewControllerAnimated:NO completion:nil];
}



- (void)initGridView
{
    UICollectionViewFlowLayout *layout =
    [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset=UIEdgeInsetsMake(0, 0, 0, 0);
    gridView = [[UICollectionView alloc]
                 initWithFrame:CGRectMake(0, 0, kDeviceHeight/2,
                                          50)
                 collectionViewLayout:layout];
    gridView.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    gridView.dataSource = self;
    gridView.delegate = self;
    gridView.bounces = YES;
    gridView.backgroundColor = [UIColor clearColor];
    gridView.showsHorizontalScrollIndicator = NO;
    [self addSubview:gridView];
    [gridView registerClass:[LandScapeHomeCell class]
  forCellWithReuseIdentifier:IDENTIFIER_CELL];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(kDeviceHeight/8, 60);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   
        LandScapeHomeCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:IDENTIFIER_CELL forIndexPath:indexPath];
        cell.backgroundColor=[UIColor clearColor];
        cell.titleLab.text=[self.titleArr objectAtIndex:indexPath.row];
        if (selectedIndex==indexPath.row) {
            cell.titleLab.textColor=kColor_Selected_Color;
            cell.iconImg.image=[UIImage imageNamed:[self.imgSelectedArr objectAtIndex:indexPath.row]];
           
        }
        else
        {
            cell.titleLab.textColor=[UIColor whiteColor];
            cell.iconImg.image=[UIImage imageNamed:[self.imgUnSelectedArr objectAtIndex:indexPath.row]];
            
        }
        return cell;
  
}



- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  
    return _titleArr.count;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex=indexPath.row;
    if (self.SelectedIndexBlock) {
        self.SelectedIndexBlock(selectedIndex);
    }
    [gridView reloadData];
}


@end
