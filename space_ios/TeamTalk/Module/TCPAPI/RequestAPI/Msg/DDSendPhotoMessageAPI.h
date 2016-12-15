//
//  DDSendPhotoMessageAPI.h
//  IOSDuoduo
//
//  Created by 东邪 on 14-6-6.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDSuperAPI.h"

@class OSSClient;
@interface DDSendPhotoMessageAPI : NSObject

+ (DDSendPhotoMessageAPI *)sharedPhotoCache;

- (OSSClient *)ossInit;

- (void)uploadImage:(NSString*)imagePath success:(void(^)(NSString* imageURL))success failure:(void(^)(id error))failure;

/**
 *  上传说说数据至阿里云OSS
 *
 *  @param filePath 数据本地磁盘路径
 *  @param success  成功回调
 *  @param failure  失败回调
 */
- (void)uploadBlogToAliYunOSSWithContent:(NSString *)filePath success:(void(^)(NSString *fileURL))success failure:(void(^)(NSError *error))failure;

//上传头像至阿里云
- (void)uploadAvatarToAliYunOSSWithContent:(NSString *)imageKey andUserID:(NSString*)userID success:(void(^)(NSString *fileURL))success failure:(void(^)(NSError *error))failure;

/**
 *  首页图片上传阿里云
 *
 */
- (void)homeUploadBlogToAliYunOSSWithContent:(NSString *)imageKey success:(void(^)(NSString *fileURL))success failure:(void(^)(NSError *error))failure;

/**
 *  博客图片上传阿里云
 *
 */
- (void)blogImagesUploadToAliYunOSSWithContent:(NSString *)imageKey success:(void(^)(NSString *fileURL))success failure:(void(^)(NSError *error))failure;

/**
 *  消息图片上传阿里云
 *
 */
- (void)uploadMsgImageToAliYunOSSWithContent:(NSString *)imageKey andUserID:(NSString*)userID success:(void(^)(NSString *fileURL))success failure:(void(^)(NSError *error))failure;

@end
