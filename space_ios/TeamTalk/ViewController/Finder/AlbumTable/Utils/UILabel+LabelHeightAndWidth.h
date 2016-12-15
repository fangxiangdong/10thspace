//
//  UILabel+LabelHeightAndWidth.h
//  PersonalTailor
//
//  Created by 宋旭 on 16/8/30.
//  Copyright © 2016年 com.Bluemobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (LabelHeightAndWidth)

+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title fontSize:(CGFloat)fontSize;

+ (CGFloat)getWidthWithTitle:(NSString *)title font:(UIFont *)font;

@end
