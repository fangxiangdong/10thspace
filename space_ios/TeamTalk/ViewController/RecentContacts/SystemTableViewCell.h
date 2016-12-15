//
//  SystemTableViewCell.h
//  TeamTalk
//
//  Created by landu on 15/11/30.
//  Copyright © 2015年 IM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTTSessionEntity.h"
#import "UIImageView+AFNetworking.h"
#import <SDWebImage/UIImageView+WebCache.h>
@protocol AgreeAddFriendDelegate <NSObject>

-(void)agreeAdd;

@end

@interface SystemTableViewCell : UITableViewCell

@property (nonatomic,strong) MTTSessionEntity *session;
@property (nonatomic,weak)id<AgreeAddFriendDelegate>delegate;

-(void)setSession:(MTTSessionEntity *)session isFriend:(BOOL)isFriend;

@end
