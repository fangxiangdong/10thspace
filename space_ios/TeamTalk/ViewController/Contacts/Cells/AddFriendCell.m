//
//  AddFriendCell.m
//  TeamTalk
//
//  Created by mac on 16/11/18.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "AddFriendCell.h"
#import <Masonry.h>
#import "UIImageView+SDWebImage.h"
@interface AddFriendCell ()
{

    UILabel *alabel;
}
@property(nonatomic,strong)UIImageView*headView;
@property(nonatomic,strong)UILabel*friendName;
@property(nonatomic,strong)UILabel*addMSG;
@property(nonatomic,strong)UIView*redView;
@end

@implementation AddFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//-(void)refresh:(AddFriendMSGModel *)model
//{
//
//    NSString*string=model.avatar_url;
//    
//    self.headView.frame=CGRectMake(10, 10, 35, 35);
//    
//   
//    [self.headView sd_setImageWithURL:[NSURL URLWithString:string] placeholderImage:[UIImage imageNamed:@"header"]];
//    [self addSubview:self.headView];
//    
//    self.friendName.frame=CGRectMake(55, 15, 20, 25);
//    
//    self.friendName.text=model.nick_name;
//    [self addSubview:self.friendName];
//    
//    self.addMSG.frame=CGRectMake(78, 15, 100, 25);
//    
//    self.addMSG.text=model.addition_msg;
//    [self addSubview:self.addMSG];
//    
//    
//
//
//}


-(void)refresh:(NSInteger)a andIsClean:(BOOL)isClean
{

    if (a>99) {
        a=99;
    }
    
    if (a!=0) {
        
        if (!self.redView) {
            
            self.redView=[[UIView alloc]init];
            self.redView.layer.cornerRadius=15/2;
            self.redView.backgroundColor=[UIColor redColor];
            [self addSubview:self.redView];
            
            [self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.size.mas_equalTo(CGSizeMake(15, 15));
                make.left.equalTo(self.mas_right).offset(-30);
                //make.top.equalTo(self.mas_top).offset(100+55/2);
                 make.centerY.equalTo(self.contentView);
            }];
            
            alabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
            alabel.textColor=[UIColor whiteColor];
            alabel.font=[UIFont systemFontOfSize:14.0];
            alabel.textAlignment=NSTextAlignmentCenter;
            alabel.text=[NSString stringWithFormat:@"%lu",(unsigned long)a];
            [self.redView addSubview:alabel];
            
        }else
        {
            
            alabel.text=[NSString stringWithFormat:@"%lu",(unsigned long)a];
            self.redView.hidden=NO;
            
        }
        
        
        
        
        
        
    }
    if (isClean) {
        self.redView.hidden=YES;
    }else{
    
        self.redView.hidden=NO;
    }
    
    
    
    self.headView.frame=CGRectMake(10, 10, 35, 35);


    self.headView.image=[UIImage imageNamed:@"icon_head"];
    [self addSubview:self.headView];

//    self.friendName.frame=CGRectMake(55, 15, 20, 25);
//
//
//    [self addSubview:self.friendName];

    self.addMSG.frame=CGRectMake(55, 15, self.frame.size.width-78, 25);

    self.addMSG.text=@"新的朋友";
    [self addSubview:self.addMSG];




}


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
@end
