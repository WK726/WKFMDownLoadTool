//
//  WKDownLoader.m
//  loadFM
//
//  Created by 王开 on 2018/5/20.
//  Copyright © 2018年 com.wk. All rights reserved.
//

#import "WKDownLoader.h"
#import "WKFileTool.h"

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmpPath NSTemporaryDirectory()

@interface WKDownLoader()<NSURLSessionDataDelegate>
{
    long long _tmpSize;
    long long _totalSize;
}
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) NSString *downLoadedPath;
@property (nonatomic, copy) NSString *downLoadingPath;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, weak) NSURLSessionDataTask *dataTask;

@end
@implementation WKDownLoader
-(void)downLoader:(NSURL *)url downLoadInfo:(downInfoType)downLoadInfo progress:(progressBlockType)progressBlock success:(successBlockType)successBlock failed:(failedBlockType)failedBlock
{
    //block赋值
    self.downInfo = downLoadInfo;
    self.progressChange = progressBlock;
    self.successBlock = successBlock;
    self.failedBlock = failedBlock;
    
    [self downLoader:url];
    
}
-(NSURLSession *)session{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration  defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}
-(void)downLoader:(NSURL *)url
{
    //实现两个功能：正在下载的时候继续下载
    //如果任务存在，继续下载
    if ([url isEqual:self.dataTask.originalRequest.URL]) {
        //判断当前的状态，
        [self resumeCurrentTask];
        return;
    }
    
    
    
    //1.文件的存放
    //下载ing =》 temp + 名称
    //MD5+URL 防止重复资源
    //a/1.png md5-
    //b/1.png
    //下载完成 =》 cache + 名称
    
    NSString *fileName = url.lastPathComponent;
    
    self.downLoadedPath = [kCachePath stringByAppendingPathComponent:fileName];;
    self.downLoadingPath = [kTmpPath stringByAppendingPathComponent:fileName];;
    //1.判断，url得治，对应的资源，是下载完成(判断目录里文件是否存在)
    //1.1 告诉外界，下载完成，并且传递相关信息（本地的路径，文件的大小）
    //return
    if ([WKFileTool fileExists:self.downLoadedPath]) {
        //UNDO:告诉外界下载完成
        NSLog(@"文件完成");
        self.state = WKDownLoadStatePauseSuccess;

        return;
    }
    
    //2.检测临时问津啊是否存在

    //2.1 不存在：从0字节开始请求资源
    //return
    if (![WKFileTool fileExists:self.downLoadingPath]) {
        //从0开始下载资源
        [self downLoadWithUrl:url offset:0];
        return;
    }
    
    //2.2 存在，：直接，以当前存在的文件大小，作为开始字节，去网络请求资源
    //HTTP:rang： 开始字节-
    //正确的大小1000 实际1001
    //本地大小 == 总大小 ==》移动到下载完成路径中
    //本地大小 〉 总大小  ==》 从0开始下载
    //本地大小 < 总大小 ==》 从本地大小开始下载
    
    //获取本地大小
    _tmpSize = [WKFileTool fileSize:self.downLoadingPath];
    [self downLoadWithUrl:url offset:_tmpSize];
    //获取总大小
    //发送网络请求
    //同步/异步
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    NSURLResponse *respose = nil;
//    request.HTTPMethod = @"HEAD";
//    NSError *error = nil;
//    [NSURLConnection sendSynchronousRequest:request returningResponse:&respose error:&error];
//    //资源已经下载完毕了
//    //我们需要的是响应头
//    if (error == nil) {
//        NSLog(@"%@",respose);
//    }
}

