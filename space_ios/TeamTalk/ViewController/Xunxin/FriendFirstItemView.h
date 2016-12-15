//
//  FriendFirstItemView.h
//  TeamTalk
//
//  Created by 1 on 16/11/28.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendFirstItemViewDelegate <NSObject>

/**
 * 开始上传
 */
- (void)startUploadImage;
/**
 * 停止上传
 */
- (void)stopUploadImage;
/**
 * 提醒用户去开启权限
 */
- (void)alertUserOpenCameraSetting;
/**
 * 用户已拒绝开启摄像头
 */
- (void)userRefuseOpenCamera;

@end

@interface FriendFirstItemView : UIView

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) id<FriendFirstItemViewDelegate> delegate;

@end
