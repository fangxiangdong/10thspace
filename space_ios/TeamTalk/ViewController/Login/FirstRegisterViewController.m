//
//  FirstRegisterViewController.m
//  TeamTalk
//
//  Created by mac on 16/12/12.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "FirstRegisterViewController.h"
#import "AFNetworking.h"
#import "UIImageView+SDWebImage.h"
#import "NSString+Additions.h"
#import "NSDictionary+JSON.h"
#import "MBProgressHUD.h"
#import "RegisterViewController.h"
@interface FirstRegisterViewController ()<UITextFieldDelegate>
{


    UIImageView *verifyCodeView;
}
@property (nonatomic, strong) UITextField *phoneTF;

@property (nonatomic, strong) UITextField *codeTF;
@property (nonatomic, strong) UIButton *registerButton;
@end

@implementation FirstRegisterViewController

#pragma mark - ViewController LifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:@"http://10thcommune.com:86/autocode.php"]];
        UIImage *image = [UIImage imageWithData:data]; // 取得图片
        
        if (data != nil) {
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
                verifyCodeView.image=image;
            });
        }
    });

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"注册";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupMainUI];
}
- (void)setupRegisterButton
{
    self.registerButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 330, SCREEN_WIDTH - 60, 50)];
    _registerButton.backgroundColor = RGBA(28, 216, 27, 1);
    
    [_registerButton setTitle:@"下一步" forState:UIControlStateNormal];
    _registerButton.layer.cornerRadius = 4;
    [_registerButton addTarget:self action:@selector(didClickFirstRegisterButton:)
              forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_registerButton];
}

- (void)setupMainUI
{
    // 昵称
    //    self.nickNameTF = [self createUserInputTextFieldWithFrame:CGRectMake(15, 80, SCREEN_WIDTH - 30, 45)
    //                                                  placeholder:@"输入昵称"
    //                                              secureTextEntry:NO
    //                                                 keyboardType:UIKeyboardTypeDefault];
    
    // 手机号
    self.phoneTF = [self createUserInputTextFieldWithFrame:CGRectMake(30, 180, SCREEN_WIDTH - 30*2, 44)
                                               placeholder:@"输入手机号码"
                                           secureTextEntry:NO
                                              keyboardType:UIKeyboardTypeNumberPad];
    
    
    //    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.phoneTF.frame), CGRectGetMaxY(_phoneTF.frame) + 1, 1, _phoneTF.frame.size.height - 2)];
    //    line2.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //    [self.view addSubview:line2];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_phoneTF.frame), CGRectGetMaxY(_phoneTF.frame), _phoneTF.bounds.size.width, 1)];
    line1.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:line1];
    
    
    
    // 验证码
    self.codeTF = [self createUserInputTextFieldWithFrame:CGRectMake(30, CGRectGetMaxY(self.phoneTF.frame), SCREEN_WIDTH - 30 - 120, 44)
                                              placeholder:@"请输入验证码"
                                          secureTextEntry:NO
                                             keyboardType:UIKeyboardTypeDefault];
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_codeTF.frame), CGRectGetMaxY(_codeTF.frame), _codeTF.bounds.size.width, 1)];
    line3.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:line3];
    
  

   verifyCodeView=[[UIImageView alloc]initWithFrame:  CGRectMake(SCREEN_WIDTH - 135, 180+44, 120, 44)];
    verifyCodeView.userInteractionEnabled=YES;
    
    [self.view addSubview:verifyCodeView];
    
    
    UITapGestureRecognizer *ges=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(refreshCodeView)];
    
    [verifyCodeView addGestureRecognizer:ges];
    
    
    [self setupRegisterButton];
    
}


-(void)refreshCodeView
{

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:@"http://10thcommune.com:86/autocode.php"]];
        UIImage *image = [UIImage imageWithData:data]; // 取得图片
        
        if (data != nil) {
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
                verifyCodeView.image=image;
            });
        }
        
    });






}
#pragma mark - Utils

