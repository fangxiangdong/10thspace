//
//  CommentTableViewCell.m
//  TeamTalk
//
//  Created by landu on 15/12/16.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "MTTUserEntity.h"

@interface CommentTableViewCell()
{
    UIImageView *headImg;
    UILabel *userName;
    UILabel *publishTime;
    UILabel *comment;
    UIView *lineView;
}
@end

@implementation CommentTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        self.backgroundColor = [UIColor whiteColor]; // RGB(240, 240, 240)
        
        // 头像
        headImg = [[UIImageView alloc] initWithFrame:CGRectMake(12, 5, 35, 35)];
        headImg.image = [UIImage imageNamed:@"user_placeholder"];
        [headImg.layer setCornerRadius:17.5];
        [headImg setUserInteractionEnabled:YES];
        [headImg setContentMode:UIViewContentModeScaleAspectFill];
        [headImg setClipsToBounds:YES];
        [self addSubview:headImg];
        
        
        // 用户名
        userName = [[UILabel alloc] initWithFrame:CGRectMake(57, 5, 180, 20)];
//        userName.text = @"马化腾";
        userName.textColor = RGB(25, 114, 241);
        userName.font = [UIFont systemFontOfSize:14];
        [self addSubview:userName];
        
        
        // 评论时间
        publishTime = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 5, 85, 20)];
        publishTime.font = [UIFont systemFontOfSize:12];
        publishTime.textColor = [UIColor grayColor];
        publishTime.textAlignment = NSTextAlignmentRight;
        [self addSubview:publishTime];
        
        
        // 内容
        comment = [[UILabel alloc] initWithFrame:CGRectZero];
        comment.textColor = [UIColor grayColor];
        comment.numberOfLines = 0;
        comment.font = [UIFont systemFontOfSize:14];
        [self addSubview:comment];
        
        
        // 分割线
        lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:lineView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    lineView.frame = CGRectMake(12, self.frame.size.height - 0.5, SCREEN_WIDTH - 12, 0.5);
}

-(void)setCommentModel:(CommentModel *)commentModel
{
    if(!commentModel){
        return;
    }
    _commentModel = commentModel;
    
    // 用户名
    MTTUserEntity *userEntity = (MTTUserEntity *)TheRuntime.user;
    if (commentModel.nickName.length) {
        userName.text = commentModel.nickName;
    }else if (userEntity.nick.length){
        userName.text = userEntity.nick;
    }else {
        userName.text = @"我是机器人";
    }
    
    [headImg sd_setImageWithURL:[NSURL URLWithString:commentModel.avatarUrl] placeholderImage:[UIImage imageNamed:@"header"] options:SDWebImageRetryFailed];
    publishTime.text = commentModel.createTime;
    comment.text     = commentModel.comment;
    
    comment.frame = CGRectMake(57, 28, SCREEN_WIDTH - 72, commentModel.commentHeight);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

@end
