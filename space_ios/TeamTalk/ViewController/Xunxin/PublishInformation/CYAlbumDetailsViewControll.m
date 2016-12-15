//
//  CYAlbumDetailsViewControll.m
//  TeamTalk
//
//  Created by landu on 15/11/16.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "CYAlbumDetailsViewControll.h"
#import "ImageGridViewCell.h"
#import "PublishInfoViewController.h"
#import "CYAlbumDetailsBottomBar.h"
#import "ChattingMainViewController.h"
#import "DDSendPhotoMessageAPI.h"
#import "MTTDatabaseUtil.h"
#import "BlogImageModel.h"
#import "MWCommon.h"
#import "MBProgressHUD.h"
#import "MTTPhotosCache.h"
#import "DDMessageSendManager.h"
#import "MWPhotoBrowser.h"

@interface CYAlbumDetailsViewControll ()<MWPhotoBrowserDelegate> // AQGridViewDataSource

@property(nonatomic, strong)NSMutableArray *photos;
@property(nonatomic, strong)NSMutableArray *selections;
@property(nonatomic, strong)MWPhotoBrowser *photoBrowser;
@property(nonatomic, strong)UIButton       *button;

@end

@implementation CYAlbumDetailsViewControll

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title=@"预览";
    self.selections = [[NSMutableArray alloc] initWithCapacity:10];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // mainView
    self.gridView = [[AQGridView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - 45)];
    self.gridView.delegate = self;
    self.gridView.dataSource = self;
    [self.view addSubview:self.gridView];
    
    self.assetsArray = [NSMutableArray array];
    self.choosePhotosArray = [NSMutableArray array];
    
    // 遍历相册里面的图片
    [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result) {
            [_assetsArray addObject:result];
        }
        
        // 遍历到最后了
        if (stop) {
            [self.gridView reloadData];
        }
    }];
    
    // 导航栏
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(backToRoot)];
    self.navigationItem.rightBarButtonItem = item;
    
    // 底部按钮
    self.bar = [[CYAlbumDetailsBottomBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 45, FULL_WIDTH, 45)];
    __weak typeof(self) weakSelf = self;
    self.bar.block = ^(int buttonIndex){
        if (buttonIndex == 0) {
            if ([self.choosePhotosArray count] == 0) {
                return ;
            }
            
            [weakSelf.selections removeAllObjects];
            
            weakSelf.photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:weakSelf];
            weakSelf.photoBrowser.displayActionButton = NO;
            weakSelf.photoBrowser.displayNavArrows = NO;
            weakSelf.photoBrowser.wantsFullScreenLayout = YES;
            weakSelf.photoBrowser.delayToHideElements = 4;
            weakSelf.photoBrowser.zoomPhotosToFill = YES;
            weakSelf.photoBrowser.displaySelectionButtons = YES;
            
            [weakSelf.photoBrowser setCurrentPhotoIndex:0];
            weakSelf.photos = [NSMutableArray new];
            for (int i =0; i<[self.choosePhotosArray count]; i++) {
                ALAsset *result = [weakSelf.choosePhotosArray objectAtIndex:i];
                ALAssetRepresentation* representation = [result defaultRepresentation];
                if (representation == nil) {
                    CGImageRef ref = [result thumbnail];
                    
                    UIImage *img = [[UIImage alloc]initWithCGImage:ref];
                    
                    MWPhoto *photo =[MWPhoto photoWithImage:img];
                    
                    [weakSelf.photos addObject:photo];
                    
                }else {
                    CGImageRef ref = [[result defaultRepresentation] fullScreenImage];
                    UIImage *img = [[UIImage alloc]initWithCGImage:ref];
                    
                    MWPhoto *photo =[MWPhoto photoWithImage:img];
                    [weakSelf.photos addObject:photo];
                }
                [weakSelf.selections addObject:@(1)];
            }
            
//            [self.photoBrowser reloadData];
            UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, FULL_WIDTH, 50)];
            [toolView setBackgroundColor:RGBA(0, 0, 0, 0.7)];
            // 选取按钮
            weakSelf.button = [UIButton buttonWithType:UIButtonTypeCustom];
            [weakSelf.button setBackgroundColor:[UIColor clearColor]]; //clearColor
            [weakSelf.button setTitle:[NSString stringWithFormat:@"选取(%ld)",(unsigned long)[weakSelf.photos count]] forState:UIControlStateNormal];
            [weakSelf.button setTitle:[NSString stringWithFormat:@"选取(%ld)",(unsigned long)[weakSelf.photos count]] forState:UIControlStateSelected];
            [weakSelf.button setBackgroundImage:[UIImage imageNamed:@"dd_image_send"] forState:UIControlStateNormal];
            [weakSelf.button setBackgroundImage:[UIImage imageNamed:@"dd_image_send"] forState:UIControlStateSelected];
            [weakSelf.button addTarget:weakSelf action:@selector(sendPhotos:) forControlEvents:UIControlEventTouchUpInside];
            
            NSString *string = [NSString stringWithFormat:@"%@",weakSelf.button.titleLabel.text];
            CGRect rect = [string boundingRectWithSize:CGSizeMake(190,0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil];
            CGSize feelSize = rect.size;
            float feelWidth = feelSize.width;
            weakSelf.button.frame = CGRectMake(FULL_WIDTH/2-feelWidth+25/2, 7, feelWidth+25, 35);
            [weakSelf.button setClipsToBounds:YES];
            [weakSelf.button.layer setCornerRadius:3];
            [toolView addSubview:weakSelf.button];
            [weakSelf.photoBrowser.view addSubview:toolView];
            
            [weakSelf pushViewController:weakSelf.photoBrowser animated:YES];
            
        }else {
            //send picture
            if ([self.choosePhotosArray count] >0) {
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:weakSelf.view];
                [weakSelf.view addSubview:HUD];
                
                HUD.dimBackground = YES;
                HUD.labelText = @"正在处理";
                
                [HUD showAnimated:YES whileExecutingBlock:^{
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    for (int i = 0; i<[self.choosePhotosArray count]; i++) {
                        MTTPhotoEnity *photo = [MTTPhotoEnity new];
                        ALAsset *asset = [weakSelf.choosePhotosArray objectAtIndex:i];
                        ALAssetRepresentation* representation = [asset defaultRepresentation];
                        NSURL* url = [representation url];
                        photo.localPath=url.absoluteString;
                        
                        UIImage *image = nil;
                        if (representation == nil) {
                            CGImageRef thum = [asset aspectRatioThumbnail];
                            image = [[UIImage alloc]initWithCGImage:thum];
                            
                        }else {
                            image =[[UIImage alloc]initWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                        }
                        
                        image = [self scaleImage:image toScale:1.0];
                        
                        NSString *keyName = [[MTTPhotosCache sharedPhotoCache] getKeyName];
                        photo.localPath = keyName;
                        
                        [array addObject:image];
                    }
                    [[PublishInfoViewController shareInstance] receiveImageArray:array];
                    
                } completionBlock:^{
                    [HUD removeFromSuperview];
                    [weakSelf.navigationController popToViewController:[weakSelf.navigationController.viewControllers objectAtIndex:2] animated:YES];
                }];
            }
        }
    };
    
    [self.view addSubview:self.bar];
    [self.gridView scrollToItemAtIndex:[self.assetsArray count] atScrollPosition:AQGridViewScrollPositionBottom animated:NO];
}

