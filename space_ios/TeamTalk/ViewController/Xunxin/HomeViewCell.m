//
//  HomeViewCell.m
//  TeamTalk
//
//  Created by 1 on 16/11/4.
//  Copyright © 2016年 IM. All rights reserved.
//

#import "HomeViewCell.h"
#import "UIImageView+SDWebImage.h"
#import "MTTUserEntity.h"
/** OSS数据*/
#import <AliyunOSSiOS/OSSService.h>
#import "DDSendPhotoMessageAPI.h"

@interface HomeViewCell()

@property (nonatomic, weak) UIImageView *showImageView;
//@property (nonatomic, weak) UIImageView *headerImgView;
@property (nonatomic, weak) UILabel *nickLabel;

@end

@implementation HomeViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.showImageView = imageView;
        [self addSubview:imageView];
        
        
        // 用户信息 height = 35
        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 20, frame.size.width, 20)];
        infoView.backgroundColor = [UIColor lightGrayColor];
        infoView.alpha = 0.3;
        [imageView addSubview:infoView];
        
        
        // 头像
//        UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12, infoView.frame.origin.y + 2.5, 30, 30)];
//        headerImgView.backgroundColor = [UIColor cyanColor];
//        headerImgView.layer.cornerRadius = 15;
//        headerImgView.clipsToBounds = YES;
//        self.headerImgView = headerImgView;
//        [imageView addSubview:headerImgView];
        
        
        // 昵称 CGRectGetMaxX(headerImgView.frame) + 3 frame.size.width - CGRectGetMaxX(headerImgView.frame) - 5
        UILabel *nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, infoView.frame.origin.y + 2.5, frame.size.width, 15)];
        nickLabel.font = [UIFont systemFontOfSize:15.0];
        nickLabel.text = @"我是机器人";
        nickLabel.textAlignment = NSTextAlignmentCenter;
        nickLabel.textColor = [UIColor whiteColor];
        self.nickLabel = nickLabel;
        [imageView addSubview:nickLabel];
    }
    return self;
}

- (void)setUserEntity:(MTTUserEntity *)userEntity
{
    _userEntity = userEntity;
    
    // 用户id
    NSString *userID = [NSString stringWithFormat:@"%@", userEntity.userID];
    // 获取自己的id
    MTTUserEntity *mySelf = (MTTUserEntity *)TheRuntime.user;
    NSString *myID = [NSString stringWithFormat:@"%@", mySelf.userID];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 展示数据
        if (![myID isEqualToString:userID]) {
            // OSS加密
            NSString  *objectKey = [NSString stringWithFormat:@"im/live/%@.png", userID];
            OSSClient *client = [[DDSendPhotoMessageAPI sharedPhotoCache] ossInit];
            NSString  *constrainURL = nil;
            OSSTask   *task = [client presignConstrainURLWithBucketName:@"tenth"
                                                          withObjectKey:objectKey
                                                 withExpirationInterval: 30 * 60];
            if (!task.error) {
                constrainURL = task.result;
            } else {
                NSLog(@"error: %@", task.error);
            }
            // 更新UI
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:constrainURL]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data) {
                    self.showImageView.image = [UIImage imageWithData:data];
                }else {
                    self.showImageView.image = [UIImage imageNamed:@"toux"];
                }
            });
        }
    });
    
    // 昵称
    if (userEntity.nick.length) {
        self.nickLabel.text = userEntity.nick;
    }else if (userEntity.name.length){
        self.nickLabel.text = userEntity.name;
    }else {
        self.nickLabel.text = @"我是机器人";
    }
}

@end
