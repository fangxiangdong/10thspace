//
//  PublishInfoViewController.m
//  TeamTalk
//
//  Created by landu on 15/11/13.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "PublishInfoViewController.h"
#import "LCActionSheet.h"
#import "CYAlbumViewController.h"
#import "BlogImageModel.h"
#import "BlogImageTableViewCell.h"
#import "IMMsgBlogAPI.h"
#import "MTTPhotosCache.h"
#import "DDSendPhotoMessageAPI.h"
#import "MBProgressHUD.h"
#import "XunXinViewController.h"
#import "MTTNotification.h"

@interface PublishInfoViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,LCActionSheetDelegate,addImageDelegate>
{
    UITableView *_tbView;
    UITextView *moodTextView;
    UILabel *promptLab;
    NSMutableArray *urlArray;
    dispatch_queue_t _globalQueue;
    MBProgressHUD *HUD;
}

@end

@implementation PublishInfoViewController

+(instancetype )shareInstance
{
    static dispatch_once_t onceToken;
    static PublishInfoViewController *publishManager = nil;
    dispatch_once(&onceToken, ^{
        publishManager = [[PublishInfoViewController alloc] init];
    });
    
    return publishManager;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

+(NSMutableArray*)shareMutabArray
{
    static NSMutableArray *mutableArray;
    if(mutableArray == nil){
        mutableArray = [NSMutableArray array];
    }
    return mutableArray;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.title = @"发布说说";
        _dataArray = [NSMutableArray array];
        urlArray = [NSMutableArray array];
    }
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [_tbView reloadData];
    
    // 导航条两边的按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(publish)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tbView.delegate = self;
    _tbView.dataSource = self;
    _tbView.bounces = NO;
    _tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_tbView];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        // 内容
        static NSString *identifier = @"identifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        moodTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 7, SCREEN_WIDTH - 20, 115)];
        moodTextView.font = [UIFont systemFontOfSize:15];
        moodTextView.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"BlogText"];
        moodTextView.delegate = self;
        [cell addSubview:moodTextView];
        
        promptLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 200, 20)];
        if(moodTextView.text.length != 0){
            promptLab.text = @"";
        }else {
            promptLab.text = @"写点什么吧...";
        }
        
        promptLab.font = [UIFont systemFontOfSize:15];
        promptLab.enabled = NO;//lable必须设置为不可用
        promptLab.backgroundColor = [UIColor clearColor];
        [cell addSubview:promptLab];
        
        
        // 分割线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 130 - 0.5, SCREEN_WIDTH - 15, 0.5)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:lineView];
        
        return cell;
        
    }else {
        // 图片
        static NSString *identifier = @"hehe";
        BlogImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if(cell == nil){
            cell = [[BlogImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
        BlogImageModel *model;
        if([PublishInfoViewController shareMutabArray].count != 0){
            model = [[PublishInfoViewController shareMutabArray] objectAtIndex:0];
        }
        [cell setBlogModel:model];
        return cell;
    }
}

-(void)receiveImageArray:(NSMutableArray*)array
{
    [_dataArray addObjectsFromArray:array];
    
    BlogImageModel *model = [[BlogImageModel alloc] init];
    model.imgArray = _dataArray;
    
    
    if([PublishInfoViewController shareMutabArray].count == 0){
        [[PublishInfoViewController shareMutabArray] addObject:model];
        
    }else {
        [[PublishInfoViewController shareMutabArray] removeAllObjects];
        [[PublishInfoViewController shareMutabArray] addObject:model];
    }
    
    [_tbView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 130;
    }
    else{
        return 400;
    }
}

#pragma mark - 发表blog

-(void)publish
{
    [moodTextView resignFirstResponder];
    
    BlogImageModel *model;
    if([PublishInfoViewController shareMutabArray].count != 0){
        model = [[PublishInfoViewController shareMutabArray] objectAtIndex:0];
    }
    
    if(model.imgArray.count == 0 && moodTextView.text.length == 0){
        return;
    }
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    HUD.dimBackground = YES;
    HUD.labelText = @"正在发表";
    
    if(model.imgArray.count != 0){
        //带图片上传
        for (int i = 0; i < model.imgArray.count; i ++) {
            
            MTTPhotoEnity *photo = [MTTPhotoEnity new];
            //设置图片文件名，保存进数据库
            NSString *keyName = [[MTTPhotosCache sharedPhotoCache] getKeyName];
            photo.localPath = keyName;
            
            [self sendImageMessage:photo Image:model.imgArray[i] count:model.imgArray.count];
        }
        
    }else { //纯文字
        
        IMMsgBlogAPI *blog = [[IMMsgBlogAPI alloc] init];
        
        // 参数
        NSDictionary *postdic = @{@"BlogText": moodTextView.text};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postdic options:NSJSONWritingPrettyPrinted error:nil];
        
        // 发表
        [blog requestWithObject:jsonData Completion:^(id response, NSError *error) {
            [response enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [HUD removeFromSuperview];
                
                //拿到blogID 直接加到本地数据库，不重新请求
                [[PublishInfoViewController shareMutabArray] removeAllObjects];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"BlogText"];
                
                // 发表完成
                [[NSNotificationCenter defaultCenter] postNotificationName:@"publishBlogFinished" object:self userInfo:nil];
                
                [self popViewControllerAnimated:YES];
            }];
        }];
    }
}

