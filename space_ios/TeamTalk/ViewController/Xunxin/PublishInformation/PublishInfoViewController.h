//
//  PublishInfoViewController.h
//  TeamTalk
//
//  Created by landu on 15/11/13.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "MTTBaseViewController.h"

@interface PublishInfoViewController : MTTBaseViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,strong) UIImagePickerController *imagePicker;
@property (nonatomic,strong) NSMutableArray *dataArray;

+(instancetype )shareInstance;
+(NSMutableArray*)shareMutabArray;
-(void)receiveImageArray:(NSMutableArray*)array;

@end
