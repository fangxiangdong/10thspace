//
//  ContactsViewController.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-15.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "ContactsViewController.h"
#import "AddFriendModule.h"
#import "PublicProfileViewControll.h"
#import "ContactsModule.h"
#import "MTTGroupEntity.h"
#import "DDSearch.h"
#import "ContactAvatarTools.h"
#import "DDContactsCell.h"
#import "DDUserDetailInfoAPI.h"
#import "DDGroupModule.h"
#import "ChattingMainViewController.h"
#import "SearchContentViewController.h"
#import "MBProgressHUD.h"
#import "DDFixedGroupAPI.h"
#import "Masonry.h"
#import "MTTNotification.h"
#import "SearchUserViewController.h"
#import "AddFriendCell.h"
#import "AddFriendMsgViewController.h"
#import <Masonry.h>
#import "ReadAddFriendAPI.h"
@interface ContactsViewController ()<ContactsModuleDelegate,setToolAndCellbarBadgeDelegate>
{

    UILabel *alabel;
}
@property(nonatomic,strong) UISegmentedControl *segmentedControl;
@property(nonatomic,strong) NSMutableDictionary *items;
@property(nonatomic,strong) NSMutableDictionary *department;
@property(nonatomic,strong) NSMutableDictionary *keys;
@property(nonatomic,strong) ContactsModule *model;
@property(nonatomic,strong) NSArray *allIndexes;
@property(nonatomic,strong) NSArray *departmentIndexes;
@property(nonatomic,strong) NSMutableArray *groups;
@property(nonatomic,strong) NSArray *searchResult;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UISearchBar *searchBar;
@property(nonatomic,strong) ContactAvatarTools *tools;
@property(nonatomic,strong) UISearchDisplayController *searchController;
@property(nonatomic,strong) SearchContentViewController *searchContent;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong)UITableView* searchTableView;
@property(nonatomic,strong)UIView* searchPlaceholderView;
@property(assign)int selectIndex;
@property(nonatomic,strong)NSMutableArray*addFriendArray;
@property(nonatomic,strong)UIView *redView;
@property(nonatomic,assign)NSInteger unReadCount;
@property(nonatomic,assign)NSInteger aCount;
@property(nonatomic,assign)BOOL isClean;

@property(nonatomic,strong)UIScrollView*myScrollview;
@property (nonatomic, weak) UIView *navTitleView;
@property (nonatomic, weak) UIButton *preveBtn;
@property (nonatomic, weak) UIView *lineView;
@property(nonatomic,strong)UITableView*attentionTableView;//关注的列表
@property(nonatomic,strong) NSMutableDictionary *attentionItems;

@property(nonatomic,assign)NSInteger nowPage;
@end

@implementation ContactsViewController


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self == [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title=@"联系人";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.aCount=0;
    ContactsModule *model = [ContactsModule shark];
    model.delegate=self;
    
    AddFriendModule *models=[AddFriendModule instance];
    models.delegate2=self;
    
    self.model = [ContactsModule new];
    
    self.groups = [NSMutableArray arrayWithArray:self.model.groups];
    
    self.searchResult = [NSArray new];
    
//    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"全部",@"部门"]];
//    self.segmentedControl.selectedSegmentIndex=0;
//    self.segmentedControl.frame=CGRectMake(80.0f, 8.0f, 200.0f, 30.0f);
//    self.segmentedControl.backgroundColor = [UIColor whiteColor];
//    self.segmentedControl.tintColor= TTBLUE;
//    [self.segmentedControl addTarget:self action:@selector(segmentSelect:) forControlEvents:UIControlEventValueChanged];
//    self.navigationItem.titleView=self.segmentedControl;
    
    
    self.myScrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49)];
    self.myScrollview.pagingEnabled=YES;
    self.myScrollview.contentSize=CGSizeMake(self.view.frame.size.width*2, 0);
    self.myScrollview.backgroundColor=[UIColor whiteColor];
    self.myScrollview.delegate=self;
    self.myScrollview.showsHorizontalScrollIndicator=NO;
    self.myScrollview.showsVerticalScrollIndicator=NO;
       [self.view addSubview:self.myScrollview];
    
   
    
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, FULL_WIDTH, 44)];
    [self.searchBar setPlaceholder:@"搜索"];
    self.searchBar.searchBarStyle = UIBarStyleDefault;
    self.searchBar.barTintColor = TTBG;
    self.searchBar.layer.borderWidth = 0.5;
    self.searchBar.layer.borderColor = RGB(204, 204, 204).CGColor;
    self.searchBar.delegate=self;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64-49)];
    self.tableView.tag=100;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.myScrollview addSubview:self.tableView];
    
    self.attentionTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width,0, self.view.frame.size.width, self.view.frame.size.height-64-49)];
    self.attentionTableView .tag=101;
    self.attentionTableView .delegate=self;
    self.attentionTableView .dataSource=self;
    self.attentionTableView.backgroundColor=[UIColor whiteColor];
    [self.myScrollview addSubview:self.attentionTableView ];
    self.attentionTableView.separatorStyle = NO;
    
    
  
