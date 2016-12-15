//
//  XunXinHomeViewController.m
//  TeamTalk
//
//  Created by 1 on 16/11/15.
//  Copyright © 2016年 IM. All rights reserved.
//

#import "XunXinHomeViewController.h"
#import "HomeViewCell.h"
#import "MJRefresh.h"
#import "MTTAFNetworkingClient.h"
#import "MTTPhotosCache.h"
#import "MTTUserEntity.h"
#import "MTTDatabaseUtil.h"
/** API*/
#import "DDSendPhotoMessageAPI.h"
#import "HomeMainAPI.h"
#import "UserOnlineUnrequestAPI.h"
#import "UserOfflineUnrequestAPI.h"
/** AVCaptureSession*/
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

#define HomeScreenWidth [UIScreen mainScreen].bounds.size.width
#define HomeScreenHeight [UIScreen mainScreen].bounds.size.height

@interface XunXinHomeViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, weak)   UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *imgsArray;
@property (nonatomic, weak)   NSTimer *timer;
@property (nonatomic, strong) UIImage *image;

@end

static CGFloat const margin = 3; // item 的间距
static int const cols = 2;
static NSString *const ID = @"cell";
#define itemWidth (self.view.frame.size.width - ((cols - 1) * margin)) / cols

@implementation XunXinHomeViewController

- (NSString *)userType
{
    return @"0";
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 好友上线
//        [self listenUserOnline];
        // 好友下线
//        [self listenUserOffline];
    }
    return self;
}

// 上线好友
- (void)listenUserOnline
{
    UserOnlineUnrequestAPI *onlineAPI = [[UserOnlineUnrequestAPI alloc] init];
    [onlineAPI registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
//        NSLog(@"online---%@", object);
        
        NSDictionary *dict = (NSDictionary *)object;
        [self.dataArray addObject:dict];
        
        // 刷新界面
        [self.collectionView reloadData];
    }];
}

// 下线好友
- (void)listenUserOffline
{
    UserOfflineUnrequestAPI *offlineAPI = [[UserOfflineUnrequestAPI alloc] init];
    [offlineAPI registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
//        NSLog(@"offline---%@", object);
        NSDictionary *dictOffline = (NSDictionary *)object;
        NSString *offlineFriendID = [NSString stringWithFormat:@"%@", [dictOffline objectForKey:@"userID"]];
        
        for (NSDictionary *dict in self.dataArray) {
            NSString *friendID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"userID"]];
            if ([friendID isEqualToString:offlineFriendID]) {
                [self.dataArray removeObject:dict];
            }
        }
        
        // 刷新界面
        [self.collectionView reloadData];
    }];
}

#pragma mark - lazy

- (NSMutableArray *)imgsArray
{
    if (_imgsArray == nil) {
        _imgsArray = [NSMutableArray array];
    }
    return _imgsArray;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
        
        MTTUserEntity *userEntity = (MTTUserEntity *)TheRuntime.user;
        NSString *userID = [NSString stringWithFormat:@"%@", userEntity.userID];
        NSDictionary *dict = @{
                               @"userID": userID,
                               @"userType": @"mySelf"
                               };
        [_dataArray addObject:dict];
    }
    return _dataArray;
}

#pragma mark - view
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建collectionView
    [self setupHomeCollectionView];
}

#pragma mark - CollectionFirstItemViewDelegate
- (void)startUploadImage
{
    [self startTimer];
}

- (void)stopUploadImage
{
    [self stopTimer];
}

