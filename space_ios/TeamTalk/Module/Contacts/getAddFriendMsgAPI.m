//
//  getAddFriendMsgAPI.m
//  TeamTalk
//
//  Created by mac on 16/11/17.
//  Copyright © 2016年 IM. All rights reserved.
//

#import "getAddFriendMsgAPI.h"
#import "IMBuddy.pb.h"
@implementation getAddFriendMsgAPI
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
        IMAddFriendData *ima=[IMAddFriendData parseFromData:data];
        
        
        
        return nil;
        
    };
    return analysis;
}
@end
