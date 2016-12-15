//
//  MXXSystemEntity.h
//  TeamTalk
//
//  Created by landu on 15/11/30.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "MTTBaseEntity.h"

#define SYSTEM_PRE @"system_"

@interface MXXSystemEntity : MTTBaseEntity

@property (nonatomic,strong) NSString *fromSessionId;
@property (nonatomic,strong) NSString *createTime;
@property (nonatomic,strong) NSString *content;

+(NSString *)pbSystemIdToLocalID:(NSUInteger)systemID;

@end
