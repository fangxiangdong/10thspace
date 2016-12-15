//
//  CommentModel.m
//  TeamTalk
//
//  Created by landu on 15/12/16.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "CommentModel.h"
#import "NSDate+DDAddition.h"

@implementation CommentModel

-(id)initWithPB:(BlogInfo *)pbBlog
{
    self = [super init];
    if(self){
        
        self.writerUserId = [NSString stringWithFormat:@"%d",  pbBlog.writerUserId];
        self.nickName     = [NSString stringWithFormat:@"%@",  pbBlog.nickName];
        self.avatarUrl    = [NSString stringWithFormat:@"%@",  pbBlog.avatarUrl];
        self.likeCnt      = [NSString stringWithFormat:@"%zd", pbBlog.likeCnt];
        self.commentCnt   = [NSString stringWithFormat:@"%zd", pbBlog.commentCnt];
        self.commentID    = [NSString stringWithFormat:@"%u", (unsigned int)pbBlog.blogId];
        self.createTime   = [NSString stringWithFormat:@"%u", (unsigned int)pbBlog.createTime];
        
        NSDate* date    = [NSDate dateWithTimeIntervalSince1970:[self.createTime doubleValue]];
        self.createTime = [date blogDataString];
        // 评论内容
        self.comment    = [[NSString alloc] initWithData:pbBlog.blogData encoding:NSUTF8StringEncoding];
    }
    return self;
}

-(void)setComment:(NSString *)comment
{
    if(!comment){
        return;
    }
    _comment = comment;
    
    _commentHeight = [_comment boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 72, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height;
}

@end
