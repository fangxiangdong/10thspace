//
//  FinderViewController.m
//  TeamTalk
//
//  Created by 独嘉 on 14-10-22.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "XunXinViewController.h"
#import "HomeRecommendViewController.h"
#import "HomeFriendsViewController.h"
#import "HomeConcernViewController.h"
#import "MTTUserEntity.h"
#import "HomeMainAPI.h"
#import "DDUserModule.h"
/** OSS数据*/
#import <AliyunOSSiOS/OSSService.h>
/** API*/
#import "DDSendPhotoMessageAPI.h"

#define HomeScreenWidth [UIScreen mainScreen].bounds.size.width
#define HomeScreenHeight [UIScreen mainScreen].bounds.size.height

@interface XunXinViewController ()<UIScrollViewDelegate>

@property (nonatomic, weak)   UIScrollView *scrollView;
@property (nonatomic, weak)   UIView   *navTitleView;
@property (nonatomic, weak)   UIButton *preveBtn;
@property (nonatomic, strong) UIButton *currentTitleBtn;
@property (nonatomic, weak)   UIView   *lineView;
@property (nonatomic, weak)   NSTimer  *timer;
@property (nonatomic, weak)   UILabel  *onlineCountLabel;

@end

@implementation XunXinViewController

#pragma mark - view

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navTitleView removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeViewWillDisappear" object:self userInfo:nil];
    
    [self stopTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"";
    
    [self setupNavTitleView];    // 设置导航条顶部视图
    [self setTitleBtnLocation];  // 处理标题栏位置
    
    self.navigationItem.rightBarButtonItem = nil;
      [self setTheFirstPromptMessage];//登录后提示调屏幕亮度
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeViewWillAppear" object:self userInfo:nil];

    
    // 开启定时器
    [self startTimer];
}

-(void)setTheFirstPromptMessage
{

//    if (![[NSUserDefaults standardUserDefaults ]objectForKey:@"FirstPromptMessage"]) {
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请调低屏幕亮度" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"下次不再提示", nil];
//        
//        
//        [alert show];
//        
//        [[NSUserDefaults standardUserDefaults ]setObject:@"yes" forKey:@"FirstPromptMessage"];
//    }
    
    if (![[NSUserDefaults standardUserDefaults ]objectForKey:@"FirstPromptMessage"]) {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请把手机屏幕亮度调低" preferredStyle:UIAlertControllerStyleAlert];
    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's cancel action occured.");
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"下次不再提示" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [[NSUserDefaults standardUserDefaults ]setObject:@"yes" forKey:@"FirstPromptMessage"];
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    // 设置导航条和状态栏
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:28.0/255.0 green:216.0/255.0 blue:27.0/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    // 不自动锁屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
  
    
    [self setupUserOnlineView];         // 提示用户在线人数
    [self loadHomeMainDatas];           // 请求首页数据
    [self addAllChildViewControllers];  // 添加所有的自控制器
    [self setupMainView];               // collectionView
    
    
    
}

#pragma mark - 创建view

- (void)setupUserOnlineView
{
    UIImageView *baseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 18)];
    baseImageView.image = [UIImage imageNamed:@"banner"];
    [self.view addSubview:baseImageView];
    
    // 文字
    UILabel *onlineCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, baseImageView.frame.size.width, baseImageView.frame.size.height)];
    onlineCountLabel.text = @"当前在线人数";
    onlineCountLabel.textAlignment = NSTextAlignmentLeft;
    onlineCountLabel.font = [UIFont systemFontOfSize:14.0];
    onlineCountLabel.textColor = [UIColor whiteColor];
    self.onlineCountLabel = onlineCountLabel;
    [baseImageView addSubview:onlineCountLabel];
}

- (void)addAllChildViewControllers
{
    [self addChildViewController:[[HomeRecommendViewController alloc] init]];
    [self addChildViewController:[[HomeFriendsViewController   alloc] init]];
    [self addChildViewController:[[HomeConcernViewController   alloc] init]];
}

- (void)setupMainView
{
    NSInteger count = self.childViewControllers.count;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + 18 + 3, self.view.frame.size.width, self.view.frame.size.height - 49 - 64 - 21)];
    scrollView.backgroundColor = [UIColor whiteColor];
    
    // 其他设置
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * count, 0);
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    
    // 添加第一个自控制器
    UIViewController *childViewController = self.childViewControllers[0];
    childViewController.view.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    [scrollView addSubview:childViewController.view];
    
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
}

