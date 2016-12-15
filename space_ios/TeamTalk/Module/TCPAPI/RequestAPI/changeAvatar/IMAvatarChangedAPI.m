//
//  IMAvatarChangedAPI.m
//  TeamTalk
//
//  Created by landu on 15/11/24.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "IMAvatarChangedAPI.h"

@implementation IMAvatarChangedAPI

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
    return CID_BUDDY_LIST_CHANGE_AVATAR_REQUEST;
}

- (int)responseCommendID
{
    return CID_BUDDY_LIST_CHANGE_AVATAR_RESPONSE;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        IMChangeAvatarRsp *rsp = [IMChangeAvatarRsp parseFromData:data];
//        NSLog(@"--- rsp == %@",rsp);
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
//        NSLog(@"---object == %@",object);
        IMChangeAvatarReqBuilder *avatar = [IMChangeAvatarReq builder];
        [avatar setAvatarUrl:object];
        [avatar setAttachData:nil];
        [avatar setUserId:0];
        
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:CID_BUDDY_LIST_CHANGE_AVATAR_REQUEST
                                  seqNo:seqNo];
        [dataout directWriteBytes:[avatar build].data];
        [dataout writeDataCount];
        
        return [dataout toByteArray];
    };
    return package;
}

@end
