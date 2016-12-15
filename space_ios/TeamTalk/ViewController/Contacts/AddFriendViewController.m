//
//  AddFriendViewController.m
//  TeamTalk
//
//  Created by landu on 15/11/12.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "AddFriendViewController.h"
#import "MTTUserEntity.h"
#import "MTTSessionEntity.h"
#import "UIImageView+WebCache.h"
#import "ContactsModule.h"
#import "UIImageView+WebCache.h"
#import "ChattingMainViewController.h"
#import "RuntimeStatus.h"
#import "DDUserDetailInfoAPI.h"
#import "MTTDatabaseUtil.h"
#import "DDUserModule.h"
#import "PublicProfileCell.h"
#import "MTTEditSignViewController.h"
#import "DDUserDetailInfoAPI.h"
#import "UIView+PointBadge.h"
#import <Masonry/Masonry.h>
#import "SJAvatarBrowser.h"
#import "UIImage+UIImageAddition.h"
#import "AddFriendAPI.h"
#import "FollowUserAPI.h"
#import "SCLAlertView.h"
#import "DDAllUserAPI.h"
#import "SendAddtionMsgViewController.h"
@interface AddFriendViewController ()

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self render];
    [self initData];
    

}

-(void)render
{
    MTT_WEAKSELF(ws);
    self.title=@"详细资料";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.showsVerticalScrollIndicator =NO;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    [self.view setBackgroundColor:TTBG];
    [self.tableView setBackgroundColor:TTBG];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(ws.view);
        make.center.equalTo(ws.view);
    }];
    
    _avatar = [UIImageView new];
    _name = [UILabel new];
    _cname = [UILabel new];
    _addBtn = [UIButton new];
    _followBtn = [UIButton new];
    
    // 获取签名
    DDUserDetailInfoAPI *request = [DDUserDetailInfoAPI new];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSInteger userId = [self.user getOriginalID];
    [array addObject:@(userId)];
    [request requestWithObject:array Completion:^(NSArray *response, NSError *error) {
        if(response){
            self.user.signature = [(MTTUserEntity*)response[0] signature];
        }
        [self.tableView reloadData];
    }];
}

-(void)initData
{
    UIImage* placeholder = [UIImage imageNamed:@"user_placeholder"];
    [_avatar sd_setImageWithURL:[NSURL URLWithString:[self.user get300AvatarUrl]] placeholderImage:placeholder];
    [_name setText:self.user.nick];
    [_cname setText:self.user.name];
}

- (void)showAvatar:(UITapGestureRecognizer*)recognizer
{
    [SJAvatarBrowser showImage:_avatarView];
}

- (UIView *)headView
{
    UIView *headView = [UIView new];
    
    [_avatar setClipsToBounds:YES];
    [_avatar.layer setCornerRadius:7.5];
    [headView addSubview:_avatar];
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headView);
        make.left.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(65, 65));
    }];
    // 增加图片放大功能
    UIImage* placeholder = [UIImage initWithColor:TTBG rect:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    _avatarView = [[UIImageView alloc]init];
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:self.user.avatar] placeholderImage:placeholder];
    
    [_avatar setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAvatar:)];
    [_avatar addGestureRecognizer:tap];
    
    [_name setFont:systemFont(15)];
    [headView addSubview:_name];
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatar.mas_right).offset(10);
        make.centerY.equalTo(headView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(100, 15));
    }];
    
    [_cname setFont:systemFont(15)];
    [_cname setTextColor:TTGRAY];
    [headView addSubview:_cname];
    [_cname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatar.mas_right).offset(10);
        make.centerY.equalTo(headView).offset(15);
        make.size.mas_equalTo(CGSizeMake(100, 15));
    }];
    
    return headView;
}

