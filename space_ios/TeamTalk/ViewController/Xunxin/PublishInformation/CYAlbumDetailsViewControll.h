//
//  CYAlbumDetailsViewControll.h
//  TeamTalk
//
//  Created by landu on 15/11/16.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "MTTBaseViewController.h"
#import "AQGridView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@class CYAlbumDetailsBottomBar;

@interface CYAlbumDetailsViewControll : MTTBaseViewController<AQGridViewDataSource,AQGridViewDelegate>

@property(nonatomic, strong)ALAssetsGroup  *assetsGroup;
@property(nonatomic, strong)NSMutableArray *assetsArray;
@property(nonatomic, strong)NSMutableArray *choosePhotosArray;
@property(nonatomic, strong)AQGridView     *gridView;
@property(nonatomic, strong)CYAlbumDetailsBottomBar *bar;

@end
