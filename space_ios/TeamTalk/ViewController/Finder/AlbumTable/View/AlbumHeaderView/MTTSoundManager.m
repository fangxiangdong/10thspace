//
//  MTTSoundManager.m
//  TeamTalk
//
//  Created by 1 on 16/11/3.
//  Copyright © 2016年 IM. All rights reserved.
//

#import "MTTSoundManager.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation MTTSoundManager
{
    SystemSoundID refreshSound;
}

+ (instancetype)sharedInstance {
    static MTTSoundManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MTTSoundManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"pullrefresh" withExtension:@"aif"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url) , &refreshSound);
    }
    return self;
}

- (void)playRefreshSound {
    AudioServicesPlaySystemSound(refreshSound);
}

@end
