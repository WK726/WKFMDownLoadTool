//
//  WKDownLoaderManager.h
//  loadFM
//
//  Created by 王开 on 2018/5/23.
//  Copyright © 2018年 com.wk. All rights reserved.
//
/* 验证文件信息的完整性（1.可以在请求头里查看相应的信息，文件大小、文件内容的md5 2.可以在url里查看文件内容的md5）
*  1.后台可以将下载的内容的md5，然后和下载到本地的内容的md5进行比对，判断下载完成之后的信息是否正确（有专门进行文件的md5算法）
 * 2.或者将下载内容的md5类型信息设置为文件的名称，然后比对文件的名称和下载之后信息 （放到url中，直接查看是否和本地的文件内容一致）
*/
#import <Foundation/Foundation.h>
#import "WKDownLoader.h"
@interface WKDownLoaderManager : NSObject
+(instancetype)shareInstance;
- (WKDownLoader *)downLoadWithURL: (NSURL *)url;
-(void)downLoader:(NSURL *)url downLoadInfo:(downInfoType)downLoadInfo progress:(progressBlockType)progressBlock success:(successBlockType)successBlock failed:(failedBlockType)failedBlock;

-(void)pauseWithURL:(NSURL*)url;
-(void)resumeWithURL:(NSURL*)url;
-(void)cancelWithURL:(NSURL*)url;
-(void)resumeAll;
@end
