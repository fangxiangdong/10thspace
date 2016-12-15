//
//  DDAgreeAddFriendAPI.m
//  TeamTalk
//
//  Created by mac on 16/11/19.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "DDAgreeAddFriendAPI.h"
#import "IMBuddy.pb.h"
@implementation DDAgreeAddFriendAPI
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
    return  CID_BUDDY_LIST_AGREE_ADD_FRIEND_REQUEST;
}

- (int)responseCommendID
{
    return CID_BUDDY_LIST_AGREE_ADD_FRIEND_RESPONSE;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        IMAgreeAddFriendRsp *rsp=[IMAgreeAddFriendRsp parseFromData:data];
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
        NSDictionary*dict=object;
        
        UInt32 firendID =[dict[@"friend"]intValue] ;
        BOOL agree=[dict[@"agree"]boolValue];
        
        //NSData *msg = [@"请求添加好友" dataUsingEncoding:NSUTF8StringEncoding];
        
       IMAgreeAddFriendReqBuilder *addUser = [IMAgreeAddFriendReq builder];
        [addUser setUserId:0];
        [addUser setFriendId:firendID];
        
        if (agree) {
             [addUser setAgree:SystemMsgTypeAddFriendAgree];
        }else{
        
            [addUser setAgree: SystemMsgTypeAddFriendDisagree];

        }
       
//        [addUser setAttachData:nil];
//        [addUser setAdditionMsg:msg];
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:CID_BUDDY_LIST_AGREE_ADD_FRIEND_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[addUser build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
        
    };
    return package;
}

@end
