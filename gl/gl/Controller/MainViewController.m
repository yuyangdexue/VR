//
//  MainViewController.m
//  gl
//
//  Created by Yuyangdexue on 15/8/4.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "MainViewController.h"
#import "Constants.h"
#import "MovieCell.h"
#import "CatoryCell.h"
#import "ImaxCell.h"
#import "AppInfo.h"
#import "MovieListModel.h"
#import "PlayerViewController.h"
#import "LandScapeViewController.h"
#import "TLSpringFlowLayout.h"
#import "LocalCell.h"
#import "MJRefresh.h"

#define kHeaderPullToRefreshText     @"下拉刷新"
#define kHeaderReleaseToRefreshText  @"释放即可刷新"
#define kHeaderRefreshingText        @"正在刷新..."


#define kFooterPullToRefreshText     @"上拉可以加载更多数据"
#define kFooterReleaseToRefreshText  @"释放马上加载更多数据了"
#define kFooterRefreshingText        @"加载中，请稍等..."

@interface MainViewController()


@end

#define IDENTIFIER_CELL @"IDENTIFIER_CELL"
#define IDENTIFIER_2DCELL @"IDENTIFIER_2DCELL"
@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    UITableView *tbView360;
    UITableView *tbView3D;
    UITableView *tbViewLocal;
    
    NSMutableArray *tbArr360;
    NSMutableArray *tbArr3D;
    NSMutableArray *gridArr2D;
    NSMutableArray *gridArrLocal;
    UIScrollView * scollView;
    
    UICollectionView *_gridView;
    UICollectionView *_2dGridView;
    NSArray *arr;
    MovieType movieType;
    NSInteger selectedIndex;
    UIButton  *vrBtn;
    
    NSInteger offset360;
    NSInteger offset3D;
    NSInteger offset2D;
    NSInteger limit;
    BOOL isUpdate;
    
}

@end

@implementation MainViewController


-(void)setStatusBarColor
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setStatusBarColor];
    
    selectedIndex=0;
    offset360=0;
    offset2D=0;
    offset3D=0;
    limit=12;
    tbArr360=[[NSMutableArray alloc]init];
    tbArr3D=[[NSMutableArray alloc]init];
    gridArr2D=[[NSMutableArray alloc]init];
    gridArrLocal=[[NSMutableArray alloc]init];
    arr=@[@"全景",@"3D",@"Imax",@"本地"];
    movieType=MovieType360;
    isUpdate=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTbLocal) name:kDownLoadNSNotification object:nil];
    [self initTitleView];
    [self initScorollView];
    [self initGridView];
    [self init2dGridView];
    [self initTbView360];
    [self initTbView3D];
    [self initTbViewLocal];
    [self initVrBtn];
    //[self initRefreshControlTView360];
    //[self initRefreshControlTView3D];
    //[self initRefreshControlGridView];
    [self requset360];
    [self requset3D];
    [self requset2D];
    
    
}

-(NSArray *)cellsForTableView:(UITableView *)tableView
{
    NSInteger sections = tableView.numberOfSections;
    NSMutableArray *cells = [[NSMutableArray alloc]  init];
    for (int section = 0; section < sections; section++) {
        NSInteger rows =  [tableView numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [cells addObject:[tableView cellForRowAtIndexPath:indexPath]];
        }
    }
    return cells;
}

- (void)reloadTbLocal
{
 
    [[self cellsForTableView:tbViewLocal] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        LocalCell *cell=(LocalCell *)obj;
        [cell removeDownLoadOperation];
        
        
    }];
    [tbViewLocal reloadData];
}

#pragma mark ScorollView
- (void)initScorollView
{
    scollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, kMarginTopHeight+40, kDeviceWidth, kDeviceHeight-kMarginTopHeight-40)];
    scollView.backgroundColor=[UIColor clearColor];
    scollView.pagingEnabled=YES;
    scollView.bounces=NO;
    scollView.delegate=self;
    //scollView.backgroundColor=[UIColor redColor];
    scollView.contentSize=CGSizeMake(kDeviceWidth*4, kDeviceHeight-kMarginTopHeight-40);
    [self.view addSubview:scollView];
}

#pragma mark Local View
- (void)initTbViewLocal
{
    tbViewLocal=[[UITableView alloc]initWithFrame:CGRectMake(kDeviceWidth*3, 0, kDeviceWidth, kDeviceHeight-kMarginTopHeight-40) style:UITableViewStylePlain];
    tbViewLocal.delegate=self;
    tbViewLocal.dataSource=self;
    tbViewLocal.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbViewLocal.backgroundColor=[UIColor clearColor];
    [scollView addSubview:tbViewLocal];
}

