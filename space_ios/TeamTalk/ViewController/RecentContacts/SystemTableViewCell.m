//
//  SystemTableViewCell.m
//  TeamTalk
//
//  Created by landu on 15/11/30.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "SystemTableViewCell.h"

@interface SystemTableViewCell()
{
    UIImageView *headImageView;
    UILabel *userName;
    UILabel *content;
    UIButton *agreeButton;
}
@end

@implementation SystemTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        [headImageView setContentMode:UIViewContentModeScaleAspectFill];
        [headImageView setClipsToBounds:YES];
        [headImageView.layer setCornerRadius:2.0];
        [self addSubview:headImageView];
        
        userName = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 150, 20)];
        [userName setFont:systemFont(17)];
        [self addSubview:userName];
        
        content = [[UILabel alloc] initWithFrame:CGRectMake(70, 35, 150, 20)];
        [content setFont:systemFont(14)];
        content.textColor = TTGRAY;
        [self addSubview:content];
        
        agreeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 20, 60, 30)];
        [agreeButton setTitle:@"接受" forState:UIControlStateNormal];
        agreeButton.backgroundColor = TTBLUE;
        agreeButton.titleLabel.font = systemFont(15);
        [agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [agreeButton addTarget:self action:@selector(agree) forControlEvents:UIControlEventTouchUpInside];
        agreeButton.layer.cornerRadius = 2.0;
        [self addSubview:agreeButton];
        
        
        
    }
    return self;
}

-(void)setSession:(MTTSessionEntity *)session isFriend:(BOOL)isFriend
{
    if(!session){
        return;
    }
    _session = session;
    if (session.lastMsg==nil) {
        NSString *user_nick_name = nil;
        NSString *avatar_url = nil;
        
        [headImageView sd_setImageWithURL:[NSURL URLWithString:avatar_url] placeholderImage:[UIImage imageNamed:@"user_placeholder"]];
        userName.text = user_nick_name;
        content.text = [NSString stringWithFormat:@"%@ 请求添加好友",user_nick_name];
    }else{
    
    NSData *data = [session.lastMsg dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSString *user_nick_name = [receiveDic objectForKey:@"user_nick_name"];
    NSString *avatar_url = [receiveDic objectForKey:@"avatar_url"];
    
    [headImageView sd_setImageWithURL:[NSURL URLWithString:avatar_url] placeholderImage:[UIImage imageNamed:@"user_placeholder"]];
    userName.text = user_nick_name;
    content.text = [NSString stringWithFormat:@"%@ 请求添加好友",user_nick_name];
    }
    if(isFriend){
        [agreeButton setTitle:@"已同意" forState:UIControlStateNormal];
        agreeButton.backgroundColor = [UIColor whiteColor];
        [agreeButton setTitleColor:TTGRAY forState:UIControlStateNormal];

    }
    else{
        [agreeButton setTitle:@"同意" forState:UIControlStateNormal];
        agreeButton.backgroundColor = TTBLUE;
        [agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

-(void)agree
{

    if(_delegate && [_delegate respondsToSelector:@selector(agreeAdd)]){
        [_delegate agreeAdd];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