//    MTT_WEAKSELF(ws);
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(ws.view);
//        make.top.equalTo(ws.view);
//        make.right.equalTo(ws.view);
//        make.bottom.equalTo(ws.view);
//    }];
    //self.tableView.contentInset =UIEdgeInsetsMake(0, 0, 49, 0);
    //[self.tableView setContentOffset:CGPointMake(0, -64)];
    
    self.tableView.tableHeaderView=self.searchBar;
    self.tableView.separatorStyle = NO;
    
    DDFixedGroupAPI *getFixgroup = [DDFixedGroupAPI new];
    [getFixgroup requestWithObject:nil Completion:^(NSArray *response, NSError *error) {
        
        [response enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop){
            NSLog(@"---obj == %@",obj);
            
            NSString *groupID = [MTTUtil changeOriginalToLocalID:(UInt32)[obj[@"groupid"] integerValue] SessionType:SessionTypeSessionTypeGroup];
            NSInteger version = [obj[@"version"] integerValue];
            MTTGroupEntity *group = [[DDGroupModule instance] getGroupByGId:groupID];
            if (group) {
                if (group.objectVersion == version) {
                    [self.groups addObject:group];
                }else{
                    [[DDGroupModule instance] getGroupInfogroupID:groupID completion:^(MTTGroupEntity *group) {
                        [self.groups addObject:group];
                        
                    }];
                }
            }else{
                [[DDGroupModule instance] getGroupInfogroupID:groupID completion:^(MTTGroupEntity *group) {
                    [self.groups addObject:group];
                }];
            }
            
        }];
        [self.tableView reloadData];
    }];
    self.department = [self.model sortByDepartment];
    //[self swichContactsToALl];
    
    [self.tableView registerClass:[AddFriendCell class] forCellReuseIdentifier:@"cell"];
    
    
    // 右侧索引颜色透明
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor=RGB(102, 102, 102);
    self.allIndexes = [NSArray new];
    self.departmentIndexes = [NSArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 初始化searchTableView
    [self addSearchTableView];
}

-(void)add
{
    SearchUserViewController *addfriend = [[SearchUserViewController alloc] init];
    [self pushViewController:addfriend animated:YES];
}

