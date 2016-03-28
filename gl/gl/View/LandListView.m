//
//  LandListView.m
//  gl
//
//  Created by Yuyangdexue on 15/8/9.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "LandListView.h"
#import "LandMovieListCell.h"
#import "AppInfo.h"
#import "PanViewController.h"
#import "PlayerViewController.h"
#define IDENTIFIER_CELL @"IDENTIFIER_CELL"

@interface LandListView ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableArray *dateArr;
    
}

@end
@implementation LandListView
@synthesize gridView,selectedIndex;

- (instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    dateArr=[[NSMutableArray alloc]init];
    [self initView];
    return self;
}


- (void)requsetUrl
{
    switch (self.moveType) {
        case MovieType360:
            [self requset360];
            break;
        case MovieType3D:
            [self requset3D];
            break;
        case MovieType2D:
            [self requset2D];
            break;
            
        default:
            break;
    }
}

- (void)initView
{
    UIImageView *bgImg=[[UIImageView alloc]initWithFrame:self
                        .frame];
    bgImg.image=[UIImage imageNamed:@"landbg.png"];
    [self addSubview:bgImg];
    
    [self initGridView];
    
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 37, 37)];
    [btn setImage:[UIImage imageNamed:@"landback.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    btn.center=CGPointMake(self.frame.size.width/2, self.frame.size.height-15-15);
    [self addSubview:btn];

}

- (void)dismiss
{
    [self.viewController dismissViewControllerAnimated:NO completion:nil];
}




- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
     NSLog(@"ContentOffset  x is  %f,yis %f",scrollView.contentOffset.x,scrollView.contentOffset.y);
    if (self.ScrollViewPoint) {
        self.ScrollViewPoint(scrollView.contentOffset);
    }
}

- (void)initGridView
{
    UICollectionViewFlowLayout *layout =
    [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset=UIEdgeInsetsMake(0, 0, 0, 0);
    gridView = [[UICollectionView alloc]
                initWithFrame:CGRectMake(0, 0, kDeviceHeight/2,
                                         22+5+105+10)
                collectionViewLayout:layout];
    gridView.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2-20);
    gridView.dataSource = self;
    gridView.delegate = self;
    gridView.bounces = YES;
    gridView.backgroundColor = [UIColor clearColor];
    gridView.showsHorizontalScrollIndicator = NO;
    [self addSubview:gridView];
    [gridView registerClass:[LandMovieListCell class]
 forCellWithReuseIdentifier:IDENTIFIER_CELL];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.moveType==MovieType2D) {
         return CGSizeMake(80, 22+5+105+10+5);
    }
    return CGSizeMake(294, 147);
   
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LandMovieListCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:IDENTIFIER_CELL forIndexPath:indexPath];
    cell.backgroundColor=[UIColor clearColor];
    if (self.moveType!=MovieTypeLocal) {
        cell.moveType=self.moveType;
         [cell initModel:[dateArr objectAtIndex:indexPath.row]];
    }
    else
    {
        
        cell.moveType=self.moveType;
        [cell initModel:[[MovieListModel alloc]initWithDictionary:[[[AppInfo instance]getDicFromMoiveModel] objectAtIndex:indexPath.row] error:nil]];

    }
   
    return cell;
    
}



- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    if (self.moveType==MovieTypeLocal) {
        return [[AppInfo instance]getDicFromMoiveModel].count;

    }
    return dateArr.count;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex=indexPath.row;
    if (self.SelectedIndexBlock) {
        self.SelectedIndexBlock(selectedIndex);
    }
    [gridView reloadData];
    
    if (MovieType360==self.moveType) {
        [self push360:indexPath];
    }
    else if (MovieType3D==self.moveType)
    {
        [self push3D:indexPath];
    }
    else if (MovieType2D==self.moveType)
    {
        [self push2D:indexPath];
    }
    else if (MovieTypeLocal==self.moveType)
    {
        [self pushLocal:indexPath];
    }
    
    
}

- (void)pushLocal:(NSIndexPath *)indexPath
{
    
     NSArray *arr=[[AppInfo instance]getDicFromMoiveModel];
      NSDictionary *dic=[arr objectAtIndex:indexPath.row];
   
                if ([[dic stringForKey:@"isDownLoad"] isEqualToString:@"1"]) {
                PanViewController *player=[[PanViewController alloc]initWithUrl:[AppInfo pathFromLocalMovieName:[dic stringForKey:@"name"]]  local:YES Fen:YES];
                    
                    [self.viewController presentViewController:player animated:NO completion:nil];
                    
                }

    
}

