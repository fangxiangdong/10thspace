//
//  DeleteFriendAPI.m
//  TeamTalk
//
//  Created by mac on 16/11/11.
//  Copyright © 2016年 IM. All rights reserved.
//

#import "DeleteFriendAPI.h"

#import "IMBuddy.pb.h"
#import "MTTUserEntity.h"
@implementation DeleteFriendAPI
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
    return CID_BUDDY_LIST_DEL_FRIEND_REQUEST;
}

- (int)responseCommendID
{
    return CID_BUDDY_LIST_DEL_FRIEND_RESPONSE;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        
       IMDelFriendRsp *rsp = [IMDelFriendRsp parseFromData:data];
      
        //NSLog(@"---add == %@",rsp);
        
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
        UInt32 firendID = [object intValue];
        
       
        
        IMDelFriendReqBuilder *addUser = [IMDelFriendReq builder];
        [addUser setUserId:0];
        [addUser setFriendId:firendID];
        [addUser setAttachData:nil];
        [addUser setAdditionMsg:nil];
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:CID_BUDDY_LIST_DEL_FRIEND_REQUEST                   
                                  seqNo:seqNo];
        [dataout directWriteBytes:[addUser build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
        
    };
    return package;
}

@end
