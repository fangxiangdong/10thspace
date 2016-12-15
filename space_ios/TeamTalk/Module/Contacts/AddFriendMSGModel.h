//
//  AddFriendMSGModel.h
//  TeamTalk
//
//  Created by mac on 16/11/18.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddFriendMSGModel : NSObject
@property(nonatomic,copy)NSString*addition_msg;
@property(nonatomic,copy)NSString*avatar_url;
@property(nonatomic,copy)NSString*nick_name;
@property(nonatomic,assign)int userId;
@property(nonatomic,assign)int friendId;
@property(nonatomic,copy)NSString*type;
@property(nonatomic,assign)int isAgree;
-(id)initWithDict:(NSDictionary*)dict;
@end
