//
//  MXXSystemEntity.m
//  TeamTalk
//
//  Created by landu on 15/11/30.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "MXXSystemEntity.h"

@implementation MXXSystemEntity

+(NSString*)pbSystemIdToLocalID:(NSUInteger)systemID
{
    return [NSString stringWithFormat:@"%@%ld",SYSTEM_PRE,(unsigned long)systemID];
}

@end
