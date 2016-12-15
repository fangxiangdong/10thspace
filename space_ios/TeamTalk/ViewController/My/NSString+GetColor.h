//
//  NSString+GetColor.h
//  PersonalTailor
//
//  Created by mac on 16/8/5.
//  Copyright © 2016年 com.Bluemobi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (GetColor)
//16位颜色编码字符串转UIColor
+ (UIColor *) colorWithHexString: (NSString *)color;
@end
