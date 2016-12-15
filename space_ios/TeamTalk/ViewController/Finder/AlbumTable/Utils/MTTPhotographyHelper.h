//
//  MTTPhotographyHelper.h
//  TeamTalk
//
//  Created by 1 on 16/11/3.
//  Copyright © 2016年 IM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DidFinishTakeMediaCompledBlock)(UIImage *image, NSDictionary *editingInfo);

@interface MTTPhotographyHelper : NSObject

- (void)showOnPickerViewControllerSourceType:(UIImagePickerControllerSourceType)sourceType onViewController:(UIViewController *)viewController compled:(DidFinishTakeMediaCompledBlock)compled;

@end
