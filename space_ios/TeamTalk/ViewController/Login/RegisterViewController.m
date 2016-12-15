//
//  RegisterViewController.m
//  TeamTalk
//
//  Created by landu on 15/11/5.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "RegisterViewController.h"
#import "AFNetworking.h"
#import "Utility.h"
#import "MyMD5.h"
#import "MBProgressHUD.h"
#import "NSDictionary+JSON.h"

@interface RegisterViewController () <UITextFieldDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) UITextField *passwordTF;

@property (nonatomic, strong) UITextField *confirmPasswordTF;
@property (nonatomic, strong) UITextField *inviteTF;
@property (nonatomic, strong) UITextField *phoneTF;

@property (nonatomic, strong) UITextField *codeTF;

@property (nonatomic, strong) UITextField *nickNameTF;

@property (nonatomic, strong) UIButton *verificationButton;

@property (nonatomic, strong) UIButton *registerButton;

@end

@implementation RegisterViewController

#pragma mark - ViewController LifeCycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"注册";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupMainUI];
}

- (void)dealloc {

}

#pragma mark - Setup Main UI

- (void)setupMainUI
{
     //昵称
//    self.nickNameTF = [self createUserInputTextFieldWithFrame:CGRectMake(30, 180, SCREEN_WIDTH - 30*2, 44)
//                                                  placeholder:@"输入昵称"
//                                              secureTextEntry:NO
//                                                 keyboardType:UIKeyboardTypeDefault];
//    
//    
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_nickNameTF.frame), CGRectGetMaxY(_nickNameTF.frame), _nickNameTF.bounds.size.width, 1)];
//    line.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    [self.view addSubview:line];
    
    
    // 手机号
//    self.phoneTF = [self createUserInputTextFieldWithFrame:CGRectMake(30, 180, SCREEN_WIDTH - 30*2, 44)
//                                              placeholder:@"输入手机号码"
//                                          secureTextEntry:NO
//                                             keyboardType:UIKeyboardTypeNumberPad];

    
//    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.phoneTF.frame), CGRectGetMaxY(_phoneTF.frame) + 1, 1, _phoneTF.frame.size.height - 2)];
//    line2.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    [self.view addSubview:line2];

//    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_phoneTF.frame), CGRectGetMaxY(_phoneTF.frame), _phoneTF.bounds.size.width, 1)];
//    line1.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    [self.view addSubview:line1];
    
    
    
    // 验证码
    self.codeTF = [self createUserInputTextFieldWithFrame:CGRectMake(30, 180, SCREEN_WIDTH - 30 *2, 44)
                                              placeholder:@"请输入验证码"
                                          secureTextEntry:NO
                                             keyboardType:UIKeyboardTypeNumberPad];
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_codeTF.frame), CGRectGetMaxY(_codeTF.frame), _codeTF.bounds.size.width, 1)];
    line3.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:line3];
    
    // 获取验证码
    //[self setupVerificationButton];
    
    // 密码
    self.passwordTF = [self createUserInputTextFieldWithFrame:CGRectMake(30, CGRectGetMaxY(self.codeTF.frame), SCREEN_WIDTH - 60, 45)
                                                  placeholder:@"请输入密码"
                                              secureTextEntry:YES
                                                 keyboardType:UIKeyboardTypeNamePhonePad];
    
    UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_passwordTF.frame), CGRectGetMaxY(_passwordTF.frame), _passwordTF.bounds.size.width, 1)];
    line4.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:line4];
    // 确认密码
    self.confirmPasswordTF = [self createUserInputTextFieldWithFrame:CGRectMake(30, CGRectGetMaxY(self.passwordTF.frame), SCREEN_WIDTH - 60, 45)
                                                         placeholder:@"请确认密码"
                                                     secureTextEntry:YES
                                                        keyboardType:UIKeyboardTypeNamePhonePad];
    
    UIView *line5 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_confirmPasswordTF.frame), CGRectGetMaxY(_confirmPasswordTF.frame), _confirmPasswordTF.bounds.size.width, 1)];
    line5.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:line5];

    // 确认密码
    self.inviteTF= [self createUserInputTextFieldWithFrame:CGRectMake(30, CGRectGetMaxY(self.confirmPasswordTF.frame), SCREEN_WIDTH - 60, 45)
                                                         placeholder:@"邀请码(可不填)"
                                                     secureTextEntry:YES
                                                        keyboardType:UIKeyboardTypeNamePhonePad];

    UIView *line6= [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_inviteTF.frame), CGRectGetMaxY(_inviteTF.frame), _inviteTF.bounds.size.width, 1)];
    line6.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:line6];
    
    [self setupRegisterButton];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{


    [self.view endEditing:YES];



}


- (void)setupVerificationButton
{
    self.verificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _verificationButton.frame = CGRectMake(SCREEN_WIDTH - 135, 180+44, 120, 44);
    [_verificationButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_verificationButton setTitleColor:RGBA(28, 216, 27, 1)
                             forState:UIControlStateNormal];
    _verificationButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _verificationButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _verificationButton.layer.borderWidth = 0.5;
    _verificationButton.layer.borderColor = RGB(211, 211, 211).CGColor;
    _verificationButton.layer.cornerRadius = 4;
    [_verificationButton addTarget:self
                            action:@selector(didClickSendMessageCodeButton:)
                  forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.view addSubview:_verificationButton];
}

