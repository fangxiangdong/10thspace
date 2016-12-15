//
//  DDMTTLoginViewController.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "MTTLoginViewController.h"
#import "MTTRootViewController.h"
#import "LoginModule.h"
#import "SendPushTokenAPI.h"
#import "MBProgressHUD.h"
#import "SCLAlertView.h"
#import "RegisterViewController.h"
#import "AddFriendModule.h"
#import "MTTPhotosCache.h"
#import "MTTUserEntity.h"
#import "DDSendPhotoMessageAPI.h"
#import "RecentUsersViewController.h"
#import "NSDictionary+JSON.h"
#import "AFNetworking.h"
#import "FirstRegisterViewController.h"
#import "NSString+Additions.h"
@interface MTTLoginViewController ()<UITextFieldDelegate>

@property(assign)CGPoint defaultCenter;

@property (nonatomic,weak)IBOutlet UITextField* userNameTextField;
@property (nonatomic,weak)IBOutlet UITextField* userPassTextField;
@property (nonatomic,weak)IBOutlet UIButton* userLoginBtn;
@property(assign)BOOL isRelogin;

@end

@implementation MTTLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleWillShowKeyboard)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleWillHideKeyboard)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSArray *array=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *strPath = (NSString*)array[0];
//    NSFileManager * fileManager = [[NSFileManager alloc]init];
//    [fileManager removeItemAtPath:strPath error:nil];
    
    //打印沙河中所有文件名
//    NSArray *file1 = [fileManager subpathsOfDirectoryAtPath: strPath error:nil];
//    NSLog(@"file1 == %@",file1);
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"username"]!=nil) {
        _userNameTextField.text =[[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"password"]!=nil) {
        _userPassTextField.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    }
    if(!self.isRelogin)
    {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"username"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"password"])
        {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"autologin"] boolValue] == YES) {
                //[self loginButtonPressed:nil];
            }
        }
    }
    
    self.defaultCenter=self.view.center;
    self.userNameTextField.leftViewMode=UITextFieldViewModeAlways;
    self.userPassTextField.leftViewMode=UITextFieldViewModeAlways;
    
    UIImageView *usernameLeftView = [[UIImageView alloc] init];
    usernameLeftView.contentMode = UIViewContentModeCenter;
    usernameLeftView.frame=CGRectMake(0, 0, 10, 22.5);
    
    UIImageView *pwdLeftView = [[UIImageView alloc] init];
    pwdLeftView.contentMode = UIViewContentModeCenter;
    pwdLeftView.frame=CGRectMake(0, 0, 10, 22.5);
    self.userNameTextField.leftView = usernameLeftView;
    self.userPassTextField.leftView = pwdLeftView;
//    [self.userNameTextField.layer setBorderColor:RGB(211, 211, 211).CGColor];
//    [self.userNameTextField.layer setBorderWidth:0.5];
//    [self.userNameTextField.layer setCornerRadius:4];
    
//    [self.userPassTextField.layer setBorderColor:RGB(211, 211, 211).CGColor];
//    [self.userPassTextField.layer setBorderWidth:0.5];
//    [self.userPassTextField.layer setCornerRadius:4];
    
    [self.userLoginBtn.layer setCornerRadius:4];
    
    // 设置用户名
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden =YES;
}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
    self.defaultCenter=self.view.center;
}

#pragma mark - keyboard hide and show notification

-(void)handleWillShowKeyboard
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.center=CGPointMake(self.view.center.x, self.defaultCenter.y-(IPHONE4?120:40));
    }];
}
-(void)handleWillHideKeyboard
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.center=self.defaultCenter;
    }];
}

#pragma mark - 头像上传阿里云

- (void)uploadHeaderToAliyunOSS
{
    MTTUserEntity *userEntity = (MTTUserEntity *)TheRuntime.user;
    NSString *urlString = [NSString stringWithFormat:@"http://maomaojiang.oss-cn-shenzhen.aliyuncs.com/im/avatar/%@.png", userEntity.userID];
    
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];;
    if (!imgData) {
        UIImage *image = [UIImage imageNamed:@"toux"];
        imgData = UIImagePNGRepresentation(image);
    }
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
            
        } failure:^(NSError *error) {
            DDLog(@"upload failure：error");
        }];
    });
}

#pragma mark - button pressed

-(IBAction)hiddenKeyboard:(id)sender
{
    [_userNameTextField resignFirstResponder];
    [_userPassTextField resignFirstResponder];
}

-(void)loginCheck:(NSString*)phone andPassword:(NSString*)password
{
    /* 需要2个字典 一个是上传dic  一个是本地用的dic2*/
    NSMutableDictionary *dic2 = [[NSMutableDictionary alloc] init];
    [dic2 setObject:phone forKey:@"phone"];
    [dic2 setObject:password forKey:@"passwd"];
    [dic2 setObject:[password MD5] forKey:@"md5passwd"];
    
  
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:phone forKey:@"phone"];
    
   
    [dic setObject:[password MD5] forKey:@"passwd"];
    [dic setObject:@"test" forKey:@"server_type"];

    NSString *landu_arg = [dic jsonString];
    NSDictionary *postDic = @{@"arg":landu_arg};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:LOGINCHECK parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
