//
//  AddFriendAPI.m
//  TeamTalk
//
//  Created by landu on 15/11/11.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "AddFriendAPI.h"

#import "IMBuddy.pb.h"
#import "MTTUserEntity.h"

@implementation AddFriendAPI

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
    return CID_BUDDY_LIST_ADD_FRIEND_REQUEST;
}

- (int)responseCommendID
{
    return CID_BUDDY_LIST_ADD_FRIEND_RESPONSE;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        
        IMAddFriendRsp *rep = [IMAddFriendRsp parseFromData:data];
        NSLog(@"---add == %@",rep);
        
        NSMutableArray *array = [NSMutableArray new];
        [array addObject:@(rep.resultCode)];
        return array;
        
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        
        NSArray *array=object;
        UInt32 firendID = [array[0]  intValue];

        NSData *msg = [array[1] dataUsingEncoding:NSUTF8StringEncoding];
        
        IMAddFriendReqBuilder *addUser = [IMAddFriendReq builder];
        [addUser setUserId:0];
        [addUser setFriendId:firendID];
        [addUser setAttachData:nil];
        [addUser setAdditionMsg:msg];
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:CID_BUDDY_LIST_ADD_FRIEND_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[addUser build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
        
    };
    return package;
}


@end
