//
//  MTTCodeViewController.m
//  TeamTalk
//
//  Created by mac on 16/12/6.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "MTTCodeViewController.h"
#import "NSString+GetColor.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
@interface MTTCodeViewController ()
{
    
    UIImage *customQrcode ;
}
@property(nonatomic,strong)UIImageView*imageView;
@end

@implementation MTTCodeViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title=@"我的二维码";
    
    
    
    self.navigationItem.rightBarButtonItem = nil;
}
- (void)creates
{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2、恢复滤镜的默认属性
    [filter setDefaults];
    // 3、设置内容
    NSString *str = [NSString stringWithFormat:@"http://www.diybuy168.com/mobile_web/register.html?invitecode="];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    // 使用KVO设置属性
    [filter setValue:data forKey:@"inputMessage"];
    // 4、获取输出文件
    CIImage *outputImage = [filter outputImage];
    // 5、显示二维码
    UIImage *image =[self createNonInterpolatedUIImageFormCIImage:outputImage withSize:500.0f];
    
    
    self.imageView=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, (self.view.frame.size.height-200)/2-150, 200, 200)];
    customQrcode = [self imageBlackToTransparent:image withRed:60.0f andGreen:74.0f andBlue:89.0f];
    
    self.imageView.image =customQrcode;
    self.imageView.userInteractionEnabled=YES;
    [self.view addSubview:self.imageView];
    
    
}
- (void)saveScreenshotToPhotosAlbum:(UIView *)view
{
    UIImageWriteToSavedPhotosAlbum([self captureScreen], nil, nil, nil);
    
    UIAlertView *a=[[UIAlertView alloc]initWithTitle:@"保存成功" message:@"请在相册查看二维码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [a show];
}
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

- (UIImage *) captureScreen {
    
    CGRect rect = [ self.imageView bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [ self.imageView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creates];
      [self  createButton];
    // Do any additional setup after loading the view.
}
-(void)createButton
{
    
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, ((self.view.frame.size.height- 200)/2+50)+40, 200, 60)];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[NSString colorWithHexString:@"1cd81b"]];
    [button setTitle:@"保存到相册" forState:UIControlStateNormal];
    
    button.layer.cornerRadius=8;
    button.layer.masksToBounds=YES;
    
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    
    
    
    UIButton *button2=[[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, ((self.view.frame.size.height-200)/2+50)+40+100, 200, 60)];
    
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button2 setBackgroundColor:[NSString colorWithHexString:@"1cd81b"]];
    [button2 setTitle:@"分享给好友" forState:UIControlStateNormal];
    
    button2.layer.cornerRadius=8;
    button2.layer.masksToBounds=YES;
    
    [button2 addTarget:self action:@selector(sharedButtonclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    
    
    
    
}

-(void)sharedButtonclick:(UIButton*)button
{

   
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:@"分享内容"
                                         images:nil
                                            url:[NSURL URLWithString:@"http://mob.com"]
                                          title:@"分享标题"
                                           type:SSDKContentTypeAuto];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:self.view //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           default:
                               break;
                       }
                   }
         ];
    
    




}

-(void)buttonClick:(UIButton*)sender
{
    
    
    [self saveScreenshotToPhotosAlbum:nil];
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
