//
//  PerfectPersonMessageController.m
//  PersonalTailor
//
//  Created by fyf on 16/3/25.
//  Copyright (c) 2016年 com.Bluemobi. All rights reserved.
//

#import "PerfectPersonMessageController.h"
#import "UpdataUserInfoAPI.h"
#define LYColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#import "UIImageView+WebCache.h"
#import "NSString+GetColor.h"
#import "MTTPhotosCache.h"
#import "DDSendPhotoMessageAPI.h"
#import "IMAvatarChangedAPI.h"
#import <AliyunOSSiOS/OSSService.h>

#define Section0Height 70
#define Section1Height 50
#define Section2Height 40
#define Section3Height 50
#define Section4Height 100 + 50
#define Section5Height 150
#define kMaxLength 200

@interface PerfectPersonMessageController ()<UIScrollViewDelegate,UITextViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>
{
    UIView *section0view;
    UIView *section1view;
    UIView *section2view;
    UIView *section3view;
    UIView *section4view;
    UIView *section5view;
    UIView *section6view;
    UIButton*b;
}

@property (nonatomic,strong) UITableView *mainTable;
@property (nonatomic,strong) UIImageView *usertouxiangimage;//用户头像
//@property (nonatomic,strong) UIImageView *usermanseximage;//男性别image
//@property (nonatomic,strong) UIImageView *userwomenseximage;//女性别image

@property (nonatomic, strong) UIButton *maleButton;    //男按钮
@property (nonatomic, strong) UIButton *femaleButton;  //女按钮

@property (nonatomic,strong) UITextField *nameTF;//昵称输入框
@property (nonatomic,strong) UITextView *personalizedsignatureTV;//个性签名输入框
@property (nonatomic, strong) UILabel *inviteCodeLabel;
@property (nonatomic, assign) BOOL isMale;

@end

@implementation PerfectPersonMessageController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
  }

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    
    
    [self CreateMainTableView];
//    [self addKeyboardNote];
}


#pragma mark - 键盘处理
#pragma mark 监听系统发出的键盘通知
- (void)addKeyboardNote
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    // 1.显示键盘
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // 2.隐藏键盘
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark 显示一个新的键盘就会调用
- (void)keyboardWillShow:(NSNotification *)note
{
    if ([_personalizedsignatureTV isFirstResponder]) {
        
//        [self.view bringSubviewToFront:self.navView];
//        //[self.view bringSubviewToFront:self.titleLB];
//        [self.view bringSubviewToFront:self.leftImg];
//        [self.view bringSubviewToFront:self.leftBtn];
        
        // 1.取得当前聚焦文本框最下面的Y值
        //        CGFloat fieldMaxY = CGRectGetMaxY(_focusedField.frame);
        CGRect frame = [_personalizedsignatureTV.superview convertRect:_personalizedsignatureTV.frame toView:self.view];
        //    - (CGRect)convertRect:(CGRect)rect toView:(UIView *)view;
        // 1.取得当前聚焦文本框最下面的Y值
        CGFloat fieldMaxY = CGRectGetMaxY(frame);

        // 2.计算键盘的Y值
        // 2.1.取出键盘的高度
        CGFloat keyboardH = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        
        // 2.2.控制器view的高度 - 键盘的高度
        CGFloat keyboardY = _mainTable.frame.size.height-keyboardH-20 ;
    
        // 3.比较 文本框最大Y 跟 键盘Y
        CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        if (duration <= 0.0) {
            
            duration = 0.25;
            
        }
        [UIView animateWithDuration:duration animations:^{
            if (fieldMaxY > keyboardY) { // 键盘挡住了文本框
                _mainTable.transform = CGAffineTransformMakeTranslation(0, keyboardY-fieldMaxY);
            } else { // 没有挡住文本框
                
            }
        }];
    }
}

#pragma mark 隐藏键盘就会调用