- (UIView *)footView
{
    BOOL isFriend = [[DDUserModule shareInstance] isFriend:self.user.objID];

    UIView *footView = [UIView new];
    [footView setBackgroundColor:[UIColor clearColor]];
    if(!isFriend && ![self.user.objID isEqualToString:TheRuntime.user.objID]){

        
        [footView addSubview:_addBtn];
        [_addBtn setClipsToBounds:YES];
        [_addBtn.layer setCornerRadius:5];
        [_addBtn setTitle:@"添加到通讯录" forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addBtn setBackgroundColor:TTBLUE];
        [_addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(footView.mas_top).offset(90);
            make.height.mas_equalTo(40);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
        [_addBtn addTarget:self action:@selector(addfriend) forControlEvents:UIControlEventTouchUpInside];
        
        [footView addSubview:_followBtn];
        [_followBtn setClipsToBounds:YES];
        [_followBtn.layer setCornerRadius:5];
        [_followBtn setTitle:[NSString stringWithFormat:@"关注%@",_user.name] forState:UIControlStateNormal];
        [_followBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_followBtn setBackgroundColor:TTBLUE];
        [_followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(footView.mas_top).offset(25);
            make.height.mas_equalTo(40);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
        [_followBtn addTarget:self action:@selector(followfriend) forControlEvents:UIControlEventTouchUpInside];
        
        

    }
    return footView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 90;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self headView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if([self.user.objID isEqualToString:TheRuntime.user.objID]){
        return 0;
    }else{
        return 165;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height =44.0f;
    
    if (2 == indexPath.row) {
        height =[PublicProfileCell cellHeightForDetailString:self.user.signature];
    }
    
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self footView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PublicProfileCell";
    PublicProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[PublicProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    switch (indexPath.row) {
        case 0:
        {
            [cell setDesc:@"部门" detail:self.user.department];
            cell.userInteractionEnabled = NO;
        }
            break;
        case 1:
        {
            [cell setDesc:@"邮箱" detail:self.user.email];
        }
            break;
        case 2:
        {
            [cell setDesc:@"签名" detail:self.user.signature];
            if(![self.user.objID isEqualToString:TheRuntime.user.objID]){
                cell.userInteractionEnabled = NO;
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 1:{
            NSString *title = [NSString stringWithFormat:@"%@%@",@"发送邮件给",self.user.email];
            LCActionSheet *sheet = [[LCActionSheet alloc] initWithTitle:title
                                                           buttonTitles:@[@"确定"]
                                                         redButtonIndex:-1
                                                               delegate:self];
            sheet.tag = 10001;
            [sheet show];
        }
            break;
        case 2:{
            if ([self.user.objID isEqualToString:TheRuntime.user.objID]) {
                //将cell的红点去掉
                UITableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];
                [cell removePointBadge:YES];
            }
            
            // 编辑签名页面
            MTTEditSignViewController *editSign = [MTTEditSignViewController new];
            [self.navigationController pushViewController:editSign animated:YES];
        }
            break;
        default:
            break;
    }
}

-(void)callPhoneNum:(NSString *)phoneNum
{
    if (!phoneNum) {
        return;
    }
    NSString *stringURL =[NSString stringWithFormat:@"tel:%@",phoneNum];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}

-(void)sendEmail:(NSString *)address
{
    if (!address.length) {
        return;
    }
    NSString *stringURL =[NSString stringWithFormat:@"mailto:%@",address];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}

-(void)followfriend
{
    
  
    FollowUserAPI *follow = [[FollowUserAPI alloc] init];
    
    [follow requestWithObject:self.user.userID Completion:^(id response, NSError *error) {
        [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *resultcode = [NSString stringWithFormat:@"%@",obj];
            if([resultcode isEqualToString:@"0"]){

                SCLAlertView *alert = [SCLAlertView new];
                [alert showSuccess:self title:[NSString stringWithFormat:@"成功关注%@",_user.name] subTitle:nil closeButtonTitle:@"确定" duration:0];
                [[DDUserModule shareInstance]addToAttention:self.user];
              
                [self performSelector:@selector(delayMethod) withObject:nil afterDelay:1.0f];
                
            }
  
            
        }];
    }];
    
    
 
    
}

-(void)delayMethod
{


[self popViewControllerAnimated:YES];

}
-(void)addfriend
{
   
    SendAddtionMsgViewController *samvc=[[SendAddtionMsgViewController alloc]init];
    
    samvc.userID=self.user.userID;
    [self pushViewController:samvc animated:NO];
    
    
}


#pragma mark - LCActionSheetDelegate
- (void)actionSheet:(LCActionSheet *)actionSheet didClickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 10001){
        if(buttonIndex == 0){
            [self sendEmail:self.user.email];
        }
    }
    if(actionSheet.tag == 10000){
        if(buttonIndex == 0){
            [self callPhoneNum:self.user.telphone];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
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
