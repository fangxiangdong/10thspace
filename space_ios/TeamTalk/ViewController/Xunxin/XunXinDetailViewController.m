//
//  XunXinDetailViewController.m
//  TeamTalk
//
//  Created by landu on 15/12/3.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "XunXinDetailViewController.h"
#import "XunxinTableViewCell.h"
#import "ActionTableViewCell.h"
#import "TouchDownGestureRecognizer.h"
#import "IMGetBlogCommentAPI.h"
#import "CommentTableViewCell.h"
#import "NSDate+DDAddition.h"
#import "MBProgressHUD.h"
#import "AddConcernAPI.h"
#import "CancellConcernAPI.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "MTTDatabaseUtil.h"

#define DDINPUT_MIN_HEIGHT          44.0f
#define DDINPUT_HEIGHT              self.ConmentInputView.size.height
#define DDINPUT_BOTTOM_FRAME        CGRectMake(0, CONTENT_HEIGHT - self.ConmentInputView.height + NAVBAR_HEIGHT,FULL_WIDTH,self.ConmentInputView.height)

@interface XunXinDetailViewController ()<UITableViewDataSource,UITableViewDelegate,LCConmentInputViewDelegate, UserActionDelegate>
{
    UITableView *_tbView;
    NSMutableArray *dataArray;
    float _inputViewY;
}
@end

@implementation XunXinDetailViewController
{
   TouchDownGestureRecognizer* _touchDownGestureRecognizer;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        dataArray = [NSMutableArray array];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"_inputViewY"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.title = @"动态正文";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self notification];
    [self initialInput];
    
    _tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 44)];
    _tbView.delegate = self;
    _tbView.dataSource = self;
    _tbView.backgroundColor = [UIColor whiteColor];
    _tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tbView];
    
    //避免inputView试图被tableView挡住了
    [self.view bringSubviewToFront:self.ConmentInputView];
    
    // 获取评论
    [self getComment];
}

#pragma mark - 获取评论

-(void)getComment
{
    IMGetBlogCommentAPI *getComment = [[IMGetBlogCommentAPI alloc] init];
    [getComment requestWithObject:self.xunxinModel.blogId Completion:^(id response, NSError *error) {
        
        [response enumerateObjectsUsingBlock:^(NSArray* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop){
            
            [dataArray addObjectsFromArray:obj];
            
        }];
        
        [_tbView reloadData];
    }];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
        
    }else {
        return dataArray.count;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){  // 内容
        static NSString *identifier = @"identifier";
        XunxinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(cell == nil){
            cell = [[XunxinTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        [cell setXunxinModel:_xunxinModel isList:NO And:indexPath.row blogType:self.blogType];
        
        return cell;
        
    }else {  // 评论区域
        
        NSString *customCellIdentifier = [@"CellIdentifier" stringByAppendingFormat:@"%ld", (long)indexPath.row];
        CommentTableViewCell *cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:customCellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(indexPath.row < dataArray.count){
            CommentModel *comment = [dataArray objectAtIndex:indexPath.row];
            [cell setCommentModel:comment];
        }
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 65 + _xunxinModel.photoViewHeight + _xunxinModel.contentHeight;
        
    }else {
        CommentModel *comment = [dataArray objectAtIndex:indexPath.row];
        return 35 + comment.commentHeight;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 0;
    }else {
        return 40;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return nil;
        
    } else {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = RGB(235, 235, 235);
        
        // 横线
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.3)];
        line.backgroundColor = RGB(200, 200, 200);
        [view addSubview:line];
        // 横线
        line = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.7, SCREEN_WIDTH, 0.3)];
        line.backgroundColor = RGB(180, 180, 180);
        [view addSubview:line];
        // 竖线
        line = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 0.3) * 0.5, 5, 0.3, 30)];
        line.backgroundColor = RGB(200, 200, 200);
        [view addSubview:line];
        
        // 按钮标题
        NSString *comment = [NSString stringWithFormat:@"评论 %@", self.xunxinModel.commentCnt];
        NSArray *array = @[@"分享", comment];
        
        for (int i = 0; i < 2; i ++) {
            UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 * i + 1, 1, SCREEN_WIDTH/2 - 2, 38)];
            actionButton.backgroundColor = RGB(235, 235, 235);
            actionButton.tag = 1000 + i;
            [actionButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [actionButton setTitle:array[i] forState:UIControlStateNormal];
            [actionButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
            actionButton.titleLabel.font = systemFont(14);
            
            [view addSubview:actionButton];
        }
        return view;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self.ConmentInputView.textView resignFirstResponder];
}

#pragma mark - 事件处理

- (void)careUser:(UIButton *)careBtn andUserModel:(XunxinModel *)model
{
    AddConcernAPI *addConcern = [[AddConcernAPI alloc] init];
    [addConcern requestWithObject:model.writerUserId Completion:^(id response, NSError *error) {
        
        [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *status = nil;
            if (idx == 0) {
                status = [NSString stringWithFormat:@"%@", obj];
            }
            
            if ([status isEqualToString:@"0"]) {
                // 添加关注
                [self blogBtn:careBtn status:@"关注成功" btnTitle:@"已关注" btnTitleColor:[UIColor lightGrayColor]];
            }
        }];
    }];
}

// 取消关注
- (void)cancellConcernUser:(UIButton *)careBtn andUserModel:(XunxinModel *)model
{
    CancellConcernAPI *cancell = [[CancellConcernAPI alloc] init];
    [cancell requestWithObject:model.writerUserId Completion:^(NSDictionary *dict, NSError *error) {
        
        NSString *resultCode = [NSString stringWithFormat:@"%@", [dict objectForKey:@"resultCode"]];
        
        if ([resultCode isEqualToString:@"0"]) {  // 取消关注
            UIColor *titleColor = [UIColor colorWithRed:14.0/255.0 green:207.0/255.0 blue:49.0/255.0 alpha:1.0];
            [self blogBtn:careBtn status:@"已取消关注" btnTitle:@"+关注" btnTitleColor:titleColor];
        }
        
    }];
}

