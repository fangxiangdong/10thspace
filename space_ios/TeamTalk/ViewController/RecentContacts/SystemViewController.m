//
//  SystemViewController.m
//  TeamTalk
//
//  Created by landu on 15/11/30.
//  Copyright © 2015年 IM. All rights reserved.
//

#import "SystemViewController.h"

#import "SystemTableViewCell.h"
#import "MsgReadACKAPI.h"
#import "DDUserModule.h"
#import "LoginModule.h"
#import "DDAllUserAPI.h"
#import "SpellLibrary.h"
#import "MBProgressHUD.h"

@interface SystemViewController ()<UITableViewDataSource,UITableViewDelegate,AgreeAddFriendDelegate>
{
    UITableView *_tbView;
    BOOL isFriend;
}
@end

@implementation SystemViewController

-(void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.module.MTTSessionEntity = self.session;
    
    if (self.session.unReadMsgCount !=0 ) {

        MsgReadACKAPI* readACK = [[MsgReadACKAPI alloc] init];
        if(self.module.MTTSessionEntity.sessionID){
            [readACK requestWithObject:@[self.module.MTTSessionEntity.sessionID,@(self.module.MTTSessionEntity.lastMsgID),@(self.module.MTTSessionEntity.sessionType)] Completion:nil];
            self.module.MTTSessionEntity.unReadMsgCount=0;
            [[MTTDatabaseUtil instance] updateRecentSession:self.module.MTTSessionEntity completion:^(NSError *error) {
                
            }];
        }
    }
    
    self.title = @"系统消息";
    isFriend = [[DDUserModule shareInstance] isFriend:[self.session.sessionID stringByReplacingOccurrencesOfString:@"system_" withString:@"user_"]];

    
    _tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tbView.dataSource = self;
    _tbView.delegate = self;
    [self.view addSubview:_tbView];
    
    
}


- (ChattingModule*)module
{
    if (!_module)
    {
        _module = [[ChattingModule alloc] init];
    }
    return _module;
}

#pragma mark - UITbableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    
    SystemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[SystemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    [cell setSession:self.session isFriend:isFriend];
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

#pragma makr - AgreeAddFriendDelegate
-(void)agreeAdd
{
//    if(isFriend){
//        return;
//    }
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:YES];
    HUD.dimBackground = YES;
    HUD.labelText = @"Loading";
    
    
//    AgreeAddFriendAPi *agree = [[AgreeAddFriendAPi alloc] init];
//    NSString *friendID = [self.session.sessionID stringByReplacingOccurrencesOfString:@"system_" withString:@""];
//    
//    [agree requestWithObject:friendID Completion:^(id response, NSError *error) {
//
//        [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            
//            if(obj){
//                NSLog(@"success");
//
//                
//                
////                DDAllUserAPI* api = [[DDAllUserAPI alloc] init];
////                [api requestWithObject:@[@"0"] Completion:^(id response, NSError *error) {
////                
////                
////                }];
//                
//                
//                //加载所有人信息，创建检索拼音
//                [[LoginModule instance] p_loadAllUsersCompletion:^{
//                    
//                    if ([[SpellLibrary instance] isEmpty]) {
//                        
//                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                            [[[DDUserModule shareInstance] getAllMaintanceUser] enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
//                                [[SpellLibrary instance] addSpellForObject:obj];
//                                [[SpellLibrary instance] addDeparmentSpellForObject:obj];
//                                
//                            }];
//                        });
//                    }
//                }];
//                
//                
//                [HUD removeFromSuperview];
//                isFriend = YES;
//                [_tbView reloadData];
//            }
//        }];
//        
//    }];
    
    
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