#pragma mark 360 initView
- (void)initTbView360
{
    tbView360=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight-kMarginTopHeight-40) style:UITableViewStylePlain];
    tbView360.delegate=self;
    tbView360.dataSource=self;
    tbView360.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbView360.backgroundColor=[UIColor clearColor];
    [scollView addSubview:tbView360];
    
    
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [tbView360 addHeaderWithTarget:self action:@selector(headerRereshing360)];
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [tbView360 addFooterWithTarget:self action:@selector(footerRereshing360)];
    
    tbView360.headerPullToRefreshText = kHeaderPullToRefreshText;
    tbView360.headerReleaseToRefreshText = kHeaderReleaseToRefreshText;
    tbView360.headerRefreshingText = kHeaderRefreshingText;
    
    tbView360.footerPullToRefreshText = kFooterPullToRefreshText;
    tbView360.footerReleaseToRefreshText = kFooterReleaseToRefreshText;
    tbView360.footerRefreshingText = kFooterRefreshingText;
    
}
#pragma mark  360 rereshing
- (void)headerRereshing360
{
    offset360=0;
    [self requset360];
}

- (void)footerRereshing360
{
    [self requset360];
}
#pragma mark 3D rereshing
- (void)initTbView3D
{
    tbView3D=[[UITableView alloc]initWithFrame:CGRectMake(kDeviceWidth, 0, kDeviceWidth, kDeviceHeight-kMarginTopHeight-40) style:UITableViewStylePlain];
    tbView3D.delegate=self;
    tbView3D.dataSource=self;
    tbView3D.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbView3D.backgroundColor=[UIColor clearColor];
    [scollView addSubview:tbView3D];
    
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [tbView3D addHeaderWithTarget:self action:@selector(headerRereshing3D)];
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [tbView3D addFooterWithTarget:self action:@selector(footerRereshing3D)];
    
    tbView3D.headerPullToRefreshText = kHeaderPullToRefreshText;
    tbView3D.headerReleaseToRefreshText = kHeaderReleaseToRefreshText;
    tbView3D.headerRefreshingText = kHeaderRefreshingText;
    
    tbView3D.footerPullToRefreshText = kFooterPullToRefreshText;
    tbView3D.footerReleaseToRefreshText = kFooterReleaseToRefreshText;
    tbView3D.footerRefreshingText = kFooterRefreshingText;
}

#pragma mark  3D rereshing
- (void)headerRereshing3D
{
    offset3D=0;
    [self requset3D];
}

- (void)footerRereshing3D
{
    [self requset3D];
}

#pragma mark IMAX View
- (void)init2dGridView
{
    TLSpringFlowLayout *layout =
    [[TLSpringFlowLayout alloc] init];
    layout.minimumLineSpacing = 3*kDeviceFactor;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset=UIEdgeInsetsMake(8, 8, 0, 8);
    //layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    
    _2dGridView = [[UICollectionView alloc]
                   initWithFrame:CGRectMake(kDeviceWidth*2, 0, kDeviceWidth,
                                            kDeviceHeight-104)
                   collectionViewLayout:layout];
    _2dGridView.dataSource = self;
    _2dGridView.delegate = self;
    _2dGridView.bounces = YES;
    _2dGridView.backgroundColor = [UIColor clearColor];
    _2dGridView.showsHorizontalScrollIndicator = NO;
    [scollView addSubview:_2dGridView];
    [_2dGridView registerClass:[ImaxCell class]
    forCellWithReuseIdentifier:IDENTIFIER_2DCELL];
    
    [_2dGridView addHeaderWithTarget:self action:@selector(headerRereshingIMAX)];
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [_2dGridView addFooterWithTarget:self action:@selector(footerRereshingIMAX)];
    
    _2dGridView.headerPullToRefreshText = kHeaderPullToRefreshText;
    _2dGridView.headerReleaseToRefreshText = kHeaderReleaseToRefreshText;
    _2dGridView.headerRefreshingText = kHeaderRefreshingText;
    
    _2dGridView.footerPullToRefreshText = kFooterPullToRefreshText;
    _2dGridView.footerReleaseToRefreshText = kFooterReleaseToRefreshText;
    _2dGridView.footerRefreshingText = kFooterRefreshingText;
}

#pragma mark  3D rereshing
- (void)headerRereshingIMAX
{
    offset2D=0;
    [self requset2D];
}

- (void)footerRereshingIMAX
{
    [self requset2D];
}






- (NSDictionary *)getOffsetDic:(NSInteger)offseting
{
    NSMutableDictionary *dic=[[NSMutableDictionary  alloc]init];
    [dic setObject:[AppInfo NSInterToString:offseting] forKey:@"offset"];
    [dic setObject:[AppInfo NSInterToString:limit] forKey:@"limit"];

    return dic;
}

