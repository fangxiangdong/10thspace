//
//  AddFriendDetailCell.h
//  TeamTalk
//
//  Created by mac on 16/11/18.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddFriendMSGModel.h"

@protocol AddFriendDetailCellDelegate <NSObject>

-(void)AddFriendDetailCellDelegate:(BOOL)agree andIndex:(NSInteger)index ;

@end

@interface AddFriendDetailCell : UITableViewCell
@property(nonatomic,weak)id<AddFriendDetailCellDelegate>delegate;
-(void)refresh:(AddFriendMSGModel *)model andIndex:(NSInteger)index;
@end
