//
//  GetUnreadAddFriendMsgAPI.m
//  TeamTalk
//
//  Created by mac on 16/11/21.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "GetUnreadAddFriendMsgAPI.h"
#import "IMBuddy.pb.h"
#import "AddFriendMSGModel.h"
@implementation GetUnreadAddFriendMsgAPI
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
    return CID_BUDDY_LIST_GET_ADD_FRIEND_DATA_REQUEST;
}

- (int)responseCommendID
{
    return CID_BUDDY_LIST_GET_ADD_FRIEND_DATA_RESPONSE;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        
       IMGetAddFriendDataRsp *rsp = [IMGetAddFriendDataRsp  parseFromData:data];
        
        NSMutableArray *array=[[NSMutableArray alloc]init];
        for (IMAddFriendData *ima in [rsp dataList]) {
            
            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:ima.addFriendData options:NSJSONReadingMutableLeaves error:nil];
            
            
            AddFriendMSGModel *model=[[AddFriendMSGModel alloc]initWithDict:responseJSON];
            model.userId=ima.userId;
            model.friendId=ima.friendId;
            if (ima.type==SystemMsgTypeAddFriendAgree) {
                
                model.isAgree=2;
            }
            
            [array addObject:model];
            
            
        }
        
        
             return array;
        
    };
    return analysis;
}

- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        
        int count=[object intValue];
        
        
       IMGetAddFriendDataReqBuilder *addUser = [ IMGetAddFriendDataReq builder];
        [addUser setUserId:0];
        [addUser setMsgCnt:count];
        [addUser setAttachData:nil];
        
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:CID_BUDDY_LIST_GET_ADD_FRIEND_DATA_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[addUser build].data];
        [dataout writeDataCount];
        return [dataout toByteArray];
        
    };
    return package;
}

@end
