//
//  HttpRequestClass.h
//  huaqiao
//
//  Created by yiliao6 on 13/4/15.
//  Copyright (c) 2015 yiliao6. All rights reserved.
//

#import <Foundation/Foundation.h>


#define HTTPCODE_SUCCESS 1

@interface HttpRequestClass : NSObject

+ (NSString *)stringHttpUrl:(NSInteger)kUrl;

#pragma mark - 监测网络的可链接性
+ (BOOL)httpReachability:(NSInteger)kUrl;

+ (void)httpRequest:(NSInteger)appUrl
           isPostMethod:(BOOL)isPostMethod
                headers:(NSDictionary *)headers
                 params:(NSDictionary *)params
    WithCompletionBlock:(void (^)(id retData))completionBlock
       WithFailureBlock:(void (^)(NSError *err))failureBlock;
@end
