//
//  HomeMainAPI.m
//  TeamTalk
//
//  Created by 1 on 16/11/8.
//  Copyright © 2016年 IM. All rights reserved.
//

#import "HomeMainAPI.h"
#import "MTTUserEntity.h"
#import "IMBuddy.pb.h"

@implementation HomeMainAPI

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
    return CID_BUDDY_LIST_ALL_ONLINE_USER_CNT_REQUEST;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CID_BUDDY_LIST_ALL_ONLINE_USER_CNT_RESPONSE;
}

/**
 *  解析数据的block
 *
 *  @return 解析数据的block
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData *data) {
        
        IMALLOnlineUserCntRsp *resp = [IMALLOnlineUserCntRsp parseFromData:data];
        
        NSString *userID     = [NSString stringWithFormat:@"%u", resp.userId];
        NSString *totalCount = [NSString stringWithFormat:@"%u", resp.onlineUserCnt];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:userID     forKey:@"userID"];
        [dict setObject:totalCount forKey:@"onlineUserCnt"];
        
        return dict;
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
        
        MTTUserEntity *userEntity = (MTTUserEntity *)TheRuntime.user;
        
        IMALLOnlineUserCntReqBuilder *reqBuilder = [IMALLOnlineUserCntReq builder];
        // 设置参数
        [reqBuilder setUserId:(UInt32)userEntity.userID];
        [reqBuilder setAttachData:nil];
        
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:CID_BUDDY_LIST_ALL_ONLINE_USER_CNT_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[reqBuilder build].data];
        [dataout writeDataCount];
        
        return [dataout toByteArray];
    };
    
    return package;
}

@end
