//
//  XunXinDetailViewController.h
//  TeamTalk
//
//  Created by landu on 15/12/3.
//  Copyright © 2015年 IM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XunxinModel.h"
#import "LCConmentInputView.h"
#import "IMAddBlogConmentAPI.h"
#import "IMMessage.pb.h"
#import "UIView+Addition.h"

@class MsgInfo;

@interface XunXinDetailViewController : UIViewController

@property (nonatomic, strong) LCConmentInputView *ConmentInputView;
@property (nonatomic, strong) XunxinModel *xunxinModel;
@property (nonatomic, assign) BlogType blogType;

@end


@interface XunXinDetailViewController(ConmentInput)

- (void)initialInput;

@end
