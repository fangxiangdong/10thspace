//
//  CollectionFirstItemView.m
//  TeamTalk
//
//  Created by 1 on 16/11/4.
//  Copyright © 2016年 IM. All rights reserved.
//

#import "CollectionFirstItemView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "DDSendPhotoMessageAPI.h"
#import "MTTPhotosCache.h"
#import "MTTUserEntity.h"

@interface CollectionFirstItemView()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, weak)   NSTimer *timer;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSMutableArray *imgsArray;
@property (nonatomic, weak)   UIButton *openCameraBtn;
@property (nonatomic, weak)   UIButton *closeCameraBtn;
@property (nonatomic, assign) BOOL isFirstOpen;

@end

@implementation CollectionFirstItemView

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
        
        self.isFirstOpen = YES;
        
        MTTUserEntity *userEntity = (MTTUserEntity *)TheRuntime.user;
        NSString *urlString = [NSString stringWithFormat:@"http://maomaojiang.oss-cn-shenzhen.aliyuncs.com/im/live/user_%@.png", userEntity.userID];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        
        // 添加子控件
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageView.userInteractionEnabled = NO;
        imageView.image = [UIImage imageWithData:data];
        UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)];
        [imageView addGestureRecognizer:imageViewTap];
        self.imageView = imageView;
        [self addSubview:imageView];
        
        
        // 开启摄像头按钮  dd_take-photo@2x  chat_take_photo@2x
        UIButton *openCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        openCameraBtn.frame = CGRectMake((frame.size.width - 60) * 0.5, (frame.size.height - 60) * 0.5, 60, 60);
        [openCameraBtn setImage:[UIImage imageNamed:@"chat_take_photo@2x"] forState:UIControlStateNormal];
        [openCameraBtn addTarget:self action:@selector(openCameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.openCameraBtn = openCameraBtn;
        [self addSubview:openCameraBtn];
        
        
        // 关闭摄像头的按钮
        UIButton *closeCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeCameraBtn.frame = CGRectMake((frame.size.width - 40), (frame.size.height - 40), 40, 40);
        closeCameraBtn.hidden = YES;
        [closeCameraBtn setImage:[UIImage imageNamed:@"chat_take_photo@2x"] forState:UIControlStateNormal];
        [closeCameraBtn addTarget:self action:@selector(closeCameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.closeCameraBtn = closeCameraBtn;
        [self addSubview:closeCameraBtn];
    }
    
    // 监听消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeViewWillDisappear) name:@"HomeViewWillDisappear" object:nil];
    
    [self notificateViewChange];
    
    return self;
}

- (void)notificateViewChange
{
    // 推荐不在界面上显示
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recommendViewMove) name:@"FriendView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recommendViewMove) name:@"ConcernView" object:nil];
    // 推荐不在界面上显示
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendViewMove) name:@"RecommendView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendViewMove) name:@"ConcernView" object:nil];
    // 关注不在界面上显示
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(comcernViewMove) name:@"RecommendView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(comcernViewMove) name:@"FriendView" object:nil];
}

#pragma mark - 按钮的点击
// 关闭摄像头
- (void)closeCameraBtnClick
{
    self.closeCameraBtn.hidden = YES;
    
    [self.captureSession stopRunning];
    [self stopTimer];
    
    self.openCameraBtn.hidden = NO;
    
    if ([self.delegate respondsToSelector:@selector(stopUploadImage)]) {
        [self.delegate stopUploadImage];
    }
}

// 开启摄像头
- (void)openCameraBtnClick
{
    self.openCameraBtn.hidden = YES;
    
    [self.captureSession startRunning];
    
    if (self.isFirstOpen) {
        // 第一次初始化摄像头
        [self initCapture];
        self.isFirstOpen = NO;
    }
    // 开启定时器
    [self startTimer];
    self.closeCameraBtn.hidden = NO;
    
    if ([self.delegate respondsToSelector:@selector(startUploadImage)]) {
        [self.delegate startUploadImage];
    }
}

- (void)imageViewTap:(UITapGestureRecognizer *)tap
{
    if (self.isFirstOpen) {
        self.isFirstOpen = NO;
    }
}

#pragma mark - 监听通知
- (void)friendViewMove
{
    if (self.closeCameraBtn.hidden == NO) {
        [self closeCameraBtnClick];
    }
}

- (void)comcernViewMove
{
    if (self.closeCameraBtn.hidden == NO) {
        [self closeCameraBtnClick];
    }
}

- (void)recommendViewMove
{
    if (self.closeCameraBtn.hidden == NO) {
        [self closeCameraBtnClick];
    }
}

- (void)homeViewWillDisappear
{
    if (self.captureSession.running) {
        [self.captureSession stopRunning];
    }
    
    self.isFirstOpen = YES;
    self.openCameraBtn.hidden = NO;
    self.closeCameraBtn.hidden = YES;
    
    [self stopTimer];
    self.captureSession = nil;
}

- (void)homeViewWillAppear
{
    if (!self.captureSession.running) {
        [self.captureSession startRunning];
    }
    
    [self initCapture];
    [self startTimer];
}

// 移除监听
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 定时器事件

// 开启定时器
- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(controlCaptureSession) userInfo:nil repeats:YES];
    
    // 添加到主运行循环中
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)controlCaptureSession
{
    self.imageView.image = self.image;
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
    
    self.image = image;
    if (self.imgsArray.count < 10) {
        [self.imgsArray addObject:image];
    }
    
    CGImageRelease(newImage);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.imageView.image == nil && self.imgsArray.count == 10) {
            self.imageView.image = self.imgsArray.lastObject;
        }
        
    });
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
}

@end
