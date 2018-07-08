//
//  WKFileTool.m
//  loadFM
//
//  Created by 王开 on 2018/5/20.
//  Copyright © 2018年 com.wk. All rights reserved.
//

#import "WKFileTool.h"

@implementation WKFileTool
+ (BOOL)fileExists:(NSString *)filePath{
    if (filePath.length == 0) {
        return NO;
    }
    return  [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}
+(long long)fileSize:(NSString *)filePath{
    if (![self fileExists:filePath]) {
        return 0;
    }
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];

    return  [fileInfo[NSFileSize]  longLongValue];
}
+(void)moveFile:(NSString *)fromePath toPath:(NSString *)toPath{
    if (![self fileExists:fromePath]) {
        return;
    }
    [[NSFileManager defaultManager] moveItemAtPath:fromePath toPath:toPath error:nil];
}
+(void)removeFile:(NSString *)filePath{
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

@end
