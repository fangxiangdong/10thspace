//
//  PublieProfileViewControll.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-16.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "PublicProfileViewControll.h"
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
#import "DDSendPhotoMessageAPI.h"
#import "IMAvatarChangedAPI.h"
#import "LoginModule.h"
#import "DDAllUserAPI.h"
#import "SpellLibrary.h"
#import "DeleteFriendAPI.h"
#import "AddFriendAPI.h"
#import "SendAddtionMsgViewController.h"

@interface PublicProfileViewControll ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation PublicProfileViewControll

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    _avatar    = [UIImageView new];
    _name      = [UILabel new];
    _cname     = [UILabel new];
    _chatBtn   = [UIButton new];
    _callBtn   = [UIButton new];
    _deleteBtn = [UIButton new];
    
    // 获取签名
    DDUserDetailInfoAPI *request = [DDUserDetailInfoAPI new];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSInteger userId = [self.user getOriginalID];
    [array addObject:@(userId)];
    [request requestWithObject:array Completion:^(NSArray *response, NSError *error) {
        
        if(response) return;
        
        self.user.signature = [(MTTUserEntity*)response[0] signature];
        [self.tableView reloadData];
    }];
}

-(void)initData
{
    UIImage* placeholder = [UIImage imageNamed:@"user_placeholder"];
    
    
    
    //[_avatar sd_setImageWithURL:[NSURL URLWithString:[self.user get300AvatarUrl]] placeholderImage:placeholder];
    
    if (self.user.avatar&&![self.user.avatar isEqualToString:@"" ]) {
        
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:self.user.avatar]];
            UIImage *image = [UIImage imageWithData:data]; // 取得图片
            
            if (data != nil) {
                //通知主线程刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    _avatar.image=image;
                });
            }
            
        });
        
    }else{
        
        
        _avatar.image=placeholder;
        
    }

    
    if (self.user.nick.length) {
        [_name setText:self.user.nick];
    }else {
        [_name setText:self.user.name];
    }
    [_cname setText:self.user.name];
}

- (void)showAvatar:(UITapGestureRecognizer*)recognizer
{
    [SJAvatarBrowser showImage:_avatarView];
}

- (UIView *)headView
{
    UIView *headView = [UIView new];
    headView.userInteractionEnabled = YES;
    
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
    //[_avatarView sd_setImageWithURL:[NSURL URLWithString:self.user.avatar] placeholderImage:placeholder];
    if (self.user.avatar&&![self.user.avatar isEqualToString:@"" ]) {
        
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:self.user.avatar]];
            UIImage *image = [UIImage imageWithData:data]; // 取得图片

             if (data != nil) {
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
                   _avatarView.image=image;
            });
             }
            
        });
        
    }else{
        
        
        _avatarView.image=placeholder;
        
    }

    
    [_avatar setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAvatar:)];
    [_avatar addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeHeadImage)];
    [headView addGestureRecognizer:tap2];
    
    
    [_name setFont:systemFont(15)];
    [headView addSubview:_name];
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatar.mas_right).offset(10);
        make.centerY.equalTo(headView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(200, 20));
    }];
    
    
    [_cname setFont:systemFont(15)];
    [_cname setTextColor:TTGRAY];
    [headView addSubview:_cname];
    [_cname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatar.mas_right).offset(10);
        make.centerY.equalTo(headView).offset(15);
        make.size.mas_equalTo(CGSizeMake(200, 20));
    }];
    
    return headView;
}

-(void)changeHeadImage
{
    if([self.user.objID isEqualToString:TheRuntime.user.objID]){
        LCActionSheet *sheet = [[LCActionSheet alloc] initWithTitle:nil
                                                       buttonTitles:@[@"拍照",@"从相册获取"]
                                                     redButtonIndex:2
                                                           delegate:self];
        
        sheet.tag = 1111;
        [sheet show];
    }
}