- (void)initTitleView
{
    UIImageView  *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    imgView.image=[UIImage imageNamed:@"bg.png"];
    [self.view addSubview:imgView];
    
    UIImageView *titleImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 53, 14)];
    titleImg.center=CGPointMake(kDeviceWidth/2, 12+7+20);
    titleImg.image=[UIImage imageNamed:@"title.png"];
    [self.view addSubview:titleImg];
    
}



- (void)initVrBtn
{
    vrBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    vrBtn.frame=CGRectMake(0, 0, 71, 71);
    vrBtn.center=CGPointMake(kDeviceWidth/2, kDeviceHeight-35-16);
    [vrBtn setImage:[UIImage imageNamed:@"downBtn.png"] forState:UIControlStateNormal];
    [vrBtn addTarget:self action:@selector(gotoNewVc) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:vrBtn];
}

- (void)gotoNewVc
{
    LandScapeViewController *nvc=[[LandScapeViewController alloc]init];
    [self presentViewController:nvc animated:NO completion:nil];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    vrBtn.hidden=YES;
}
#pragma mark scrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scollView==scrollView) {
        int row=(int)scollView.contentOffset.x/(int)kDeviceWidth;
        selectedIndex=(NSInteger)row;
        [_gridView reloadData];
        
    }
    vrBtn.hidden=NO;
    
}






#pragma UITableView


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tbView360==tableView) {
        return tbArr360.count;
    }
    else if (tbView3D==tableView)
    {
        return tbArr3D.count;
    }
    else if (tbViewLocal==tableView)
    {
        return [[AppInfo instance]getDicFromMoiveModel].count;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tbViewLocal==tableView) {
        return 85;
    }
    return kDeviceWidth*0.5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tbViewLocal!=tableView) {
        
    
    static NSString *CELLID=@"CELLID";
    MovieCell *cell=[tableView dequeueReusableHeaderFooterViewWithIdentifier:CELLID];
    if (!cell) {
        cell=[[MovieCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELLID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.viewController=self;
    if (tbView360==tableView) {
        cell.downloadBtn.hidden=NO;
        cell.moveType=MovieType360;
        if (indexPath.row<tbArr360.count) {
            
            [cell resetModel:[[MovieListModel alloc]initWithDictionary:[tbArr360 objectAtIndex:indexPath.row] error:nil]];
            [cell initDic:[tbArr360 objectAtIndex:indexPath.row]];
        }
    }
    else if(tbView3D==tableView)
    {
        cell.downloadBtn.hidden=YES;
        cell.moveType=MovieType3D;
        if (indexPath.row<tbArr3D.count) {
            [cell resetModel:[[MovieListModel alloc]initWithDictionary:[tbArr3D objectAtIndex:indexPath.row] error:nil]];
            
        }
    }
       return cell;
        
    }
    
    else if (tbViewLocal==tableView)
    {
        
        static  NSString *cellID=@"cellider";
      
        LocalCell *cell=[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];        
        if (!cell) {
            cell=[[LocalCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        cell.viewController=self;
        [cell initDic:[[[AppInfo instance] getDicFromMoiveModel] objectAtIndex:indexPath.row]];
        return cell;
    }
  
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}




#pragma mark collectionView

- (void)initGridView
{
    UICollectionViewFlowLayout *layout =
    [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset=UIEdgeInsetsMake(0, 0, 0, 0);
    _gridView = [[UICollectionView alloc]
                 initWithFrame:CGRectMake(0, 64, kDeviceWidth,
                                          40)
                 collectionViewLayout:layout];
    _gridView.dataSource = self;
    _gridView.delegate = self;
    _gridView.bounces = YES;
    _gridView.backgroundColor = kColor_MianBg_Color;
    _gridView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_gridView];
    [_gridView registerClass:[CatoryCell class]
  forCellWithReuseIdentifier:IDENTIFIER_CELL];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView==_gridView) {
        return CGSizeMake(kDeviceWidth / 4.0, 40);
    }
    else if (collectionView==_2dGridView)
    {
        return CGSizeMake(100*kDeviceFactor, 140*kDeviceFactor);
        
    }
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView==_gridView) {
        CatoryCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:IDENTIFIER_CELL forIndexPath:indexPath];
        cell.backgroundColor=kColor_MianBg_Color;
        if (selectedIndex==indexPath.row) {
            cell.titleLable.textColor=kColor_Selected_Color;
            cell.line.hidden=NO;
        }
        else
        {
            cell.titleLable.textColor=kColor_NoSelected_Color;
            cell.line.hidden=YES;
            
        }
        [cell initTitle:[arr objectAtIndex:indexPath.row]];
        return cell;
    }
    else if (collectionView==_2dGridView)
    {
        ImaxCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:IDENTIFIER_2DCELL forIndexPath:indexPath];
        if (indexPath.row<gridArr2D.count) {
            [cell resetModel:[gridArr2D objectAtIndex:indexPath.row]];
        }
        
        return cell;
    }
    
    return nil;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (collectionView==_gridView) {
        return arr.count;
    }
    else if(collectionView==_2dGridView)
    {
        return gridArr2D.count;
    }
    return 0;
    
}
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if (collectionView==_gridView) {

        switch (indexPath.row) {
            case 0:
                movieType=MovieType360;
                [self requset360];
                
                [scollView setContentOffset:CGPointMake(0, 0) animated:YES];
                break;
            case 1:
                movieType=MovieType3D;
                [self requset3D];
            
               [scollView setContentOffset:CGPointMake(kDeviceWidth, 0) animated:YES];
                break;
                
            case 2:
                movieType=MovieType2D;
                [self requset2D];
               
                [scollView setContentOffset:CGPointMake(kDeviceWidth*2, 0) animated:YES];
                break;
                
            case 3:
                 [scollView setContentOffset:CGPointMake(kDeviceWidth*3, 0) animated:YES];
             
            
                break;
                
                
            default:
                break;
        }
        selectedIndex=indexPath.row;
        [_gridView reloadData];
        
    }
    else
    {
        if (movieType==MovieType2D)
        {
            [AppInfo getMovieUrlMovieId:((MovieListModel *)[gridArr2D objectAtIndex:indexPath.row]).id complete:^(NSString *url) {
                PlayerViewController *player=[[PlayerViewController alloc]init];
                player.url=url;
                player.movieType=movieType;
                [self presentViewController:player animated:NO completion:nil];
            }];
            
            
        }
    }
    
    
}
#pragma HTTP
- (void)requset360
{
    
    [AppInfo httpGET:AppURL_360 headerWithUserInfo:NO parameters:[self getOffsetDic:offset360] successBlock:^(int code, NSDictionary *dictResp) {
        if ([dictResp isKindOfClass:[NSArray class]]) {
            NSLog(@"123123");
            if (offset360==0) {
                [tbArr360 removeAllObjects];
            }
            
            for (int i=0; i<((NSArray *)dictResp).count; i++) {
//                MovieListModel *model=[[MovieListModel alloc]initWithDictionary:[((NSArray *)dictResp) objectAtIndex:i] error:nil];
//                [tbArr360 addObject:model];
                [tbArr360 addObject:[((NSArray *)dictResp) objectAtIndex:i]];
                
            }
            offset360=tbArr360.count;
            [tbView360 reloadData];
            
        }
        [tbView360 headerEndRefreshing];
        [tbView360 footerEndRefreshing];
        
    } failureBlock:^(NSError *error) {
      
        [tbView360 headerEndRefreshing];
        [tbView360 footerEndRefreshing];
    }];
}