- (void)keyboardWillHide:(NSNotification *)note
{
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations: ^{
        _mainTable.transform = CGAffineTransformIdentity;
        //  baseView.transform=CGAffineTransformScale(baseView.transform, .75f, 1.f);
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)CreateMainTableView
{
    _mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0 ,0, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStyleGrouped];
    _mainTable.delegate = self;
    _mainTable.dataSource = self;
    _mainTable.backgroundColor = [UIColor clearColor];
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.view.backgroundColor = LYColor(243, 243, 243);
    [self.view addSubview:_mainTable];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 7;
}

/*设置标题头的宽度*/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return Section0Height;
            break;
        case 1:
            return Section1Height;
            break;
        case 2:
            return Section2Height;
            break;
        case 3:
            return Section3Height;
            break;
        case 4:
            return Section4Height;
            break;
        case 5:
            return Section3Height;
            break;
        case 6:
            return Section5Height;
            break;
        default:
            return 0;
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==0 || section==1)
    {
        return 5;
    }else
    {
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        
        if (section0view==nil)
        {
            section0view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, Section0Height)];
            section0view.backgroundColor = [UIColor whiteColor];
            
            UILabel *edicttouxiangLB = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 150, section0view.frame.size.height)];
            edicttouxiangLB.text = @"编辑头像";
            edicttouxiangLB.textColor = [UIColor blackColor];
            edicttouxiangLB.textAlignment = NSTextAlignmentLeft;
            edicttouxiangLB.font = [UIFont systemFontOfSize:14];
         
            _usertouxiangimage = [[UIImageView alloc]initWithFrame:CGRectMake(section0view.frame.size.width-100, 10, 50, 50)];
           // _usertouxiangimage.image = [UIImage imageNamed:@"header"];
            
            //[_usertouxiangimage sd_setImageWithURL:[NSURL URLWithString:self.theUser.avatar] placeholderImage:[UIImage imageNamed:@"header"]];
            if (self.theUser.avatar&&![self.theUser.avatar isEqualToString:@""]) {
                
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:self.theUser.avatar]];
                UIImage *image = [UIImage imageWithData:data]; // 取得图片
                
                if (data != nil) {
                    //通知主线程刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _usertouxiangimage.image=image;
                    });
                }
            });
                
            }else{
                _usertouxiangimage.image=[UIImage imageNamed:@"header"];
            }
            _usertouxiangimage.clipsToBounds = YES;
            _usertouxiangimage.layer.cornerRadius = 25;
            
            UIImageView *xiangjiimage = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_usertouxiangimage.frame)-15, CGRectGetMaxY(_usertouxiangimage.frame)-15, 20, 16)];
            xiangjiimage.image = [UIImage imageNamed:@"照相机图标"];
            
            
            UIButton *upimageBtn = [[UIButton alloc]initWithFrame:CGRectMake(_usertouxiangimage.frame.origin.x-10,0, CGRectGetMaxX(_usertouxiangimage.frame)+10, section0view.frame.size.height)];
            [upimageBtn addTarget:self action:@selector(upimageBtnAction) forControlEvents:UIControlEventTouchUpInside];
            
            [section0view addSubview:edicttouxiangLB];
            [section0view addSubview:_usertouxiangimage];
            [section0view addSubview:xiangjiimage];
            [section0view addSubview:upimageBtn];
        }
        return section0view;
    }
    else if (section==1)
    {
        if (section1view==nil)
        {
            section1view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, Section1Height)];
            section1view.backgroundColor = [UIColor whiteColor];
            
            UILabel *sexLB = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 80, section1view.frame.size.height)];
            sexLB.text = @"性别";
            sexLB.textColor = [UIColor blackColor];
            sexLB.textAlignment = NSTextAlignmentLeft;
            sexLB.font = [UIFont systemFontOfSize:14];
            
            /*
             //男性别图标
             _usermanseximage = [[UIImageView alloc]initWithFrame:CGRectMake(section1view.frame.size.width-115, 10, 30, 30)];
             _usermanseximage.image = [UIImage imageNamed:@"性别男"];
             _usermanseximage.clipsToBounds = YES;
             _usermanseximage.layer.cornerRadius = 15;
             _usermanseximage.layer.borderWidth =1;
             _usermanseximage.layer.borderColor = [[UIColor clearColor] CGColor];
             
             //女性别图标
             _userwomenseximage = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_usermanseximage.frame)+20, 10, _usermanseximage.frame.size.width, _usermanseximage.frame.size.height)];
             _userwomenseximage.image = [UIImage imageNamed:@"性别女"];
             _userwomenseximage.clipsToBounds = YES;
             _userwomenseximage.layer.cornerRadius = 15;
             _userwomenseximage.layer.borderWidth =1;
             _userwomenseximage.layer.borderColor = [[UIColor clearColor] CGColor];
             */
            
            
           
            [section1view addSubview:self.maleButton];
            [section1view addSubview:self.femaleButton];
            
            if (self.theUser.sex==1||self.theUser.sex==0) {
                self.maleButton.selected=YES;
            }else{
                
                self.femaleButton.selected=YES;
            }

            [section1view addSubview:sexLB];
        }
        return section1view;
        
    }else if (section==2)
    {
        if (section2view==nil)
        {
            section2view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, Section2Height)];
            section2view.backgroundColor = [UIColor clearColor];
            
            UILabel *phoneLB = [[UILabel alloc]initWithFrame:CGRectMake(10, section2view.frame.size.height-25, 80, 20)];
            phoneLB.text = @"基本信息";
            phoneLB.textColor = [UIColor darkGrayColor];
            phoneLB.textAlignment = NSTextAlignmentLeft;
            phoneLB.font = [UIFont systemFontOfSize:14];
            
            [section2view addSubview:phoneLB];
            
        }
        
        return section2view;
        
    }else if (section==3)
    {
        if (section3view==nil)
        {
            section3view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, Section3Height)];
            section3view.backgroundColor = [UIColor whiteColor];
            
            //昵称
            UILabel *nichengLB = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 80, section3view.frame.size.height)];
            nichengLB.text = @"昵称";
            nichengLB.textColor = [UIColor blackColor];
            nichengLB.textAlignment = NSTextAlignmentLeft;
            nichengLB.font = [UIFont systemFontOfSize:14];
            
            
            //昵称输入框
            _nameTF = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nichengLB.frame), 0, section3view.frame.size.width-CGRectGetMaxX(nichengLB.frame), section3view.frame.size.height)];
            _nameTF.delegate = self;
            _nameTF.placeholder = @"请输入您的昵称";
            //            _nameTF.text = self.phoneStr;
            _nameTF.text=self.theUser.nick;
            _nameTF.font = [UIFont boldSystemFontOfSize:14];
            _nameTF.textColor =[UIColor blackColor];
            _nameTF.textAlignment = NSTextAlignmentLeft;
            
            
            UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(section3view.frame.size.width-25, section3view.frame.size.height/2-7, 10, 14)];
            image.image = [UIImage imageNamed:@"向右箭头"];
            
            
            [section3view addSubview:nichengLB];
            [section3view addSubview:_nameTF];
            //            [section3view addSubview:image];
            
        }
        
        
        return section3view;
        
    }else if (section==4)
    {
        if (section4view==nil)
        {
            section4view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, Section4Height+50)];
            section4view.backgroundColor = [UIColor whiteColor];
            section4view.userInteractionEnabled = YES;
            
            UILabel *detailaddressLB = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 80, 50)];
            detailaddressLB.text = @"个性签名";
            detailaddressLB.textColor = [UIColor darkGrayColor];
            detailaddressLB.textAlignment = NSTextAlignmentLeft;
            detailaddressLB.font = [UIFont systemFontOfSize:14];
            
            //个性签名输入框
            _personalizedsignatureTV = [[UITextView alloc]init];
            _personalizedsignatureTV.frame = CGRectMake(CGRectGetMaxX(detailaddressLB.frame), 10, section4view.frame.size.width-CGRectGetMaxX(detailaddressLB.frame)-15, section4view.frame.size.height-10 - 100);
            _personalizedsignatureTV.layer.cornerRadius = 2.f;
            _personalizedsignatureTV.delegate=self;
            _personalizedsignatureTV.backgroundColor = [UIColor clearColor];
            _personalizedsignatureTV.font = [UIFont systemFontOfSize:12];
            
            _personalizedsignatureTV.text=self.theUser.signature;
            [section4view addSubview:detailaddressLB];
            [section4view addSubview:_personalizedsignatureTV];
            
            UILabel *inviteCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(detailaddressLB.frame.origin.x, CGRectGetMaxY(_personalizedsignatureTV.frame), detailaddressLB.bounds.size.width, detailaddressLB.bounds.size.height)];
            inviteCodeLabel.text = @"邀请码";
            inviteCodeLabel.textColor = [UIColor darkGrayColor];
            inviteCodeLabel.textAlignment = NSTextAlignmentLeft;
            inviteCodeLabel.font = [UIFont systemFontOfSize:14];
            [section4view addSubview:inviteCodeLabel];
            
            _inviteCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_personalizedsignatureTV.frame), CGRectGetMaxY(_personalizedsignatureTV.frame), _personalizedsignatureTV.frame.size.width, inviteCodeLabel.bounds.size.height)];
            _inviteCodeLabel.font = [UIFont systemFontOfSize:14];
            [section4view addSubview:_inviteCodeLabel];
            
            
           
            
            
            
        }
        
        
        return section4view;
        
    }else if (section==5)
    {
        if (section6view==nil)
        {
            section6view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
           section6view.backgroundColor = [UIColor whiteColor];
            section6view.userInteractionEnabled = YES;
            
            UILabel *detailaddressLB = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 80, 50)];
            detailaddressLB.text = @"粉丝数";
            detailaddressLB.textColor = [UIColor darkGrayColor];
            detailaddressLB.textAlignment = NSTextAlignmentLeft;
            detailaddressLB.font = [UIFont systemFontOfSize:14];
            
            //个性签名输入框
            
            UILabel *fansCountLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(detailaddressLB.frame), 0, section6view.frame.size.width-CGRectGetMaxX(detailaddressLB.frame)-15, 50)];
            fansCountLabel.text=[NSString stringWithFormat:@"%ld",self.theUser.fansCount];
            
