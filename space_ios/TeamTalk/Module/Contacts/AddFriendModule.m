//
//  AddFriendModule.m
//  TeamTalk
//
//  Created by mac on 16/11/18.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "AddFriendModule.h"
#import "IMBuddy.pb.h"
#import "AddFriendMsgViewController.h"
#import "AddFriendUnrequestAPI.h"
#import "GetUnreadAddFriendMsgCntAPI.h"
#import "GetUnreadAddFriendMsgAPI.h"
#import "MTTDatabaseUtil.h"
#import "MTTNotification.h"
#import "LoginModule.h"
#import "DDUserModule.h"
#import "SpellLibrary.h"
@implementation AddFriendModule
+ (instancetype)instance
{
    static AddFriendModule* module;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        module = [[AddFriendModule alloc] init];
        
    });
    return module;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addFriendAPI];
        self.reciverMsgCount=0;
        //        [self getRecentAddFriendMsgCount:^(NSUInteger count) {
        //
        //        }];
        
        
    }
    
    
    return self;
}

-(void)addFriendAPI
{
    
    AddFriendUnrequestAPI *api=[[AddFriendUnrequestAPI alloc]init];
    [api registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        
        
        self.reciverMsgCount++; //实时收取的信息数加一
        
        [self.delegate2 setToolAndCellbarBadge:self.reciverMsgCount];
        IMAddFriendData *data=object;
        
        if (data.type==SystemMsgTypeAddFriendAgree) {
            
            [[LoginModule instance] p_loadAllUsersCompletion:^{
                
                if ([[SpellLibrary instance] isEmpty]) {
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [[[DDUserModule shareInstance] getAllMaintanceUser] enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                            [[SpellLibrary instance] addSpellForObject:obj];
                            [[SpellLibrary instance] addDeparmentSpellForObject:obj];
                            
                        }];
                    });
                }
            }];
            
            
        }
        
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data.addFriendData options:NSJSONReadingMutableLeaves error:nil];
        
        
        AddFriendMSGModel *model=[[AddFriendMSGModel alloc]initWithDict:responseJSON];
        model.userId=data.userId;
        model.friendId=data.friendId;
        if (data.type==SystemMsgTypeAddFriendAgree) {
            model.isAgree=2;
        }
        
        
        
        if (self.delegate && [self.delegate respondsToSelector:@selector( AddFriendModuleUpdate:)]) {
            [self.delegate AddFriendModuleUpdate:model];
        }
        
        if (![self contain:model andArray:[AddFriendMsgViewController instance].dataArray]) {
            [[AddFriendMsgViewController instance].dataArray addObject:model];
            
        }
        
        [[MTTDatabaseUtil instance]insertAlladdFriendMsg:@[model] completion:^(NSError *error) {
            
        }];
        
        
        
    }];
    
    
    
    
    
}
-(void)getRecentAddFriendMSG:(NSString*)count :(void(^)(NSUInteger count))block
{
    GetUnreadAddFriendMsgAPI*api=[[GetUnreadAddFriendMsgAPI alloc]init];
    
    [api requestWithObject:count Completion:^(id response, NSError *error) {
        
        
        [[MTTDatabaseUtil instance]insertAlladdFriendMsg:response completion:^(NSError *error) {
            
        }];
        
        
        //      if (self.delegate && [self.delegate respondsToSelector:@selector( addFriendUnreadMsgUpdate:)]) {
        //           [self.delegate addFriendUnreadMsgUpdate:response];
        //      }
        
        
    }];
    
    
}

-(int)getRecentAddFriendMsgCount:(void(^)(NSUInteger count))block
{
    
    
    
    GetUnreadAddFriendMsgCntAPI *api=[[GetUnreadAddFriendMsgCntAPI alloc]init];
    
    [api requestWithObject:nil Completion:^(id response, NSError *error) {
        
        self.unreadMsgCount=[response intValue];
        [self getRecentAddFriendMSG:response  :^(NSUInteger count) {
            
            
            
            
            
            
        }];
        
        
        
    }];
    
    
    return self.unreadMsgCount;
}



-(int)onlyGetRecentAddFriendMsgCount:(void(^)(NSUInteger count))block
{
    
    
    
    GetUnreadAddFriendMsgCntAPI *api=[[GetUnreadAddFriendMsgCntAPI alloc]init];
    
    [api requestWithObject:nil Completion:^(id response, NSError *error) {
        
        self.unreadMsgCount=[response intValue];
        
        block([response intValue]);
        
    }];
    
    
    return self.unreadMsgCount;
}





-(BOOL)contain:(AddFriendMSGModel*)model andArray:(NSArray*)dataArray
{
    
    for (AddFriendMSGModel* modelInArray in dataArray) {
        
        if (modelInArray.friendId==model.friendId) {
            return YES;
        }
        
    }
    
    return NO;
    
    
    
}


@end
