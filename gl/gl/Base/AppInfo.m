//
//  AppInfo.m
//  Trade
//
//  Created by Yuyangdexue on 15/6/24.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "AppInfo.h"
#import "HttpRequestClass.h"
#import "CacheFile.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#define  dbString @"dbString"
@implementation AppInfo

+ (instancetype)instance {
  static AppInfo *_instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _instance = [AppInfo new];
  });
  return _instance;
}


- (void)dispatchMainAfter:(NSTimeInterval)delay block:(void (^)())block {
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       block();
                   });
}
+ (void)showToast:(NSString *)txt
{
    [SVProgressHUD showInfoWithStatus:txt];
    [[AppInfo instance] dispatchMainAfter:1.4
                      block:^{
                          [SVProgressHUD dismiss];
                      }];
}
+ (void)showLoading:(BOOL) isVertical;
{
    
    [SVProgressHUD isVerticalScreen:isVertical];
    [SVProgressHUD showWithStatus:@"加载中..."
                         maskType:SVProgressHUDMaskTypeNone];
}
+ (void)showLoading:(BOOL)isVertical SVProgressHUDMaskType:(SVProgressHUDMaskType) MSVProgressHUDMaskType
{
    [SVProgressHUD isVerticalScreen:isVertical];
    [SVProgressHUD showWithStatus:@"加载中..."
                         maskType:SVProgressHUDMaskTypeClear];
}
+ (void)hideLoading
{
    [SVProgressHUD dismiss];
}

+ (NSString *)pathFromLocalMovieName:(NSString *)name
{
    NSString *nameString=[NSString stringWithFormat:@"%@.mp4",name];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    // 下载文件本地文件夹 (此处是为了下载视频所以`/Video`)
    // 提醒: 下载文件到Download目录下一定要给用户提示, 为了审核!! 如: http://github.com/LeoiOS/LCProgressHUD
    NSString *videoDir = [NSString stringWithFormat:@"%@/Download/Video", docPath];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:videoDir isDirectory:&isDir];
    
    if (!(isDir == YES && existed == YES)) {
        
        [fileManager createDirectoryAtPath:videoDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filePath = [videoDir stringByAppendingPathComponent:nameString];
    
    //NSLog(@"filePath=========%@",filePath);
    return filePath;
}

+ (StatusDownLoad)statusFromMovieId:(NSString  *)mid
{
    NSArray *arr=[[self alloc] dictionaryWithJsonString:[CacheFile cache_file_get:dbString]];
    
    __block BOOL isHaveId;
    __block BOOL isHaveDownLoad;
    isHaveDownLoad=NO;
    isHaveId=NO;
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic=(NSDictionary *)obj;
        
        if ([[dic stringForKey:@"id"] isEqualToString:mid]) {
            isHaveId=YES;
            if ([[dic stringForKey:@"isDownLoad"] isEqualToString:@"1"]) {
                isHaveDownLoad=YES;
            }
        }
        
    }];
    if (!isHaveId) {
        //没有下载
        return StatusDownLoad_NoneDownload;
    }
   else if (isHaveId&&!isHaveDownLoad) {
        //正在下载或者暂停
        return StatusDownLoad_DownLoading;
    }
    else if (isHaveId&&isHaveDownLoad)
    {
        //  下载完成！
        return StatusDownLoad_HaveDownload;
    }
    return StatusDownLoad_NoneDownload;

}


- (NSArray *)getDicFromMoiveModel
{
  
    
    return [self
            dictionaryWithJsonString:
            [CacheFile cache_file_get:dbString]];
}

- (NSArray *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];

    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return arr;
}


