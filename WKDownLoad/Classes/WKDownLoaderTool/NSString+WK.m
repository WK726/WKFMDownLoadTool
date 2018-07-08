//
//  NSString+WK.m
//  loadFM
//
//  Created by 王开 on 2018/5/25.
//  Copyright © 2018年 com.wk. All rights reserved.
//

#import "NSString+WK.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (WK)
- (NSString *)md5;
{
    const char *data = self.UTF8String;
    
    
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    //c语言的字符串转换为 md5字符串
    CC_MD5(data, (CC_LONG)strlen(data), md);
    
    //32位
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];

    for (int i = 0; i < CC_MD5_DIGEST_LENGTH ; i++) {
        [result appendFormat:@"%02x",md[i]];
    }
    return  result;
}
@end
