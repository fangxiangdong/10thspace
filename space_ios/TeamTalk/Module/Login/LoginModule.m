//
//  DDLoginManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2015年 IM All rights reserved.
//

#import "LoginModule.h"
#import "DDHttpServer.h"
#import "DDMsgServer.h"
#import "DDTcpServer.h"
#import "SpellLibrary.h"
#import "DDUserModule.h"
#import "MTTUserEntity.h"
#import "DDClientState.h"
#import "RuntimeStatus.h"
#import "ContactsModule.h"
#import "MTTDatabaseUtil.h"
#import "DDAllUserAPI.h"
#import "LoginAPI.h"
#import "MTTNotification.h"
#import "SessionModule.h"
#import "DDGroupModule.h"
#import "MTTUtil.h"
#import "LoginModule.h"
#import "AddFriendModule.h"
#import "AddFriendMsgViewController.h"
#import "AFNetworking.h"
@interface LoginModule(privateAPI)

- (void)p_loadAfterHttpServerWithToken:(NSString*)token userID:(NSString*)userID dao:(NSString*)dao password:(NSString*)password uname:(NSString*)uname success:(void(^)(MTTUserEntity* loginedUser))success failure:(void(^)(NSString* error))failure;
// 重新登录
- (void)reloginAllFlowSuccess:(void(^)())success failure:(void(^)())failure;
@property(nonatomic,strong)NSDictionary*dict;
@property(nonatomic,strong)NSDictionary*theLastPassDict;
@property(nonatomic,copy)NSString*theLastUserName;
@end

@implementation LoginModule
{
    NSString* _lastLoginUser;       //最后登录的用户ID
    NSString* _lastLoginPassword;
    NSString* _lastLoginUserName;
    NSString* _dao;
    NSString * _priorIP;
    NSInteger _port;
    
    NSDictionary*_dict;
    NSDictionary* _theLastPassDict;
    NSString*_theLastUserName;
    BOOL _relogining;
}

+ (instancetype)instance
{
    static LoginModule *g_LoginManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_LoginManager = [[LoginModule alloc] init];
    });
    return g_LoginManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _httpServer = [[DDHttpServer alloc] init];
        _msgServer = [[DDMsgServer alloc] init];
        _tcpServer = [[DDTcpServer alloc] init];
        _relogining = NO;
    }
    return self;
}

#pragma mark Public API

- (void)loginWithUsername:(NSString*)name password:(NSDictionary*)password andDict:(NSDictionary *)dic success:(void(^)(MTTUserEntity* loginedUser))success  failure:(void (^)(NSString *))failure
{
//    NSLog(@"token--%@", name);
        NSInteger code  = [[dic objectForKey:@"code"] integerValue];
        if (code == 0) {
            _priorIP = [dic objectForKey:@"priorIP"];
            _port    =  [[dic objectForKey:@"port"] integerValue];
            [MTTUtil setMsfsUrl:[dic objectForKey:@"msfsPrior"]];
            [_tcpServer loginTcpServerIP:_priorIP port:_port Success:^{
                [_msgServer checkUserID:name Pwd:password[@"passwd"] token:@"" success:^(id object) {
                    [[NSUserDefaults standardUserDefaults] setObject:password[@"passwd"] forKey:@"password"];
                    [[NSUserDefaults standardUserDefaults] setObject:password[@"phone"]  forKey:@"username"];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autologin"];
                    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"userToken"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    //用于记录在外面 方便下一次登录
                    _lastLoginPassword=password[@"passwd"];
                    _lastLoginUserName=password[@"phone"];
                    //重新登陆是 需要的参数
//                    _dict=[[NSDictionary alloc]initWithDictionary:dic];
//                    
//                    
//                    _theLastPassDict=[[NSDictionary alloc]initWithDictionary:password];
//                    _theLastUserName=name;
                    DDClientState* clientState = [DDClientState shareInstance];
                    clientState.userState=DDUserOnline;
                    _relogining=YES;
                    MTTUserEntity *user = object[@"user"];
                    TheRuntime.user = user;
                    
                    [[MTTDatabaseUtil instance] openCurrentUserDB];
                    
                    //加载所有人信息，创建检索拼音
                    [self p_loadAllUsersCompletion:^{
                        
                        if ([[SpellLibrary instance] isEmpty]) {
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [[[DDUserModule shareInstance] getAllMaintanceUser] enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                                    [[SpellLibrary instance] addSpellForObject:obj];
                                    [[SpellLibrary instance] addDeparmentSpellForObject:obj];
                                    
                                }];
                                NSArray *array =  [[DDGroupModule instance] getAllGroups];
                                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                    [[SpellLibrary instance] addSpellForObject:obj];
                                }];
                            });
                        }
                    }];
                    
                    [[SessionModule instance] loadLocalSession:^(bool isok) {}];
                    [AddFriendModule instance];
                    [AddFriendMsgViewController instance];
                    success(user);
                    
                    [MTTNotification postNotification:DDNotificationUserLoginSuccess userInfo:nil object:user];
                    
                } failure:^(NSError *object) {
                    
                    DDLog(@"login#登录验证失败");
                   
                    failure(object.domain);
                }];
                
            } failure:^{
                 DDLog(@"连接消息服务器失败");
                  failure(@"连接消息服务器失败");
            }];
        }
}

