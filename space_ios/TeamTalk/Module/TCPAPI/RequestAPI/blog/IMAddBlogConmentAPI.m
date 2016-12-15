//
//  IMAddBlogConmentAPI.m
//  TeamTalk
//
//  Created by landu on 15/12/8.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "IMAddBlogConmentAPI.h"
#import "IMBlog.pb.h"
#import "MTTUserEntity.h"

@implementation IMAddBlogConmentAPI

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
    return CID_BLOG_ADD_COMMENT_REQUEST;
}

- (int)responseCommendID
{
    return CID_BLOG_ADD_COMMENT_RESPONSE;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data) {
        
       IMBlogAddCommentRsp *rsp = [IMBlogAddCommentRsp parseFromData:data];
//        NSLog(@"--- rsp == %@",rsp);
        
        NSString *commentID = [NSString stringWithFormat:@"%u",(unsigned int)rsp.commentId];
        NSString *updatatime = [NSString stringWithFormat:@"%u",(unsigned int)rsp.updateTime];
        NSString *resultCode = [NSString stringWithFormat:@"%u",(unsigned int)rsp.resultCode];
        
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        
        NSArray *array = @[commentID, updatatime, resultCode];
        [dataArray addObject:array];
        
        return dataArray;
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        //NSLog(@"--- %@",object);
        NSArray* array = (NSArray*)object;
//        NSLog(@"--%@--%d",array[0],[array[1] intValue]);
        MTTUserEntity *userEntity = (MTTUserEntity *)TheRuntime.user;
        
        IMBlogAddCommentReqBuilder *blog = [IMBlogAddCommentReq builder];
        
        [blog setUserId:(UInt32)userEntity.userID];
        [blog setBlogId:[array[1] intValue]];
        [blog setBlogData:array[0]];
        [blog setAttachData:nil];
        
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BLOG
                                    cId:CID_BLOG_ADD_COMMENT_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[blog build].data];
        [dataout writeDataCount];
        
        return [dataout toByteArray];
    };
    return package;
}


@end
