//
//  XunxinTableViewCell.m
//  TeamTalk
//
//  Created by landu on 15/11/4.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "XunxinTableViewCell.h"
#import "LCView.h"
#import "LCImageView.h"
#import "SJAvatarBrowser.h"
#import "TLClickImageView.h"
#import "UIImageView+WebCache.h"

@interface XunxinTableViewCell()

@property (nonatomic, weak) UIImageView *headImg;
@property (nonatomic, weak) UILabel *userName;
@property (nonatomic, weak) UILabel *publishTime;
@property (nonatomic, weak) UIView *photoView;
@property (nonatomic, weak) UILabel *content;
@property (nonatomic, weak) UIView *userActionView;

@end

@implementation XunxinTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        self.contentView.backgroundColor = RGB(255, 255, 255);
        
        // 用户头像
        UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(12, 15, 40, 40)];
        headImg.layer.cornerRadius = 20;
        headImg.clipsToBounds = YES;
        headImg.userInteractionEnabled = YES;
        headImg.contentMode = UIViewContentModeScaleAspectFill;
        self.headImg = headImg;
        [self.contentView addSubview:headImg];
        
        
        // 用户名
        UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(62, 15, 150, 20)];
        userName.font = [UIFont systemFontOfSize:16];
        self.userName = userName;
        [self.contentView addSubview:userName];
        
        
        // 发帖时间
        UILabel *publishTime = [[UILabel alloc] initWithFrame:CGRectMake(62, 35, 85, 20)];
        publishTime.font = [UIFont systemFontOfSize:12];
        publishTime.textColor = [UIColor grayColor];
        publishTime.textAlignment = NSTextAlignmentLeft;
        self.publishTime = publishTime;
        [self.contentView addSubview:publishTime];
        
        
        // 关注按钮
        self.careBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.careBtn.frame = CGRectMake(SCREEN_WIDTH - 60 - 8, 15 + 2.5, 60, 25);
        self.careBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        self.careBtn.layer.borderWidth = 0.5;
        self.careBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.careBtn.layer.cornerRadius = 3;
        [self.careBtn setTitle:@"+关注" forState:UIControlStateNormal];
        [self.careBtn setTitleColor:[UIColor colorWithRed:14.0/255.0 green:207.0/255.0 blue:49.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.careBtn addTarget:self action:@selector(careBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.careBtn];
        
        
        // 文字内容
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectZero];
        content.numberOfLines = 0;
        content.font = [UIFont systemFontOfSize:17.0];
        self.content = content;
        [self.contentView addSubview:content];
    }
    return self;
}

// 点击关注按钮
- (void)careBtnOnClick:(UIButton *)careBtn
{
    if ([self.delegate respondsToSelector:@selector(userCareBtnOnClick:)]) {
        [self.delegate userCareBtnOnClick:self];
    }
}

// 模型赋值
-(void)setXunxinModel:(XunxinModel *)xunxinModel isList:(BOOL)isList And:(NSInteger)index blogType:(BlogType)blogType
{
    if(!xunxinModel) {
        return;
    }
    _xunxinModel = xunxinModel;
    // 创建cell下面的按钮
    [self initUserAction:index andModel:xunxinModel];
    
    
    // 发表的图片内容
    [self initPhotoView:xunxinModel.imgArray AndIndex:index];
    [self refreshPhotoViewWithCount:(int)xunxinModel.imgArray.count];
    
    
    // 内容的高度
    self.content.frame = CGRectMake(12, 60, SCREEN_WIDTH - 24, xunxinModel.contentHeight);
    self.photoView.frame = CGRectMake(8, 60 + xunxinModel.contentHeight, SCREEN_WIDTH - 16, xunxinModel.photoViewHeight);
    
    
    // 设置值
    // 头像
    NSString *urlString = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_mfit,h_100,w_100", xunxinModel.avatarUrl];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        if (data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.headImg.image = [UIImage imageWithData:data];
            });
        }else {
            self.headImg.image = [UIImage imageNamed:@"header"];
        }
    });
    [self.headImg sd_setImageWithURL:[NSURL URLWithString:xunxinModel.avatarUrl] placeholderImage:[UIImage imageNamed:@"header"]];
    // 昵称
    if (xunxinModel.nickName.length) {
        self.userName.text = xunxinModel.nickName;
    }else {
        self.userName.text = @"董小姐";
    }
    // 内容
    self.content.text = xunxinModel.content;
    // 发帖时间
    self.publishTime.text = xunxinModel.publishTime;
    
    
    // 控制按钮的状态
    if (blogType == BlogTypeBlogTypeFollowuser) {
        [self.careBtn setTitle:@"已关注" forState:UIControlStateNormal];
        [self.careBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }else if (blogType == BlogTypeBlogTypeFriend) {
        self.careBtn.hidden = YES;
    }
    
    // 底部按钮
    self.userActionView.hidden = !isList;
    self.userActionView.frame = CGRectMake(0, 66 + xunxinModel.photoViewHeight + xunxinModel.contentHeight, SCREEN_WIDTH, 40);
}

