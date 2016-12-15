//
//  LCUserActionView.m
//  TeamTalk
//
//  Created by landu on 15/12/5.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "LCUserActionView.h"

@interface LCUserActionView()

@end

@implementation LCUserActionView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        self.backgroundColor = [UIColor whiteColor];
        
        
        UILabel * line = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, 4.5, 0.3, 40)];
        line.backgroundColor = RGB(200, 200, 200);
        [self addSubview:line];
        
        line = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3 * 2, 4.5, 0.3, 40)];
        line.backgroundColor = RGB(200, 200, 200);
        [self addSubview:line];
        
        
        
        NSArray *array1 = @[@"xx_zf",@"xx_z",@"xx_pl"];
        NSArray *array2 = @[@"分享",@"赞",@"评论"];
        
        for (int i = 0; i < 3; i ++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3 * i + 1, 1, SCREEN_WIDTH/3 - 2, 49)];
            view.backgroundColor = [UIColor yellowColor];
            view.userInteractionEnabled = YES;
            view.tag = 100 + i;
            [self addSubview:view];
            
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/6 - 22, 14, 18, 18)];
            img.image = [UIImage imageNamed:array1[i]];
            [view addSubview:img];
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/6, 13, 30, 22)];
            lab.text = array2[i];
            lab.font = systemFont(13);
            lab.textColor = [UIColor grayColor];
            lab.textAlignment = NSTextAlignmentLeft;
            [view addSubview:lab];
            
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
            [view addGestureRecognizer:tap];
            
        }
        
    }
    return self;
}

-(void)actionTap:(UITapGestureRecognizer*)t
{
    UIView *view = (UIView*)t.view;
    NSInteger count = view.tag;
    
    if(_delegate && [_delegate respondsToSelector:@selector(userActionDetail:)]){
        [_delegate userActionDetail:count];
    }
}

@end
