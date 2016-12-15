//
//  AddFriendDetailCell.m
//  TeamTalk
//
//  Created by mac on 16/11/18.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "AddFriendDetailCell.h"
#import "UIImageView+SDWebImage.h"
#import <Masonry.h>
@interface AddFriendDetailCell ()
@property(nonatomic,strong)UIImageView*headView;
@property(nonatomic,strong)UILabel*friendName;
@property(nonatomic,strong)UILabel*addMSG;
@property(nonatomic,strong)UIButton*agreeButton;
@property(nonatomic,strong)UIButton*disagreeButton;
@property(nonatomic,assign)NSInteger theIndex;
@property(nonatomic,strong)UIButton*garyButton;
@end

@implementation AddFriendDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)refresh:(AddFriendMSGModel *)model andIndex:(NSInteger)index
{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.theIndex=index;
    NSString*string=model.avatar_url;
    
    [self.contentView addSubview:self.headView];
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(35, 35));
        make.centerY.equalTo(self.contentView);
        make.left.mas_equalTo(10);
        
    }];
    
    [self.headView sd_setImageWithURL:[NSURL URLWithString:string] placeholderImage:[UIImage imageNamed:@"header"]];
    
    
    
    
    self.friendName.text=model.nick_name;
    [self.contentView addSubview:self.friendName];
    
    
    [ self.friendName mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.headView.mas_right).offset(10);
        make.size.mas_equalTo(CGSizeMake(50, 20));
        make.centerY.equalTo(self.contentView);
        
    }];
    
    
    
    
    
    
    
    
    self.addMSG.text=model.addition_msg;
    [self.contentView addSubview:self.addMSG];
    
    [ self.addMSG mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.friendName.mas_right).offset(10);
        make.centerY.equalTo(self.contentView);
        
    }];
    
    
    
    
    if (model.isAgree==1) {
        [self.garyButton setTitle:@"已同意" forState:UIControlStateNormal];
        [self.garyButton setBackgroundColor:[UIColor grayColor]];
        self.garyButton .titleLabel.font=[UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.garyButton];
        
        [ self.garyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(60, 25));
            
            make.right.equalTo(self.contentView.mas_right).offset(-20);
            make.centerY.equalTo(self.contentView);
            
        }];
        
        
    }
    else   if (model.isAgree==2) {
        [self.garyButton setTitle:@"已添加" forState:UIControlStateNormal];
        self.garyButton .titleLabel.font=[UIFont systemFontOfSize:14];
        [self.garyButton setBackgroundColor:[UIColor grayColor]];
        
        [self.contentView addSubview:self.garyButton];
        
        [ self.garyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(60, 25));
            
            make.right.equalTo(self.contentView.mas_right).offset(-20);
            make.centerY.equalTo(self.contentView);
            
        }];
        
        
    }
    else{
        
        
        [self.agreeButton setTitle:@"接受" forState:UIControlStateNormal];
        
        [self.agreeButton addTarget:self action:@selector(buttonClickYES:) forControlEvents:UIControlEventTouchUpInside];
        [self.agreeButton setBackgroundColor:[UIColor blueColor]];
        [self.contentView addSubview:self.agreeButton];
        
        [ self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(40, 25));
            //        make.left.equalTo(self.friendName.mas_right).offset(10);
            make.right.equalTo(self.contentView.mas_right).offset(-20);
            make.centerY.equalTo(self.contentView);
            
        }];
        
        //        [self.disagreeButton setTitle:@"拒绝" forState:UIControlStateNormal];
        //        [self.disagreeButton setBackgroundColor:[UIColor redColor]];
        //        [self.disagreeButton addTarget:self action:@selector(buttonClickNO:) forControlEvents:UIControlEventTouchUpInside];
        //        [self.contentView addSubview:self.disagreeButton];
        //
        //        [ self.disagreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        //            make.size.mas_equalTo(CGSizeMake(40, 25));
        //
        //            make.right.equalTo(self.contentView.mas_right).offset(-20);
        //            make.centerY.equalTo(self.contentView);
        //
        //        }];
        
        
        
        
    }
    
    
    
    
    
    
    
    
}

-(void)buttonClickYES:(UIButton*)b
{
    
    
    
    [self.delegate AddFriendDetailCellDelegate:YES andIndex:self.theIndex];
    
    
    
}
//-(void)buttonClickNO:(UIButton*)b
//{
//
//     [self.delegate AddFriendDetailCellDelegate:NO andIndex:self.theIndex];
//
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(UIImageView *)headView
{
    if (_headView==nil) {
        _headView=[[UIImageView alloc]init];
    }
    return _headView;
    
}

-(UILabel *)addMSG
{
    
    if (_addMSG==nil) {
        _addMSG=[[UILabel alloc]init];
    }
    return _addMSG;
    
    
    
}


-(UILabel *)friendName
{
    if (_friendName==nil) {
        _friendName=[[UILabel alloc]init];
    }
    
    return _friendName;
    
    
}

-(UIButton *)agreeButton
{
    if (_agreeButton==nil) {
        _agreeButton=[[UIButton alloc]init];
        
    }
    return _agreeButton;
    
}
-(UIButton *)disagreeButton
{
    if (_disagreeButton==nil) {
        _disagreeButton=[[UIButton alloc]init];
        
    }
    return _disagreeButton;
    
}
-(UIButton *)garyButton
{
    if (_garyButton==nil) {
        _garyButton=[[UIButton alloc]init];
    }
    
    return _garyButton;
    
    
}
@end
