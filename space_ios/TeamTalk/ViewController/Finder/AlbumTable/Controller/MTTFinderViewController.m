//
//  MTTFinderViewController.m
//  TeamTalk
//
//  Created by 1 on 16/10/31.
//  Copyright © 2016年 IM. All rights reserved.
//

#import "MTTFinderViewController.h"
#import "PublishInfoViewController.h"
#import "RecommendViewController.h"
#import "FriendsViewController.h"
#import "ConcernViewController.h"

@interface MTTFinderViewController ()<UIScrollViewDelegate>

@property (nonatomic, weak)   UIView *navTitleView;
@property (nonatomic, weak)   UIButton *preveBtn;
@property (nonatomic, strong) UIButton *currentTitleBtn;
@property (nonatomic, weak)   UIView *lineView;
@property (nonatomic, weak)   UIScrollView *scrollView;

@end

@implementation MTTFinderViewController

#pragma mark - View

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"";
    
    // 导航条右边
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"publishBlog"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(publish) forControlEvents:UIControlEventTouchUpInside];
//    [rightBtn sizeToFit];
    rightBtn.bounds = CGRectMake(0, 0, 35, 35);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(publish)];
    
    // 设置导航条顶部视图
    [self setupNavTitleView];
    
    // 处理标题栏位置
    [self setTitleBtnLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navTitleView removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = RGB(255, 255, 255);
    
    // 添加所有的自控制器
    [self addAllChildViewControllers];
    
    // 添加scrollView
    [self setupMainScrollView];
}

#pragma mark - setupView
- (void)addAllChildViewControllers
{
    [self addChildViewController:[[RecommendViewController alloc] init]];
    [self addChildViewController:[[FriendsViewController   alloc] init]];
    [self addChildViewController:[[ConcernViewController   alloc] init]];
}

- (void)setupMainScrollView
{
    NSInteger count = self.childViewControllers.count;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 49)];
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
    CGFloat width = 60 * 3 + 10 * 2;
    CGFloat x = (self.navigationController.navigationBar.bounds.size.width - width - 40) * 0.5;
    UIView *navBarTitleView = [[UIView alloc] initWithFrame:CGRectMake(x, 0, width, 44)];
    self.navTitleView = navBarTitleView;
    
    // 添加子控件
    [self setupNavTitleViewBtn:navBarTitleView];
    
    [self.navigationController.navigationBar addSubview:navBarTitleView];
}

- (void)setupNavTitleViewBtn:(UIView *)titlView
{
    CGFloat btnWidth = 60;
    CGFloat margin = 10;
    
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

#pragma mark - button_click

- (void)navTitleViewBtnClick:(UIButton *)titleBtn
{
    self.preveBtn.selected = NO;
    titleBtn.selected = YES;
    self.preveBtn = titleBtn;
    self.currentTitleBtn = titleBtn;
    
    CGSize size = [titleBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: titleBtn.titleLabel.font}];
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
    }];
}

- (void)publish
{
    PublishInfoViewController *info = [[PublishInfoViewController alloc] init];
    
    [self pushViewController:info animated:YES];
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
    
    if (childVC.isViewLoaded) return;
    
    childVC.view.frame = CGRectMake(self.scrollView.frame.size.width * index, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    [self.scrollView addSubview:childVC.view];
}

#pragma mark- UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 拖拽完成时拿到scrollView的偏移量, 通过偏移量计算出偏移的个数(对应标题按钮的下标)
    NSInteger index = scrollView.contentOffset.x / self.scrollView.frame.size.width;
    
    UIButton *titleButton = self.navTitleView.subviews[index];
    
    if (self.currentTitleBtn == titleButton) return;
    
    [self navTitleViewBtnClick:titleButton];
}

#pragma mark - other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

@end