#pragma mark - 协议方法
//第一次接收到相应的时候掉用（响应头，并没有具体的资源内容）
//通过这个方法里面，系统提供的代码块，可以控制，是继续请求还是取消本次请求 NSURLSessionResponseDisposition 代码块
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    
    //总大小
    //本地缓存大小
    //content-length 请求的大小 ！= 资源的大小
    //content-range里取总的大小 如果请求投里没设置开始bytes，那么没有该key
    //1.从content-length 取出来
    //2.如果content-range 有，应该从centent-range里获取
    _totalSize = [((NSHTTPURLResponse *)response).allHeaderFields[@"Content_Length"] longLongValue];
    NSString *contentRangeStr = ((NSHTTPURLResponse *)response).allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        _totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    //传递给外界信息：总大小 & 本地文件的路径
    if (self.downInfo) {
        self.downInfo(_totalSize);
    }
    
    
    //比对本地大小和总大小
    if (_tmpSize == _totalSize) {
        //移动到下载完成文件夹
        NSLog(@"文件移动到cache缓存");
        [WKFileTool moveFile:self.downLoadingPath toPath:self.downLoadedPath];
        self.state = WKDownLoadStatePauseSuccess;
        //取消本次请求
        completionHandler(NSURLSessionResponseCancel);

        return;
    }
    
    if (_tmpSize > _totalSize) {
        //1.删除临时缓存
        [WKFileTool removeFile:self.downLoadingPath];
        NSLog(@"删除临时缓存");
        //2.取消本次请求
        completionHandler(NSURLSessionResponseCancel);
        
        //3.从0开始下载 downLoader 包含一些验证工作，所以用这个方法
        [self downLoader:response.URL];
        
        return;
    }

    //继续接收数据 _tmpSize < _totalSize
    //确定开始下载数据 输出流进行创建一个通道直接放到磁盘里。不占用内存
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downLoadingPath append:YES];
    [self.outputStream open];
    self.state = WKDownLoadStateDownLoading;

    completionHandler(NSURLSessionResponseAllow);

}
//当用户确定，继续接收数据的时候掉用
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    _tmpSize += data.length;
    self.progress = 1.0*_tmpSize/_totalSize;
    [self.outputStream write:data.bytes maxLength:data.length];
}
//请求完成的时候掉用（！= 请求失败/成功）
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"请求完成");
    if (error == nil) {
        //不一定是成功
        //数据确实请求完毕
        //下载的每一小段里可能有重叠的内容，其实是内容错误的
        //判断本地缓存 == 文件总大小（filename ： filesize ： md5:）
        //如果等于 =》 验证，是否文件完整（file md5）
        [WKFileTool moveFile:self.downLoadingPath toPath:self.downLoadedPath];
        self.state = WKDownLoadStatePauseSuccess;
    }else{
        NSLog(@"有问题");
        if (error.code == 999) {
            self.state = WKDownLoadStatePause;
        }else{
            self.state = WKDownLoadStatePauseFailed;
        }
    }
    [self.outputStream close];
}
#pragma mark - 私有方法
-(void)downLoadWithUrl:(NSURL *)url offset:(long long) offset
{

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    //session分配的task，默认情况，是挂起状态
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self resumeCurrentTask];
}


#pragma mark - 暂停
- (void)pauseCurrentTask{
    
    if (self.state == WKDownLoadStateDownLoading) {
        self.state = WKDownLoadStatePause;
        [self.dataTask suspend];
    }

}
- (void)cancelCurrentTask
{    self.state = WKDownLoadStatePause;

    //晴空session缓存可以
    [self.session invalidateAndCancel];
    self.session = nil;
}
- (void)cancelAndClean
{
    //只删除正在下载的文件
    [self cancelCurrentTask];
    [WKFileTool removeFile:self.downLoadingPath];
    
    //如果删除下载完成的文件那么：
    //下载完成的文件 -》 手动删除 -〉统一清理缓存
}
//继续任务
- (void)resumeCurrentTask{
    
    if (self.dataTask && self.state == WKDownLoadStatePause) {
        [self.dataTask resume];
        self.state = WKDownLoadStateDownLoading;
    }

}

#pragma mark - 时间传递
//只有内部用
-(void)setState:(WKDownLoadState)state
{
    if (_state == state) {
        return;
    }
    _state = state;
    if (self.stateChange) {
        self.stateChange(_state);
    }
    
    if (_state == WKDownLoadStatePauseSuccess && self.successBlock) {
        self.successBlock(self.downLoadedPath);
    }
    
    if (_state == WKDownLoadStatePauseFailed && self.failedBlock) {
        self.failedBlock();
    }
}

-(void)setProgress:(float)progress
{
    _progress = progress;
    if (self.progressChange) {
        self.progressChange(_progress);
    }
    
}









@end
