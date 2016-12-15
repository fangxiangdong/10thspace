//
//  AddFriendModule.h
//  TeamTalk
//
//  Created by mac on 16/11/18.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddFriendMSGModel.h"

@protocol setToolAndCellbarBadgeDelegate <NSObject>

-(void)setToolAndCellbarBadge:(NSInteger)count;

@end


@protocol AddFriendModuleDelegate<NSObject>
@optional
- (void)AddFriendModuleUpdate:(AddFriendMSGModel*)model;
-(void)addFriendUnreadMsgUpdate:(NSArray*)array;

@end

@interface AddFriendModule : NSObject
@property(nonatomic,weak)id<AddFriendModuleDelegate>delegate;
@property(nonatomic,weak)id<setToolAndCellbarBadgeDelegate>delegate2;
@property(nonatomic,assign)int unreadMsgCount;//从服务器取到的未读消息数
@property(nonatomic,assign)int reciverMsgCount;//实时接收到的消息数
+ (instancetype)instance;

-(int)getRecentAddFriendMsgCount:(void(^)(NSUInteger count))block;

-(int)onlyGetRecentAddFriendMsgCount:(void(^)(NSUInteger count))block;
@end