- (void)requset3D
{
    
    [AppInfo httpGET:AppURL_3D headerWithUserInfo:NO parameters:[self getOffsetDic:offset3D] successBlock:^(int code, NSDictionary *dictResp) {
        if ([dictResp isKindOfClass:[NSArray class]]) {
            
            if (offset3D==0) {
                [tbArr3D removeAllObjects];
            }
            for (int i=0; i<((NSArray *)dictResp).count; i++) {
//                MovieListModel *model=[[MovieListModel alloc]initWithDictionary:[((NSArray *)dictResp) objectAtIndex:i] error:nil];
                [tbArr3D addObject:[((NSArray *)dictResp) objectAtIndex:i]];
                
            }
            offset3D=tbArr3D.count;
            [tbView3D reloadData];
        }
      
        [tbView3D headerEndRefreshing];
        [tbView3D footerEndRefreshing];
    } failureBlock:^(NSError *error) {
    
        [tbView3D headerEndRefreshing];
        [tbView3D footerEndRefreshing];
    }];
}

- (void)requset2D
{
    
    [AppInfo httpGET:AppURL_Imax headerWithUserInfo:NO parameters:[self getOffsetDic:offset2D] successBlock:^(int code, NSDictionary *dictResp) {
        if ([dictResp isKindOfClass:[NSArray class]]) {
            
            if (offset2D==0) {
                [gridArr2D removeAllObjects];
            }
            for (int i=0; i<((NSArray *)dictResp).count; i++) {
                MovieListModel *model=[[MovieListModel alloc]initWithDictionary:[((NSArray *)dictResp) objectAtIndex:i] error:nil];
                [gridArr2D addObject:model];
                
            }
            
            offset2D=gridArr2D.count;
            [_2dGridView reloadData];
        }
        [_2dGridView headerEndRefreshing];
        [_2dGridView footerEndRefreshing];
   
    } failureBlock:^(NSError *error) {
        
        [_2dGridView headerEndRefreshing];
        [_2dGridView footerEndRefreshing];

    }];
}






@end
