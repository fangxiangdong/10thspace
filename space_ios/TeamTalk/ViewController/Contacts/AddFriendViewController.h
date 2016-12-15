//
//  AddFriendViewController.h
//  TeamTalk
//
//  Created by landu on 15/11/12.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "MTTBaseViewController.h"
#import "LCActionSheet.h"
@class MTTUserEntity;
@interface AddFriendViewController : MTTBaseViewController<UITableViewDataSource,UITableViewDelegate,LCActionSheetDelegate>

@property(nonatomic,strong)MTTUserEntity *user;
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)UIImageView *avatar;
@property(nonatomic,strong)UIImageView *avatarView;
@property(nonatomic,strong)UILabel *name;
@property(nonatomic,strong)UILabel *cname;
@property(nonatomic,strong)UIButton *addBtn;
@property (nonatomic,strong) UIButton *followBtn;


@end
