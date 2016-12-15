//
//  FriendFirstItemView.m
//  TeamTalk
//
//  Created by 1 on 16/11/28.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "FriendFirstItemView.h"
#import "XunXinViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "MTTUserEntity.h"
#import "MTTPhotosCache.h"
#import "MTTUserEntity.h"
#import "DDSendPhotoMessageAPI.h"
#import "UIImage+Orientation.h"

@interface FriendFirstItemView()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, weak)   NSTimer *timer;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSMutableArray *imgsArray;
@property (nonatomic, weak)   UIButton *openCameraBtn;
@property (nonatomic, weak)   UIButton *closeCameraBtn;
@property (nonatomic, copy)   NSString *urlString;
/** 是否第一次开启摄像头*/
@property (nonatomic, assign) BOOL isFirstOpen;
/** 切换之前的状态*/
@property (nonatomic, assign) BOOL cameraStatusIsOpen;
/** 上传第一张*/
@property (nonatomic, assign) BOOL isFirstUpload;

@end

@implementation FriendFirstItemView

#pragma mark - 懒加载

- (NSMutableArray *)imgsArray
{
    if (_imgsArray == nil) {
        _imgsArray = [NSMutableArray array];
    }
    return _imgsArray;
}

- (AVCaptureSession *)captureSession
{
    if (_captureSession == nil) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        // 头像地址
        MTTUserEntity *userEntity = (MTTUserEntity *)TheRuntime.user;
        NSString *userID;
        if ([userEntity.userID containsString:@"user_"]) {
            userID = [userEntity.userID substringFromIndex:5];
        }else {
            userID = userEntity.userID;
        }
        NSString *urlString = [NSString stringWithFormat:@"http://maomaojiang.oss-cn-shenzhen.aliyuncs.com/im/avatar/%@.png", userID];
        self.urlString = urlString;
        
        self.isFirstOpen        = YES;
        self.cameraStatusIsOpen = NO;
        self.isFirstUpload      = NO;
        
        // 添加子控件
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageView.image = [UIImage imageNamed:@"toux"];
        self.imageView = imageView;
        [self addSubview:imageView];
        
        
        // 用户信息
        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 20, frame.size.width, 20)];
        infoView.backgroundColor = [UIColor colorWithRed:14.0/255.0 green:207.0/255.0 blue:49.0/255.0 alpha:1.0];
        infoView.alpha = 0.3;
        [imageView addSubview:infoView];
        
        // 头像