+ (void)deleteMovieId:(NSString *)mid MovieName:(NSString *) movieName;
{
    NSArray *arr=[[self alloc] dictionaryWithJsonString:[CacheFile cache_file_get:dbString]];
    NSMutableArray *arr1=[[NSMutableArray alloc]initWithArray:arr];
    __block BOOL isHaveId;
    __block NSInteger index;
    index=0;
    isHaveId=NO;
    [arr1 enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic=(NSDictionary *)obj;
        
        if ([[dic stringForKey:@"id"] isEqualToString:mid]) {
            isHaveId=YES;
            index=idx;
        }
        
    }];
    if (isHaveId) {
        [arr1 removeObjectAtIndex:index];
    }
    
    //对于错误信息
    NSError *error;
    // 创建文件管理器
    NSLog(@"path=============%@",[AppInfo pathFromLocalMovieName:movieName]);
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if ([fileMgr removeItemAtPath:[AppInfo pathFromLocalMovieName:movieName] error:&error] != YES)
    {
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    }
    [CacheFile cache_file_set:dbString
                     contents:[arr1 JSONString]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownLoadNSNotification object:nil];

    

}
- (void)setModelToJson:(NSDictionary *)dic;
{
  
    NSArray *arr1=[self dictionaryWithJsonString:[CacheFile cache_file_get:dbString]];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithDictionary:dic];
    
    NSMutableArray *arr=[NSMutableArray arrayWithArray:arr1];
    
    [dict setValue:@"0" forKey:@"isDownLoad"];
    [dict setValue:@"0" forKey:@"isStop"];

    
    __block BOOL isSame;
    isSame=NO;
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[dict stringForKey:@"id"] isEqualToString:[(NSDictionary *)obj objectForKey:@"id"]]) {
            isSame=YES;
        };
        
    }];
    if (!isSame) {
         [arr addObject:dict];
    }
    [CacheFile cache_file_set:dbString
                     contents:[arr JSONString]];
    
}

- (void)changeHavDic:(NSDictionary *)dic
{
    NSArray *arr1=[self dictionaryWithJsonString:[CacheFile cache_file_get:dbString]];
    NSMutableArray *arr=[NSMutableArray arrayWithArray:arr1];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithDictionary:dic];


    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[dict stringForKey:@"id"] isEqualToString:[(NSDictionary *)obj objectForKey:@"id"]]) {
            
            [(NSDictionary *)obj setValue:@"1" forKey:@"isDownLoad"];
        };
        
    }];
    [CacheFile cache_file_set:dbString
                     contents:[arr JSONString]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownLoadNSNotification object:nil];

    
    
}

- (unsigned long long)fileSizeForPath:(NSString *)path {
    
    signed long long fileSize = 0;
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if ([fileManager fileExistsAtPath:path]) {
        
        NSError *error = nil;
        
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        
        if (!error && fileDict) {
            
            fileSize = [fileDict fileSize];
        }
    }
    fileSize=fileSize/1024/1024;
    
    return fileSize;
}

- (void)saveDownLoadData:(NSDictionary *)dic
{
    NSArray *arr1=[self dictionaryWithJsonString:[CacheFile cache_file_get:dbString]];
    NSMutableArray *arr=[NSMutableArray arrayWithArray:arr1];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithDictionary:dic];
    
    
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[dict stringForKey:@"id"] isEqualToString:[(NSDictionary *)obj objectForKey:@"id"]]) {
            
            [(NSDictionary *)obj setValue:[dict stringForKey:@"totalSize"] forKey:@"totalSize"];
           
        };
        
    }];
    [CacheFile cache_file_set:dbString
                     contents:[arr JSONString]];
}
- (void)changeHavDic:(NSDictionary *)dic stopYesOrNo:(BOOL)isYes
{
    
    NSArray *arr1=[self dictionaryWithJsonString:[CacheFile cache_file_get:dbString]];
    NSMutableArray *arr=[NSMutableArray arrayWithArray:arr1];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithDictionary:dic];
    
    
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[dict stringForKey:@"id"] isEqualToString:[(NSDictionary *)obj objectForKey:@"id"]]) {
            if (isYes) {
                 [(NSDictionary *)obj setValue:@"1" forKey:@"isStop"];
            }
            else
            {
                 [(NSDictionary *)obj setValue:@"0" forKey:@"isStop"];
            }
        };
        
    }];
    [CacheFile cache_file_set:dbString
                     contents:[arr JSONString]];
}
- (BOOL)isStopFromDb:(NSString *)mid
{
    NSArray *arr1=[self dictionaryWithJsonString:[CacheFile cache_file_get:dbString]];
    NSMutableArray *arr=[NSMutableArray arrayWithArray:arr1];
   
    
    __block BOOL isStop;
    isStop=NO;
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([mid isEqualToString:[(NSDictionary *)obj objectForKey:@"id"]]) {
            
            if ([[(NSDictionary *)obj stringForKey:@"isStop"] isEqualToString:@"1"]) {
                isStop=YES;
            }
        
            
        };
        
    }];
    return isStop;

}