#pragma mark - 上传说说图片并返回图片URL

-(void)sendImageMessage:(MTTPhotoEnity *)photo Image:(UIImage *)image count:(NSInteger)count
{
    NSData *photoData = UIImageJPEGRepresentation(image, 0.5);
    [[MTTPhotosCache sharedPhotoCache] storePhoto:photoData forKey:photo.localPath toDisk:YES];//图片写到磁盘
    
    NSString *postImage =  [photo.localPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[DDSendPhotoMessageAPI sharedPhotoCache] blogImagesUploadToAliYunOSSWithContent:postImage success:^(NSString *fileURL)
     {
         [urlArray addObject:fileURL];
         if (urlArray.count == count) {
             IMMsgBlogAPI *blog = [[IMMsgBlogAPI alloc] init];
             NSDictionary *postdic = @{
                                       @"BlogText":moodTextView.text,
                                       @"BlogImages":urlArray
                                       };
             NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postdic options:NSJSONWritingPrettyPrinted error:nil];
             
             [blog requestWithObject:jsonData Completion:^(id response, NSError *error)
             {
                 [response enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     [HUD removeFromSuperview];
                     
                     [[PublishInfoViewController shareMutabArray] removeAllObjects];
                     [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"BlogText"];
                     
                     // 发表完成
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"publishBlogFinished" object:self userInfo:nil];
                     
                     [self popViewControllerAnimated:YES];
                 }];
             }];
         }
         
     } failure:^(NSError *error) {
         NSLog(@"上传阿里云OSS失败了");
     }];
}

#pragma mark - addImageDelegate

-(void)clickImage:(NSInteger)count
{
//    NSLog(@"--%ld",count);
}

-(void)addImage
{
    [[NSUserDefaults standardUserDefaults] setObject:moodTextView.text forKey:@"BlogText"];
    
    [moodTextView resignFirstResponder];
    LCActionSheet *sheet = [[LCActionSheet alloc] initWithTitle:@"请选择获取方式"
                                                   buttonTitles:@[@"拍照",@"从相册获取"]
                                                 redButtonIndex:2
                                                       delegate:self];
    
    
    [sheet show];
}

-(void)cancel
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"退出此次编辑" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
    [alert show];
}

#pragma mark - LCAlertViewDelegate
-(void)actionSheet:(LCActionSheet *)actionSheet didClickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:  //  拍照
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 判断照相机是否可用
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                }
                
                self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                
                [self.navigationController presentViewController:self.imagePicker animated:YES completion:nil];
            });
        }
            break;
            
        case 1:  //  从相册获取
        {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            // 自定义的相册
            CYAlbumViewController *album = [[CYAlbumViewController alloc] init];
            
            [self pushViewController:album animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:( NSString *)kUTTypeImage]){
        
        __block UIImage *theImage = nil;
        if ([picker allowsEditing]){
            theImage = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        UIImage *image = [self scaleImage:theImage toScale:0.5];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:image];
        [[PublishInfoViewController shareInstance] receiveImageArray:array];
        
        [picker dismissViewControllerAnimated:NO completion:nil];
        self.imagePicker = nil;
        
        [_tbView reloadData];
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker = nil;
}

#pragma mark 等比縮放image
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize, image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark - UIAlertViewDelegate
// 取消退出编辑的时候
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:  // 取消
        {
            
        }
            break;
            
        case 1:  // 退出
        {
            [moodTextView resignFirstResponder];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"BlogText"];
            [[PublishInfoViewController shareMutabArray] removeAllObjects];
            [[[PublishInfoViewController shareInstance] dataArray] removeAllObjects];
            [self popViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]){
        
        [moodTextView resignFirstResponder];
        
        return NO;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    //self.examineText =  textView.text;
    if (textView.text.length == 0) {
        promptLab.text = @"写点什么吧...";
    }else{
        promptLab.text = @"";
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
