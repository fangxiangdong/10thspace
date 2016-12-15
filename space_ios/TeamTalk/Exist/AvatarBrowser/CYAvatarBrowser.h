//
//  CYAvatarBrowser.h
//  TeamTalk
//
//  Created by landu on 15/11/23.
//  Copyright © 2015年 IM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+AFNetworking.h"
@interface CYAvatarBrowser : NSObject

+(void)showImage:(NSMutableArray*)imgArray AndCount:(NSInteger)count AndFirstImage:(UIImageView*)firstImage;


@end
