//
//  IMGetBlogCommentAPI.m
//  TeamTalk
//
//  Created by landu on 15/12/16.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "IMGetBlogCommentAPI.h"
#import "CommentModel.h"
#import "IMBlog.pb.h"
#import "MTTUserEntity.h"

@implementation IMGetBlogCommentAPI

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
    return CID_BLOG_GET_COMMENT_REQUEST;
}

- (int)responseCommendID
{
    return CID_BLOG_GET_COMMENT_RESPONSE;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data) {
       
        IMBlogGetCommentRsp *rsp = [IMBlogGetCommentRsp parseFromData:data];
//        NSLog(@"rsp---%@", rsp);
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        
        for(BlogInfo *info in [rsp commentList]){
            
            //NSLog(@"--- info = %@",info);
            CommentModel *commentModel = [[CommentModel alloc] initWithPB:info];
            
            NSArray *array = @[commentModel];
            
            [list addObject:array];
        }
        
        return list;
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        NSString *blogID = (NSString*)object;
//        NSLog(@"blogID--%@", blogID);
        
        MTTUserEntity *user = (MTTUserEntity *)TheRuntime.user;
        
        IMBlogGetCommentReqBuilder *blog = [IMBlogGetCommentReq builder];
        [blog setUserId:(UInt32)user.userID];
        [blog setBlogId:[blogID intValue]];
        [blog setUpdateTime:0];
        
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BLOG
                                    cId:CID_BLOG_GET_COMMENT_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[blog build].data];
        [dataout writeDataCount];
        
        return [dataout toByteArray];
    };
    return package;
}


@end