- (void)setupRegisterButton
{
    self.registerButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 430, SCREEN_WIDTH - 60, 50)];
    _registerButton.backgroundColor = RGBA(28, 216, 27, 1);
    
    [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
    _registerButton.layer.cornerRadius = 4;
    [_registerButton addTarget:self action:@selector(didClickRegisterButton:)
              forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_registerButton];
}

#pragma mark -
#pragma mark - 点击获取验证码

-(void)didClickSendMessageCodeButton:(UIButton *)sender
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
    //  请求验证码
    [self requestVerificationCode];
}

#pragma mark - 
#pragma mark - 点击注册

- (void)didClickRegisterButton:(UIButton *)sender
{
    [self resignFirstResponderForAllTextField];
//    if (_nickNameTF.text.length == 0) {
//        [self showErrorInfoWithMessage:@"用户名不能为空" hideAfterDelay:1.0f];
//        return;
//    }
//    if (_nickNameTF.text.length > 16 || _nickNameTF.text.length <= 2) {
//        [self showErrorInfoWithMessage:@"用户名长度应在4-16位之间" hideAfterDelay:1.0f];
//        return;
//    }
    if (_passwordTF.text.length < 6 || _passwordTF.text.length > 20) {
        [self showErrorInfoWithMessage:@"密码长度必须6~20位" hideAfterDelay:1.0f];
        return;
    }
    if (![_confirmPasswordTF.text isEqualToString:_passwordTF.text]) {
        [self showErrorInfoWithMessage:@"两次密码不一致" hideAfterDelay:1.0f];
        return;
    }
    [self regiserRequest];
}

#pragma mark - Networking Request

/** 获取短信验证码 */
- (void)requestVerificationCode
{
    //  开启倒计时
    [self openCountdown];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:_phoneTF.text forKey:@"phone"];
    NSString *landu_arg = [dic jsonString];
    
    NSDictionary *postDic = @{@"arg":landu_arg};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:GET_VALID_CODE parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (!responseObject) {
             DDLog(@"服务器返回数据为空");
             return;
         }
         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
         DDLog(@"----responseDic == %@",responseDictionary);
         
         NSString *error_code = [NSString stringWithFormat:@"%@",[responseDictionary objectForKey:@"error_code"]];
         
         if([error_code isEqualToString:@"0"]) {
             DDLog(@"获取短信验证码成功");
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         DDLog(@"--- error == %@",error);
     } ];
}

/** 发起注册请求 */
- (void)regiserRequest
{
    // 正在注册提示
    MBProgressHUD *HUD = [self showNoticeWithMessage:@"正在注册..." modeOfHUD:MBProgressHUDModeIndeterminate];
    
    // 注册申请参数
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.phoneString forKey:@"phone"];
    [dic setIntValue:[_codeTF.text intValue] forKey:@"valid_code"];
    [dic setObject:[MyMD5 md5:_passwordTF.text] forKey:@"passwd"];
    //[dic setObject:_nickNameTF.text forKey:@"nick"];
    

    NSString *landu_arg = [dic jsonString];
    NSDictionary *postDic = @{@"arg":landu_arg};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:REGISTER parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        [HUD hide:NO];
        if (!responseObject) {
            DDLog(@"服务器返回数据为空!!!");
            return;
        }
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        DDLog(@"----responseDic == %@",responseDictionary);
        
        NSString *error_code = [NSString stringWithFormat:@"%@",[responseDictionary objectForKey:@"error_code"]];
        NSString *error_message = [NSString stringWithFormat:@"%@",[responseDictionary objectForKey:@"error_message"]];
        
        if([error_code isEqualToString:@"0"]) {
            
            [self showErrorInfoWithMessage:@"注册成功" hideAfterDelay:1.0f];
            [self performSelector:@selector(delayMethod) withObject:nil afterDelay:1.0f];
            
        }
        else if([error_code isEqualToString:@"3"])
        {
        
        [self showErrorInfoWithMessage:error_message hideAfterDelay:1.5f];
        
        
        }
        else {
            [self showErrorInfoWithMessage:error_message hideAfterDelay:1.5f];
          [self performSelector:@selector(delayMethod) withObject:nil afterDelay:1.0f];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HUD removeFromSuperview];
        [self showErrorInfoWithMessage:[NSString stringWithFormat:@"%@",error] hideAfterDelay:1.5f];
    } ];
}

-(void)delayMethod
{

[self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
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

- (void)resignFirstResponderForAllTextField {
    [_phoneTF resignFirstResponder];
    [_passwordTF resignFirstResponder];
    [_confirmPasswordTF resignFirstResponder];
    [_phoneTF resignFirstResponder];
    [_codeTF resignFirstResponder];
}

- (void)openCountdown
{
    __block NSInteger time = 59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        
        if (time <= 0) { //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮的样式
                [self.verificationButton setTitle:@"重新发送" forState:UIControlStateNormal];
                [self.verificationButton setTitleColor:RGB(251, 133, 87) forState:UIControlStateNormal];
                self.verificationButton.userInteractionEnabled = YES;
            });
            
        } else {
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮显示读秒效果
                [self.verificationButton setTitle:[NSString stringWithFormat:@"重新发送(%.2d)", seconds] forState:UIControlStateNormal];
                [self.verificationButton setTitleColor:RGB(151,151,151) forState:UIControlStateNormal];
                self.verificationButton.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
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

- (void)showErrorInfoWithMessage:(NSString *)errorMessage hideAfterDelay:(NSTimeInterval)delay {
    MBProgressHUD *tips = [self showNoticeWithMessage:errorMessage modeOfHUD:MBProgressHUDModeText];
    [tips hide:YES afterDelay:delay];
}

@end