- (void)blogBtn:(UIButton *)careBtn status:(NSString *)status btnTitle:(NSString *)title btnTitleColor:(UIColor *)titleColor
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    HUD.dimBackground = YES;
    HUD.labelText = status;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD hide:YES];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [careBtn setTitle:title forState:UIControlStateNormal];
        [careBtn setTitleColor:titleColor forState:UIControlStateNormal];
    });
}

-(void)shared
{
    NSArray* imageArray = @[[UIImage imageNamed:@"header"]];
    if (imageArray) {
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:@"分享内容"
                                         images:imageArray
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
         ];}
}

#pragma mark - 按钮的点击

- (void)userCareBtnOnClick:(XunxinTableViewCell *)userCell
{
    UIButton *careBtn = userCell.careBtn;
    XunxinModel *xunxinModel = userCell.xunxinModel;
    
    if ([careBtn.titleLabel.text isEqualToString:@"+关注"]) {
        [self careUser:careBtn andUserModel:xunxinModel];
        
    }else if ([careBtn.titleLabel.text isEqualToString:@"已关注"]) {
        [self cancellConcernUser:careBtn andUserModel:xunxinModel];
        
    }
}

// 分享、赞、评论按钮
-(void)action:(UIButton*)tap
{
    switch (tap.tag) {
        case 1000:{  // 分享
            [self shared];
        }
            break;
            
        case 1001:{  // 评论
            [self.ConmentInputView.textView becomeFirstResponder];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 键盘的通知
// 键盘的通知
-(void)notification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

//键盘出现是调用的方法
-(void)keyboardWillShow:(NSNotification *)note
{
    //取键盘坐标
    CGRect rect = [[note userInfo] [@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    [UIView animateWithDuration:0.25 animations:^{
        self.ConmentInputView.frame = CGRectMake(0, rect.origin.y - DDINPUT_HEIGHT, SCREEN_WIDTH, DDINPUT_HEIGHT);
    }];
    
    [self setValue:@(rect.origin.y - DDINPUT_HEIGHT) forKeyPath:@"_inputViewY"];
}

-(void)keyboardWillHidden:(NSNotification *)note
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.ConmentInputView setFrame:DDINPUT_BOTTOM_FRAME];
    }];
    
    
    [self setValue:@(self.ConmentInputView.origin.y) forKeyPath:@"_inputViewY"];
    [self.view endEditing:YES];
}

#pragma mark - 添加评论
-(void)textViewEnterSend
{
    NSString* text = [self.ConmentInputView.textView text];
    
    if(text.length == 0){
        return;
    }
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    HUD.dimBackground = YES;
    HUD.labelText = @"Loading";
    
    NSData  *CommentData = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *object = @[CommentData, self.xunxinModel.blogId];
    
    // 添加评论
    IMAddBlogConmentAPI *blogComment = [[IMAddBlogConmentAPI alloc] init];
    [blogComment requestWithObject:object Completion:^(id response, NSError *error) {
        
        [response enumerateObjectsUsingBlock:^(NSArray*  obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //_Nonnull
            NSMutableArray *array = [NSMutableArray array];
            [array addObjectsFromArray:obj];
            
            CommentModel *comment = [[CommentModel alloc] init];
            comment.commentID = [NSString stringWithFormat:@"%@",array[0]];
            comment.comment = text;
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:[array[1] doubleValue]];
            comment.createTime = [date blogDataString];
            [dataArray addObject:comment];
            
            [_tbView reloadData];
            
            [self.ConmentInputView.textView resignFirstResponder];
            self.ConmentInputView.textView.text = @"";
            
            [HUD removeFromSuperview];
        }];
        
        [HUD removeFromSuperview];
    }];
}

- (void)viewheightChanged:(float)height
{
    [self setValue:@(self.ConmentInputView.origin.y) forKeyPath:@"_inputViewY"];
}

- (void)textViewChanged
{
     //此方法判断是否输入@
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"_inputViewY"]){
        float maxY = FULL_HEIGHT - DDINPUT_MIN_HEIGHT;
        float gap = maxY - _inputViewY - DDINPUT_MIN_HEIGHT;
        [UIView animateWithDuration:0.25 animations:^{
            _tbView.contentInset = UIEdgeInsetsMake(_tbView.contentInset.top, 0, gap+DDINPUT_MIN_HEIGHT, 0);
        }completion:^(BOOL finished) {
            
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation XunXinDetailViewController(ConmentInput)

- (void)initialInput
{
    CGRect inputFrame = CGRectMake(0, CONTENT_HEIGHT - DDINPUT_MIN_HEIGHT + NAVBAR_HEIGHT ,FULL_WIDTH,DDINPUT_MIN_HEIGHT);

    self.ConmentInputView = [[LCConmentInputView alloc] initWithFrame:inputFrame delegate:self];
    [self.ConmentInputView setBackgroundColor:RGBA(249, 249, 249, 0.9)];
    [self.view addSubview:self.ConmentInputView];
    
    [self.ConmentInputView.emotionbutton addTarget:self
                                            action:@selector(showEmotions)
                                  forControlEvents:UIControlEventTouchUpInside];



    [self addObserver:self forKeyPath:@"_inputViewY" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

-(void)showEmotions
{
    NSLog(@"---- 图标");
}

@end
