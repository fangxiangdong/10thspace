//
//  SendAddtionMsgViewController.m
//  TeamTalk
//
//  Created by mac on 16/11/30.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "SendAddtionMsgViewController.h"
#import "AddFriendAPI.h"
@interface SendAddtionMsgViewController ()<UITextViewDelegate>
{
    NSString *tipString;
    UITextView *textview;
}
@end

@implementation SendAddtionMsgViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    UIButton *b=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 35)];
    b.backgroundColor=[UIColor clearColor];
    [b setTitle:@"发送" forState:UIControlStateNormal];
    [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [b addTarget:self action:@selector(dispatch) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:b];
    






}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    tipString= @"您需要发送验证申请，等待对方通过";
    self.automaticallyAdjustsScrollViewInsets=NO;
    textview = [[UITextView alloc] initWithFrame:CGRectMake(10, 64, self.view.frame.size.width-20, 100)];
    textview.backgroundColor=[UIColor whiteColor];
     textview.delegate = self;
     textview.textAlignment = NSTextAlignmentLeft;
    textview.backgroundColor=[UIColor whiteColor];
    
    textview.text = tipString;
    textview.textColor=[UIColor grayColor];
    [self.view addSubview:textview];
    
    UIView *bottomLine=[[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(textview.frame), self.view.frame.size.width-20, 1)];
    
    
    bottomLine.backgroundColor=[UIColor colorWithRed:14.0/255.0 green:207.0/255.0 blue:49.0/255.0 alpha:1.0];
    [self.view addSubview:bottomLine];
    
    
    // Do any additional setup after loading the view.
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView

{
    
    textView.text=@"";
    
    textView.textColor = [UIColor blackColor];
    
    return YES;
    
}

-(void)dispatch
{
    
    if (!self.userID) {
        return;
    }
    
    NSString *string=textview.text;
    
    if ([string isEqualToString:tipString]) {
        string=@"";
    }

    
    
        AddFriendAPI *add = [[AddFriendAPI alloc] init];
    
    
    
    [add requestWithObject:@[self.userID,string] Completion:^(id response, NSError *error) {
    
    
            [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *resultcode = [NSString stringWithFormat:@"%@",obj];
    
                if([resultcode isEqualToString:@"0"]){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求发送成功" message:@"等待对方验证" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    
                    [self popViewControllerAnimated:NO];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                     [self popViewControllerAnimated:NO];
                }
                
            }];
            
        }];











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
