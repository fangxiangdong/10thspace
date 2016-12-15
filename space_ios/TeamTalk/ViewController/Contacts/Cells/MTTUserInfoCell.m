//
//  userInfoCell.m
//  TeamTalk
//
//  Created by scorpio on 15/6/19.
//  Copyright (c) 2015年 IM. All rights reserved.
//

#import "MTTUserInfoCell.h"
#import "UIImageView+WebCache.h"
#import <Masonry/Masonry.h>

@implementation MTTUserInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        MTT_WEAKSELF(ws);
        
        // 头像
        _avatar = [UIImageView new];
        [_avatar setContentMode:UIViewContentModeScaleAspectFit];
        [_avatar setClipsToBounds:YES];
//        [_avatar.layer setBorderWidth:0.3];
//        [_avatar.layer setBorderColor:RGB(153,153,153).CGColor];
        [_avatar.layer setCornerRadius:4.0];
        [self.contentView addSubview:_avatar];

        [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.centerY.equalTo(ws.contentView);
            make.size.mas_equalTo(CGSizeMake(70, 70));
        }];
        
        
        // 用户名
        _nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatar.mas_right).offset(10);
            make.centerY.equalTo(ws.contentView).offset(-16);
            make.size.mas_equalTo(CGSizeMake(200, 20));
        }];
        
        
        // 昵称
        _cnameLabel = [[UILabel alloc] init];
        [_cnameLabel setTextColor:TTGRAY];
        [self.contentView addSubview:_cnameLabel];
        [_cnameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatar.mas_right).offset(10);
            make.centerY.equalTo(ws.contentView).offset(16);
            make.size.mas_equalTo(CGSizeMake(200, 20));
        }];
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = RGB(244, 245, 246);
    }
    return self;
}

-(void)setCellContent:(NSString *)avatar Name:(NSString *)name Cname:(NSString *)cname
{
    UIImage *placeholder = [UIImage imageNamed:@"user_placeholder"];
    //[_avatar sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:placeholder];
   
    if (avatar && ![avatar isEqualToString:@""]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // 处理耗时操作的代码块...
            NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:avatar]];
            UIImage *image = [UIImage imageWithData:data]; // 取得图片
             if (data != nil) {
                 //通知主线程刷新
                 dispatch_async(dispatch_get_main_queue(), ^{
                     //回调或者说是通知主线程刷新，
                     _avatar.image=image;
                 });
             }
        });
        
    }else{
        _avatar.image=placeholder;
    }
    
    if (cname.length) {
        [_nameLabel setText:cname];
    }else {
        [_nameLabel setText:name];
    }
    [_cnameLabel setText:name];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
