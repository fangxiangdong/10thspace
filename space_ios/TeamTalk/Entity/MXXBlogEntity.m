//
//  MXXBlogEntity.m
//  TeamTalk
//
//  Created by landu on 15/11/19.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "MXXBlogEntity.h"

@implementation MXXBlogEntity

-(id)init
{
    self = [super init];
    if(self){
        self.blogImages = [NSMutableArray array];
    }
    return self;
}

-(id)initWithPB:(MsgInfo *)pbBlog
{
    self = [super init];
    if(self){

        
        self.msgType = [NSString stringWithFormat:@"%d",(int)pbBlog.msgType];
        self.fromSessionId = [NSString stringWithFormat:@"%d",(unsigned int)pbBlog.fromSessionId];
        self.createTime = [NSString stringWithFormat:@"%d",(unsigned int)pbBlog.fromSessionId];
        self.msgData = pbBlog.msgData;
        
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self.msgData options:NSJSONReadingAllowFragments error:nil];
        self.blogContent = [dic objectForKey:@"blogtext"];
        
        
        NSArray *array = [dic objectForKey:@"blogImages"];
        for (int i = 0; i < array.count; i ++) {
            NSString *imgUrl = array[i];
            
            imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"&$#@~^@[{:" withString:@""];
            imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@":}]&$~@#@" withString:@""];
            
            
            [self.blogImages addObject:imgUrl];
        }
        
    }
    return self;
}


@end
