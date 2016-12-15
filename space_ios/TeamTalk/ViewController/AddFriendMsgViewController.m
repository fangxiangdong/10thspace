//
//  AddFriendMsgViewController.m
//  TeamTalk
//
//  Created by mac on 16/11/18.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "AddFriendMsgViewController.h"
#import "AddFriendDetailCell.h"
#import "AddFriendModule.h"
#import "LoginModule.h"
#import "SpellLibrary.h"
#import "SpellLibrary.h"
#import "MTTDatabaseUtil.h"
#import "DDUserModule.h"
#import "DDAgreeAddFriendAPI.h"
#import "ReadAddFriendAPI.h"
@interface AddFriendMsgViewController ()<AddFriendModuleDelegate,AddFriendDetailCellDelegate>
@property(nonatomic,strong)UITableView*tableView;
@end

@implementation AddFriendMsgViewController

+ (instancetype)instance
{
    static AddFriendMsgViewController* module;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        module = [[AddFriendMsgViewController alloc] init];
        
    });
    return module;
    
    
}

-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    
    
    [[MTTDatabaseUtil instance]getAddFriendMsg:^(NSArray *contacts, NSError *error) {
        
        self.dataArray =[[NSMutableArray alloc]initWithArray:contacts];
        [self.tableView reloadData];
        
        
    }];


   

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [AddFriendModule instance].delegate=self;
    self.tableView=[[UITableView alloc]initWithFrame: self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[AddFriendDetailCell class] forCellReuseIdentifier:@"cell"];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.tableView setTableFooterView:v];
    
    // Do any additional setup after loading the view.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{


    return self.dataArray.count;

}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    AddFriendDetailCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.delegate=self;
    [cell refresh:self.dataArray[indexPath.row]andIndex:indexPath.row];
    
    return cell;
    
    
    
    
    
}
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSMutableArray *)dataArray
{

    if (_dataArray==nil) {
        _dataArray=[[NSMutableArray alloc]init];
    }
    return _dataArray;

}

-(void)addFriendUnreadMsgUpdate:(NSArray*)array
{
   
    for (AddFriendMSGModel*model in array) {
        
        [self.dataArray addObject:model];
    }
    [self.tableView reloadData];






}


- (void)AddFriendModuleUpdate:(AddFriendMSGModel*)model
{

   
    if (![self contain:model]) {
        [self.dataArray insertObject:model atIndex:0];

        [self.tableView reloadData];

    }




}

-(BOOL)contain:(AddFriendMSGModel*)model
{

    for (AddFriendMSGModel* modelInArray in self.dataArray) {

        if (modelInArray.userId==model.userId) {
            return YES;
        }

    }

    return NO;



}

-(void)AddFriendDetailCellDelegate:(BOOL)agree andIndex:(NSInteger)index
{

    int friend=((AddFriendMSGModel *)self.dataArray[index]).userId;
    
    DDAgreeAddFriendAPI *daAPI=[[DDAgreeAddFriendAPI  alloc]init];
    
    NSString *friendstring= [NSString stringWithFormat:@"%d",friend];
     NSString *agreestring= [NSString stringWithFormat:@"%d",agree];
    NSDictionary *dict=@{@"agree":agreestring,@"friend":friendstring};
    
    if (agree) {
        [daAPI  requestWithObject:dict Completion:^(id response, NSError *error) {
            
            [response enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *resultcode = [NSString stringWithFormat:@"%@",obj];
                
                
                    AddFriendMSGModel *model=self.dataArray[index];
                
                
                    model.isAgree=1;
                
                if([resultcode isEqualToString:@"0"]){
                    
                    [[MTTDatabaseUtil instance]insertAlladdFriendMsg:@[model] completion:^(NSError *error) {
                        
                    }];

                    
                    [self.dataArray replaceObjectAtIndex:index withObject:model];
                    
                    [self.tableView reloadData];
                    
                    [[LoginModule instance] p_loadAllUsersCompletion:^{
                        
                        if ([[SpellLibrary instance] isEmpty]) {
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [[[DDUserModule shareInstance] getAllMaintanceUser] enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                                    [[SpellLibrary instance] addSpellForObject:obj];
                                    [[SpellLibrary instance] addDeparmentSpellForObject:obj];
                                    
                                }];
                            });
                        }
                    }];
                    
                    
                    
                }else{
                    
                }
                
            }];
        }];

    }
    
    
    
    
    
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