#pragma mark - 定时器事件
// 开启定时器
- (void)startTimer
{
    // 20s上传阿里云
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(uploadImageToAliyunOSS) userInfo:nil repeats:YES];
    
    // 添加到主运行循环中
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)uploadImageToAliyunOSS
{
    UIImage *image = nil;
    
    NSData *imgData = UIImageJPEGRepresentation(image, 0.4);
    if (imgData == nil) return;
    
    // 上传文件名
    MTTPhotoEnity *photoEnity = [[MTTPhotoEnity alloc] init];
    photoEnity.localPath = [[MTTPhotosCache sharedPhotoCache] getHomeImgKeyName];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 缓存磁盘
        [[MTTPhotosCache sharedPhotoCache] storePhoto:imgData forKey:photoEnity.localPath toDisk:YES];
    });
    
    NSString *imgKey = [photoEnity.localPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 将图片上传阿里云
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[DDSendPhotoMessageAPI sharedPhotoCache] homeUploadBlogToAliYunOSSWithContent:imgKey success:^(NSString *fileURL) {
//            DDLog(@"fileURL--%@", fileURL);
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

#pragma mark - 创建view

- (void)setupHomeCollectionView
{
    // 布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth * 1.2);
    
    
    // collectionView
    UICollectionView *collectionView  = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, HomeScreenWidth, HomeScreenHeight - 64 - 49 - margin - 21) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[HomeViewCell class] forCellWithReuseIdentifier:ID];
    
    
    // 上下拉刷新加载
    [collectionView addHeaderWithTarget:self action:@selector(loadNewHomeData) dateKey:@"head"];
    [collectionView headerBeginRefreshing];
    [collectionView addFooterWithTarget:self action:@selector(loadMoreHomeData)];
    
    
    // 显示自己摄像头数据
    
    
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];
}

#pragma mark - 获取数据库好友列表

- (void)getAllContactsFromFMDB
{
    [[MTTDatabaseUtil instance] getAllUsers:^(NSArray *contacts, NSError *error) {
        
        if (contacts.count != 0) {
            // 遍历
            [contacts enumerateObjectsUsingBlock:^(MTTUserEntity *userEntity, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString *userID = [userEntity.objID substringFromIndex:5];
                
                // 检查是否用图片
                NSString *urlString = [NSString stringWithFormat:@"http://maomaojiang.oss-cn-shenzhen.aliyuncs.com/im/live/user_%@.png", userID];
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
                if (data) {
                    [self.dataArray addObject:userID];
                }
            }];
        }
        // 刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}

#pragma mark - load_data

- (void)loadNewHomeData
{
    // 刷新collectionView
    HomeMainAPI *homeAPI = [[HomeMainAPI alloc] init];
    [homeAPI requestWithObject:nil Completion:^(id response, NSError *error) {
        
        NSLog(@"response--%@", response);
        
    }];
    
    if ([self.userType isEqualToString:@"recommend"]) {
        NSLog(@"recommend");
    }
    if ([self.userType isEqualToString:@"friend"]) {
        NSLog(@"friend");
        [self getAllContactsFromFMDB];
    }
    if ([self.userType isEqualToString:@"concern"]) {
        NSLog(@"concern");
    }
    
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
    return 28;
//    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"cell";
    HomeViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[HomeViewCell alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemWidth * 1.2)];
    }
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    }else {
        cell.backgroundColor = [self randomColor];
    }
//    cell.imgURL = self.dataArray[indexPath.item];
    return cell;
}

#pragma mark - UIScrollViewDelegate

// 拖拽完成
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}

// 将要开始拖拽的时候
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

#pragma mark - AVCaptureSession

- (void)initCapture
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    // lastObject 前置摄像头    firstObject 后置摄像头
    AVCaptureDeviceInput *captureInput =[AVCaptureDeviceInput deviceInputWithDevice:[devices firstObject] error:NULL];
    
    // 视频数据采集
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    // 设置代理
    dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    
    // 设置setting
    NSString *key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
    NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    
    if ([self.captureSession canAddInput:captureInput]) {
        [self.captureSession addInput:captureInput];
    }
    
    if ([self.captureSession canAddOutput:captureOutput]) {
        [self.captureSession addOutput:captureOutput];
    }
    
    // 开始获取
    [self.captureSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    
    // 释放
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    // 得到图片
    UIImage *image = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
    self.image = image;
    
    if (self.imgsArray.count < 10) {
        [self.imgsArray addObject:image];
    }
    
    CGImageRelease(newImage);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        self.firstItemView.imageView.image = self.imgsArray.lastObject;
        
    });
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
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
