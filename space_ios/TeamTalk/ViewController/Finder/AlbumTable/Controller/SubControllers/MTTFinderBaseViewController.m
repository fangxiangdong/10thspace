//
//  MTTFinderBaseViewController.m
//  TeamTalk
//
//  Created by 1 on 16/11/11.
//  Copyright © 2016年 IM. All rights reserved.
//

#import "MTTFinderBaseViewController.h"
#import "XunXinDetailViewController.h"
#import "PublishInfoViewController.h"
#import "MTTWebViewController.h"
#import <SVWebViewController.h>
/** OTHER*/
#import "ScanQRCodePage.h"
#import "RuntimeStatus.h"
#import "MTTUserEntity.h"
#import "AFHTTPRequestOperationManager.h"
#import "MTTURLProtocal.h"
#import <Masonry/Masonry.h>
#import "XunxinTableViewCell.h"
#import "XunxinModel.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"
#import "CYAvatarBrowser.h"
#import "MTTDatabaseUtil.h"
#import "MTTPhotographyHelper.h"
#import "DDClientState.h"
/** API*/
#import "IMMsgBlogListAPI.h"
#import "AddConcernAPI.h"
#import "CancellConcernAPI.h"
#import "DDUserModule.h"
/** SDK*/
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

@interface MTTFinderBaseViewController ()<UITableViewDelegate, UITableViewDataSource, UserActionDelegate>

@property (nonatomic, strong) MTTPhotographyHelper *photographyHelper;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, strong) IMMsgBlogListAPI *requestBlogAPI;
@property (nonatomic, strong) NSMutableDictionary *myUsersDictM;

@end

@implementation MTTFinderBaseViewController

static CGFloat const kGrayIntervalHeight = 10;

- (BlogType)requestBlogType
{
    return 0;
}

#pragma mark - 懒加载

- (NSMutableDictionary *)myUsersDictM
{
    if (_myUsersDictM == nil) {
        _myUsersDictM = [NSMutableDictionary dictionary];
        
        MTTUserEntity *userEntity = (MTTUserEntity *)TheRuntime.user;
        NSString *key = [NSString stringWithFormat:@"user_%@", userEntity.userID];
        [_myUsersDictM setObject:userEntity.userID forKey:key];
    }
    return _myUsersDictM;
}

- (IMMsgBlogListAPI *)requestBlogAPI
{
    if (_requestBlogAPI == nil) {
        _requestBlogAPI = [[IMMsgBlogListAPI alloc] init];
    }
    return _requestBlogAPI;
}

- (MTTPhotographyHelper *)photographyHelper {
    if (!_photographyHelper) {
        _photographyHelper = [[MTTPhotographyHelper alloc] init];
    }
    return _photographyHelper;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

#pragma mark - view
- (void)viewWillAppear:(BOOL)animated
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
    
    self.view.backgroundColor = RGB(255, 255, 255);
    [self setupMainTable];
    
    // 获取与自己有关的用户
    [self getAllMyUsers];
    
    self.isFirstLoad = YES;
    self.currentPage = 0;
    // blog发表完成的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishBlogFinished:) name:@"publishBlogFinished" object:nil];
}

#pragma mark - 监听通知

- (void)publishBlogFinished:(NSNotification *)note
{
    [_tableView headerBeginRefreshing];
}

#pragma mark - setupView

- (void)setupMainTable
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 49 - 64) style:UITableViewStylePlain];
    [_tableView setBackgroundColor:RGB(240, 240, 240)];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = YES;
    
    [_tableView addHeaderWithTarget:self action:@selector(headerFreshing) dateKey:@"header"];
    [_tableView headerBeginRefreshing];
    [_tableView addFooterWithTarget:self action:@selector(loadMoreBlogsData)];
    
    [self.view addSubview:_tableView];
}

- (void)headerFreshing
{
    [self requestBlogListData];
    [self.tableView headerEndRefreshing];
}

#pragma mark UITableView