//            _personalizedsignatureTV = [[UITextView alloc]init];
//            _personalizedsignatureTV.frame = CGRectMake(CGRectGetMaxX(detailaddressLB.frame), 10, section4view.frame.size.width-CGRectGetMaxX(detailaddressLB.frame)-15, 50);
//            _personalizedsignatureTV.layer.cornerRadius = 2.f;
//            _personalizedsignatureTV.delegate=self;
//            _personalizedsignatureTV.backgroundColor = [UIColor clearColor];
//            _personalizedsignatureTV.font = [UIFont systemFontOfSize:12];
//            
//            _personalizedsignatureTV.text=self.theUser.signature;
            [section6view addSubview:detailaddressLB];
            [section6view addSubview:fansCountLabel];
            
          
            
            
            
            
            
            
        }
        
        
        return section6view;
        
    }
    else if (section==6)
    {
        if (section5view==nil)
        {
            section5view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, Section5Height)];
            section5view.backgroundColor = [UIColor clearColor];
            
            
            UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            nextBtn.frame = CGRectMake(50, 32, self.view.frame.size.width-100, 40);
            [nextBtn setTitle:@"确定" forState:UIControlStateNormal];
            [nextBtn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
            nextBtn.backgroundColor = [NSString colorWithHexString:@"1cd81b"];
            nextBtn.layer.cornerRadius = 5;
            nextBtn.clipsToBounds = YES;
            nextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            nextBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [nextBtn addTarget:self action:@selector(nextBtnAction) forControlEvents:UIControlEventTouchUpInside];
            
            [section5view addSubview:nextBtn];
            
            
        }
        return section5view;
        
    }
   
    else
    {
        return nil;
    }
    
    
}



