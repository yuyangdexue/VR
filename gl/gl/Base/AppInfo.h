//
//  AppInfo.h
//  Trade
//
//  Created by Yuyangdexue on 15/6/24.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "Constants.h"
typedef NS_ENUM(NSInteger, AppURL)
{
    AppURL_Start=1000,
    AppURL_Imax,
    AppURL_Detail,
    AppURL_3D,
    AppURL_360,
    AppURL_Zero
};





@interface AppInfo : NSObject

+(instancetype)instance;
@property (nonatomic,weak)AFHTTPRequestOperation *operation;


+ (NSString *)pathFromLocalMovieName:(NSString *)name;

+ (void)showToast:(NSString *)txt;
+ (void)showLoading:(BOOL) isVertical;

+ (void)showLoading:(BOOL)isVertical SVProgressHUDMaskType:(SVProgressHUDMaskType) MSVProgressHUDMaskType;

+ (void)hideLoading;


+ (StatusDownLoad)statusFromMovieId:(NSString  *)mid;



+ (void)deleteMovieId:(NSString *)mid MovieName:(NSString *) movieName;

- (NSArray *)getDicFromMoiveModel;
- (BOOL)isStopFromDb:(NSString *)mid;
- (void)setModelToJson:(NSDictionary *)dic;
- (void)changeHavDic:(NSDictionary *)dic;
- (void)changeHavDic:(NSDictionary *)dic stopYesOrNo:(BOOL)isYes;
- (void)saveDownLoadData:(NSDictionary *)dic;
- (unsigned long long)fileSizeForPath:(NSString *)path;
//==============
- (void)removeKey:(int)ikey;

- (void)setArray:(int)ikey arr:(NSArray *)arr;
- (NSArray *)getArray:(int)ikey;

- (NSDictionary *)getDictionary:(int)ikey;
- (void)setDictionary:(int)ikey dict:(NSDictionary *)dict;

- (NSString *)getString:(int)ikey;
- (void)setString:(int)ikey str:(NSString *)str;

- (BOOL)getBool:(int)ikey;
- (void)setBool:(int)ikey val:(BOOL)val;

- (int)getInteger:(int)ikey;
- (void)setInteger:(int)ikey val:(int)val;
//===========

+ (NSString *)NSInterToString:(NSInteger )index;

+ (void)httpGET:(AppURL)appUrl
headerWithUserInfo:(BOOL)headerWithUserInfo
     parameters:(NSDictionary *)parameters
   successBlock:(void (^)(int code, NSDictionary *dictResp))successBlock
   failureBlock:(void (^)(NSError *error))failureBlock;

+ (void)httpPOST:(AppURL)appUrl
headerWithUserInfo:(BOOL)headerWithUserInfo
      parameters:(NSDictionary *)parameters
    successBlock:(void (^)(int code, NSDictionary *dictResp))successBlock
    failureBlock:(void (^)(NSError *error))failureBlock;

+ (void)cacheHttpResult:(NSString *)strKey content:(NSDictionary *)content;

- (void)cancelHttpMethods;

+ (void)getMovieUrlMovieId:(NSString *)movieId complete:(void(^)(NSString *url))completeUrl;

@end
