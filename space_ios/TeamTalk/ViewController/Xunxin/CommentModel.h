//
//  CommentModel.h
//  TeamTalk
//
//  Created by landu on 15/12/16.
//  Copyright © 2015年 IM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMBaseDefine.pb.h"


@class MsgInfo;
@class BlogInfo;

@interface CommentModel : NSObject

@property (nonatomic,copy) NSString *commentID;
@property (nonatomic,copy) NSString *headImage;
@property (nonatomic,copy) NSString *userName;

// new model
@property (nonatomic,strong) NSString *blogType;
@property (nonatomic,strong) NSString *writerUserId;
@property (nonatomic,strong) NSString *likeCnt;
@property (nonatomic,strong) NSString *commentCnt;
/** 评论id*/
@property (nonatomic,copy) NSString *blogId;
/** 头像*/
@property (nonatomic,copy) NSString *avatarUrl;
/** 昵称*/
@property (nonatomic,copy) NSString *nickName;
/** 评论时间*/
@property (nonatomic,copy) NSString *createTime;
/** 评论内容*/
@property (nonatomic,copy) NSString *comment;
/** 内容的高度*/
@property (nonatomic,assign,readonly) CGFloat commentHeight;

-(id)initWithPB:(BlogInfo *)pbBlog;

@end
