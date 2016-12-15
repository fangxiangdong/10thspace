//
//  XunxinModel.m
//  TeamTalk
//
//  Created by landu on 15/11/4.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "XunxinModel.h"
#import "DDUserModule.h"
#import "NSDate+DDAddition.h"

@implementation XunxinModel

-(id)init
{
    self = [super init];
    if(self){
        self.imgArray = [NSMutableArray array];
    }
    return self;
}

+ (XunxinModel *)xunxinModelFromDic:(NSDictionary *)dict
{
    XunxinModel *model = [[XunxinModel alloc] init];
    
    model.blogId       = [dict objectForKey:@"blogId"];
    model.blogType     = [dict objectForKey:@"blogType"];
    model.writerUserId = [dict objectForKey:@"writerUserId"];
    model.nickName     = [dict objectForKey:@"nickName"];
    model.avatarUrl    = [dict objectForKey:@"avatarUrl"];
    model.likeCnt      = [dict objectForKey:@"likeCnt"];
    model.commentCnt   = [dict objectForKey:@"commentCnt"];
    model.createTime   = [dict objectForKey:@"createTime"];
    model.content      = [dict objectForKey:@"blogContent"];
    
    NSString *imgURL   = [dict objectForKey:@"blogImages"];
    
    NSArray *array = [imgURL componentsSeparatedByString:@"+"];
    NSMutableArray *imgAM = [NSMutableArray array];
    for (NSString *urlString in array) {
        if (urlString.length) {
            [imgAM addObject:urlString];
        }
        model.imgArray = imgAM;
    }
    
    return model;
}

-(id)initWithPB:(BlogInfo *)pbBlog
{
    if(self = [super init]){
        
        self.blogId       = [NSString stringWithFormat:@"%d",  pbBlog.blogId];
        self.writerUserId = [NSString stringWithFormat:@"%d",  pbBlog.writerUserId];
        self.nickName     = [NSString stringWithFormat:@"%@",  pbBlog.nickName];
        self.avatarUrl    = [NSString stringWithFormat:@"%@",  pbBlog.avatarUrl];
        self.likeCnt      = [NSString stringWithFormat:@"%zd", pbBlog.likeCnt];
        self.commentCnt   = [NSString stringWithFormat:@"%zd", pbBlog.commentCnt];
        self.createTime   = [NSString stringWithFormat:@"%u",  (unsigned int)pbBlog.createTime];
        self.blogData     = pbBlog.blogData;
        
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self.blogData options:NSJSONReadingAllowFragments error:nil];
        // 只有内容  和  图片数组
        self.content  = [dic objectForKey:@"BlogText"];
        self.imgArray = [dic objectForKey:@"BlogImages"];
        
        [[DDUserModule shareInstance] getUserForUserID:self.fromSessionId Block:^(MTTUserEntity *user) {
            self.userName  = user.name;
            self.headImage = user.avatar;
        }];
        
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[self.createTime doubleValue]];
        self.publishTime = [date blogDataString];
    }
    return self;
}

- (void)setImgArray:(NSMutableArray *)imgArray
{
    _imgArray = imgArray;
    
    switch (_imgArray.count) {
        case 0:
            _photoViewHeight = 0;
            break;
        case 1:
        case 2:
        case 3:
            _photoViewHeight = (SCREEN_WIDTH - 16) / 3;
            break;
        case 4:
        case 5:
        case 6:
            _photoViewHeight = (SCREEN_WIDTH - 16) / 3 * 2;
            break;
        default:
            _photoViewHeight = (SCREEN_WIDTH - 16);
            break;
    }
    //NSLog(@"----- _photoViewHeight == %f",_photoViewHeight);
}

-(void)setContent:(NSString *)content
{
    _content = content;
    
    if(content.length == 0){
        _contentHeight = 0;
    }
    else{
        _contentHeight = [_content boundingRectWithSize:CGSizeMake(SCREEN_HEIGHT - 24, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:22]} context:nil].size.height;
    }
    //NSLog(@"----_contentHeight %f",_contentHeight);
}

@end
