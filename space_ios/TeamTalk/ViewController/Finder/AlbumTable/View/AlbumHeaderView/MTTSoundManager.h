//
//  MTTSoundManager.h
//  TeamTalk
//
//  Created by 1 on 16/11/3.
//  Copyright © 2016年 IM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTTSoundManager : NSObject

+ (instancetype)sharedInstance;

- (void)playRefreshSound;

@end
