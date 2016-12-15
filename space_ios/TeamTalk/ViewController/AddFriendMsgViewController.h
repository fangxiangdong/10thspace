//
//  AddFriendMsgViewController.h
//  TeamTalk
//
//  Created by mac on 16/11/18.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "MTTBaseViewController.h"

@interface AddFriendMsgViewController : MTTBaseViewController<UITableViewDataSource,UITableViewDelegate>
+ (instancetype)instance;
@property(nonatomic,strong)NSMutableArray*dataArray;

@end