// 发表的图片内容
-(void)initPhotoView:(NSArray *)imgArray AndIndex:(NSInteger)count
{
    float x = SCREEN_WIDTH - 16;
    UIView *photoView = [[UIView alloc] initWithFrame:CGRectMake(8, CGRectGetMaxY(self.content.frame) + 4, x, x)];
    photoView.backgroundColor = [UIColor whiteColor];
    photoView.tag = count * 10;
    self.photoView = photoView;
    [self.contentView addSubview:photoView];
    
    NSMutableArray *views = [NSMutableArray array];
    for(int i = 0; i < 3; i++){
        for(int j = 0; j < 3; j++){
            NSInteger index = 3 * i + j;
            
            TLClickImageView *imgView = [[TLClickImageView alloc] initWithFrame:CGRectMake(4 + (x/3 * j),4 + (x/3 * i), (x/3) - 8, (x/3) - 8)];
            // 大图的URL
            imgView.urlArray = imgArray;
            imgView.backgroundColor = [self randomColor];
            
            imgView.userInteractionEnabled = YES;
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.clipsToBounds = YES;
            
            if(index < imgArray.count) {
                // ?x-oss-process=image/resize,m_mfit,h_150,w_150
                NSString *imgUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_mfit,h_200,w_200", [imgArray objectAtIndex:index]];
                // 有毒
                [imgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"chat_pick_photo@2x"] options:SDWebImageRetryFailed];
                
                [photoView addSubview:imgView];
                [views addObject:imgView];
            }
            [imgView setViews:views];
        }
    }
}

- (UIColor *)randomColor
{
    CGFloat r = arc4random_uniform(256) / 255.0;
    CGFloat g = arc4random_uniform(256) / 255.0;
    CGFloat b = arc4random_uniform(256) / 255.0;
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    return color;
}

// 创建cell下面的按钮
-(void)initUserAction:(NSInteger)index andModel:(XunxinModel *)xunxinModel
{
    UIView *userActionView = [[UIView alloc] initWithFrame:CGRectZero];
    userActionView.backgroundColor = [UIColor whiteColor];
    self.userActionView = userActionView;
    [self.contentView addSubview:userActionView];
    
    // 横线
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.3)];
    line.backgroundColor = RGB(200, 200, 200);
    [userActionView addSubview:line];
    // 横线
    line = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.7, SCREEN_WIDTH, 0.3)];
    line.backgroundColor = RGB(180, 180, 180);
    [userActionView addSubview:line];
    
    // 竖线
    line = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 0.3) * 0.5, 5, 0.3, 30)];
    line.backgroundColor = RGB(200, 200, 200);
    [userActionView addSubview:line];
    
    
    NSArray *array = @[@"xx_zf", @"xx_pl"];
    NSArray *labelTitle = @[@"分享", xunxinModel.commentCnt]; // xunxinModel.likeCnt
    
    for (int i = 0; i < 2; i ++) {
        
        LCView *view = [[LCView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 * i + 1, 1, SCREEN_WIDTH/2 - 2, 38)];
        view.backgroundColor = RGB(255, 255, 255);
        view.userInteractionEnabled = YES;
        view.tag = 100 + i;
        view.index = index;
        [userActionView addSubview:view];
        
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((view.frame.size.width - 18) * 0.5 - 10, 10, 18, 18)];
        img.image = [UIImage imageNamed:array[i]];
        [view addSubview:img];
        
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(img.frame) + 5, 9, 30, 20)];
        lab.text = labelTitle[i];
        lab.font = systemFont(13);
        lab.textColor = [UIColor grayColor];
        lab.textAlignment = NSTextAlignmentLeft;
        [view addSubview:lab];
        
        // 点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        [view addGestureRecognizer:tap];
    }
}

-(void)actionTap:(UITapGestureRecognizer *)t
{
    LCView *view = (LCView*)t.view;
    NSInteger count = view.tag;
    NSInteger index = (NSInteger)view.index;
    
    
    // 代理实现分享，点赞，评论按钮的点击
    if(_delegate && [_delegate respondsToSelector:@selector(userAction:Andindex:)]){
        [_delegate userAction:count Andindex:index];
    }
}

- (void)refreshPhotoViewWithCount:(int)count
{
    float x = SCREEN_WIDTH - 80;
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            int index = 3 * i + j;
            UIView * v = [self.photoView viewWithTag:index+10];
            if (count <= index) {
                // 隐藏UIImageView
                v.frame = CGRectZero;
            }else{
                // 显示
                v.frame = CGRectMake(4 + x/3 * j, 4 + x/3 * i, x/3 - 8, x/3 - 8);
            }
        }
    }
}

@end
