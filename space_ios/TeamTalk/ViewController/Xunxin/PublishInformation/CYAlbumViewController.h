//
//  CYAlbumViewController.h
//  TeamTalk
//
//  Created by landu on 15/11/16.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "MTTBaseViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface CYAlbumViewController : MTTBaseViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) ALAssetsLibrary * assetsLibrary;
@property(nonatomic,strong) NSMutableArray *albumsArray;

@end
