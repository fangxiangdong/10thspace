//
//  CYAlbumViewController.m
//  TeamTalk
//
//  Created by landu on 15/11/16.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "CYAlbumViewController.h"
#import "CYAlbumDetailsViewControll.h"
@interface CYAlbumViewController ()

@end

@implementation CYAlbumViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化数组
    self.albumsArray = [NSMutableArray new];
    self.assetsLibrary =  [[ALAssetsLibrary alloc] init];
    
    // 创建tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    tableView.delegate=self;
    tableView.dataSource=self;
    [self.view addSubview:tableView];
    
    // 分组block
    void (^assetsGroupsEnumerationBlock)(ALAssetsGroup *,BOOL *) = ^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
        if (assetsGroup.numberOfAssets > 0) {
            [self.albumsArray addObject:assetsGroup];
        }
        if (stop) {
            [tableView reloadData];
        }
    };
    
    // 查找相册失败block
    void(^assetsGroupsFailureBlock)(NSError *) = ^(NSError *error) {
        DDLog(@"查找相册失败: %@", [error localizedDescription]);
    };
    
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.albumsArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"DDAlbumsCellIdentifier";
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    NSString * name = [[self.albumsArray objectAtIndex:indexPath.row]
                       valueForProperty:ALAssetsGroupPropertyName];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@  ( %ld )",name,(long)[[self.albumsArray objectAtIndex:indexPath.row] numberOfAssets]];
    [cell.textLabel setTextColor:RGB(145, 145, 145)];
    [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    UIView *view = [[UIView alloc] initWithFrame:cell.frame];
    view.backgroundColor=RGB(246, 93, 137);
    cell.selectedBackgroundView=view;
    [cell.imageView setImage:[UIImage imageWithCGImage:[[self.albumsArray objectAtIndex:indexPath.row] posterImage]]] ;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

// 选择相册
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 相册里的相片
    CYAlbumDetailsViewControll *details = [[CYAlbumDetailsViewControll alloc] init];
    // 相册组的albumsArray
    details.assetsGroup = [self.albumsArray objectAtIndex:indexPath.row];
    
    [self pushViewController:details animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
