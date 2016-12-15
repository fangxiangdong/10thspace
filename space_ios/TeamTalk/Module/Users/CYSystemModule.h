//
//  CYSystemModule.h
//  TeamTalk
//
//  Created by landu on 15/11/28.
//  Copyright © 2015年 IM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXXSystemEntity.h"

@interface CYSystemModule : NSObject

+ (instancetype)shareInstance;

- (void)addMaintanceSystem:(MXXSystemEntity*)system;

@end
