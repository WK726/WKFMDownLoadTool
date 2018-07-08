//
//  WKDownLoaderManager.m
//  loadFM
//
//  Created by 王开 on 2018/5/23.
//  Copyright © 2018年 com.wk. All rights reserved.
//

#import "WKDownLoaderManager.h"
#import "NSString+WK.h"
@interface WKDownLoaderManager()<NSCopying,NSMutableCopying>
//@property(nonatomic, strong) WKDownLoader *downLoader;
@property(nonatomic, strong) NSMutableDictionary *downLoadInfo;
@end
@implementation WKDownLoaderManager
static WKDownLoaderManager *_shareInstance;
+(instancetype)shareInstance
{
    if (_shareInstance == nil) {
        _shareInstance = [[self alloc] init];
    }
    return _shareInstance;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
    return _shareInstance;
}
-(id)copyWithZone:(NSZone *)zone
{
    return _shareInstance;
}
-(NSMutableDictionary *)downLoadInfo
{
    if (!_downLoadInfo) {
        _downLoadInfo = [NSMutableDictionary dictionary];
    }
    return _downLoadInfo;
}

-(void)downLoader:(NSURL *)url downLoadInfo:(downInfoType)downLoadInfo progress:(progressBlockType)progressBlock success:(successBlockType)successBlock failed:(failedBlockType)failedBlock{
    
    //1.url
    NSString *urlMd5 = [url.absoluteString md5];
    WKDownLoader *downLoader = self.downLoadInfo[urlMd5];
    if (downLoader == nil) {
        downLoader = [[WKDownLoader alloc] init];
        self.downLoadInfo[urlMd5] = downLoader;
    }
    [downLoader downLoader:url downLoadInfo:downLoadInfo progress:progressBlock success:^(NSString *filePath) {
       //下载的删除
        [self.downLoadInfo removeObjectForKey:urlMd5];
        //拦截block
        successBlock(filePath);
    } failed:failedBlock];

}
- (WKDownLoader *)downLoadWithURL: (NSURL *)url
{
    
    // 文件名称  aaa/a.x  bb/a.x
    
    NSString *md5 = [url.absoluteString md5];
    
    WKDownLoader *downLoader = self.downLoadInfo[md5];
    if (downLoader) {
        [downLoader resumeCurrentTask];
        return downLoader;
    }
    downLoader = [[WKDownLoader alloc] init];
    [self.downLoadInfo setValue:downLoader forKey:md5];
    
    __weak typeof(self) weakSelf = self;
    [downLoader downLoader:url downLoadInfo:nil progress:^(float progress) {
    } success:^(NSString *filePath) {
        [weakSelf.downLoadInfo removeObjectForKey:md5];
    } failed:^{
        [weakSelf.downLoadInfo removeObjectForKey:md5];
    }];
    
    return downLoader;
    
}
-(void)pauseWithURL:(NSURL*)url{
    NSString *urlMD5 = [url.absoluteString md5];
    WKDownLoader *downLoader = self.downLoadInfo[urlMD5];
    [downLoader pauseCurrentTask];
}
-(void)resumeWithURL:(NSURL*)url{
    NSString *urlMD5 = [url.absoluteString md5];
    WKDownLoader *downLoader = self.downLoadInfo[urlMD5];
    [downLoader resumeCurrentTask];
}
-(void)cancelWithURL:(NSURL*)url{
    NSString *urlMD5 = [url.absoluteString md5];
    WKDownLoader *downLoader = self.downLoadInfo[urlMD5];
    [downLoader cancelCurrentTask];
}
-(void)pauseAll{
    [self.downLoadInfo.allValues performSelector:@selector(pauseCurrentTask) withObject:nil];
    
}
-(void)resumeAll{
    [self.downLoadInfo.allValues performSelector:@selector(resumeCurrentTask) withObject:nil];
    
}
@end
