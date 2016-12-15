//
//  XunxinTableViewCell.h
//  TeamTalk
//
//  Created by landu on 15/11/4.
//  Copyright © 2015年 IM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XunxinModel.h"
#import "UIImageView+AFNetworking.h"

@class XunxinTableViewCell;
@protocol UserActionDelegate <NSObject>

@optional

- (void)userAction:(NSInteger)count Andindex:(NSInteger)index;
- (void)imageMagnify:(NSInteger)count AndIndex:(NSInteger)index AndRect:(CGRect) oldRect;
@required
- (void)userCareBtnOnClick:(XunxinTableViewCell *)userCell;

@end

@interface XunxinTableViewCell : UITableViewCell

@property (nonatomic,strong) UIButton *careBtn;
@property (nonatomic,strong) XunxinModel * xunxinModel;
@property (nonatomic,weak) id<UserActionDelegate>delegate;

-(void)setXunxinModel:(XunxinModel *)xunxinModel isList:(BOOL)isList And:(NSInteger)index blogType:(BlogType)blogType;

@end
