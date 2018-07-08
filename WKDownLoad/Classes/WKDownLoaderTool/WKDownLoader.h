//
//  WKDownLoader.h
//  loadFM
//
//  Created by 王开 on 2018/5/20.
//  Copyright © 2018年 com.wk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger ,WKDownLoadState) {
    WKDownLoadStatePause = 0,
    WKDownLoadStateDownLoading,
    WKDownLoadStatePauseSuccess,
    WKDownLoadStatePauseFailed
};

typedef void(^downInfoType) (long long totalSize);
typedef void(^stateChangeType) (WKDownLoadState state);
typedef void(^progressBlockType) (float progress);
typedef void(^successBlockType) (NSString * filePath);
typedef void(^failedBlockType)(void);

//一个下载器，对应一个下载任务
@interface WKDownLoader : NSObject

-(void)downLoader:(NSURL *)url downLoadInfo:(downInfoType)downLoadInfo progress:(progressBlockType)progressBlock success:(successBlockType)successBlock failed:(failedBlockType)failedBlock;


-(void)downLoader:(NSURL *)url;
- (void)pauseCurrentTask;
- (void)cancelCurrentTask;
- (void)cancelAndClean;
- (void)resumeCurrentTask;

@property(nonatomic, assign ,readonly) WKDownLoadState state;
@property(nonatomic, assign,readonly) float progress;

///事件
@property(nonatomic, copy) downInfoType downInfo;
@property(nonatomic, copy) stateChangeType stateChange;
@property(nonatomic, copy) progressBlockType progressChange;
@property(nonatomic,copy) successBlockType successBlock;
@property(nonatomic,copy) failedBlockType failedBlock;

@end
