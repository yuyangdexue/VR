//
//  LCDownloadManager.m
//  TTlol
//
//  Created by 刘超 on 15/7/9.
//  Copyright (c) 2015年 Leo. All rights reserved.
//

#import "LCDownloadManager.h"

@interface LCDownloadManager ()
@property (nonatomic,strong) NSString *mCachePath;
@property (nonatomic,strong) AFHTTPRequestOperation *mOperation;
@property (nonatomic, strong) NSMutableArray *paths;


@end

@implementation LCDownloadManager

- (NSMutableArray *)paths {
    
    if (!_paths) {
        
        _paths = [[NSMutableArray alloc] init];
    }
    
    return _paths;
}

#pragma mark - 类方法

+ (unsigned long long)fileSizeForPath:(NSString *)path {
    
    return [[self alloc] fileSizeForPath:path];
}

+ (AFHTTPRequestOperation *)downloadFileWithURLString:(NSString *)URLString cachePath:(NSString *)cachePath progressBlock:(DownloadProgress)progressBlock successBlock:(DownloadSuccess)successBlock failureBlock:(DownloadFailure)failureBlock {
    
    return [[self alloc] downloadFileWithURLString:URLString
                                         cachePath:cachePath
                                     progressBlock:progressBlock
                                      successBlock:successBlock
                                      failureBlock:failureBlock];
}

+ (void)pauseWithOperation:(AFHTTPRequestOperation *)operation {
    
    [[self alloc] pauseWithOperation:operation];
}

#pragma mark - 实例方法

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
    
    return fileSize;
}

- (AFHTTPRequestOperation *)downloadFileWithURLString:(NSString *)URLString cachePath:(NSString *)cachePath progressBlock:(DownloadProgress)progressBlock successBlock:(DownloadSuccess)successBlock failureBlock:(DownloadFailure)failureBlock {
    
//    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    // 下载文件本地文件夹 (此处是为了下载视频所以`/Video`)
    // 提醒: 下载文件到Download目录下一定要给用户提示, 为了审核!! 如: http://github.com/LeoiOS/LCProgressHUD
//    NSString *videoDir = [NSString stringWithFormat:@"%@/Download/Video", docPath];
//    BOOL isDir = NO;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL existed = [fileManager fileExistsAtPath:videoDir isDirectory:&isDir];
//    
//    if (!(isDir == YES && existed == YES)) {
//        
//        [fileManager createDirectoryAtPath:videoDir withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    
//    NSString *filePath = [videoDir stringByAppendingPathComponent:cachePath];
    _mCachePath=cachePath;
    NSString *filePath=cachePath;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    unsigned long long downloadedBytes = 0;
    
    NSLog(@"%@", filePath);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        // 获取已下载的文件长度
        downloadedBytes = [self fileSizeForPath:filePath];
        
        // 检查文件是否已经下载了一部分
        if (downloadedBytes > 0) {
            
            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            request = mutableURLRequest;
        }
    }
    
    // 不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    // 下载请求
    _mOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // 检查是否已经有该下载任务. 如果有, 释放掉...
    for (NSDictionary *dic in self.paths) {
        
        if ([cachePath isEqualToString:dic[@"path"]] && ![(AFHTTPRequestOperation *)dic[@"operation"] isPaused]) {
            
            return dic[@"operation"];
            
        } else {
            
            [(AFHTTPRequestOperation *)dic[@"operation"] cancel];
        }
    }
    NSDictionary *dicNew = @{@"path"        : cachePath,
                             @"operation"   : self.mOperation};
    [self.paths addObject:dicNew];
  
    // 下载路径
    self.mOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
    
//    [self.mOperation addObserver:self forKeyPath:@"isPaused" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    // 下载进度回调
    [self.mOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        // 下载进度
        CGFloat progress = ((CGFloat)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes);
        
        progressBlock(progress, (totalBytesRead + downloadedBytes) / 1024 / 1024.0f, (totalBytesExpectedToRead + downloadedBytes) / 1024 / 1024.0f);
    }];
    
    // 成功和失败回调
    [self.mOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        successBlock(operation, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failureBlock(operation, error);
    }];
    
    [self.mOperation start];
    
    // 为了做暂停，把这个下载任务返回
    return self.mOperation;
}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    NSLog(@"keypath = %@ changeDic = %@",keyPath,change);
//    //暂停状态
//    if ([keyPath isEqualToString:@"isPaused"] && [[change objectForKey:@"new"] intValue] == 1) {
//        
//        
//        
//        long long cacheLength = [[self class] fileSizeForPath:self.mCachePath];
//        //暂停读取data 从文件中获取到NSNumber
//        cacheLength = [[self.mOperation.outputStream propertyForKey:NSStreamFileCurrentOffsetKey] unsignedLongLongValue];
//        NSLog(@"cacheLength = %lld",cacheLength);
//        [self.mOperation setValue:@"0" forKey:@"totalBytesRead"];
//        //重组进度block
//        
//        __weak LCDownloadManager *weakSelf=self;
//        [self.mOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//            NSData* data = [NSData dataWithContentsOfFile:weakSelf.mCachePath];
//            [weakSelf.mOperation setValue:data forKey:@"responseData"];
//            CGFloat progress = (totalBytesRead + cacheLength) / (totalBytesExpectedToRead + cacheLength);
////            weakSelf.downloadProgress=^(CGFloat progress, CGFloat totalMBRead, CGFloat totalMBExpectedToRead)
////            {
////                
////            };
//            if (weakSelf.downloadProgress) {
//                weakSelf.downloadProgress(progress, (totalBytesRead + cacheLength) / 1024 / 1024.0f, (totalBytesExpectedToRead + cacheLength) / 1024 / 1024.0f);
//            }
//        }];
//      
//    }
//}



- (void)pauseWithOperation:(AFHTTPRequestOperation *)operation {
    
    NSLog(@"Pause download");
    
    [operation pause];
}

@end