// 分组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray ? self.dataArray.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kGrayIntervalHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = RGB(240, 240, 240);
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XunxinModel *xunxinModel;
    if(indexPath.section < _dataArray.count) {
        xunxinModel = [_dataArray objectAtIndex:indexPath.section];
    }
    
    return 40 + 66 + xunxinModel.photoViewHeight + xunxinModel.contentHeight;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *blogID = @"BlogCellIdentifier";
    
    XunxinTableViewCell *cell = [[XunxinTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:blogID];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    [cell setXunxinModel:self.dataArray[indexPath.section] isList:YES And:indexPath.section blogType:self.requestBlogType];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    XunxinModel *xunxinModel = [_dataArray objectAtIndex:indexPath.section];
    XunXinDetailViewController *xunxin = [[XunXinDetailViewController alloc] init];
    xunxin.xunxinModel = xunxinModel;
    xunxin.blogType = self.requestBlogType;
    
    [self pushViewController:xunxin animated:YES];
}

#pragma mark - 事件处理

- (void)dealWithTableViewDatas:(NSArray *)obj
{
    // 过滤掉好友和关注用户的blogs数据
    if (self.requestBlogType == BlogTypeBlogTypeRcommend) {
        XunxinModel *model = obj[0];
        NSString *userID = [self.myUsersDictM objectForKey:[NSString stringWithFormat:@"user_%@", model.writerUserId]];
        if (userID.length == 0) {
            [_dataArray addObjectsFromArray:obj];
        }
    }else {
        [_dataArray addObjectsFromArray:obj];
    }
    
    // 插入数据库(1-推荐，2-好友，3-关注)
    NSString *blogType = [NSString stringWithFormat:@"%zd", self.requestBlogType];
    [[MTTDatabaseUtil instance] insertBlogs:obj withBlogType:blogType completion:^(NSError *error) {
        if (!error) {
//            DDLog(@"--blog成功插入数据库");
        }else {
            DDLog(@"blog插入数据库失败 %@", error);
        }
    }];
}

- (void)getAllMyUsers
{
    // 获取关注用户
    NSString *userID;
    DDUserModule *userModule = [DDUserModule shareInstance];
    
    NSArray *concernA = [userModule getAllAttention];
    for (MTTUserEntity *userEntity in concernA) {
        if ([userEntity.userID containsString:@"user_"]) {
            userID = [userEntity.userID substringFromIndex:5];
        }else {
            userID = userEntity.userID;
        }
        NSString *key = [NSString stringWithFormat:@"user_%@", userID];
        [self.myUsersDictM setObject:userID forKey:key];
    }
    
    // 获取好友用户
    NSArray *friendA = [userModule getAllMaintanceUser];
    for (MTTUserEntity *userEntity in friendA) {
        if ([userEntity.userID containsString:@"user_"]) {
            userID = [userEntity.userID substringFromIndex:5];
        }else {
            userID = userEntity.userID;
        }
        NSString *key = [NSString stringWithFormat:@"user_%@", userID];
        [self.myUsersDictM setObject:userID forKey:key];
    }
}