-(void)addSearchTableView
{
    self.searchTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 109, SCREEN_WIDTH, SCREEN_HEIGHT-109)];
    [self.view addSubview:self.searchTableView];
    [self.searchTableView setHidden:YES];
    [self.searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.searchTableView setBackgroundColor:TTBG];
    self.searchContent = [SearchContentViewController new];
    self.searchContent.viewController=self;
    if(self.isFromAt){
        self.searchContent.searchType = MTTSearchUser;
        self.searchContent.isFromAt = self.isFromAt;
        MTT_WEAKSELF(ws);
        self.searchContent.selectUser =^(MTTUserEntity *user){
            ws.selectUser(user);
            [ws.navigationController popViewControllerAnimated:YES];
            return;
//            NSString *atName = [NSString stringWithFormat:@"@%@ ",user.nick];
//            text = [text stringByReplacingCharactersInRange:range withString:atName];
//            [self.chatInputView.textView setText:text];
        };
    }
    self.searchTableView.delegate = self.searchContent.delegate;
    self.searchTableView.dataSource = self.searchContent.dataSource;
    
    MTT_WEAKSELF(ws);
    self.searchContent.didScrollViewScrolled = ^(){
        [ws.view endEditing:YES];
        [ws enableControlsInView:ws.searchBar];
    };
    
    self.searchPlaceholderView = [[UIView alloc]initWithFrame:CGRectMake(0, 109, SCREEN_WIDTH, SCREEN_HEIGHT-109)];
    [self.view addSubview:self.searchPlaceholderView];
    [self.searchPlaceholderView setHidden:YES];
    [self.searchPlaceholderView setBackgroundColor:[UIColor whiteColor]];
    
    // 点击取消
    self.searchPlaceholderView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endSearch)];
    [self.searchPlaceholderView addGestureRecognizer:tapGesture];
    
    // 添加其他元素
    UILabel *searchMore = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, SCREEN_WIDTH, 20)];
    [self.searchPlaceholderView addSubview:searchMore];
    [searchMore setTextAlignment:NSTextAlignmentCenter];
    [searchMore setText:@"搜索更多内容"];
    [searchMore setFont:systemFont(20)];
    [searchMore setTextColor:RGB(129, 129, 131)];
    
    UILabel *searchMoreLine = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, 95, 200, 0.5)];
    [self.searchPlaceholderView addSubview:searchMoreLine];
    [searchMoreLine setBackgroundColor:RGB(230, 230, 232)];
    
    UIView *searchMoreContent = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, 110, 200, 50)];
    [self.searchPlaceholderView addSubview:searchMoreContent];
    
    UIImageView *searchUser = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [searchUser setImage:[UIImage imageNamed:@"search_user"]];
    [searchMoreContent addSubview:searchUser];
    
    UILabel *searchUserLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 35, 25, 25)];
    [searchUserLabel setText:@"用户"];
    [searchUserLabel setTextColor:RGB(170, 170, 171)];
    [searchUserLabel setFont:systemFont(12)];
    [searchUserLabel setTextAlignment:NSTextAlignmentCenter];
    [searchMoreContent addSubview:searchUserLabel];
    
    UIImageView *searchGroup = [[UIImageView alloc]initWithFrame:CGRectMake(25+33, 0, 25, 25)];
    [searchGroup setImage:[UIImage imageNamed:@"search_group"]];
    [searchMoreContent addSubview:searchGroup];
    
    UILabel *searchGroupLabel = [[UILabel alloc]initWithFrame:CGRectMake(25+33, 35, 25, 25)];
    [searchGroupLabel setText:@"群组"];
    [searchGroupLabel setTextColor:RGB(170, 170, 171)];
    [searchGroupLabel setFont:systemFont(12)];
    [searchGroupLabel setTextAlignment:NSTextAlignmentCenter];
    [searchMoreContent addSubview:searchGroupLabel];
    
    UIImageView *searchDepartment = [[UIImageView alloc]initWithFrame:CGRectMake((25+33)*2, 0, 25, 25)];
    [searchDepartment setImage:[UIImage imageNamed:@"search_department"]];
    [searchMoreContent addSubview:searchDepartment];
    
    UILabel *searchDepartmentLabel = [[UILabel alloc]initWithFrame:CGRectMake((25+33)*2, 35, 25, 25)];
    [searchDepartmentLabel setText:@"部门"];
    [searchDepartmentLabel setTextColor:RGB(170, 170, 171)];
    [searchDepartmentLabel setFont:systemFont(12)];
    [searchDepartmentLabel setTextAlignment:NSTextAlignmentCenter];
    [searchMoreContent addSubview:searchDepartmentLabel];
    
    UIImageView *searchChat = [[UIImageView alloc]initWithFrame:CGRectMake((25+33)*3, 0, 25, 25)];
    [searchChat setImage:[UIImage imageNamed:@"search_chat"]];
    [searchMoreContent addSubview:searchChat];
    
    UILabel *searchChatLabel = [[UILabel alloc]initWithFrame:CGRectMake((25+33)*3, 35, 25, 25)];
    [searchChatLabel setText:@"聊天"];
    [searchChatLabel setTextColor:RGB(170, 170, 171)];
    [searchChatLabel setFont:systemFont(12)];
    [searchChatLabel setTextAlignment:NSTextAlignmentCenter];
    [searchMoreContent addSubview:searchChatLabel];
}


