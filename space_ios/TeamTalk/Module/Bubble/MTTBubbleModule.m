//
//  MTTBubble.m
//  TeamTalk
//
//  Created by scorpio on 15/7/2.
//  Copyright (c) 2015年 IM. All rights reserved.
//

#import "MTTBubbleModule.h"
#import "MTTUtil.h"

@implementation MTTBubbleModule
{
    MTTBubbleConfig* _left_config;
    MTTBubbleConfig* _right_config;
}

+ (instancetype)shareInstance
{
    static MTTBubbleModule* g_bubbleModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_bubbleModule = [[MTTBubbleModule alloc] init];
    });
    return g_bubbleModule;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSString* leftBubbleType = [MTTUtil getBubbleTypeLeft:YES];
        NSString* rightBubbleType = [MTTUtil getBubbleTypeLeft:NO];
        NSString* leftBubblePath = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/config.json", leftBubbleType];
        NSString* rightBubblePath = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/config.json", rightBubbleType];
        NSString* leftPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:leftBubblePath];
        NSString* rightPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:rightBubblePath];
        
        _left_config = [[MTTBubbleConfig alloc] initWithConfig:leftPath left:YES];
        _right_config = [[MTTBubbleConfig alloc] initWithConfig:rightPath left:NO];
    }
    return self;
    
}

- (MTTBubbleConfig*)getBubbleConfigLeft:(BOOL)left
{
    if(left){
        return _left_config;
    }
    return _right_config;
}

- (void)selectBubbleTheme:(NSString *)bubbleType left:(BOOL)left
{
    [MTTUtil setBubbleTypeLeft:bubbleType left:left];
    NSString* path = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/config.json", bubbleType];
    NSString* realPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    if(left){
        _left_config = [[MTTBubbleConfig alloc] initWithConfig:realPath left:(BOOL)left];
    }else{
        _right_config = [[MTTBubbleConfig alloc] initWithConfig:realPath left:(BOOL)left];
    }
}

@end

@implementation MTTBubbleConfig

- (instancetype)initWithConfig:(NSString*)string left:(BOOL)left
{
    self = [super init];
    if (self)
    {
        NSString* textBgImagePath;
        NSString* picBgImagePath;
        
        
        
        NSData* data = [NSData dataWithContentsOfFile:string];
        //NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        //NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *dic;
        
        MTTBubbleContentInset insetTemp;
//        insetTemp.top = [dic[@"contentInset"][@"top"] floatValue];//消息顶边距
//        insetTemp.bottom = [dic[@"contentInset"][@"bottom"] floatValue];//底边框距离
        insetTemp.top = 10;//消息顶距离
        insetTemp.bottom = 10;//底边框距离
        if(left){
//            insetTemp.left = [dic[@"contentInset"][@"left"] floatValue];
//            insetTemp.right = [dic[@"contentInset"][@"right"] floatValue];
            insetTemp.left = 18;//消息左边距
            insetTemp.right = 10;//消息右边距
        }else{
//            insetTemp.left = [dic[@"contentInset"][@"right"] floatValue];
//            insetTemp.right = [dic[@"contentInset"][@"left"] floatValue];
            insetTemp.left = 10;
            insetTemp.right = 18;
        }
        self.inset = insetTemp;
        
        
        MTTBubbleVoiceInset voiceInsetTemp;
//        voiceInsetTemp.top = [dic[@"voiceInset"][@"top"] floatValue];
//        voiceInsetTemp.bottom = [dic[@"voiceInset"][@"bottom"] floatValue];
        voiceInsetTemp.top = 12;//声音顶距离
        voiceInsetTemp.bottom = 10;//声音长度
        if(left){
//            voiceInsetTemp.left = [dic[@"voiceInset"][@"left"] floatValue];
//            voiceInsetTemp.right = [dic[@"voiceInset"][@"right"] floatValue];
            voiceInsetTemp.left = 1;
            voiceInsetTemp.right = 2;
        }else{
//            voiceInsetTemp.left = [dic[@"voiceInset"][@"right"] floatValue];
//            voiceInsetTemp.right = [dic[@"voiceInset"][@"left"] floatValue];
            voiceInsetTemp.left = 1;
            voiceInsetTemp.right = 2;
        }
        self.voiceInset = voiceInsetTemp;
        
        
        MTTBubbleStretchy stretchyTemp;
//        stretchyTemp.left = [dic[@"stretchy"][@"left"] floatValue];
//        stretchyTemp.top = [dic[@"stretchy"][@"top"] floatValue];
        stretchyTemp.left = 10;//气泡边距
        stretchyTemp.top = 20;
        self.stretchy = stretchyTemp;
        
        
        MTTBubbleStretchy imgStretchyTemp;
        imgStretchyTemp.left = [dic[@"imgStretchy"][@"left"] floatValue];
        imgStretchyTemp.top = [dic[@"imgStretchy"][@"top"] floatValue];
        //imgStretchyTemp.left = 10;//   ????????????
        //imgStretchyTemp.top = 40;//   ???????????
        self.imgStretchy = imgStretchyTemp;
        
        
        NSArray *textColorTemp = [dic[@"textColor"] componentsSeparatedByString:@","];
        self.textColor = RGB([textColorTemp[0] floatValue], [textColorTemp[1] floatValue], [textColorTemp[2] floatValue]);  //设置聊天字体颜色
        NSArray *linkColorTemp = [dic[@"linkColor"] componentsSeparatedByString:@","];
        self.linkColor = RGB([linkColorTemp[0] floatValue], [linkColorTemp[1] floatValue], [linkColorTemp[2] floatValue]);
        
        NSString* bubbleType = [MTTUtil getBubbleTypeLeft:left];
        if(left){
            //textBgImagePath = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/textLeftBubble", bubbleType];
            textBgImagePath = @"left";
            picBgImagePath = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/picLeftBubble", bubbleType];
            //picBgImagePath = @"chat_bubble_incomming";
        }else{
            //textBgImagePath = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/textBubble", bubbleType];
            textBgImagePath = @"right";
            picBgImagePath = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/picBubble", bubbleType];
            //picBgImagePath = @"chat_img_bubble_outgoing";
        }
        
        //self.textBgImage = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:textBgImagePath];
        self.textBgImage = textBgImagePath;
        //self.picBgImage = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:picBgImagePath];
        self.picBgImage = picBgImagePath;

    }
    return self;
}

@end
