//
//  SystemViewController.h
//  TeamTalk
//
//  Created by landu on 15/11/30.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "MTTBaseViewController.h"
#import "MXXSystemEntity.h"
#import "MTTSessionEntity.h"
#import "ChattingModule.h"
#import "MTTDatabaseUtil.h"
@interface SystemViewController : MTTBaseViewController

@property (nonatomic,strong) MTTSessionEntity *session;
@property(nonatomic,strong)ChattingModule* module;




@end
