//
//  UserCameraOpenAPI.m
//  TeamTalk
//
//  Created by 1 on 16/11/23.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "UserCameraOpenAPI.h"
#import "IMSystem.pb.h"

@implementation UserCameraOpenAPI

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
        IMSystemCameraStatusData *onlineDatas = [IMSystemCameraStatusData parseFromData:data];
        
//        PBArray *array = onlineDatas.friendIdList;
//        
//        NSMutableArray *friendOnlineList = [NSMutableArray array];
//        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            
//            NSString *friendID = [NSString stringWithFormat:@"%@", obj];
//            [friendOnlineList addObject:friendID];
//            
//        }];
        
        return onlineDatas;
    };
    return analysis;
}


@end
