//
//  LGHDownloadManager.m
//  断电续传-LGH
//
//  Created by 高飞 on 2017/6/9.
//  Copyright © 2017年 高飞. All rights reserved.
//

#import "LGHDownloadManager.h"

@implementation LGHDownloadManager
+ (instancetype)sharedManager{
    static LGHDownloadManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LGHDownloadManager alloc]init];
    });
    return manager;
    
}

- (void)startDownloadingWithURL:(NSURL *)url{
    //方式一：downloadTaskWithRequest
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    if (self.resumeData) {
        self.task = [self.session downloadTaskWithResumeData:self.resumeData];
        //执行
        [self.task resume];
        
        NSLog(@"继续下载");
    }else{
        //task
        self.task = [self.session downloadTaskWithRequest:request];
        //执行task
        [self.task resume];
        NSLog(@"重新下载");
    }

}
- (void)pause{
    //防止多次点击按钮
    if (!self.task) {
        return ;
        
    }
    //取消下载
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        //resumeData:截止到点中暂停按钮瞬间,服务器返回的数据
        self.resumeData = resumeData;
        
        //设置task为nil,清空任务
        self.task = nil;
        
    }];
}
- (void)resumeDownload{
    //防止恢复按钮多次点击
    if (!self.resumeData) {
        return ;
        
    }
    //实际上执行一次新的发送任务的请求(从某个点之后开始下载)-downloadTaskWithResumeData
    self.task = [self.session downloadTaskWithResumeData:self.resumeData];
    //执行
    [self.task resume];
    //清空，设置resumeData为nil
    self.resumeData = nil;
}
#pragma mark---------NSURLSessionDownloadDelegate--下载完成后调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"下载完毕");
    //缓存
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *downloadPath = [cachesPath stringByAppendingPathComponent:@"download"];
    self.downloadPath = downloadPath;
    BOOL isSuccess = [[NSFileManager defaultManager] createDirectoryAtPath: downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
    if (isSuccess) {
        NSString* filePath = [downloadPath stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
        NSLog(@"%@",filePath);
        //转存到磁盘,复制
        NSError *error = nil;
        [[NSFileManager defaultManager]moveItemAtPath:location.path toPath:filePath error:&error];
        if (!error) {
            NSLog(@"成功复制到磁盘");
            
        }
        
    }
 
}
#pragma mark--------每次写入沙盒完毕调用
//调用多次;
/*bytesWritten:这一次服务器返回的数据的大小
 totalBytesWritten:截止到这一次服务器一共返回的数据大小
 totalBytesExpectedToWrite:请求的文件的总大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
    NSLog(@"文件总大小：%lld;已返回写入的文件大小:%lld;这一次写入的文件大小:%lld",totalBytesExpectedToWrite,totalBytesWritten,bytesWritten);
    CGFloat percent = totalBytesWritten * 1.0 /totalBytesExpectedToWrite;
    self.downloadBlock(percent);
    
    
    
    
    
}
#pragma mark----------恢复下载后调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"恢复下载:%lld",expectedTotalBytes);
    
}
- (void)getDownloadDataPercentWithBlock:(DownloadBlock)block{
    _downloadBlock = block;
    
}
- (void)clearCache{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.downloadPath]){
        [[NSFileManager defaultManager] removeItemAtPath:self.downloadPath error:nil];
        
    }
}
@end
