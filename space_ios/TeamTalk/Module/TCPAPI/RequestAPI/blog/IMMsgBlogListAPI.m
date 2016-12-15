//
//  IMMsgBlogListAPI.m
//  TeamTalk
//
//  Created by landu on 15/11/19.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "IMMsgBlogListAPI.h"
#import "MXXBlogEntity.h"
#import "XunxinModel.h"
#import "IMBlog.pb.h"
#import "MTTUserEntity.h"

@implementation IMMsgBlogListAPI

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
    return CID_BLOG_GET_LIST_REQUEST;
}

- (int)responseCommendID
{
    return CID_BLOG_GET_LIST_RESPONSE;
}

- (Analysis)analysisReturnData
{   
    Analysis analysis = (id)^(NSData* data) {
        
        IMBlogGetListRsp *rsp = [IMBlogGetListRsp parseFromData:data];
//        NSLog(@"blogList---%@", rsp);
        
        NSMutableArray *list = [NSMutableArray array];
        for(BlogInfo *blogInfo in [rsp blogList]){
            
            XunxinModel *blog = [[XunxinModel alloc] initWithPB:blogInfo];
            // 包装成数组
            NSArray *array = @[blog];
            
            // 添加到可变数组
            [list addObject:array];
        }
        
        return list;
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo) {
        
        NSDictionary *dict = (NSDictionary *)object;
        
        // 处理请求参数
        BlogType requestBlogType;
        NSString *type = [NSString stringWithFormat:@"%@", [dict objectForKey:@"blogType"]];
        if ([type isEqualToString:@"1"]) {
            requestBlogType = BlogTypeBlogTypeRcommend;
        }
        else if ([type isEqualToString:@"2"]) {
            requestBlogType = BlogTypeBlogTypeFriend;
        }
        else if ([type isEqualToString:@"3"]) {
            requestBlogType = BlogTypeBlogTypeFollowuser;
        }
        NSString *pageString     = [dict objectForKey:@"page"];
        NSString *pageSizeString = [dict objectForKey:@"pageSize"];
        NSInteger page           = [pageString integerValue];
        NSInteger pageSize       = [pageSizeString integerValue];
        
        // 设置参数
        MTTUserEntity *userEntity = (MTTUserEntity *)TheRuntime.user;
        
        IMBlogGetListReqBuilder *blog = [IMBlogGetListReq builder];
        [blog setUserId:(UInt32)userEntity.userID];
        [blog setUpdateTime:0];
        [blog setBlogType:requestBlogType];
        [blog setPage:(UInt32)page];
        [blog setPageSize:(UInt32)pageSize];
        [blog setAttachData:nil];
        
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BLOG
                                    cId:CID_BLOG_GET_LIST_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[blog build].data];
        [dataout writeDataCount];
        
        return [dataout toByteArray];
    };
    return package;
}

@end
