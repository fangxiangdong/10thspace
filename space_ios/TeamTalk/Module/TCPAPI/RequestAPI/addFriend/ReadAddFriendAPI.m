//
//  ReadAddFriendAPI.m
//  TeamTalk
//
//  Created by mac on 16/11/21.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "ReadAddFriendAPI.h"
#import "IMBuddy.pb.h"
@implementation ReadAddFriendAPI


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
    return CID_BUDDY_LIST_ADD_FRIEND_READ_DATA_ACK;
}

- (int)responseCommendID
{
    return CID_BUDDY_LIST_ADD_FRIEND_READ_DATA_ACK;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        
        
    };
    return nil;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        
        
        
        
        IMAddFriendReadDataAckBuilder *addUser = [ IMAddFriendReadDataAck builder];
        [addUser setUserId:0];
        
        
        
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:CID_BUDDY_LIST_ADD_FRIEND_READ_DATA_ACK
                                  seqNo:seqNo];
        [dataout directWriteBytes:[addUser build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
        
    };
    return package;
}

@end