- (void)endSearch{
    // 原tableview允许滚动
    self.tableView.scrollEnabled = YES;
    self.searchBar.text = @"";
    [self.searchPlaceholderView setHidden:YES];
    [self.searchTableView setHidden:YES];
    // 显示tabbar
    self.tabBarController.tabBar.hidden = NO;
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void)enableControlsInView:(UIView *)view
{
    for (id subview in view.subviews) {
        if ([subview isKindOfClass:[UIControl class]]) {
            [subview setEnabled:YES];
        }
        [self enableControlsInView:subview];
    }
}

-(void)appBecomeActive{
    
    //self.tableView.contentInset =UIEdgeInsetsMake(64, 0, 49, 0);
}

-(void)scrollToTitle:(NSNotification *)notification
{
    NSString *string = [notification object];
    self.searchKey=string;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    [self swichContactsToALl];
    

    
    [[AddFriendModule instance]onlyGetRecentAddFriendMsgCount:^(NSUInteger count) {
        
        [self setToolbarBadge:count];
        self.unReadCount=count;
              //[self setCellbarBadge:count];
        
        self.aCount=count;
    
        [self.tableView reloadData];
 
        
    }];
    

    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    
    //self.title=@"联系人";
    
    //self.navigationItem.titleView = self.segmentedControl;
     [self setupNavTitleView];
        self.navigationItem.title = @"";
    
    if (self.searchKey) {
        [self.segmentedControl setSelectedSegmentIndex:1];
        self.selectIndex=1;
        [self swichToShowDepartment];
        if ([self.allKeys count]) {
            NSInteger location = [self.allKeys indexOfObject:self.searchKey];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:location] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
        return;
    }
}
- (void)setupNavTitleView
{
    CGFloat width = 60 * 2 + 10 * 1;
    CGFloat x = (self.navigationController.navigationBar.bounds.size.width - width) * 0.5;
    UIView *navTitleView = [[UIView alloc] initWithFrame:CGRectMake(x, 0, width, 44)];
   self.navTitleView = navTitleView;
    
    [self setupNavTitleViewBtn:navTitleView];

    
    [self.navigationController.navigationBar addSubview:navTitleView];
}
- (void)setupNavTitleViewBtn:(UIView *)titlView
{
    CGFloat btnWidth = 60;
    CGFloat margin = 10;
    
    NSArray *btnTitle = @[@"好友", @"关注"];
    for (NSInteger i = 0; i < btnTitle.count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i * (btnWidth + margin), 0, btnWidth, 40);
        btn.tag = i+1;
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [btn setTitle:btnTitle[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(navTitleViewBtnClicks:) forControlEvents:UIControlEventTouchUpInside];
        
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
    
    UIButton *btn = self.navTitleView.subviews[self.nowPage];
    NSString *title = btn.titleLabel.text;
    
    
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: btn.titleLabel.font}];
    
    
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((btn.frame.size.width - size.width) * 0.5, CGRectGetMaxY(btn.frame), size.width, 2)];
    lineView.backgroundColor = btn.titleLabel.textColor;
    
    
    self.lineView = lineView;
    
    CGRect tempFrame = self.lineView.frame;
    tempFrame.size.width = size.width;
    
    CGPoint center = self.lineView.center;
    center.x = btn.center.x;
    self.lineView.center = center;
    
    [self.navTitleView addSubview:self.lineView];
}
- (void)navTitleViewBtnClicks:(UIButton *)titleBtn
{
    self.preveBtn.selected = NO;
    titleBtn.selected = YES;
    self.preveBtn = titleBtn;
    
    self.nowPage=titleBtn.tag;
    CGSize size = [titleBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: titleBtn.titleLabel.font}];
    [UIView animateWithDuration:0.25 animations:^{
        // 下划线
        CGRect tempFrame = self.lineView.frame;
        tempFrame.size.width = size.width;
        
        CGPoint center = self.lineView.center;
        center.x = titleBtn.center.x;
        self.lineView.center = center;
        
        NSInteger off=titleBtn.tag-1;
        
        
        self.myScrollview.contentOffset=CGPointMake(self.view.frame.size.width*off, -64);
        self.myScrollview.backgroundColor=[UIColor whiteColor];
        
                
    } completion:^(BOOL finished) {
       
     
    }];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
 
   [self.navTitleView removeFromSuperview];



}
-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
}