//         if (!responseObject) {
//             DDLog(@"服务器返回数据为空!!!");
//             return;
//         }
       NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
//         DDLog(@"----responseDic == %@",responseDictionary);
//
         DDLog(@"----responseDic == %@",responseDictionary[@"return_message"]);
         if (!responseDictionary[@"return_code"]||!([responseDictionary[@"return_code"]intValue]==0)) {
             
             
               SCLAlertView *alert = [SCLAlertView new];
             [alert showError:self title:@"登录失败" subTitle:responseDictionary[@"return_message"] closeButtonTitle:@"确定" duration:0];
             [self.userLoginBtn setEnabled:YES];
             return ;
         }
        
       
         if (responseDictionary[@"return_message"]&&responseDictionary[@"return_server"]) {
             
             [[LoginModule instance] loginWithUsername:responseDictionary[@"return_message"] password:dic2 andDict:responseDictionary[@"return_server"] success:^(MTTUserEntity *user) {
                 
                 [[NSUserDefaults standardUserDefaults]setObject:postDic forKey:@"postDic"];
                 [[NSUserDefaults standardUserDefaults]setObject:dic2 forKey:@"postDic2"];
                 [[NSUserDefaults standardUserDefaults]synchronize];  //登录成功 保存登录信息 方便重新连接
                 
             // 登录成功后上传自己头像
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self uploadHeaderToAliyunOSS];
             });
             
             [self.userLoginBtn setEnabled:YES];
             if (user) {
                 TheRuntime.user = user;
                 [TheRuntime updateData];
                 
                 if (TheRuntime.pushToken) {
                     SendPushTokenAPI *pushToken = [[SendPushTokenAPI alloc] init];
                     [pushToken requestWithObject:TheRuntime.pushToken Completion:^(id response, NSError *error) {
                         
                     }];
                 }
                 [[AddFriendModule instance] getRecentAddFriendMsgCount:^(NSUInteger count) {
                     
                 }];
                 
                 [[RecentUsersViewController shareInstance]refreshUI];
                 
                 MTTRootViewController *rootVC =[[MTTRootViewController alloc] init];
                 [self pushViewController:rootVC animated:YES];
             }
             
         }failure:^(NSString *error) {
             [self.userLoginBtn setEnabled:YES];
  
         }];
         }
//         NSString *error_code = [NSString stringWithFormat:@"%@",[responseDictionary objectForKey:@"error_code"]];
//         NSString *error_message = [NSString stringWithFormat:@"%@",[responseDictionary objectForKey:@"error_message"]];
//         
//         if([error_code isEqualToString:@"0"]) {
//             [self.navigationController popViewControllerAnimated:YES];
//         } else {
//             [self showErrorInfoWithMessage:error_message hideAfterDelay:1.5f];
//         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         [HUD removeFromSuperview];
//         [self showErrorInfoWithMessage:[NSString stringWithFormat:@"%@",error] hideAfterDelay:1.5f];
           SCLAlertView *alert = [SCLAlertView new];
          [alert showError:self title:@"错误" subTitle:@"登录失败" closeButtonTitle:@"确定" duration:0];
         [self.userLoginBtn setEnabled:YES];
     } ];

    [self.userLoginBtn setEnabled:YES];
}

- (IBAction)loginButtonPressed:(UIButton*)button{
    
    [self.userLoginBtn setEnabled:NO];
    NSString* userName = _userNameTextField.text;
    NSString* password = _userPassTextField.text;
   
    
    if (userName.length ==0 || password.length == 0) {
        [self.userLoginBtn setEnabled:YES];
        return;
    }
    
    [self loginCheck:userName andPassword:password];

    
//    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:HUD];
//    [HUD show:YES];
//    HUD.dimBackground = YES;
//    HUD.labelText = @"正在登录";
//    
//    SCLAlertView *alert = [SCLAlertView new];
//    
//    [[LoginModule instance]loginWithUsername:userName password:password success:^(MTTUserEntity *user) {
//        
//        [HUD removeFromSuperview];
//        
//       
//        
//    } failure:^(NSString *error) {
//        
//        [HUD removeFromSuperview];
//        
//        if([error isEqualToString:@"版本过低"]) {
////            DDLog(@"强制更新");
////            SCLAlertView *alert = [SCLAlertView new];
////            [alert addButton:@"确定" actionBlock:^{
////                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://tt.mogu.io"]];
////            }];
////            [alert showError:self title:@"升级提示" subTitle:@"版本过低，需要强制更新" closeButtonTitle:nil duration:0];
//            
//        }else {
//            [self.userLoginBtn setEnabled:YES];
//            [alert showError:self title:@"错误" subTitle:error closeButtonTitle:@"确定" duration:0];
//        }
//    }];
}
- (IBAction)reg:(id)sender {

//    RegisterViewController *reg = [[RegisterViewController alloc] init];
//    [self.navigationController pushViewController:reg animated:YES];
    
    FirstRegisterViewController*frvc=[[FirstRegisterViewController alloc] init];
    [self.navigationController pushViewController:frvc animated:YES];
    
    
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self loginButtonPressed:nil];
    
    return YES;
}
@end
