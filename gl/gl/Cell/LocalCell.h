//
//  LocalCell.h
//  gl
//
//  Created by Yuyangdexue on 15/8/11.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "AppInfo.h"
@class LCDownloadManager;
@interface LocalCell : UITableViewCell

@property (nonatomic,weak)UIViewController *viewController;
@property (nonatomic,strong) LCDownloadManager *downLoadOperation;
@property (nonatomic,strong)  NSString *downUrl;
@property (nonatomic,strong)AFHTTPRequestOperation *operation;
- (void)initDic:(NSDictionary *)dic;

- (void)removeDownLoadOperation;
@end
