//
//  HomeRecommendViewController.m
//  TeamTalk
//
//  Created by 1 on 16/11/15.
//  Copyright © 2016年 IM. All rights reserved.
//

#import "HomeRecommendViewController.h"
#import "RecommendFirstItemView.h"
#import "InfiniteScrollView.h"
#import "HomeViewCell.h"
#import "MJRefresh.h"
#import "MTTAFNetworkingClient.h"
#import "MTTPhotosCache.h"
#import "MTTUserEntity.h"
#import "UIImage+Orientation.h"
/** API*/
#import "DDSendPhotoMessageAPI.h"

#define HomeScreenWidth [UIScreen mainScreen].bounds.size.width
#define HomeScreenHeight [UIScreen mainScreen].bounds.size.height

static CGFloat const margin = 3; // item 的间距
static int const cols = 2;
static NSString *const ID = @"cell";
#define itemWidth (self.view.frame.size.width - ((cols - 1) * margin)) / cols

@interface HomeRecommendViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, RecommendFirstItemViewDelegate, InfiniteScrollViewDelegate>

@property (nonatomic, weak)   UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, weak)   RecommendFirstItemView *firstItemView;
@property (nonatomic, weak)   NSTimer *timer;
@property (nonatomic, assign) BOOL cameraIsOpen;
@property (nonatomic, weak)   InfiniteScrollView *scrollView;
@property (nonatomic, strong) MTTUserEntity *userEntity;

@end

@implementation HomeRecommendViewController

#pragma mark - lazy

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
        
        MTTUserEntity *userEntity = (MTTUserEntity *)TheRuntime.user;
        self.userEntity = userEntity;
        [_dataArray addObject:userEntity];
    }
    return _dataArray;
}

#pragma mark - View

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 广告轮播器
    [self setupADView];
    
    self.cameraIsOpen = NO;
    // 创建collectionView
    [self setupHomeCollectionView];
}

#pragma mark - 创建view

- (void)setupADView
{
    InfiniteScrollView *scrollView = [[InfiniteScrollView alloc] init];
    scrollView.imagesArray = @[
                               [UIImage imageNamed:@"img_00"],
                               [UIImage imageNamed:@"img_01"],
                               [UIImage imageNamed:@"img_02"],
                               [UIImage imageNamed:@"img_03"],
                               [UIImage imageNamed:@"img_04"]
                               ];
    
    scrollView.frame = CGRectMake(0, 0, HomeScreenWidth, 150);
    scrollView.delegate = self;
    
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
}

- (void)setupHomeCollectionView
{
    // 布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth * 1.3);
    // 设置collectionView item开始时的高度
    layout.headerReferenceSize = CGSizeMake(0, 152);
    
    
    // collectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, HomeScreenWidth, HomeScreenHeight - 64 - 49 - margin - 21) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[HomeViewCell class] forCellWithReuseIdentifier:ID];
    
    
    // 上下拉刷新加载
//    [collectionView addHeaderWithTarget:self action:@selector(loadNewHomeData) dateKey:@"head"];
//    [collectionView headerBeginRefreshing];
//    [collectionView addFooterWithTarget:self action:@selector(loadMoreHomeData)];
    
    
    // 显示自己摄像头数据
    RecommendFirstItemView *firstItemView = [[RecommendFirstItemView alloc] initWithFrame:CGRectMake(0, 152, itemWidth, itemWidth * 1.3)];
    firstItemView.backgroundColor = [UIColor lightGrayColor];
    firstItemView.delegate = self;
    self.firstItemView = firstItemView;
    [collectionView addSubview:firstItemView];
    
    [collectionView addSubview:self.scrollView];
    
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];
}

#pragma mark - load_data

- (void)loadNewHomeData
{
    [self.collectionView reloadData];
    
    [self.collectionView headerEndRefreshing];
}

- (void)loadMoreHomeData
{
    [self.collectionView reloadData];
    
    [self.collectionView footerEndRefreshing];
}

#pragma mark - collectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    return 28;
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"cell";
    HomeViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[HomeViewCell alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemWidth * 1.3)];
    }
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    }else {
        cell.backgroundColor = [self randomColor];
    }
    cell.userEntity = self.dataArray[indexPath.item];
    return cell;
}

#pragma mark - UIScrollViewDelegate

// 广告轮播的点击
- (void)infiniteScrollView:(InfiniteScrollView *)infiniteScrollView didClickImageAtIndex:(NSInteger)index
{
    NSLog(@"%s", __func__);
}

// 拖拽完成
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.cameraIsOpen) {
        [self startTimer];
    }
}

// 将要开始拖拽的时候
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.cameraIsOpen) {
        [self stopTimer];
    }
}

#pragma mark - CollectionFirstItemViewDelegate

- (void)startUploadImage
{
    self.cameraIsOpen = YES;
    [self startTimer];
}

- (void)stopUploadImage
{
    self.cameraIsOpen = NO;
    [self stopTimer];
}

#pragma mark - 提醒用户开启摄像头

- (void)userRefuseOpenCamera
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"已关闭相机功能，如需重新开启可前往 “设置->隐私->相机” 里设置开启" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

// 提醒设置
- (void)alertUserOpenCameraSetting
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"该设备尚未开启摄像机功能，是否去设置开启？" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - 定时器事件

// 开启定时器
- (void)startTimer
{
    // 20s上传阿里云
    self.timer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(dealWithTimerThing) userInfo:nil repeats:YES];
    
    // 添加到主运行循环中
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)dealWithTimerThing
{
    // dispatch_get_main_queue()
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        
//    });
    [self uploadImageToAliyunOSS];
}

- (void)uploadImageToAliyunOSS
{
    UIImage *image = self.firstItemView.imageView.image;
    UIImage *newImage = [UIImage fixOrientation:image];
    // 等比缩放图片
    newImage = [UIImage scaleImage:newImage toScale:0.5];
    NSData *imgData = UIImageJPEGRepresentation(newImage, 0.3);
    if (imgData == nil) return;
    
    // 上传文件名
    MTTPhotoEnity *photoEnity = [[MTTPhotoEnity alloc] init];
    photoEnity.localPath = [[MTTPhotosCache sharedPhotoCache] getHomeImgKeyName];
    
    // 缓存磁盘
    [[MTTPhotosCache sharedPhotoCache] storePhoto:imgData forKey:photoEnity.localPath toDisk:YES];
    NSString *imgKey = [photoEnity.localPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // 将图片上传阿里云
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[DDSendPhotoMessageAPI sharedPhotoCache] homeUploadBlogToAliYunOSSWithContent:imgKey success:^(NSString *fileURL) {
            
        } failure:^(NSError *error) {
            DDLog(@"upload failure：error");
        }];
    });
}

// 暂停
- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor *)randomColor
{
    CGFloat r = arc4random_uniform(256) / 255.0;
    CGFloat g = arc4random_uniform(256) / 255.0;
    CGFloat b = arc4random_uniform(256) / 255.0;
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    return color;
}

@end
