//
//  GetUnreadAddFriendMsgCntAPI.m
//  TeamTalk
//
//  Created by mac on 16/11/21.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "GetUnreadAddFriendMsgCntAPI.h"
#import "IMBuddy.pb.h"
@implementation GetUnreadAddFriendMsgCntAPI
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
    return CID_BUDDY_LIST_ADD_FRIEND_UNREAD_CNT_REQUEST;
}

- (int)responseCommendID
{
    return CID_BUDDY_LIST_ADD_FRIEND_UNREAD_CNT_RESPONSE;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        
        IMAddFriendUnreadCntRsp *rsp = [IMAddFriendUnreadCntRsp  parseFromData:data];
        
//        //NSLog(@"---add == %@",rsp);
//        
//        NSMutableArray *array = [NSMutableArray new];
//        [array addObject:@(rsp.resultCode)];
        return [NSString stringWithFormat:@"%d",rsp.unreadCnt];
        
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        
        
        
        
        IMAddFriendUnreadCntReqBuilder *addUser = [ IMAddFriendUnreadCntReq builder];
        [addUser setUserId:0];
       
        [addUser setAttachData:nil];
       
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:CID_BUDDY_LIST_ADD_FRIEND_UNREAD_CNT_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[addUser build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
        
    };
    return package;
}

@end
