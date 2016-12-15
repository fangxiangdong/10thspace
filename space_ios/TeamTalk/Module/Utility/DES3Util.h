//
//  DES3Util.h
//  AesBase64Test
//
//  Created by CloverFly on 14/11/18.
//  Copyright (c) 2014年 CloverStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DES3Util : NSObject

// 加密方法
+ (NSString*)encrypt:(NSString*)plainText;

// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText;

@end
