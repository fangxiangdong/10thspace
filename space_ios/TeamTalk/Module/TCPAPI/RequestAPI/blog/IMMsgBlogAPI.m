//
//  IMMsgBlogAPI.m
//  TeamTalk
//
//  Created by landu on 15/11/16.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "IMMsgBlogAPI.h"
#import "IMBlog.pb.h"
#import "MTTUserEntity.h"

@implementation IMMsgBlogAPI

- (int)requestTimeOutTimeInterval
{
    return 0;
}

- (int)requestServiceID
{
    return SID_BLOG;
}

- (int)responseServiceID
{
    return SID_BLOG;
}

- (int)requestCommendID
{
    return CID_BLOG_SEND;
}

- (int)responseCommendID
{
    return CID_BLOG_SEND_ACK;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data) {
     
        IMBlogSendAck *res = [IMBlogSendAck parseFromData:data];
//        NSLog(@"hhh---res %@",res);
        
        NSMutableArray *array = [NSMutableArray new];
        [array addObject:@(res.userId)];
        
        return array;
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo) {
        
        MTTUserEntity *userEntity = (MTTUserEntity *)TheRuntime.user;
        
        IMBlogSendBuilder *blog = [IMBlogSend builder];
        [blog setUserId:(UInt32)userEntity.userID];
        [blog setBlogData:object];
        [blog setAttachData:nil];
        
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BLOG
                                    cId:CID_BLOG_SEND
                                  seqNo:seqNo];
        [dataout directWriteBytes:[blog build].data];
        [dataout writeDataCount];
        
        return [dataout toByteArray];
    };
    return package;
}

@end