//        UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12, infoView.frame.origin.y + 2.5, 30, 30)];
//        headerImgView.layer.cornerRadius = 15;
//        headerImgView.clipsToBounds = YES;
//        [headerImgView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"header"]];
//        [imageView addSubview:headerImgView];
        
        // 昵称
        UILabel *nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, infoView.frame.origin.y + 2.5, frame.size.width, 15)];
        nickLabel.font = [UIFont systemFontOfSize:15.0];
        if (userEntity.nick.length) {
            nickLabel.text = userEntity.nick;
        }else {
            nickLabel.text = @"我是机器人";
        }
        nickLabel.textAlignment = NSTextAlignmentCenter;
        nickLabel.textColor = [UIColor whiteColor];
        [imageView addSubview:nickLabel];
        
        // 开启摄像头按钮  dd_take-photo@2x  chat_take_photo@2x
        UIButton *openCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        // (frame.size.height - 60) * 0.5
        openCameraBtn.frame = CGRectMake((frame.size.width - 60) * 0.5, 0, 60, 60);
        [openCameraBtn setImage:[UIImage imageNamed:@"chat_take_photo@2x"] forState:UIControlStateNormal];
        [openCameraBtn addTarget:self action:@selector(openCameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.openCameraBtn = openCameraBtn;
        [self addSubview:openCameraBtn];
        
        
        // 关闭摄像头的按钮
        UIButton *closeCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeCameraBtn.frame = CGRectMake((frame.size.width - 40), (frame.size.height - 40 - 15), 40, 40);
        closeCameraBtn.hidden = YES;
        [closeCameraBtn setImage:[UIImage imageNamed:@"chat_take_photo@2x"] forState:UIControlStateNormal];
        [closeCameraBtn addTarget:self action:@selector(closeCameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.closeCameraBtn = closeCameraBtn;
        [self addSubview:closeCameraBtn];
    }
    // 注册监听
    [self listenForEvents];
    
    NSString *cameraStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentCameraStatus"];
    if ([cameraStatus isEqualToString:@"cameraOpen"]) {
        [self dealWithCameraData];
    }
    
    return self;
}

#pragma mark - 监听事件

- (void)listenForEvents
{
    /** 监听其他界面的摄像头是否开启*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherViewCameraOpen:) name:@"RecommendViewCameraOpen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherViewCameraOpen:) name:@"ConcernViewCameraOpen" object:nil];
    /** 当前窗口显示的是自己的view*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentViewIsFriendView:) name:@"FriendView" object:nil];
    /** 当前窗口显示的不是自己的view*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherViewWillShow:) name:@"RecommendView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherViewWillShow:) name:@"ConcernView" object:nil];
    /** 控制器view消失*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeViewWillDisappear) name:@"HomeViewWillDisappear" object:nil];
    /** 控制器view显示*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeViewWillAppear:) name:@"HomeViewWillAppear" object:nil];
}

#pragma mark - 实现监听的方法

- (void)homeViewWillAppear:(NSNotification *)note
{
    XunXinViewController *xunxinVC = note.object;
    if (xunxinVC.titleBtnTag == 1) {
        if (self.openCameraBtn.hidden) {
            
            [self initCapture];
            [self.captureSession startRunning];
            [self startTimer];
            
            if ([self.delegate respondsToSelector:@selector(startUploadImage)]) {
                [self.delegate startUploadImage];
            }
        }
    }
}

- (void)homeViewWillDisappear
{
    if (self.openCameraBtn.hidden) {
        [self.captureSession stopRunning];
        self.isFirstOpen = YES;
        
        // 停止上传
        if ([self.delegate respondsToSelector:@selector(stopUploadImage)]) {
            [self.delegate stopUploadImage];
        }
        
        [self stopTimer];
        self.captureSession = nil;
    }
}

- (void)otherViewWillShow:(NSNotification *)note
{
    if (self.openCameraBtn.hidden) {
        [self.captureSession stopRunning];
        [self stopTimer];
        
        // 停止上传
        if ([self.delegate respondsToSelector:@selector(stopUploadImage)]) {
            [self.delegate stopUploadImage];
        }
    }
}

- (void)currentViewIsFriendView:(NSNotification *)note
{
    NSString *cameraStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentCameraStatus"];
    // 相机打开状态
    if ([cameraStatus isEqualToString:@"cameraOpen"]) {
        // 检查按钮状态
        if (self.openCameraBtn.hidden) {
            [self.captureSession startRunning];
            [self startTimer];
            
            if ([self.delegate respondsToSelector:@selector(startUploadImage)]) {
                [self.delegate startUploadImage];
            }
        }else {
            [self dealWithCameraData];
        }
    // 相机关闭状态
    }else if ([cameraStatus isEqualToString:@"cameraClose"]) {
        if (self.openCameraBtn.hidden) {
            // 关闭相机
            [self closeCameraBtnAffter];
            // 显示自己头像
            [self showUserHeaderAndUpload];
        }
    }
}

- (void)otherViewCameraOpen:(NSNotification *)note
{
    if (self.openCameraBtn.hidden) {
        [self.captureSession stopRunning];
        [self stopTimer];
        
        if ([self.delegate respondsToSelector:@selector(stopUploadImage)]) {
            [self.delegate stopUploadImage];
        }
    }
}

#pragma mark - 按钮的点击

- (void)dealWithCameraData
{
    self.openCameraBtn.hidden  = YES;
    self.closeCameraBtn.hidden = NO;
    self.cameraStatusIsOpen    = YES;
    self.isFirstUpload         = YES;
    
    if (self.isFirstOpen) {
        // 第一次初始化摄像头
        [self initCapture];
        self.isFirstOpen = NO;
    }else {
        [self.captureSession startRunning];
    }
    // 开启定时器
    [self startTimer];
    // 代理上传
    if ([self.delegate respondsToSelector:@selector(startUploadImage)]) {
        [self.delegate startUploadImage];
    }
    // 通知本页面开启了摄像头
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendViewCameraOpen" object:self userInfo:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@"cameraOpen" forKey:@"currentCameraStatus"];
}

- (void)openCameraBtnClick
{
    NSString *isFirstRunning = [[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstRunning"];
    if ([isFirstRunning isEqualToString:@"YES"]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted){
                    // 同意授权
                    [self dealWithCameraData];
                }
            });
        }];
        
    }else if ([isFirstRunning isEqualToString:@"NO"]){
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == 3) {
            [self dealWithCameraData];
        }else
        {
            // 提醒用户去开启设置
            if ([self.delegate respondsToSelector:@selector(alertUserOpenCameraSetting)]) {
                [self.delegate alertUserOpenCameraSetting];
            }
        }
    }
}

// 关闭相机之后
- (void)closeCameraBtnAffter
{
    self.closeCameraBtn.hidden = YES;
    self.openCameraBtn.hidden  = NO;
    self.cameraStatusIsOpen    = NO;
    
    [self.captureSession stopRunning];
    [self stopTimer];
    
    if ([self.delegate respondsToSelector:@selector(stopUploadImage)]) {
        [self.delegate stopUploadImage];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"cameraClose" forKey:@"currentCameraStatus"];
}

- (void)closeCameraBtnClick
{
    [self closeCameraBtnAffter];
    
    // 显示自己的头像
    [self showUserHeaderAndUpload];
    // 并上传阿里云
    [self uploadImgToAliyunOSS:self.imageView.image];
}

#pragma mark - 头像上传阿里云

- (void)showUserHeaderAndUpload
{
    // 显示自己的头像
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.urlString]];
    if (data) {
        self.imageView.image = [UIImage imageWithData:data];
    }else {
        self.imageView.image = [UIImage imageNamed:@"toux"];
    }
}

- (void)uploadImgToAliyunOSS:(UIImage *)image
{
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

#pragma mark - 定时器事件

// 开启定时器
- (void)startTimer
{
    [self.imgsArray removeAllObjects];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(controlCaptureSession) userInfo:nil repeats:YES];
    
    // 添加到主运行循环中
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)controlCaptureSession
{
    self.imageView.image = self.image;
    
    if (self.captureSession.isRunning) {
        [self.captureSession stopRunning];
    }else {
        [self.captureSession startRunning];
    }
}

// 暂停
- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark -  initCapture

- (void)initCapture
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    // lastObject 前置摄像头    firstObject 后置摄像头
    AVCaptureDeviceInput *captureInput =[AVCaptureDeviceInput deviceInputWithDevice:[devices lastObject] error:NULL];
    
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

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

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
    
    if (self.imgsArray.count < 10) {
        [self.imgsArray addObject:image];
    }
    
    CGImageRelease(newImage);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.imgsArray.count == 10) {
            self.imageView.image = self.imgsArray.lastObject;
            self.image = self.imgsArray.lastObject;
            
            if (self.isFirstUpload) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self uploadImgToAliyunOSS:self.image];
                });
                self.isFirstUpload = NO;
            }
            
            [self.imgsArray removeAllObjects];
            [self.captureSession stopRunning];
        }
        
    });
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
}

#pragma mark - dealloc

// 移除监听
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
