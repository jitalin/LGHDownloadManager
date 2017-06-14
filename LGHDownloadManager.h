//
//  LGHDownloadManager.h
//  断电续传-LGH
//
//  Created by 高飞 on 2017/6/9.
//  Copyright © 2017年 高飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^DownloadBlock) (CGFloat percent);
@interface LGHDownloadManager : NSObject<NSURLSessionDownloadDelegate>
//task
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
//session
@property (nonatomic, strong) NSURLSession *session;
//resumeData
@property (nonatomic, strong) NSData *resumeData;
@property (nonatomic,copy) DownloadBlock downloadBlock;
//下载目录
@property (nonatomic,strong) NSString *downloadPath;
+ (instancetype)sharedManager;
//开始下载或继续下载
- (void)startDownloadingWithURL:(NSURL*)url;
//暂停下载
- (void)pause;
//恢复下载
- (void)resumeDownload;
//获取下载进度
- (void)getDownloadDataPercentWithBlock:(DownloadBlock)block;
//清空下载目录
- (void)clearCache;
@end