-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 2)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - fdsfasdasdf
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark -上传头像按钮

-(void)upimageBtnAction
{
    //    UIAlertView *getHeadImage = [[UIAlertView alloc]initWithTitle:@"选取头像" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拍摄照片",@"从相册中选", nil];
    //    getHeadImage.tag = 2001;
    //    [getHeadImage show];
    
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil                                                                             message: nil                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    //添加Button
    [alertController addAction: [UIAlertAction actionWithTitle: @"拍摄照片" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //处理点击拍照
        
        
        UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
            //pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
            
        }
        pickerImage.delegate = self;
        pickerImage.allowsEditing = YES;
        [self presentViewController:pickerImage animated:YES completion:^{
            
        }];
    }]];
    
    [alertController addAction: [UIAlertAction actionWithTitle: @"从相册中选取" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        //处理点击从相册选取
        
        UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            //                pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
            pickerImage.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
        }
        pickerImage.delegate = self;
        pickerImage.allowsEditing = YES;
        [self presentViewController:pickerImage animated:YES completion:^{
            
        }];
        
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController: alertController animated: YES completion: nil];
    
}

/// 用户头像来源/是否退出登录状态
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 2://**< 从相册中选 */
        {
            UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                pickerImage.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
            }
            pickerImage.delegate = self;
            pickerImage.allowsEditing = YES;
            [self presentViewController:pickerImage animated:YES completion:^{
                
            }];
        }
            break;
            
        case 1://**< 拍照 */
        {
            UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
                pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
            }
            pickerImage.delegate = self;
            pickerImage.allowsEditing = YES;
            [self presentViewController:pickerImage animated:YES completion:^{
                
            }];
        }
            break;
            
        case 0://**< 取消 */
        {
          
        }
            break;
        default:
            break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    //获取媒体类型
