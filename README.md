# LGHDownloadManager
简易断点下载，简易api. Simple breakpoint download, simple api.
API:
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