// 关注
- (void)careUser:(UIButton *)careBtn andUserModel:(XunxinModel *)model
{
    AddConcernAPI *addConcern = [[AddConcernAPI alloc] init];
    [addConcern requestWithObject:model.writerUserId Completion:^(id response, NSError *error) {
        
        [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSLog(@"%@--%zd", obj, idx);
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

#pragma mark - UserActionDelegate-cellDelegate

- (void)imageMagnify:(NSInteger)count AndIndex:(NSInteger)index AndRect:(CGRect)oldRect
{
    NSLog(@"--- %ld--%ld",count - 10,index);
//    XunxinModel *xunxinModel = [_dataArray objectAtIndex:index];
}

- (void)userCareBtnOnClick:(XunxinTableViewCell *)userCell
{
    UIButton *careBtn = userCell.careBtn;
    XunxinModel *xunxinModel = userCell.xunxinModel;
    
    if ([careBtn.titleLabel.text isEqualToString:@"+关注"]) {
        // 可关注
        [self careUser:careBtn andUserModel:xunxinModel];
        // 更新blogs数据(3-关注)
//        [[MTTDatabaseUtil instance] updateBlogsWithBlogType:@"3" andUserID:xunxinModel.writerUserId completion:^(NSError *error) {
//            if (error) {
//                DDLog(@"%@", error);
//            }
//        }];
        
    }else if ([careBtn.titleLabel.text isEqualToString:@"已关注"]) {
        // 是否取消关注
        UIAlertController *alterVC = [UIAlertController alertControllerWithTitle:@"" message:@"确定要取消关注此人吗？" preferredStyle:UIAlertControllerStyleActionSheet];
        [alterVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alterVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            // 取消关注
            [self cancellConcernUser:careBtn andUserModel:xunxinModel];
            // 更新blogs数据(3-关注)
//            NSString *blogType = [NSString stringWithFormat:@"%zd", self.requestBlogType];
//            [[MTTDatabaseUtil instance] updateBlogsWithBlogType:blogType andUserID:xunxinModel.writerUserId completion:^(NSError *error) {
//                if (error) {
//                    DDLog(@"%@", error);
//                }
//            }];
        }]];
        
        [self presentViewController:alterVC animated:YES completion:nil];
    }
}

// 转发、点赞、评论按钮的点击
- (void)userAction:(NSInteger)count Andindex:(NSInteger)index
{
    if (_dataArray.count <= index) {
        return;
    }
    
    XunxinModel *xunxinModel = [_dataArray objectAtIndex:index];
    switch (count) {
        case 100:  // 转发按钮
        {
            [self shared];
        }
            break;
            
        case 101:  // 评论按钮
        {
            XunXinDetailViewController *xunxin = [[XunXinDetailViewController alloc] init];
            xunxin.xunxinModel = xunxinModel;
            [self pushViewController:xunxin animated:YES];
        }
            break;
            
        default:
            break;
    }
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

#pragma mark - Networking Request

// 下拉刷新
- (void)requestBlogListData
{
    // 无网络
    DDNetWorkState netWorkState = [DDClientState shareInstance].networkState;
    if (netWorkState == DDNetWorkDisconnect) {
        
        if (self.isFirstLoad) {
            // 第一次请求
            // 从数据库读取阅读过的数据
            NSString *blogType = [NSString stringWithFormat:@"%zd", self.requestBlogType];
            [[MTTDatabaseUtil instance] getAllBlogsWithBlogType:blogType complection:^(NSArray *blogs, NSError *error) {
                for (XunxinModel *model in blogs) {
                    [_dataArray addObject:model];
                }
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.currentPage = (self.dataArray.count + 10) / 10;
                [self.tableView reloadData];
            });
        }
        return;
    }
    
    self.currentPage = 0;
    // 设置请求参数
    NSDictionary *params = @{
                             @"blogType": @(self.requestBlogType),
                             @"page"    : @"0",
                             @"pageSize": @"10"
                             };
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self.requestBlogAPI requestWithObject:params Completion:^(NSArray *response, NSError *error)
         {
             [_dataArray removeAllObjects];
             
             [response enumerateObjectsUsingBlock:^(NSArray* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
              {
                  // 数据处理
                  [self dealWithTableViewDatas:obj];
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.tableView reloadData];
                  });
              }];
             self.currentPage++;
             self.isFirstLoad = NO;
         }];
    });
}

// 上拉加载更多
- (void)loadMoreBlogsData
{
    // 无网络
    DDNetWorkState netWorkState = [DDClientState shareInstance].networkState;
    if (netWorkState == DDNetWorkDisconnect) {
        // 给用户提示
        return;
    }
    
    NSString *currentPage = [NSString stringWithFormat:@"%zd", self.currentPage];
    NSDictionary *params = @{
                             @"blogType": @(self.requestBlogType),
                             @"page"    : currentPage,
                             @"pageSize": @"10"
                             };
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 请求数据
        [self.requestBlogAPI requestWithObject:params Completion:^(NSArray *response, NSError *error)
         {
             if (response.count) {
                 [response enumerateObjectsUsingBlock:^(NSArray* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
                  {
                      [self dealWithTableViewDatas:obj];
                  }];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.currentPage++;
                     [self.tableView reloadData];
                 });
             }
         }];
    });
    [self.tableView footerEndRefreshing];
}

#pragma mark - other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
