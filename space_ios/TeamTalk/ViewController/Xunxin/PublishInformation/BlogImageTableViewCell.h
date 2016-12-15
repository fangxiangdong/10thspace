//
//  BlogImageTableViewCell.h
//  TeamTalk
//
//  Created by landu on 15/11/17.
//  Copyright © 2015年 IM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlogImageModel.h"
#import "SJAvatarBrowser.h"
#import "CYAvatarBrowser.h"
#import "PublishInfoViewController.h"

@protocol addImageDelegate <NSObject>

-(void)addImage;
-(void)clickImage:(NSInteger)count;

@end

@interface BlogImageTableViewCell : UITableViewCell

@property (nonatomic,strong) BlogImageModel *blogModel;
@property (nonatomic,strong) id<addImageDelegate> delegate;

@end