- (void)setupNavTitleView
{
    CGFloat width = 65 * 3 + 15 * 2;
    CGFloat x = (self.navigationController.navigationBar.bounds.size.width - width) * 0.5;
    UIView *navTitleView = [[UIView alloc] initWithFrame:CGRectMake(x, 0, width, 44)];
    self.navTitleView = navTitleView;
    
    // 添加子控件
    [self setupNavTitleViewBtn:navTitleView];
    
    [self.navigationController.navigationBar addSubview:navTitleView];
}

- (void)setupNavTitleViewBtn:(UIView *)titlView
{
    CGFloat btnWidth = 65;
    CGFloat margin = 15;
    
    NSArray *btnTitle = @[@"推荐", @"好友", @"关注"];
    for (NSInteger i = 0; i < btnTitle.count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i * (btnWidth + margin), 0, btnWidth, 40);
        btn.tag = i;
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [btn setTitle:btnTitle[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(navTitleViewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            btn.selected = YES;
            self.preveBtn = btn;
        }
        
        [titlView addSubview:btn];
    }
    // 添加按钮下划线
    [self setupBtnLineView];
}

- (void)setupBtnLineView
{
    UIButton *btn = self.navTitleView.subviews[0];
    NSString *title = btn.titleLabel.text;
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: btn.titleLabel.font}];
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((btn.frame.size.width - size.width) * 0.5, CGRectGetMaxY(btn.frame), size.width, 2)];
    lineView.backgroundColor = btn.titleLabel.textColor;
    self.lineView = lineView;
    [self.navTitleView addSubview:lineView];
}

#pragma mark - 定时器事件

// 开启定时器
- (void)startTimer
{
    [self loadHomeMainDatas];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(loadHomeMainDatas) userInfo:nil repeats:YES];
    
    // 添加到主运行循环中
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

// 暂停
- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - 事件处理

- (void)setTitleBtnLocation
{
    // 下划线
    if (self.currentTitleBtn.titleLabel.text.length) {
        CGSize size = [self.currentTitleBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.currentTitleBtn.titleLabel.font}];
        
        CGRect tempFrame = self.lineView.frame;
        tempFrame.size.width = size.width;
        
        CGPoint center = self.lineView.center;
        center.x = self.currentTitleBtn.center.x;
        self.lineView.center = center;
    }
}

- (void)addSubViewToScrollView:(NSInteger)index
{
    UIViewController *childVC = self.childViewControllers[index];
    
    // 是否已经加载过
    if (childVC.isViewLoaded) return;
    
    childVC.view.frame = CGRectMake(self.scrollView.frame.size.width * index, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    // 添加自控制器的view
    [self.scrollView addSubview:childVC.view];
}

// 推荐用户在线人数
- (void)loadRecommendOnlineUser
{
    HomeMainAPI *api = [[HomeMainAPI alloc] init];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 请求数据
        [api requestWithObject:nil Completion:^(NSDictionary *response, NSError *error) {
            NSString *totalOnlineUserCount = [response objectForKey:@"onlineUserCnt"];
            NSString *totalString = [NSString stringWithFormat:@"当前在线人数 %@ 人", totalOnlineUserCount];
            // 回主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                self.onlineCountLabel.text = totalString;
            });
        }];
    });
}

// 好友用户在线人数
- (void)loadFriendUserOnlineFromFBDM
{
    __block NSInteger onlineCount = 0;
    NSArray *array = [[DDUserModule shareInstance] getAllMaintanceUser];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (MTTUserEntity *userEntity in array) {
            NSString *userID = [userEntity.objID substringFromIndex:5];
            // 检查是否有图片
            NSString *objectKey = [NSString stringWithFormat:@"im/live/%@.png", userID];
            OSSClient *client   = [[DDSendPhotoMessageAPI sharedPhotoCache] ossInit];
            NSError *error      = nil;
            BOOL isExist = [client doesObjectExistInBucket:@"tenth" objectKey:objectKey error:&error];
            if (!error) {
                if(isExist) {
                    // 文件存在
                    onlineCount++;
                }
            }
        }
        // 回主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onlineCount == 0) {
                self.onlineCountLabel.text = @"当前暂无好友在线！！";
            }else {
                NSString *totalString = [NSString stringWithFormat:@"当前好友在线人数 %zd 人", onlineCount];
                self.onlineCountLabel.text = totalString;
            }
        });
    });
}

