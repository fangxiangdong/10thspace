//
//  MXXBlogEntity.h
//  TeamTalk
//
//  Created by landu on 15/11/19.
//  Copyright © 2015年 IM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMBaseDefine.pb.h"

@class MsgInfo;

@interface MXXBlogEntity : NSObject

@property (nonatomic,strong) NSString *msgType;
@property (nonatomic,strong) NSString *fromSessionId;
@property (nonatomic,strong) NSString *createTime;
@property (nonatomic,strong) NSData *msgData;
@property (nonatomic,strong) NSString *blogContent;
@property (nonatomic,strong) NSMutableArray *blogImages;


-(id)initWithPB:(MsgInfo *)pbBlog;


@end
