//
//  SearchUserViewController.m
//  TeamTalk
//
//  Created by landu on 15/11/12.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "SearchUserViewController.h"
#import "Masonry.h"
#import "IMBuddy.pb.h"
#import "DDDataOutputStream.h"
#import "SearchUserAPI.h"
#import "DDContactsCell.h"
#import "MTTUserEntity.h"
#import "AddFriendViewController.h"

@interface SearchUserViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    NSMutableArray *dataArray;
}
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UISearchBar *searchBar;
@end

@implementation SearchUserViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        
        self.title = @"搜索好友";
        dataArray = [NSMutableArray array];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, FULL_WIDTH, 44)];
    [self.searchBar setPlaceholder:@"搜索"];
    self.searchBar.searchBarStyle = UIBarStyleDefault;
    self.searchBar.barTintColor = TTBG;
    self.searchBar.layer.borderWidth = 0.5;
    self.searchBar.layer.borderColor = RGB(204, 204, 204).CGColor;
    self.searchBar.delegate=self;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    
    MTT_WEAKSELF(ws);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.view);
        make.top.equalTo(ws.view);
        make.right.equalTo(ws.view);
        make.bottom.equalTo(ws.view);
    }];
    self.tableView.contentInset =UIEdgeInsetsMake(0, 0, 20, 0);
    //[self.tableView setContentOffset:CGPointMake(0, -64)];
    
    self.tableView.tableHeaderView=self.searchBar;
    //self.tableView.separatorStyle = NO;
    
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    DDContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[DDContactsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    MTTUserEntity *user;
    if(indexPath.row < dataArray.count){
        user = [dataArray objectAtIndex:indexPath.row];
        [cell setCellContent:[user getAvatarUrl] Name:user.nick];
    }

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    MTTUserEntity *user;
    if(indexPath.row < dataArray.count){
        user = [dataArray objectAtIndex:indexPath.row];
        AddFriendViewController *add = [AddFriendViewController new];
        add.user=user;
        NSLog(@"--- add.user == %@",add.user);
        [self pushViewController:add animated:YES];
    }
}

#pragma mark - UISearchbarDelegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [dataArray removeAllObjects];
    
    SearchUserAPI *searchUser = [[SearchUserAPI alloc] init];
    
    [searchUser requestWithObject:_searchBar.text Completion:^(id response, NSError *error) {
        
        [response enumerateObjectsUsingBlock:^(NSArray* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop){
            
            [dataArray addObjectsFromArray:obj];
        }];
        
        [self.tableView reloadData];
    }];
    
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self endSearch];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)endSearch{
    // 原tableview允许滚动
    self.tableView.scrollEnabled = YES;
    self.searchBar.text = @"";
    
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
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
