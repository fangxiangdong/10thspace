//
//  CYAlbumDetailsBottomBar.h
//  TeamTalk
//
//  Created by landu on 15/11/16.
//  Copyright © 2015年 IM. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ButtonSelectBlock)(int buttonIndex) ;
@interface CYAlbumDetailsBottomBar : UIView
@property(nonatomic,strong)UIButton *send;
@property(nonatomic,copy)ButtonSelectBlock block;

-(void)setSendButtonTitle:(int)num;
@end
