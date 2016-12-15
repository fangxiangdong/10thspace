//
//  UserOnlineUnrequestAPI.m
//  TeamTalk
//
//  Created by 1 on 16/11/21.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "UserOnlineUnrequestAPI.h"
#import "IMSystem.pb.h"

@implementation UserOnlineUnrequestAPI

- (int)responseServiceID
{
    return  SID_SYSTEM;
}

- (int)responseCommandID
{
    return CID_SYS_USER_ONLINE;
}

- (UnrequestAPIAnalysis)unrequestAnalysis
{
    UnrequestAPIAnalysis analysis = (id)^(NSData *data)
    {
//        IMSystemUserOnlineData *onlineDatas = [IMSystemUserOnlineData parseFromData:data];
////        NSLog(@"onlineDatas--%@", onlineDatas);
//        
//        NSArray *array = onlineDatas.userList;
//        
//        NSMutableDictionary *friendOnlineList = [NSMutableDictionary dictionary];
//        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            
//            IMSystemUserOnline *userOnline = (IMSystemUserOnline *)obj;
//            
//            [friendOnlineList setObject:@(userOnline.friendId) forKey:@"userID"];
//            [friendOnlineList setObject:@(userOnline.type)     forKey:@"userType"];
//            
//        }];
        
        return analysis;
    };
    return analysis;
}

@end
