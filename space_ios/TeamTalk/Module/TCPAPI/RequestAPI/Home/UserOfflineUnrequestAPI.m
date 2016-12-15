//
//  UserOfflineUnrequestAPI.m
//  TeamTalk
//
//  Created by 1 on 16/11/21.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "UserOfflineUnrequestAPI.h"
#import "IMSystem.pb.h"

@implementation UserOfflineUnrequestAPI

- (int)responseServiceID
{
    return  SID_SYSTEM;
}

- (int)responseCommandID
{
    return CID_SYS_USER_OFFLINE;
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
//        NSMutableDictionary *friendOfflineList = [NSMutableDictionary dictionary];
//        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            
//            IMSystemUserOnline *userOffline = (IMSystemUserOnline *)obj;
//            
//            [friendOfflineList setObject:@(userOffline.friendId) forKey:@"userID"];
//            [friendOfflineList setObject:@(userOffline.type)     forKey:@"userType"];
//            
//        }];
        
        return analysis;
    };
    return analysis;
}

@end
