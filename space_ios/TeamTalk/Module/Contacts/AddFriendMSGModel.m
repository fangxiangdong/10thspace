//
//  AddFriendMSGModel.m
//  TeamTalk
//
//  Created by mac on 16/11/18.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "AddFriendMSGModel.h"

@implementation AddFriendMSGModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        
        if ([self isExist:dict[@"addition_msg"]]) {
            self.addition_msg=dict[@"addition_msg"];
        }
        if ([self isExist:dict[@"avatar_url"]]) {
            self.avatar_url=dict[@"avatar_url"];
        }if ([self isExist:dict[@"nick_name"]]) {
            self.nick_name=dict[@"nick_name"];
        }
        
        
    }
    return self;
}

-(BOOL)isExist:(NSString*)string
{
    if ([string isKindOfClass:[NSNull class]] || string ==nil) {
        return NO;
    }else {
        return YES;
    }




}
@end
