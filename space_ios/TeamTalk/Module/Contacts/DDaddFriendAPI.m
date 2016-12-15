//
//  DDaddFriendAPI.m
//  TeamTalk
//
//  Created by mac on 16/11/16.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "DDaddFriendAPI.h"
#import "IMBuddy.pb.h"
@implementation DDaddFriendAPI
- (int)responseServiceID
{
    return SID_BUDDY_LIST;
}

- (int)responseCommandID
{
    return CID_BUDDY_LIST_ADD_FRIEND_DATA;
}

- (UnrequestAPIAnalysis)unrequestAnalysis
{
    UnrequestAPIAnalysis analysis = (id)^(NSData *data)
    {
        IMGetAddFriendDataRsp *ima=[IMGetAddFriendDataRsp parseFromData:data];
        
        
        
        
        
        return ima;
        
    };
    return analysis;
}
@end
