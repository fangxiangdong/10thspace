//
//  LCUserActionView.h
//  TeamTalk
//
//  Created by landu on 15/12/5.
//  Copyright © 2015年 IM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserActionDetailDelegate <NSObject>

-(void)userActionDetail:(NSInteger)index;

@end

@interface LCUserActionView : UIView

@property (nonatomic,weak) id<UserActionDetailDelegate> delegate;

@end