#pragma mark - photoBrowser
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index
{
    return [NSString stringWithFormat:@"%zd/%ld",index+1,(unsigned long)[self.photos count]];
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index
{
    return [[_selections objectAtIndex:index] boolValue];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected
{
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    [self setSendButtonTitle];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    
    return nil;
}

-(void)setSendButtonTitle
{
    __block int j = 0;
    [self.selections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj boolValue]) {
            j++;
        }
    }];
    
    [self.button setTitle:[NSString stringWithFormat:@"选取(%d)",j] forState:UIControlStateNormal];
}

- (void)dealloc
{
    self.choosePhotosArray = nil;
    self.gridView = nil;
    self.assetsArray = nil;
    self.bar = nil;
}

#pragma mark 等比縮放image
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

#pragma mark 自定义大小image
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)backToRoot
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AQGridViewDataSource
- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView
{
    return  [self.assetsArray count];
}

- (AQGridViewCell *)gridView: (AQGridView *)aGridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * PlainCellIdentifier = @"PlainCellIdentifier";
    ImageGridViewCell * cell = (ImageGridViewCell *)[self.gridView dequeueReusableCellWithIdentifier: PlainCellIdentifier];
    
    if ( cell == nil ) {
        cell = [[ImageGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 75.0, 75.0) reuseIdentifier: PlainCellIdentifier];
    }
    
    // 展示选中
    cell.isShowSelect = YES;
    cell.selectionGlowColor = [UIColor clearColor];
    
    
    // 拿到图片
    ALAsset *asset = [self.assetsArray objectAtIndex:index];
    CGImageRef thum = [asset thumbnail];
    UIImage *ti = [UIImage imageWithCGImage:thum];
    cell.image = ti;
    cell.tag = index;
    
    if ([self.choosePhotosArray containsObject:asset]) {
        [cell setCellIsToHighlight:YES];
        
    }else {
        [cell setCellIsToHighlight:NO];
    }
    
    return cell ;
}

