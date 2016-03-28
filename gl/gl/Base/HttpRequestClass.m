//
//  HttpRequestClass.m
//  huaqiao
//
//  Created by yiliao6 on 13/4/15.
//  Copyright (c) 2015 yiliao6. All rights reserved.
//

#import "HttpRequestClass.h"
#import "AppInfo.h"

@implementation HttpRequestClass

#pragma mark - 监测网络的可链接性
+ (BOOL)httpReachability:(NSInteger)kUrl {
    
    __block BOOL netState = NO;
    NSString *strUrl = [HttpRequestClass stringHttpUrl:kUrl];
    NSURL *baseURL = [NSURL URLWithString:strUrl];
    AFHTTPRequestOperationManager *manager =
    [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    NSOperationQueue *operationQueue = manager.operationQueue;
    [manager.reachabilityManager
     setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
         switch (status) {
             case AFNetworkReachabilityStatusReachableViaWWAN:
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 [operationQueue setSuspended:NO];
                 netState = YES;
                 break;
             case AFNetworkReachabilityStatusNotReachable:
                 netState = NO;
             default:
                 [operationQueue setSuspended:YES];
                 break;
         }
     }];
    
    [manager.reachabilityManager startMonitoring];
    return netState;
}

+ (NSString *)stringHttpUrl:(NSInteger)kUrl {
    NSString *strSuffix = @"";
    switch (kUrl) {
            
        case AppURL_Imax:
            strSuffix = @"list";
            break;
        case AppURL_Detail:
            strSuffix = @"media/detail";
            break;
        case AppURL_3D:
            strSuffix = @"list/threedimensional";
            break;
        case AppURL_360:
            strSuffix = @"list/panoramic";
            break;
            
        default:
            break;
    }
    if (strSuffix.length > 0) {
        return [NSString stringWithFormat:@"%@%@", PREFIX_URL, strSuffix];
    }
    return strSuffix;
}

+ (void)httpRequest:(NSInteger)appUrl
       isPostMethod:(BOOL)isPostMethod
            headers:(NSDictionary *)headers
             params:(NSDictionary *)params
WithCompletionBlock:(void (^)(id retData))completionBlock
   WithFailureBlock:(void (^)(NSError *err))failureBlock {
    
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *val,
                                                 BOOL *stop) {
        [manager.requestSerializer setValue:val forHTTPHeaderField:key];
    }];
    
    NSLog(@"HTTPRequestHeaders=====> %@",
          manager.requestSerializer.HTTPRequestHeaders);
    
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseString========%@", operation.responseString);
        //        NSDictionary *dict = (NSDictionary *)responseObject;
        //        NSLog(@"responseDict========> %@", dict);
        completionBlock(responseObject);
    };
    
    void (^errBlock)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@" errBlock - responseString========> %@ \n %@",
              operation.responseString, [error description]);
        failureBlock(error);
    };
    
    NSString *strUrl = [HttpRequestClass stringHttpUrl:appUrl];
    NSLog(@"managerReq======>%@", strUrl);
    if (isPostMethod) {
        [manager POST:strUrl
           parameters:params
              success:successBlock
              failure:errBlock];
    } else {
        [manager GET:strUrl
          parameters:params
             success:successBlock
             failure:errBlock];
    }
}

@end
