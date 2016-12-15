//
//  DDAddFriendMsgModule.m
//  TeamTalk
//
//  Created by mac on 16/11/16.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "DDAddFriendMsgModule.h"
#import "DDaddFriendAPI.h"
@implementation DDAddFriendMsgModule
+ (instancetype)shareInstance
{
    static DDAddFriendMsgModule* addFriendMessageModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        addFriendMessageModule = [[DDAddFriendMsgModule alloc] init];
    });
    return addFriendMessageModule;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //注册收到消息API
       
        
        [self p_registerReceiveMessageAPI];
    }
    return self;
}
- (void)p_registerReceiveMessageAPI
{
    
    DDaddFriendAPI* receiveMessageAPI = [[DDaddFriendAPI alloc] init];
    
    [receiveMessageAPI registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        
        
        
        
    }];
        
        
        
      
   
}
@end