// 选择相片
- (void) gridView:(AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
    [gridView deselectItemAtIndex:index animated:YES];
    
    ALAsset *asset = [self.assetsArray objectAtIndex:index];
    // self.gridView
    ImageGridViewCell *cell =(ImageGridViewCell *) [self.gridView cellForItemAtIndex:index];
    if ([self.choosePhotosArray containsObject:asset]) {
        [cell setCellIsToHighlight:NO];
        [self.choosePhotosArray removeObject:asset];
        
    }else {
        BlogImageModel *model;
        if([PublishInfoViewController shareMutabArray].count != 0){
            model = [[PublishInfoViewController shareMutabArray] objectAtIndex:0];
        }
        
        // 最多可选9张
        NSInteger max = 9 - model.imgArray.count;
        
        if ([self.choosePhotosArray count] == max) {
            return;
        }
        [cell setCellIsToHighlight:YES];
        [self.choosePhotosArray addObject:asset];
    }
    
    [self.bar setSendButtonTitle:(int)[self.choosePhotosArray count]];
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) gridView
{
    return CGSizeMake(75, 80);
}

-(IBAction)sendPhotos:(id)sender
{
    UIButton *button =(UIButton *)sender;
    [button setEnabled:NO];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.photoBrowser.view addSubview:HUD];
    
    HUD.dimBackground = YES;
    HUD.labelText = @"";
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        if ([self.photos count] >0) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            NSMutableArray *tmp = [NSMutableArray new];
            [self.selections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj boolValue]) {
                    [tmp addObject:@(idx)];
                }
            }];
            
            [tmp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSInteger index = [obj integerValue];
                MWPhoto *newPhoto = [self.photos objectAtIndex:index];
                
                MTTPhotoEnity *photo = [MTTPhotoEnity new];
                NSString *keyName = [[MTTPhotosCache sharedPhotoCache] getKeyName];
//                NSData *photoData = UIImagePNGRepresentation(newPhoto.image);
//                [[MTTPhotosCache sharedPhotoCache] storePhoto:photoData forKey:keyName toDisk:YES];
                photo.localPath=keyName;
                photo.image = [self scaleImage:newPhoto.image toScale:0.3];
                [array addObject:photo.image];
                
            }];
            [[PublishInfoViewController shareInstance] receiveImageArray:array];
        }
        [button setEnabled:YES];
        
    } completionBlock:^{
        [HUD removeFromSuperview];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
        [button setEnabled:YES];
    }];
}

@end