- (UITextField *)createUserInputTextFieldWithFrame:(CGRect)frame placeholder:(NSString *)placeholder secureTextEntry:(BOOL)needSecure keyboardType:(UIKeyboardType)keyboardType
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    //UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 22.5)];
    textField.placeholder = placeholder;
    //textField.leftView = leftView;
    textField.secureTextEntry = needSecure;
    textField.keyboardType = keyboardType;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    //textField.leftViewMode = UITextFieldViewModeAlways;
    textField.font = [UIFont systemFontOfSize:15];
    textField.delegate = self;
    
    //    [textField.layer setBorderColor:RGB(211, 211, 211).CGColor];
    //    [textField.layer setBorderWidth:0.5];
    //    [textField.layer setCornerRadius:4];
    
    [self.view addSubview:textField];
    
    return textField;
}

-(void)didClickFirstRegisterButton:(UIButton*)sender
{
  
    NSString *phoneRegex = @"^1[3|4|5|7|8][0-9]\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    
    BOOL isPhoneNumber = [phoneTest evaluateWithObject:_phoneTF.text];
    if ([_phoneTF.text isEqualToString:@""]) {
        [self showErrorInfoWithMessage:@"手机号不能为空" hideAfterDelay:1.0f];
        return;
    }
    if (!isPhoneNumber || _phoneTF.text.length != 11) {
        [self showErrorInfoWithMessage:@"请输入正确的手机号" hideAfterDelay:1.0f];
        return;
    }
    if ([_codeTF.text isEqualToString:@""]) {
        [self showErrorInfoWithMessage:@"验证码不能为空" hideAfterDelay:1.0f];
        return;
    }
    

    
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:_phoneTF.text forKey:@"phone"];
    
    
    [dic setObject:_codeTF.text  forKey:@"valid_code2"];
    
    NSString *landu_arg = [dic jsonString];
    NSDictionary *postDic = @{@"arg":landu_arg};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:FIRSTREGIST parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
         NSLog(@"%@",responseDictionary);
         NSLog(@"%@",responseDictionary[@"error_message"]);
         
         if ([responseDictionary[@"error_code"]intValue]==0) {
             
             RegisterViewController*reg=[[RegisterViewController alloc]init];
             reg.phoneString=_phoneTF.text;
             
             
             [self pushViewController:reg animated:NO];
         }
         else if([responseDictionary[@"error_code"]intValue]==1){
         
              [self showErrorInfoWithMessage:@"图形验证码过期，请重新输入" hideAfterDelay:1.5f];
             [self refreshCodeView];
             
         }
         else if([responseDictionary[@"error_code"]intValue]==2){
             
             [self showErrorInfoWithMessage:@"图形验证码错误，请重新输入" hideAfterDelay:1.5f];
             [self refreshCodeView];
         }

         else{
         
            [self showErrorInfoWithMessage:[NSString stringWithFormat:@"%@",responseDictionary[@"error_message"]] hideAfterDelay:1.5f];
          
             [self.navigationController popViewControllerAnimated:NO];
         }
         
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         //         [HUD removeFromSuperview];
                  [self showErrorInfoWithMessage:[NSString stringWithFormat:@"%@",error] hideAfterDelay:1.5f];

     } ];
    
         
    
    
    
}


- (void)showErrorInfoWithMessage:(NSString *)errorMessage hideAfterDelay:(NSTimeInterval)delay {
    MBProgressHUD *tips = [self showNoticeWithMessage:errorMessage modeOfHUD:MBProgressHUDModeText];
    [tips hide:YES afterDelay:delay];
}
- (MBProgressHUD *)showNoticeWithMessage:(NSString *)message modeOfHUD:(MBProgressHUDMode)mode
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    HUD.mode = mode;
    HUD.dimBackground = YES;
    HUD.labelText = message;
    
    return HUD;
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
