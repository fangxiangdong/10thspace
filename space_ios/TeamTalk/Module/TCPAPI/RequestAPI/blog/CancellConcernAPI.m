//
//  CancellConcernAPI.m
//  TeamTalk
//
//  Created by 1 on 16/11/11.
//  Copyright © 2016年 IM. All rights reserved.
//

#import "CancellConcernAPI.h"
#import "IMBuddy.pb.h"
#import "MTTUserEntity.h"

@implementation CancellConcernAPI

/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 0;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return SID_BUDDY_LIST;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return SID_BUDDY_LIST;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return CID_BUDDY_LIST_DEL_FOLLOW_USER_REQUEST;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CID_BUDDY_LIST_DEL_FOLLOW_USER_RESPONSE;
}

/**
 *  解析数据的block
 *
 *  @return 解析数据的block
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData *data) {
        
        IMDelFollowUserRsp *resp = [IMDelFollowUserRsp parseFromData:data];
//        NSLog(@"---%@", resp);
        
        NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
        [dictM setObject:@(resp.resultCode) forKey:@"resultCode"];
        [dictM setObject:@(resp.friendId)   forKey:@"friendId"];
        
        return dictM;
    };
    
    return analysis;
}

/**
 *  打包数据的block
 *
 *  @return 打包数据的block
 */
- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo) {
        
        UInt32 friendID = [object intValue];
        MTTUserEntity *userEntity = (MTTUserEntity *)TheRuntime.user;
        
        IMDelFollowUserReqBuilder *reqBuilder = [IMDelFollowUserReq builder];
        // 设置参数
        [reqBuilder setUserId:(UInt32)userEntity.userID];
        [reqBuilder setFriendId:friendID];
        [reqBuilder setAttachData:nil];
        
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:CID_BUDDY_LIST_DEL_FOLLOW_USER_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[reqBuilder build].data];
        [dataout writeDataCount];
        
        return [dataout toByteArray];
    };
    
    return package;
}

@end
