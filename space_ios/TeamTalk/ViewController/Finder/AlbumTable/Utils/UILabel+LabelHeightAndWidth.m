//
//  UILabel+LabelHeightAndWidth.m
//  PersonalTailor
//
//  Created by 宋旭 on 16/8/30.
//  Copyright © 2016年 com.Bluemobi. All rights reserved.
//

#import "UILabel+LabelHeightAndWidth.h"

@implementation UILabel (LabelHeightAndWidth)

+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title fontSize:(CGFloat)fontSize
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
}

+ (CGFloat)getWidthWithTitle:(NSString *)title font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 0)];
    label.text = title;
    label.font = font;
    [label sizeToFit];
    return label.frame.size.width;
}

@end
