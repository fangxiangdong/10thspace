//
//  TLTapImageView.h
//  TLCycleScrollView
//
//  Created by andezhou on 15/8/4.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLClickImageView : UIImageView

@property (nonatomic, strong) UIColor *pageIndicatorTintColor;
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;
/** 保存图片的URL*/
@property (nonatomic, strong) NSArray *urlArray;

- (void)setViews:(NSArray *)views;

@end