//    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
//    //判断是静态图像还是视频
//    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
//        //获取用户编辑之后的图像
//        UIImage* editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
//        //将该图像保存到媒体库中
//        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
//            //            UIImageWriteToSavedPhotosAlbum(editedImage, self, @selector(nilSymbol), NULL);
//        }
//        [self saveImage:editedImage withName:@"currentImage.png"];
//        
//        //        imageString = [GTMBase64 stringByEncodingData:UIImageJPEGRepresentation(touxiangimage.image, 0.5)];
//    
//    }
//    [picker dismissViewControllerAnimated:YES completion:^{
//        
//    }];
    
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
    NSData *photoData = UIImageJPEGRepresentation(image, 0.2);
    
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
        
        [[DDSendPhotoMessageAPI sharedPhotoCache] uploadAvatarToAliYunOSSWithContent:postImage andUserID:self.theUser.userID success:^(NSString *fileURL) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更UI
                IMAvatarChangedAPI *avatar = [[IMAvatarChangedAPI alloc] init];
                [avatar requestWithObject:fileURL Completion:^(id response, NSError *error) {
                    
                    [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *resultCode = [NSString stringWithFormat:@"%@",obj];
                        if([resultCode isEqualToString:@"0"]){
//                            _avatar .image = image;
                            TheRuntime.user.avatar   = fileURL;
                            self.theUser.avatar      = fileURL;
                            _usertouxiangimage.image = image;
                        }}];
                }];
            });
            
        } failure:^(NSError *error) {
            DDLog(@"头像 upload failure：error");
        }];
    });
}

#pragma mark - 性别选择

-(void)genderButtonClicked:(UIButton *)sender
{
    _maleButton.selected = !_maleButton.selected;
    _femaleButton.selected = !_femaleButton.selected;
    _isMale =YES;
}

-(void)genderButtonClicked2:(UIButton *)sender
{
    _maleButton.selected = !_maleButton.selected;
    _femaleButton.selected = !_femaleButton.selected;
    _isMale =NO;
}

