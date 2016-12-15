//
//  UIImage+Orientation.h
//  TeamTalk
//
//  Created by 1 on 16/12/12.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Orientation)

+ (UIImage *)fixOrientation:(UIImage *)aImage;
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

@end
