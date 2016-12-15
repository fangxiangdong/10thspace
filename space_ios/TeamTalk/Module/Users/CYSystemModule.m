//
//  CYSystemModule.m
//  TeamTalk
//
//  Created by landu on 15/11/28.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "CYSystemModule.h"

@implementation CYSystemModule
{
    NSMutableDictionary* _allSystemInfo;
}

+ (instancetype)shareInstance
{
    static CYSystemModule* g_systemModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_systemModule = [[CYSystemModule alloc] init];
    });
    return g_systemModule;
}

-(void)addMaintanceSystem:(MXXSystemEntity *)system
{
    if (!system)
    {
        return;
    }
    if (!_allSystemInfo)
    {
        _allSystemInfo = [[NSMutableDictionary alloc] init];
    }

    NSLog(@"---- %@",system.fromSessionId);
    NSLog(@"---- %@",system.content);
    NSLog(@"---- %@",system.createTime);
    [_allSystemInfo setValue:system forKey:system.fromSessionId];
}

@end
