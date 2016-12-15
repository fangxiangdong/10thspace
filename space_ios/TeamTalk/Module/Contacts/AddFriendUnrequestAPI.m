//
//  AddFriendUnrequestAPI.m
//  TeamTalk
//
//  Created by mac on 16/11/21.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "AddFriendUnrequestAPI.h"
#import "IMBuddy.pb.h"
@implementation AddFriendUnrequestAPI
- (int)responseServiceID
{
    return  SID_BUDDY_LIST;
}

- (int)responseCommandID
{
    return CID_BUDDY_LIST_ADD_FRIEND_DATA;
}

- (UnrequestAPIAnalysis)unrequestAnalysis
{
    UnrequestAPIAnalysis analysis = (id)^(NSData *data)
    {

        IMAddFriendData *datas=[IMAddFriendData parseFromData:data];
        
        
        return datas;
        
    };
    return analysis;
}
@end