// 关注用户在线人数
- (void)loadConcernUserOnlineFromFBDM
{
    __block NSInteger onlineCount = 0;
    NSArray *array = [[DDUserModule shareInstance] getAllAttention];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (MTTUserEntity *userEntity in array) {
            NSString *userID = [userEntity.objID substringFromIndex:5];
            // 检查是否有图片
            NSString *objectKey = [NSString stringWithFormat:@"im/live/%@.png", userID];
            OSSClient *client   = [[DDSendPhotoMessageAPI sharedPhotoCache] ossInit];
            NSError *error      = nil;
            BOOL isExist = [client doesObjectExistInBucket:@"tenth" objectKey:objectKey error:&error];
            if (!error) {
                if(isExist) {
                    // 文件存在
                    onlineCount++;
                }
            }
        }
        // 回主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onlineCount == 0) {
                self.onlineCountLabel.text = @"当前暂无关注用户在线！！";
            }else {
                NSString *totalString = [NSString stringWithFormat:@"当前关注用户在线人数 %zd 人", onlineCount];
                self.onlineCountLabel.text = totalString;
            }
        });
    });
}

#pragma mark - load-data

// 在线人数
- (void)loadHomeMainDatas
{
    if (self.currentTitleBtn.tag == 0) {
        [self loadRecommendOnlineUser];
    }
    if (self.currentTitleBtn.tag == 1) {
        [self loadFriendUserOnlineFromFBDM];
    }
    if (self.currentTitleBtn.tag == 2) {
        [self loadConcernUserOnlineFromFBDM];
    }
}

#pragma mark - button_click

- (void)navTitleViewBtnClick:(UIButton *)titleBtn
{
    self.preveBtn.selected = NO;
    titleBtn.selected = YES;
    self.preveBtn = titleBtn;
    self.currentTitleBtn = titleBtn;
    
    // 当前显示的view
    if (titleBtn.tag == 0) {
        self.titleBtnTag = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RecommendView" object:self userInfo:nil];
    }
    if (titleBtn.tag == 1) {
        self.titleBtnTag = 1;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendView" object:self userInfo:nil];
    }
    if (titleBtn.tag == 2) {
        self.titleBtnTag = 2;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ConcernView" object:self userInfo:nil];
    }
    
    CGSize size = [titleBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: titleBtn.titleLabel.font}];
    // 动画
    [UIView animateWithDuration:0.25 animations:^{
        // 下划线
        CGRect tempFrame = self.lineView.frame;
        tempFrame.size.width = size.width;
        
        CGPoint center = self.lineView.center;
        center.x = titleBtn.center.x;
        self.lineView.center = center;
        
        // scrollView的偏移
        CGPoint offset = self.scrollView.contentOffset;
        offset.x = self.scrollView.frame.size.width * titleBtn.tag;
        self.scrollView.contentOffset = offset;
        
    } completion:^(BOOL finished) {
        [self addSubViewToScrollView:titleBtn.tag];
        // 滚动到当前view并开启定时器
        [self startTimer];
    }];
}

#pragma mark- UIScrollView Delegate

// 拖拽完成时
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 拖拽完成时拿到scrollView的偏移量, 通过偏移量计算出偏移的个数(对应标题按钮的下标)
    NSInteger index = scrollView.contentOffset.x / self.scrollView.frame.size.width;
    UIButton *titleButton = self.navTitleView.subviews[index];
    
    if (self.currentTitleBtn == titleButton) return;
    
    [self navTitleViewBtnClick:titleButton];
}

// 将要开始拖拽的时候
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 关闭定时器
    [self stopTimer];
}

#pragma mark - other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor *)randomColor
{
    CGFloat r = arc4random_uniform(256) / 255.0;
    CGFloat g = arc4random_uniform(256) / 255.0;
    CGFloat b = arc4random_uniform(256) / 255.0;
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    return color;
}

@end