-(void)swichContactsToALl
{
    [self.items removeAllObjects];
    [self.attentionItems removeAllObjects];
    self.departmentIndexes =[self.department allKeys];
    self.allIndexes =[self.items allKeys];
    self.items = [self.model sortByContactPy];
    self.attentionItems=[self.model sortByAttentionPy];
    
    //NSLog(@"--- items == %@",self.items);
    [self.tableView reloadData];
    [self.attentionTableView reloadData];
}
-(void)swichToShowDepartment
{
    // [self.items removeAllObjects];
    //self.items = [self.model sortByDepartment];
    [self.tableView reloadData];
}
-(NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    if ([tableView isEqual:self.tableView]) {
        

    NSMutableArray* array = [[NSMutableArray alloc] init];
    if (self.selectIndex == 1) {
        [[self allKeys] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
            
            char firstLetter = [MTTUtil getFirstChar:obj];
            NSString *fl = [[NSString stringWithFormat:@"%c",firstLetter] uppercaseString];
            if(![array containsObject:fl]){
                [array addObject:fl];
            }
        }];
    }
    else
    {
        NSArray* allKeys = [self allKeys];
        [allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [array addObject:[obj uppercaseString]];
        }];
    }
    return array ;
            }else
            {
                 NSMutableArray* array = [[NSMutableArray alloc] init];
                NSArray* allKeys = [self allAttentionKeys];
                [allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [array addObject:[obj uppercaseString]];
                }];
                
                return array;
            
            
            }
}
-(void)segmentSelect:(UISegmentedControl *)sender
{
    NSInteger index = sender.selectedSegmentIndex;
    switch (index) {
        case 0:
            self.selectIndex=0;
            [self swichContactsToALl];
            break;
        case 1:
            self.selectIndex=1;
            [self swichToShowDepartment];
        default:
            break;
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(NSArray*)allKeys{
    if (self.selectIndex == 1) {
        if ([self.departmentIndexes count]) {
            return self.departmentIndexes;
        }else{
            self.departmentIndexes =[[self.department allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                char char1 = [MTTUtil getFirstChar:obj1];
                NSString *fl1 = [[NSString stringWithFormat:@"%c",char1] uppercaseString];
                char char2 = [MTTUtil getFirstChar:obj2];
                NSString *fl2 = [[NSString stringWithFormat:@"%c",char2] uppercaseString];
                return [fl1 compare:fl2];
            }];
            return  self.departmentIndexes;
        }
        
    }else{
        if ([self.allIndexes count]) {
            return self.allIndexes;
        }else{
           
            self.allIndexes =[[self.items allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                char char1 = [MTTUtil getFirstChar:obj1];
                NSString *fl1 = [[NSString stringWithFormat:@"%c",char1] uppercaseString];
                char char2 = [MTTUtil getFirstChar:obj2];
                NSString *fl2 = [[NSString stringWithFormat:@"%c",char2] uppercaseString];
                return [fl1 compare:fl2];
            }];
            return self.allIndexes;
        }
    }
}
-(NSArray*)allAttentionKeys{
    
    NSArray *array;
    
            array =[[self.attentionItems allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                char char1 = [MTTUtil getFirstChar:obj1];
                NSString *fl1 = [[NSString stringWithFormat:@"%c",char1] uppercaseString];
                char char2 = [MTTUtil getFirstChar:obj2];
                NSString *fl2 = [[NSString stringWithFormat:@"%c",char2] uppercaseString];
                return [fl1 compare:fl2];
            }];
            return array;
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([tableView isEqual:self.tableView]){
    
    if (self.selectIndex == 0) {
        return [[self.items allKeys] count]+1+1;
    }else{
        return [[self.department allKeys] count];
    }
    }else{
    
    
        
        return [[self.attentionItems allKeys] count];
        
    
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([tableView isEqual:self.tableView]) {
        
   
    
    if (self.selectIndex == 0) {
        
        if (section==0) {
            return  1;
        }
        if (section == 1) {
            return [self.groups count];
        }
        else
        {
            NSString *keyStr = [self allKeys][(NSUInteger) (section - 2)];
            NSArray *arr = (self.items)[keyStr];
            return [arr count];
            
        }
    }else{
        return 0;
//        NSString *keyStr = [self allKeys][(NSUInteger) (section)];
//        NSArray *arr = (self.department)[keyStr];
//        return [arr count];
    }
      }else
      {
          
         
         
          
              
                  NSString *keyStr = [self allAttentionKeys][(NSUInteger) section];
                  NSArray *arr = (self.attentionItems)[keyStr];
             
                  return [arr count];
       
        
          
          
          
      }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if ([tableView isEqual:self.tableView]) {
        
        if(self.selectIndex == 0 && section == 0){
            return 0;
        }
        return 22;
    }else{
        return 22;
    
    }
  
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *text;
    
    
    if ([tableView isEqual:self.tableView]) {
        
    
    
    
    if (self.selectIndex == 0) {
        if (section==0) {
            
        }
        else if (section == 1) {
            text = @"";
        }else{
            text = [self.allKeys[section - 2] uppercaseString];
        }
    }else
    {
        text = [self.allKeys[section] uppercaseString];
        if(text.length == 0){
            text = @"神奇账号";
        }
    }
    UIView *sectionHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 22)];
    [sectionHeadView setBackgroundColor:RGB(240, 240, 245)];
    UILabel *sectionHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4.5, SCREEN_WIDTH, 13)];
    [sectionHeaderLabel setText:text];
    [sectionHeaderLabel setTextColor:RGB(144,144, 148)];
    [sectionHeaderLabel setFont:systemFont(13)];
    [sectionHeadView addSubview:sectionHeaderLabel];
    return sectionHeadView;
       }else
       {
           
           
                   text = [self.allAttentionKeys[section] uppercaseString];
                   
           
                      UIView *sectionHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 22)];
           [sectionHeadView setBackgroundColor:RGB(240, 240, 245)];
           UILabel *sectionHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4.5, SCREEN_WIDTH, 13)];
           [sectionHeaderLabel setText:text];
           [sectionHeaderLabel setTextColor:RGB(144,144, 148)];
           [sectionHeaderLabel setFont:systemFont(13)];
           [sectionHeadView addSubview:sectionHeaderLabel];
           return sectionHeadView;
           
           
           
       
       
       
       
       }
        
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    if ([tableView isEqual:self.tableView]) {
        
    
    
    NSInteger count;
    if (self.selectIndex == 0) {
        count = 1;
    }else{
        count = 0;
    }
    for(NSString *character in [self allKeys]){
        char firstLetter = [MTTUtil getFirstChar:character];
        NSString *fl = [[NSString stringWithFormat:@"%c",firstLetter] uppercaseString];
        if([fl isEqualToString:title]){
            return count;
        }
        count ++;
    }
    return 1;
        }
    else{
    
    
    
        return  [self allAttentionKeys].count;
    
    
    
    
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"contactsCell";
    
    static NSString *cellIdentifier2 = @"attendionsCell";
    
    if ([tableView isEqual:self.tableView]) {
        
  
    
    DDContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    if (cell == nil) {
        cell = [[DDContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (self.selectIndex == 0) {
        if (indexPath.section == 0) {
            
            AddFriendCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
            
            [cell refresh:self.aCount andIsClean:self.isClean];
            return cell;
            
        }
        
        else if (indexPath.section == 1) {
            
            MTTGroupEntity *group = [self.groups objectAtIndex:indexPath.row];
            [cell setCellContent:nil Name:group.name];
            [cell setGroupAvatar:group];
        }
        else
        {
            NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section-2];
            NSArray *userArray =[self.items objectForKey:keyStr];
            MTTUserEntity *user = [userArray objectAtIndex:indexPath.row];
            
            
            [cell setCellContent:[user getAvatarUrl] Name:user.nick];
        }
    }
        
        return cell;
    }else{
    
    
    
        DDContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2 ];
        if (cell == nil) {
            cell = [[DDContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (self.selectIndex == 0) {
           
                NSString *keyStr = [[self allAttentionKeys] objectAtIndex:indexPath.section];
                NSArray *userArray =[self.attentionItems objectForKey:keyStr];
            
                MTTUserEntity *user = [userArray objectAtIndex:indexPath.row];
                
                
                [cell setCellContent:[user getAvatarUrl] Name:user.nick];
            
        }
        
        
        
        
        
        return cell;
    
    
    }
        
//    else
//    {
//        NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section];
//        NSArray *userArray =[self.department objectForKey:keyStr];
//        MTTUserEntity *user = [userArray objectAtIndex:indexPath.row];
//        [cell setCellContent:[user getAvatarUrl] Name:user.nick];
//    }
    
    
        
        
        
}

-(IBAction)showActions:(id)sender
{
}

-(void)callNum:(MTTUserEntity *)user
{
    if (user == nil) {
        return;
    }
    NSString *string = [NSString stringWithFormat:@"tel:%@",user.telphone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}
-(void)sendEmail:(MTTUserEntity *)user
{
    if (user == nil) {
        return;
    }
    NSString *string = [NSString stringWithFormat:@"mailto:%@",user.email];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}
-(void)chatTo:(MTTUserEntity *)user
{
    if (user == nil) {
        return;
    }
    MTTSessionEntity* session = [[MTTSessionEntity alloc] initWithSessionID:user.objID type:SessionTypeSessionTypeSingle];
    [session setSessionName:user.nick];
    [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
    [self pushViewController:[ChattingMainViewController shareInstance] animated:YES];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tools.isShow) {
        [self.tools hiddenSelf];
        
    }
    if ([scrollView isEqual:self.myScrollview]) {
        
        
        if (scrollView.contentOffset.x==0) {
            
            self.nowPage=0;
         UIButton *titleBtn = self.navTitleView.subviews[0];
            if (!titleBtn) {
                return;
            }
            self.preveBtn.selected = NO;
            titleBtn.selected = YES;
            self.preveBtn = titleBtn;
            
            CGSize size = [titleBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: titleBtn.titleLabel.font}];
            [UIView animateWithDuration:0.25 animations:^{
                // 下划线
                CGRect tempFrame = self.lineView.frame;
                tempFrame.size.width = size.width;
                
                CGPoint center = self.lineView.center;
                center.x = titleBtn.center.x;
                self.lineView.center = center;
            }];
        }
        if (scrollView.contentOffset.x==self.view.frame.size.width) {
            
            self.nowPage=1;
            UIButton *titleBtn = self.navTitleView.subviews[1];
            
            if (!titleBtn) {
                return;
            }
            
            self.preveBtn.selected = NO;
            titleBtn.selected = YES;
            self.preveBtn = titleBtn;
            
            CGSize size = [titleBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: titleBtn.titleLabel.font}];
            [UIView animateWithDuration:0.25 animations:^{
                // 下划线
                CGRect tempFrame = self.lineView.frame;
                tempFrame.size.width = size.width;
                
                CGPoint center = self.lineView.center;
                center.x = titleBtn.center.x;
                self.lineView.center = center;
            }];

            
            
            
        }

        
    }
    
 
    
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if ([tableView isEqual:self.tableView]) {
        
  
    
    
    if (self.tools.isShow) {
        [self.tools hiddenSelf];
        return;
    }
    if (self.selectIndex == 0) {
        
        if (indexPath.section==0) {
         
            
            AddFriendMsgViewController *add=[AddFriendMsgViewController instance];
            
            [AddFriendModule instance].reciverMsgCount=0;
            ReadAddFriendAPI *API=[[ReadAddFriendAPI alloc]init];
            [API requestWithObject:nil Completion:^(id response, NSError *error) {
                
            }];
          
              self.aCount=0;
            self.isClean=YES;
            [self.tableView reloadData];
            
              [self pushViewController:add animated:NO];
            
            
         return;
        }
        
        
        else if (indexPath.section == 1) {
            if(self.isFromAt){
                return;
            }
            MTTGroupEntity *group = [self.groups objectAtIndex:indexPath.row];
            MTTSessionEntity *session = [[MTTSessionEntity alloc] initWithSessionID:group.objID type:SessionTypeSessionTypeGroup];
            [session setSessionName:group.name];
            ChattingMainViewController *main = [ChattingMainViewController shareInstance];
            [main showChattingContentForSession:session];
            [self pushViewController:main animated:YES];
            return;
        }
        NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section-2];
        NSArray *userArray =[self.items objectForKey:keyStr];
        MTTUserEntity *user;
        user = [userArray objectAtIndex:indexPath.row];
        
        if (self.selectUser && self.isFromAt) {
            self.selectUser(user);
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        PublicProfileViewControll *public = [PublicProfileViewControll new];
        public.user=user;
        
        [self pushViewController:public animated:YES];
    }else
    {
        NSString *keyStr = [[self allKeys] objectAtIndex:indexPath.section];
        NSArray *userArray =[self.department objectForKey:keyStr];
        MTTUserEntity *user;
        user = [userArray objectAtIndex:indexPath.row];
        if (self.selectUser && self.isFromAt) {
            self.selectUser(user);
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        PublicProfileViewControll *public = [PublicProfileViewControll new];
        public.user=user;
        
        [self pushViewController:public animated:YES];
        
    }
        
    }else{
    
    
    
    
        NSString *keyStr = [[self allAttentionKeys] objectAtIndex:indexPath.section];
        NSArray *userArray =[self.attentionItems objectForKey:keyStr];
        MTTUserEntity *user;
        user = [userArray objectAtIndex:indexPath.row];
        
//        if (self.selectUser && self.isFromAt) {
//            self.selectUser(user);
//            [self.navigationController popViewControllerAnimated:YES];
//            return;
//        }
        
        PublicProfileViewControll *public = [PublicProfileViewControll new];
        public.user=user;
        public.isFromAttention=YES;
        [self pushViewController:public animated:YES];
        
        
        
    
    
    
    
    
    
    
    }
}

-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSString* nick = [RuntimeStatus instance].user.nick;
    NSDictionary *dict = @{@"nick" : nick};
    self.searchContent.searchKey = searchBar.text;
    // 原tableview不允许滚动
    self.tableView.scrollEnabled = NO;
    if(searchBar.text.length){
        [self enableControlsInView:searchBar];
        // 显示空白view
        [self.searchPlaceholderView setHidden:YES];
        // 隐藏tabbar
        self.tabBarController.tabBar.hidden = YES;
    }else{
        // 显示取消按钮
        [self.searchBar setShowsCancelButton:YES animated:YES];
        // 显示空白view
        [self.searchPlaceholderView setHidden:NO];
        // 隐藏tabbar
        self.tabBarController.tabBar.hidden = YES;
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self endSearch];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length){
        [self.searchPlaceholderView setHidden:YES];
        [self.searchTableView setHidden:NO];
        MTT_WEAKSELF(ws);
        
        [self.searchContent searchTextDidChanged:searchText Block:^(bool done) {
            [ws.searchTableView reloadData];
        }];
    }else{
        [self.searchPlaceholderView setHidden:NO];
        [self.searchTableView setHidden:YES];
    }
}
-(void)setToolbarBadge:(NSUInteger)count
{
    if (count !=0) {
        if (count > 99)
        {
            [self.tabBarItem setBadgeValue:@"99+"];
        }
        else
        {
            [self.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%ld",(unsigned long)count]];
        }
    }else
    {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [self.tabBarItem setBadgeValue:nil];
    }
}
-(void)setCellbarBadge:(NSUInteger)a
{

   
    
  




}
-(void)setToolAndCellbarBadge:(NSInteger)count
{
    
    
    [self setToolbarBadge:count+self.unReadCount];
    
    //[self setCellbarBadge:count+self.unReadCount];
    self.aCount=count+self.unReadCount;
    self.isClean=NO;
    [self.tableView reloadData];
}

@end
