//
//  SearchUserAPI.m
//  TeamTalk
//
//  Created by landu on 15/11/11.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "SearchUserAPI.h"
#import "IMBuddy.pb.h"
#import "MTTUserEntity.h"
@implementation SearchUserAPI

- (int)requestTimeOutTimeInterval
{
    return 0;
}

- (int)requestServiceID
{
    return SID_BUDDY_LIST;
}

- (int)responseServiceID
{
    return SID_BUDDY_LIST;
}

- (int)requestCommendID
{
    return CID_BUDDY_LIST_SEARCH_USER_REQUEST;
}

- (int)responseCommendID
{
    return CID_BUDDY_LIST_SEARCH_USER_RESPONSE;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        IMSearchUserRsp *rsp = [IMSearchUserRsp parseFromData:data];
        NSLog(@"--- %@",rsp);
        NSMutableArray* userList = [[NSMutableArray alloc] init];
        for (UserInfo *userInfo in [rsp searchUserList]) {
            MTTUserEntity *user = [[MTTUserEntity alloc] initWithPB:userInfo];

            NSArray *array = @[user];
            
            [userList addObject:array];
        }
 
        return userList;
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
  
        NSString* nickName = (NSString*)object;
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        IMSearchUserReqBuilder *searchUser = [IMSearchUserReq builder];
        [searchUser setUserId:0];
        [searchUser setSearchUserName:nickName];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:CID_BUDDY_LIST_SEARCH_USER_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[searchUser build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
        
    };
    return package;
}

@end
