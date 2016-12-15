//
//  UpdataUserInfoAPI.m
//  TeamTalk
//
//  Created by mac on 16/12/14.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "UpdataUserInfoAPI.h"
#import "IMBuddy.pb.h"
#import "MTTUserEntity.h"
@implementation UpdataUserInfoAPI

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
    return CID_BUDDY_LIST_UPDATE_USER_INFO_REQUEST ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CID_BUDDY_LIST_UPDATE_USER_INFO_RESPONSE;
}

/**
 *  解析数据的block
 *
 *  @return 解析数据的block
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData *data) {
        
        IMUpdateUsersInfoRsp
         *resp=[IMUpdateUsersInfoRsp parseFromData:data];
        
        NSMutableArray *array = [NSMutableArray new];
        [array addObject:@(resp.resultCode)];
        
        return array;

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
        
        IMUpdateUsersInfoReqBuilder *reqBuilder=[ IMUpdateUsersInfoReq builder];
        
        MTTUserEntity *userEntity = (MTTUserEntity *)TheRuntime.user;
        
        NSArray *array= (NSArray*)object;
      
        UserInfoBuilder *infob=[UserInfo builder];

        
        [infob setUserId:0];
        [infob setUserGender:[array[0] intValue]];
        [infob setUserNickName:array[1]];
        [infob setEmail:@""];
        [infob setSignInfo:array[2]];
        [infob setAvatarUrl:@""];
        [infob setDepartmentId:0];
         [infob setUserRealName:@""];
        [infob setUserTel:@""];
        [infob setUserDomain:@""];
        [infob setStatus:0];
        // 设置参数
        [reqBuilder setUserId:(UInt32)userEntity.userID];
        
        
        
 [reqBuilder setUserInfoBuilder:infob];
        
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:CID_BUDDY_LIST_UPDATE_USER_INFO_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[reqBuilder build].data];
        [dataout writeDataCount];
        
        return [dataout toByteArray];
    };
    
    return package;
}

@end