- (UIView *)footView
{
    UIView *footView = [UIView new];
    [footView setBackgroundColor:[UIColor clearColor]];
    
    if (self.isFromAttention==YES) {
        
        _addBtn=[[UIButton alloc]init];
        [footView addSubview:_addBtn];
        [_addBtn setClipsToBounds:YES];
        [_addBtn.layer setCornerRadius:5];
        [_addBtn setTitle:@"添加好友" forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addBtn setBackgroundColor:TTBLUE];
        [_addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(footView.mas_top).offset(15);
            make.height.mas_equalTo(40);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
        [_addBtn addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
    }else{
    
    if(![self.user.objID isEqualToString:TheRuntime.user.objID]){
        
        [footView addSubview:_chatBtn];
        [_chatBtn setClipsToBounds:YES];
        [_chatBtn.layer setCornerRadius:5];
        [_chatBtn setTitle:@"发送消息" forState:UIControlStateNormal];
        [_chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_chatBtn setBackgroundColor:[UIColor colorWithRed:14.0/255.0 green:207.0/255.0 blue:49.0/255.0 alpha:1.0]];
        [_chatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(footView.mas_top).offset(15);
            make.height.mas_equalTo(40);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
        [_chatBtn addTarget:self action:@selector(startChat) forControlEvents:UIControlEventTouchUpInside];
        //
        //        [footView addSubview:_callBtn];
        //        [_callBtn setClipsToBounds:YES];
        //        [_callBtn.layer setCornerRadius:5];
        //        [_callBtn.layer setBorderColor:RGB(222, 222, 226).CGColor];
        //        [_callBtn.layer setBorderWidth:1];
        //        [_callBtn setTitle:@"拨打电话" forState:UIControlStateNormal];
        //        [_callBtn setTitleColor:RGB(69, 69, 69) forState:UIControlStateNormal];
        //        [_callBtn setBackgroundColor:RGB(247, 247, 247)];
        //        [_callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.top.equalTo(_chatBtn.mas_bottom).offset(15);
        //            make.height.mas_equalTo(40);
        //            make.left.mas_equalTo(15);
        //            make.right.mas_equalTo(-15);
        //        }];
        //[_callBtn addTarget:self action:@selector(callUser) forControlEvents:UIControlEventTouchUpInside];
        //删除好友按钮
        [footView addSubview:_deleteBtn];
        [_deleteBtn setClipsToBounds:YES];
        [_deleteBtn.layer setCornerRadius:5];
        [_deleteBtn.layer setBorderColor:RGB(222, 222, 226).CGColor];
        [_deleteBtn.layer setBorderWidth:1];
        [_deleteBtn setTitle:@"删除好友" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // RGB(69, 69, 69)
        [_deleteBtn setBackgroundColor:[UIColor whiteColor]];
        [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_chatBtn.mas_bottom).offset(15);
            make.height.mas_equalTo(40);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }];
        [_deleteBtn addTarget:self action:@selector(deleteFriend) forControlEvents:UIControlEventTouchUpInside];
        
    }
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    return 4;
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
        case 3:
        {
            
            [cell setDesc:@"粉丝数" detail:[NSString stringWithFormat:@"%ld",self.user.fansCount]];
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
    if (!phoneNum) return;
    
    NSString *stringURL =[NSString stringWithFormat:@"tel:%@",phoneNum];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}

-(void)sendEmail:(NSString *)address
{
    if (!address.length) return;
    
    NSString *stringURL =[NSString stringWithFormat:@"mailto:%@",address];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}

-(void)startChat
{
    MTTSessionEntity* session = [[MTTSessionEntity alloc] initWithSessionID:self.user.objID type:SessionTypeSessionTypeSingle];
    [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
    
    if ([[self.navigationController viewControllers] containsObject:[ChattingMainViewController shareInstance]]) {
        [self.navigationController popToViewController:[ChattingMainViewController shareInstance] animated:YES];
    }else
    {
        [self pushViewController:[ChattingMainViewController shareInstance] animated:YES];
        
    }
}

-(void)addFriend
{

//    NSLog(@"%@",self.user.userID);
//    NSLog(@"%@",TheRuntime.user.userID);

    SendAddtionMsgViewController *samvc=[[SendAddtionMsgViewController alloc]init];
    
    samvc.userID=self.user.userID;
    [self pushViewController:samvc animated:NO];
    
//    AddFriendAPI *add = [[AddFriendAPI alloc] init];
//    
//    [add requestWithObject:self.user.userID Completion:^(id response, NSError *error) {
//        
//        
//        [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSString *resultcode = [NSString stringWithFormat:@"%@",obj];
//            
//            if([resultcode isEqualToString:@"0"]){
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求发送成功" message:@"等待对方验证" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alert show];
//            }
//            else{
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alert show];
//            }
//            
//        }];
//    }];
}

-(void)callUser
{
    NSString *alertMsg;
    if([self.user.telphone length]>0){
        NSString *num = [self.user.telphone stringByReplacingCharactersInRange:NSMakeRange(4, 3) withString:@"***"];
        alertMsg = [NSString stringWithFormat:@"呼叫%@?",num];
        LCActionSheet *sheet = [[LCActionSheet alloc] initWithTitle:alertMsg
                                                       buttonTitles:@[@"确定"]
                                                     redButtonIndex:-1
                                                           delegate:self];
        sheet.tag = 10000;
        [sheet show];
    }else{
        NSString *title = @"此人没有手机号码";
        LCActionSheet *sheet = [[LCActionSheet alloc] initWithTitle:title
                                                       buttonTitles:@[]
                                                     redButtonIndex:-1
                                                           delegate:self];
        sheet.tag = 10000;
        [sheet show];
    }
}

-(void)deleteFriend
{
    DeleteFriendAPI *delete = [[DeleteFriendAPI alloc] init];
    
    [delete  requestWithObject:self.user.userID Completion:^(id response, NSError *error) {
        
        [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *resultcode = [NSString stringWithFormat:@"%@",obj];
            
            if([resultcode isEqualToString:@"0"]){
                
                [[DDUserModule shareInstance]deleteFriendUser:self.user.userID];
                [[MTTDatabaseUtil instance]deleteFriendForSession:self.user.objID completion:^(BOOL success) {
                    
                }];
            }else{
                
            }
            [self popViewControllerAnimated:YES];
        }];
    }];
}

-(void)delayMethod
{
    
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
    if(actionSheet.tag == 1111){
        NSInteger sourseType = 0;
        
        switch (buttonIndex) {
            case 0:{
                //相机
                sourseType = UIImagePickerControllerSourceTypeCamera;
                
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
                imagePickerController.delegate = self;
                imagePickerController.allowsEditing = YES;
                imagePickerController.sourceType = sourseType;
                
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
                break;
            case 1:{
                //相册
                sourseType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
                imagePickerController.delegate = self;
                imagePickerController.allowsEditing = YES;
                imagePickerController.sourceType = sourseType;
                
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
                break;
            default:
                break;
        }

    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    //    headImage.image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.5)];
    //    NSData *mydata = UIImageJPEGRepresentation(image, 0.5);
    //    NSString *pictureDataString = [mydata base64Encoding];
    //    NSLog(@"---- %@",pictureDataString);
    //NSString *base64 = [UIImageJPEGRepresentation(image, 0.05) base64Encoding];

//    NSLog(@"--- %@",image);
    MTTPhotoEnity *photo = [MTTPhotoEnity new];
    //设置图片文件名，保存进数据库
    NSString *keyName = [[MTTPhotosCache sharedPhotoCache] getKeyName];
    photo.localPath   = keyName;
    
    [self sendImageMessage:photo Image:image];
}

-(void)sendImageMessage:(MTTPhotoEnity *)photo Image:(UIImage *)image
{
    //NSData *photoData = UIImagePNGRepresentation(image);
    NSData *photoData = UIImageJPEGRepresentation(image, 0.2);
  
//    NSLog(@"chssasasasa%lu",(unsigned long)photoData.length);
    
    [[MTTPhotosCache sharedPhotoCache] storePhoto:photoData forKey:photo.localPath toDisk:YES];//图片写到磁盘
    
                    
    
    NSString *postImage = [photo.localPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

//    MTTPhotoEnity *photoEnity = [[MTTPhotoEnity alloc] init];
//    photoEnity.localPath = [[MTTPhotosCache sharedPhotoCache] getKeyName];
//    // 缓存磁盘
//    [[MTTPhotosCache sharedPhotoCache] storePhoto:imgData forKey:photoEnity.localPath toDisk:YES];
//    
//    NSString *imgKey =  [photoEnity.localPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 将头像上传阿里云
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[DDSendPhotoMessageAPI sharedPhotoCache] uploadAvatarToAliYunOSSWithContent:postImage andUserID:self.user.userID success:^(NSString *fileURL) {
            
            DDLog(@"fileURL--%@", fileURL);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更UI
                
                IMAvatarChangedAPI *avatar = [[IMAvatarChangedAPI alloc] init];
                [avatar requestWithObject:fileURL Completion:^(id response, NSError *error) {
                    
                    [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        NSString *resultCode = [NSString stringWithFormat:@"%@",obj];
                        if([resultCode isEqualToString:@"0"]){
                            _avatar .image = image;
                            TheRuntime.user.avatar=fileURL;
                                
                    [self.tableView reloadData];
                }}];
                
                }];
            });
            
        } failure:^(NSError *error) {
            DDLog(@"upload failure：error");
        }];
    });
    
    
    
    
    
//    [[DDSendPhotoMessageAPI sharedPhotoCache] uploadImage:postImage success:^(NSString *imageURL) {
//        
//        imageURL = [imageURL stringByReplacingOccurrencesOfString:@"&$#@~^@[{:" withString:@""];
//        imageURL = [imageURL stringByReplacingOccurrencesOfString:@":}]&$~@#@" withString:@""];
//        NSLog(@"---imageURL == %@",imageURL);
//        
//        IMAvatarChangedAPI *avatar = [[IMAvatarChangedAPI alloc] init];
//        [avatar requestWithObject:imageURL Completion:^(id response, NSError *error) {
//            
//            [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                 NSString *resultCode = [NSString stringWithFormat:@"%@",obj];
//                if([resultCode isEqualToString:@"0"]){
//                    NSLog(@"---- success");
//                    
//                    
//                    //加载所有人信息，创建检索拼音
//                    [[LoginModule instance] p_loadAllUsersCompletion:^{
//                        
//                        if ([[SpellLibrary instance] isEmpty]) {
//                            
//                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                [[[DDUserModule shareInstance] getAllMaintanceUser] enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
//                                    [[SpellLibrary instance] addSpellForObject:obj];
//                                    [[SpellLibrary instance] addDeparmentSpellForObject:obj];
//                                    
//                                }];
//                            });
//                        }
//                    }];
//                    
//                    
//                    
//                    
//                    [self.tableView reloadData];
//                }
//                
//            }];
//            
//        }];
//        
//        
//        
//    } failure:^(id error) {
//        
//    }];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