- (void)push360:(NSIndexPath*)indexPath
{
    
    __weak LandListView *weakSelf=self;
    [AppInfo getMovieUrlMovieId:((MovieListModel *)[dateArr objectAtIndex:indexPath.row]).id complete:^(NSString *url) {
        
        
        __block BOOL isHavLocal;
        isHavLocal=NO;
        NSArray *arr=[[AppInfo instance]getDicFromMoiveModel];
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([((MovieListModel *)[dateArr objectAtIndex:indexPath.row]).id isEqualToString:[(NSDictionary*)(obj) stringForKey:@"id"]]) {
                if ([[(NSDictionary *)obj stringForKey:@"isDownLoad"] isEqualToString:@"1"]) {
                  
    
                      PanViewController *player=[[PanViewController alloc]initWithUrl:[AppInfo pathFromLocalMovieName:((MovieListModel *)[dateArr objectAtIndex:indexPath.row]).name]  local:YES Fen:YES];
                    
                    [self.viewController presentViewController:player animated:NO completion:nil];
                    isHavLocal=YES;
                    return ;
                    
                }
            }
        }];

        if (!isHavLocal) {
            
             PanViewController *player=[[PanViewController alloc]initWithUrl:url local:NO Fen:YES];
            [weakSelf.viewController presentViewController:player animated:NO completion:nil];
        }

    }];

}

- (void)push3D:(NSIndexPath*)indexPath
{
    __weak LandListView *weakSelf=self;
    [AppInfo getMovieUrlMovieId:((MovieListModel *)[dateArr objectAtIndex:indexPath.row]).id complete:^(NSString *url) {
        PlayerViewController *player=[[PlayerViewController alloc]init];
        player.movieType=MovieType3D;
//        player.isFen=YES;
        player.url=url;
        [weakSelf.viewController presentViewController:player animated:NO completion:nil];
    }];
}

- (void)push2D:(NSIndexPath*)indexPath
{
    __weak LandListView *weakSelf=self;
    [AppInfo getMovieUrlMovieId:((MovieListModel *)[dateArr objectAtIndex:indexPath.row]).id complete:^(NSString *url) {
        PlayerViewController *player=[[PlayerViewController alloc]init];
        player.url=url;
        player.isFen=YES;
        player.movieType=MovieType2D;
        [weakSelf.viewController presentViewController:player animated:NO completion:nil];
    }];
}



- (NSDictionary *)getOffsetDic:(NSInteger)offseting
{
    NSMutableDictionary *dic=[[NSMutableDictionary  alloc]init];
    [dic setObject:[AppInfo NSInterToString:offseting] forKey:@"offset"];
    [dic setObject:[AppInfo NSInterToString:100] forKey:@"limit"];
    
    return dic;
}

#pragma HTTP
- (void)requset360
{
    
    [AppInfo httpGET:AppURL_360 headerWithUserInfo:NO parameters:[self getOffsetDic:0] successBlock:^(int code, NSDictionary *dictResp) {
        if ([dictResp isKindOfClass:[NSArray class]]) {
            NSLog(@"123123");
            
            [dateArr removeAllObjects];
            for (int i=0; i<((NSArray *)dictResp).count; i++) {
                MovieListModel *model=[[MovieListModel alloc]initWithDictionary:[((NSArray *)dictResp) objectAtIndex:i] error:nil];
                [dateArr addObject:model];
                
            }
          
            [gridView reloadData];
            
        }
      
        
    } failureBlock:^(NSError *error) {
       
    }];
}

- (void)requset2D
{
    
    [AppInfo httpGET:AppURL_Imax headerWithUserInfo:NO parameters:[self getOffsetDic:0] successBlock:^(int code, NSDictionary *dictResp) {
        if ([dictResp isKindOfClass:[NSArray class]]) {
            
            [dateArr removeAllObjects];
            for (int i=0; i<((NSArray *)dictResp).count; i++) {
                MovieListModel *model=[[MovieListModel alloc]initWithDictionary:[((NSArray *)dictResp) objectAtIndex:i] error:nil];
                [dateArr addObject:model];
                
            }
            
            [gridView reloadData];
        }
        
    } failureBlock:^(NSError *error) {
      
    }];
}
- (void)requset3D
{
    
    [AppInfo httpGET:AppURL_3D headerWithUserInfo:NO parameters:[self getOffsetDic:0] successBlock:^(int code, NSDictionary *dictResp) {
        if ([dictResp isKindOfClass:[NSArray class]]) {
            [dateArr removeAllObjects];
            for (int i=0; i<((NSArray *)dictResp).count; i++) {
                MovieListModel *model=[[MovieListModel alloc]initWithDictionary:[((NSArray *)dictResp) objectAtIndex:i] error:nil];
                [dateArr addObject:model];
                
            }
         
            [gridView reloadData];
        }
       
    } failureBlock:^(NSError *error) {
        
    }];
}


@end
