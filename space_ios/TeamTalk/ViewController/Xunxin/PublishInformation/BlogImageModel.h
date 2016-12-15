//
//  BlogImageModel.h
//  TeamTalk
//
//  Created by landu on 15/11/17.
//  Copyright © 2015年 IM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlogImageModel : NSObject

// 照片墙高度imgArr.count决定 0 80 160 240
@property (nonatomic,assign,readonly) CGFloat photoViewHeight;
@property (nonatomic,copy) NSMutableArray *imgArray;

@end
