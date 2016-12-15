//
//  XunxinModel.h
//  TeamTalk
//
//  Created by landu on 15/11/4.
//  Copyright © 2015年 IM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMBaseDefine.pb.h"


@class MsgInfo;
@class BlogInfo;

@interface XunxinModel : NSObject

@property (nonatomic,strong) NSString *msgType;
@property (nonatomic,strong) NSString *fromSessionId;
//@property (nonatomic,strong) NSString *createTime;
@property (nonatomic,strong) NSData   *msgData;
@property (nonatomic,strong) NSString *blogID;

// new model 9个属性
@property (nonatomic,strong) NSString *blogId;
@property (nonatomic,strong) NSString *blogType;
@property (nonatomic,strong) NSString *writerUserId;
@property (nonatomic,strong) NSString *nickName;
@property (nonatomic,strong) NSString *avatarUrl;
@property (nonatomic,strong) NSString *likeCnt;
@property (nonatomic,strong) NSString *commentCnt;
@property (nonatomic,strong) NSString *createTime;
@property (nonatomic,strong) NSData   *blogData;


@property (nonatomic,copy) NSString *headImage;
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *industry;
@property (nonatomic,copy) NSString *educationBackground;
@property (nonatomic,copy) NSString *publishTime;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,strong) NSMutableArray *imgArray;
@property (nonatomic,copy)   NSString *allImageUrl;

// 照片墙高度imgArr.count决定 0 80 160 240
@property (nonatomic,assign,readonly) CGFloat photoViewHeight;
// 说说内容高度
//@property (nonatomic,assign,readonly) CGFloat contentWidth;
@property (nonatomic,assign,readonly) CGFloat contentHeight;
//@property (nonatomic,assign,readonly) CGRect rect;

-(id)initWithPB:(BlogInfo *)pbBlog;

+ (XunxinModel *)xunxinModelFromDic:(NSDictionary *)dict;

@end
