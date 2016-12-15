//
//  AgreeAddFriendAPi.m
//  TeamTalk
//
//  Created by landu on 15/11/26.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "AgreeAddFriendAPi.h"
#import "IMBuddy.pb.h"
@implementation AgreeAddFriendAPi

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
    return CID_BUDDY_LIST_AGREE_ADD_FRIEND_REQUEST;
}

- (int)responseCommendID
{
    return CID_BUDDY_LIST_AGREE_ADD_FRIEND_RESPONSE;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        
        IMAgreeAddFriendRsp *rsp = [IMAgreeAddFriendRsp parseFromData:data];
        NSLog(@"---AgreeAddFriend == %@",rsp);
        
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
        NSData *msg = [@"OK" dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"--- %u",(unsigned int)friendID);
        IMAgreeAddFriendReqBuilder *agree = [IMAgreeAddFriendReq builder];
        [agree setUserId:0];
        [agree setFriendId:friendID];
        [agree setAgree:2];
        [agree setAdditionMsg:msg];
        [agree setAttachData:nil];
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:CID_BUDDY_LIST_AGREE_ADD_FRIEND_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[agree build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
        
    };
    return package;
}


@end