#pragma mark NSUserDefaults
- (void)removeKey:(int)ikey {
  NSString *strKey = [NSString stringWithFormat:@"%d", ikey];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:strKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)getArray:(int)ikey {
  NSString *strKey = [NSString stringWithFormat:@"%d", ikey];
  NSArray *temp = [[NSUserDefaults standardUserDefaults] arrayForKey:strKey];

  return temp;
}

- (void)setArray:(int)ikey arr:(NSArray *)arr {
  if (arr == nil) {
    [self removeKey:ikey];
    return;
  }
  NSString *strKey = [NSString stringWithFormat:@"%d", ikey];
  [[NSUserDefaults standardUserDefaults] setObject:[arr copy] forKey:strKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)getDictionary:(int)ikey {
  NSString *strKey = [NSString stringWithFormat:@"%d", ikey];
  NSDictionary *temp =
      [[NSUserDefaults standardUserDefaults] dictionaryForKey:strKey];
  return temp;
}

- (void)setDictionary:(int)ikey dict:(NSDictionary *)dict {
  if (dict == nil) {
    [self removeKey:ikey];
    return;
  }
  NSString *strKey = [NSString stringWithFormat:@"%d", ikey];
  [[NSUserDefaults standardUserDefaults] setObject:[dict copy] forKey:strKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getString:(int)ikey {
  NSString *strKey = [NSString stringWithFormat:@"%d", ikey];
  NSString *temp = [[NSUserDefaults standardUserDefaults] stringForKey:strKey];
  return temp ? temp : @"";
}

- (void)setString:(int)ikey str:(NSString *)str {
  if (str == nil) {
    [self removeKey:ikey];
    return;
  }
  NSString *strKey = [NSString stringWithFormat:@"%d", ikey];
  [[NSUserDefaults standardUserDefaults] setObject:[str copy] forKey:strKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)getBool:(int)ikey {

  NSString *strKey = [NSString stringWithFormat:@"%d", ikey];
  return [[NSUserDefaults standardUserDefaults] boolForKey:strKey];
}

- (void)setBool:(int)ikey val:(BOOL)val {
  NSString *strKey = [NSString stringWithFormat:@"%d", ikey];
  [[NSUserDefaults standardUserDefaults] setBool:val forKey:strKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)getInteger:(int)ikey {
  NSString *strKey = [NSString stringWithFormat:@"%d", ikey];
  return (int)[[NSUserDefaults standardUserDefaults] integerForKey:strKey];
}

- (void)setInteger:(int)ikey val:(int)val {
  NSString *strKey = [NSString stringWithFormat:@"%d", ikey];
  [[NSUserDefaults standardUserDefaults] setInteger:val forKey:strKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)NSInterToString:(NSInteger )index
{
    NSString *str=String_Format(@"%ld",index);
    return str;
}

#pragma mark httpMethods
+ (void)httpGET:(AppURL)appUrl
    headerWithUserInfo:(BOOL)headerWithUserInfo
            parameters:(NSDictionary *)parameters
          successBlock:(void (^)(int code, NSDictionary *dictResp))successBlock
          failureBlock:(void (^)(NSError *error))failureBlock {
  [[AppInfo instance] httpMethod:appUrl
                    isPostMethod:NO
              headerWithUserInfo:headerWithUserInfo
                          params:parameters
                    successBlock:successBlock
                    failureBlock:failureBlock];
}

+ (void)httpPOST:(AppURL)appUrl
    headerWithUserInfo:(BOOL)headerWithUserInfo
            parameters:(NSDictionary *)parameters
          successBlock:(void (^)(int code, NSDictionary *dictResp))successBlock
          failureBlock:(void (^)(NSError *error))failureBlock {
  [[AppInfo instance] httpMethod:appUrl
                    isPostMethod:YES
              headerWithUserInfo:headerWithUserInfo
                          params:parameters
                    successBlock:successBlock
                    failureBlock:failureBlock];
}

+ (void)cacheHttpResult:(NSString *)strKey content:(NSDictionary *)content {
  if (strKey && strKey.length > 0 && content) {
    [CacheFile cache_file_set:strKey contents:[content JSONString]];
  }
}
- (void)httpMethod:(AppURL)appUrl
          isPostMethod:(BOOL)isPostMethod
    headerWithUserInfo:(BOOL)headerWithUserInfo
                params:(NSDictionary *)params
          successBlock:(void (^)(int code, NSDictionary *dictResp))successBlock
          failureBlock:(void (^)(NSError *error))failureBlock {

  // TODO: 使用Cache来返回http请求结果
  NSString *strCacheKey = @"";
  NSInteger iCacheSeconds = 0;
  NSString *strCache =
      [CacheFile cache_file_get:strCacheKey expiredSecond:iCacheSeconds];
  if (strCache && strCache.length > 0) {
    NSData *data = [strCache dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = (NSDictionary *)
        [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
   // int code = [dict intForKey:@"code"];
  
      //DLog(@"use httpcache ====> %@", strCacheKey);
      successBlock(1, dict);
    
    return;
  }

  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  [manager.responseSerializer
      setAcceptableContentTypes:
          [NSSet setWithObjects:@"application/json", @"text/json",
                                @"text/javascript", @"text/html", @"text/css",
                                nil]];
  manager.responseSerializer = [AFJSONResponseSerializer serializer];
  manager.requestSerializer = [AFHTTPRequestSerializer serializer];

  NSString *strUrl = [HttpRequestClass stringHttpUrl:appUrl];
  if (isPostMethod) {
    _operation=[manager POST:strUrl
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"返回值格式不正确");
            return;
          }
          NSDictionary *dict = (NSDictionary *)responseObject;
          //int code = [dict intForKey:@"code"];

          // TODO: 存储Cache
          [[self class] cacheHttpResult:strCacheKey content:dict];
          successBlock(1, dict);

        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          failureBlock(error);
        }];
  } else {
    _operation=[manager GET:strUrl
        parameters:params
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSDictionary *dict = (NSDictionary *)responseObject;
          //int code = [dict intForKey:@"code"];
          // TODO: 存储Cache
          [[self class] cacheHttpResult:strCacheKey content:dict];
          successBlock(1, dict);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          failureBlock(error);
        }];
  }
}
- (void)cancelHttpMethods
{
    if (_operation) {
        [_operation cancel];
        _operation=nil;
        
        
    }
    [AppInfo hideLoading];
    [[AFHTTPRequestOperationManager manager].operationQueue cancelAllOperations];
}

+ (void)getMovieUrlMovieId:(NSString *)movieId complete:(void(^)(NSString *url))completeUrl;
{
    
    
    [AppInfo showLoading:YES SVProgressHUDMaskType:SVProgressHUDMaskTypeClear];
  
    if (movieId) {
        NSDictionary *parame=@{@"meid":movieId};
    
    
    [AppInfo httpGET:AppURL_Detail headerWithUserInfo:NO parameters:parame successBlock:^(int code, NSDictionary *dictResp) {
        NSArray *episodesArr=[dictResp arrayForKey:@"episodes"];
        if (episodesArr.count>0) {
            NSDictionary  *dic=[episodesArr objectAtIndex:0];
            NSArray *urlsArr=[dic objectForKey:@"urls"];
            if (urlsArr.count>0) {
                NSString *urlStr=[((NSDictionary *)[urlsArr objectAtIndex:0]) stringForKey:@"url"];
                   [AppInfo hideLoading];
                if (completeUrl) {
                    completeUrl(urlStr);
                }
            }
        }
         [AppInfo hideLoading];
        
        
    } failureBlock:^(NSError *error) {
        [AppInfo hideLoading];
    }];
    
    }
    
}

@end