- (void)reloginSuccess:(void(^)())success failure:(void(^)(NSString* error))failure
{

    
    NSDictionary *dict=[[NSUserDefaults standardUserDefaults]objectForKey:@"postDic"];//已经打包好的数据
    NSDictionary*dict2=[[NSUserDefaults standardUserDefaults]objectForKey:@"postDic2"];//用户输入的账号密码
    
    if ([DDClientState shareInstance].userState == DDUserOffLine && dict) {
        
//        [self loginWithUsername:_theLastUserName password:_theLastPassDict andDict:_dict success:^(MTTUserEntity *user) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloginSuccess" object:nil];
//            success(YES);
//        } failure:^(NSString *error) {
//            failure(@"重新登陆失败");
//        }];

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager POST:LOGINCHECK parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //         if (!responseObject) {
             //             DDLog(@"服务器返回数据为空!!!");
             //             return;
             //         }
             NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
             //         DDLog(@"----responseDic == %@",responseDictionary);
             //
             //         DDLog(@"----responseDic == %@",responseDictionary[@"return_message"]);
             if (!responseDictionary[@"return_code"]||!([responseDictionary[@"return_code"]intValue]==0)) {
                 return ;
             }
             
             
             if (responseDictionary[@"return_message"]&&responseDictionary[@"return_server"]) {
                 
            [self loginWithUsername:responseDictionary[@"return_message"] password:dict2 andDict:responseDictionary[@"return_server"] success:^(MTTUserEntity *user) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloginSuccess" object:nil];
                            success(YES);
                
            } failure:^(NSString *error) {
                
            }];
              
               
             }
          
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
           
         } ];
        
        
        
    }
}

- (void)offlineCompletion:(void(^)())completion
{
    completion();
}

/**
 *  登录成功后获取所有好友用户
 *
 *  @param completion 异步执行的block
 */
- (void)p_loadAllUsersCompletion:(void(^)())completion
{
    __block NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    __block NSInteger version = [[defaults objectForKey:@"alllastupdatetime"] integerValue];

    
    // 获取所有的好友联系人
    [[MTTDatabaseUtil instance] getAllUsers:^(NSArray *contacts, NSError *error) {
        if ([contacts count] != 0) {
            [contacts enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                [[DDUserModule shareInstance] addMaintanceUser:obj];
            }];
            if (completion !=nil) {
                completion();
            }
        }else{
            version=0;
            DDAllUserAPI* api = [[DDAllUserAPI alloc] init];
            [api requestWithObject:@[@(version)] Completion:^(id response, NSError *error) {
                if (!error)
                {
                    NSUInteger responseVersion = [[response objectForKey:@"alllastupdatetime"] integerValue];
                    if (responseVersion == version && responseVersion !=0) {
                        
                        return ;
                        
                    }
                    [defaults setObject:@(responseVersion) forKey:@"alllastupdatetime"];
                    NSMutableArray *array = [response objectForKey:@"userlist"];
                    
                    [[MTTDatabaseUtil instance] insertAllUser:array completion:^(NSError *error) {
                        
                    }];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [array enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                            [[DDUserModule shareInstance] addMaintanceUser:obj];
                        }];
                        
                        dispatch_async(dispatch_get_main_queue(),^{
                            if (completion !=nil) {
                                completion();
                            }
                        });
                    });
                }
            }];
        }
    }];
    
    // 获取所有的好友
    DDAllUserAPI* api = [[DDAllUserAPI alloc] init];
    [api requestWithObject:@[@(version)] Completion:^(id response, NSError *error) {
        if (!error)
        {
            NSUInteger responseVersion = [[response objectForKey:@"alllastupdatetime"] integerValue];
            if (responseVersion == version && responseVersion != 0) {
                return;
            }
            
            [defaults setObject:@(responseVersion) forKey:@"alllastupdatetime"];
            NSMutableArray *array = [response objectForKey:@"userlist"];
            // 插入FMDB
            [[MTTDatabaseUtil instance] insertAllUser:array completion:^(NSError *error) {
                
            }];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [array enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                    [[DDUserModule shareInstance] addMaintanceUser:obj];
                }];
            });
        }
    }];
}

@end
