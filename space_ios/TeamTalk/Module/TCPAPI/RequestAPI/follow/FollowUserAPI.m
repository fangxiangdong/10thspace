//
//  FollowUserAPI.m
//  TeamTalk
//
//  Created by landu on 15/12/17.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "FollowUserAPI.h"
#import "IMBuddy.pb.h"

@implementation FollowUserAPI

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
    return CID_BUDDY_LIST_FOLLOW_USER_REQUEST;
}

- (int)responseCommendID
{
    return CID_BUDDY_LIST_FOLLOW_USER_RESPONSE;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        IMFollowUserRsp *rsp = [IMFollowUserRsp parseFromData:data];
        NSLog(@"--- rsp == %@",rsp);
        NSMutableArray *array = [NSMutableArray new];
        [array addObject:@(rsp.resultCode)];
        return array;
        
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        UInt32 friendID = [object intValue];
        NSLog(@"---friend == %u",(unsigned int)friendID);
        
        IMFollowUserReqBuilder *follow = [IMFollowUserReq builder];
        [follow setUserId:0];
        [follow setFriendId:friendID];
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:CID_BUDDY_LIST_FOLLOW_USER_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[follow build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    
    return package;
}

@end