#pragma mark - 确定按钮点击事件
-(void)nextBtnAction {
    
    if (_nameTF.text==self.theUser.nick&&_personalizedsignatureTV.text==self.theUser.signature) {
        if (self.maleButton.selected&&self.theUser.sex==1) {
            return;
        }
        if (self.femaleButton.selected&&self.theUser.sex==2) {
            return;
        }
        
    }
    
    
    if (_nameTF.text.length==0) {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"用户名不能为空"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil,nil];
        
        [alert show];
        
    }
    
    
    NSMutableArray *array=[NSMutableArray new];
    
    if (self.maleButton.selected) {
        
        [array addObject:@"1"];
    }else{
    
        [array addObject:@"2"];
    }

    
    [array addObject:_nameTF.text];
    
    [array addObject:_personalizedsignatureTV.text];
    
    UpdataUserInfoAPI *uuf=[[UpdataUserInfoAPI alloc]init];
    
    
    [uuf requestWithObject:array Completion:^(id response, NSError *error) {
        
        if ([response[0] intValue]==0) {
            
            TheRuntime.user.sex=[array[0]intValue];
            TheRuntime.user.nick=array[1];
             TheRuntime.user.signature=array[2];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"修改成功" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
           
            [alert show];
            
        }
        
        
    }];
    
    
    
    
}

#pragma mark - UITextView相关

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(textView.textColor == [UIColor lightGrayColor])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(textView.text.length == 0)
    {
        textView.text = @"这个人太懒，什么都没有留下~~";
        textView.textColor = [UIColor lightGrayColor];
    }
}

//限制输入框字数
-(void)textViewDidChange:(NSNotification *)obj{
    
    UITextView *textView;
    textView = (UITextView *)obj;
    //    if (isfirst==NO)
    //    {
    //        isfirst =YES;
    //        textView  = (UITextView *)obj;
    //    }else
    //    {
    //        textView = (UITextView *)obj.object;
    //        isfirst =NO;
    //    }
    
    NSString *toBeString = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
//    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textView.text = [toBeString substringToIndex:kMaxLength];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > kMaxLength) {
            textView.text = [toBeString substringToIndex:kMaxLength];
        }
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

-(void)leftBtnClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 保存图片至沙盒

- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    [imageData writeToFile:fullPath atomically:NO];
}

#pragma mark - Getters
- (UIButton *)maleButton
{
    if (!_maleButton) {
        _maleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _maleButton.frame = CGRectMake(self.view.frame.size.width - 45 - 30 * 2, 10, 30, 30);
        
        /** 写文字太low,需要就打开 */
        //        [_manButton setTitle:@"男" forState:UIControlStateNormal];
        //        _manButton.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [_maleButton setTitleColor:[UIColor blackColor]
                          forState:UIControlStateNormal];
        
        [_maleButton setImage:[UIImage imageNamed:@"性别男"]
                     forState:UIControlStateNormal];
        [_maleButton setImage:[UIImage imageNamed:@"性别男高亮"]
                     forState:UIControlStateSelected];
        
        [_maleButton addTarget:self
                        action:@selector(genderButtonClicked:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _maleButton;
}

- (UIButton *)femaleButton
{
    if (!_femaleButton) {
        _femaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _femaleButton.frame = CGRectMake(self.view.frame.size.width - 35 - 30, 10, 30, 30);
        /** 原因同上 */
        //        [_femaleButton setTitle:@"女" forState:UIControlStateNormal];
        //        _femaleButton.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [_femaleButton setTitleColor:[UIColor blackColor]
                            forState:UIControlStateNormal];
        
        [_femaleButton setImage:[UIImage imageNamed:@"性别女"]
                       forState:UIControlStateNormal];
        [_femaleButton setImage:[UIImage imageNamed:@"性别女高亮"]
                       forState:UIControlStateSelected];
        
        [_femaleButton addTarget:self
                          action:@selector(genderButtonClicked2:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _femaleButton;
}

@end
