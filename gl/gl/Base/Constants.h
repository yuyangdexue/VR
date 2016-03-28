//
//  Constants.h
//  gl
//
//  Created by Yuyangdexue on 15/7/28.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#ifndef gl_Constants_h
#define gl_Constants_h

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import <UIColor+MCUIColorsUtils.h>
#import <UIAlertView+Block.h>
#import <UIActionSheet+Blocks.h>
#import "UIImageView+AFNetworking.h"
#import "NSDictionary+Accessors.h"
#import "CacheFile.h"
#import "SVProgressHUD.h"

#endif 

extern float kDeviceFactor;
extern float kDeviceWidth;
extern float kDeviceHeight;


#define PREFIX_URL @"http://101.200.231.61:9900/"


#define DEBUG_LOG_OPEN

#ifdef DEBUG_LOG_OPEN
#define DLog(fmt, ...)                                                         \
NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

#define String_Format(...) [NSString stringWithFormat:__VA_ARGS__]
#define kNavigationBarHeight 44
#define kStatusBarHeight 20
#define kMarginTopHeight 64
#define kTabBarHeight 49
typedef enum
{
    VRStatusN0 = 0,
    VRStatusYES,
}VRStatus;

typedef enum
{
    MovieType360= 1000,
    MovieType3D,
    MovieType2D,
    MovieTypeLocal,
}MovieType;


typedef NS_ENUM(NSInteger, StatusDownLoad)
{
    StatusDownLoad_NoneDownload=2000,
    StatusDownLoad_DownLoading,
    StatusDownLoad_HaveDownload,
};

#define degreesToRadians(x) (M_PI*(x)/180.0)//弧度

#define   kColor_NavBg_Color  [UIColor colorWithHexRGBString:@"191d30"]
#define   kColor_MianBg_Color  kColor_ImaxBg_Color
#define   kColor_Selected_Color [UIColor colorWithHexRGBString:@"46F5FF"]
#define   kColor_NoSelected_Color [UIColor colorWithHexRGBString:@"4a578a"]
#define   kColor_ImaxBg_Color  [UIColor colorWithHexRGBString:@"272f4e"]

#define   kDownLoadNSNotification  @"DownLoadNSNotification"

#endif
