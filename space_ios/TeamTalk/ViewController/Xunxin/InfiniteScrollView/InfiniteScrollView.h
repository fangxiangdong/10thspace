//
//  InfiniteScrollView.h
//  无限轮播器
//
//  Created by 杨晓明 on 16/5/7.
//  Copyright © 2016年 杨晓明. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InfiniteScrollView;
@protocol InfiniteScrollViewDelegate <NSObject>

- (void)infiniteScrollView:(InfiniteScrollView* )infiniteScrollView didClickImageAtIndex:(NSInteger)index;

@end

@interface InfiniteScrollView : UIView

// 接收外界传进来的图片/图片的url
@property (strong, nonatomic) NSArray *imagesArray;
// 占位图片
@property (strong, nonatomic) UIImage *placeholderImage;

@property (weak, nonatomic) id<InfiniteScrollViewDelegate> delegate;

@end
