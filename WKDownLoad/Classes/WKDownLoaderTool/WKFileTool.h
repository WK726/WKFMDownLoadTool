//
//  WKFileTool.h
//  loadFM
//
//  Created by 王开 on 2018/5/20.
//  Copyright © 2018年 com.wk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKFileTool : NSObject
+ (BOOL)fileExists:(NSString *)filePath;
+(long long)fileSize:(NSString *)filePath;
+(void)moveFile:(NSString *)fromePath toPath:(NSString *)toPath;
+(void)removeFile:(NSString *)filePath;
@end
