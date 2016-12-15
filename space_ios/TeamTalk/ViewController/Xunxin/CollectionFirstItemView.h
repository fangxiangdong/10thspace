//
//  CollectionFirstItemView.h
//  TeamTalk
//
//  Created by 1 on 16/11/4.
//  Copyright © 2016年 IM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CollectionFirstItemViewDelegate <NSObject>

/**
 * 开始上传
 */
- (void)startUploadImage;
/**
 * 停止上传
 */
- (void)stopUploadImage;

@end

@interface CollectionFirstItemView : UIView

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) id<CollectionFirstItemViewDelegate> delegate;

@end
