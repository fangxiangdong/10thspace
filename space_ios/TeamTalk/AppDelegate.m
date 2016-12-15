//
//  AppDelegate.m
//  TeamTalk
//
//  Created by kevin on 15/6/18.
//  Copyright (c) 2015年 XunXin. All rights reserved.
//

#import "AppDelegate.h"
#import "MTTLoginViewController.h"
#import "ChattingMainViewController.h"
#import "DDClientStateMaintenanceManager.h"
#import "SessionModule.h"
#import "NSDictionary+Safe.h"
//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
#import "WeiboSDK.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 使用NSUserDefaults来判断程序是否第一次启动
    NSUserDefaults *TimeOfBootCount = [NSUserDefaults standardUserDefaults];
    if (![TimeOfBootCount valueForKey:@"time"]) {
        [TimeOfBootCount setValue:@"sd" forKey:@"time"];
        // 下载后第一次启动
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isFirstRunning"];
    }else{
        // 不是第一次启动
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isFirstRunning"];
    }
    
    [DDClientStateMaintenanceManager shareInstance];
    [RuntimeStatus instance];
    
    // 移除webview cache
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    // 推送消息的注册方式
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // for iOS 8
        UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // for iOS 7 or iOS 6
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    if( SYSTEM_VERSION >= 8 ) {
        [[UINavigationBar appearance] setTranslucent:YES];
    }
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    //分享注册
    [ShareSDK registerApp:@"1984704f116b0"
     
          activePlatforms:@[
                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ)
                            ]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             case SSDKPlatformTypeSinaWeibo:
                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                 break;
                 
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                 [appInfo SSDKSetupSinaWeiboByAppKey:@"2984192694"
                                           appSecret:@"5c0fa3430ed7ae0cd6185096a049e800"
                                         redirectUri:@"http://www.sharesdk.cn"
                                            authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wxc3e4e04af6798673"
                                       appSecret:@"d0fc81dba00c9eaec28e1df69a733376"];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:@"101366167"
                                      appKey:@"e2d47d625b09d6e7b2d69e0cd4005fb7"
                                    authType:SSDKAuthTypeBoth];
                 break;
             default:
                 break;
         }
     }];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    MTTLoginViewController *loginVC =[[MTTLoginViewController alloc] initWithNibName:@"MTTLoginViewController" bundle:nil];
    UINavigationController *navRoot =[[UINavigationController alloc] initWithRootViewController:loginVC];
    navRoot.hidesBottomBarWhenPushed =YES;
    self.window.rootViewController =navRoot;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

// 将要退出程序
- (void)applicationWillResignActive:(UIApplication *)application
{
//    [[NSUserDefaults standardUserDefaults] setObject:@"cameraClose" forKey:@"currentCameraStatus"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([[SessionModule instance] getAllUnreadMessageCount] == 0) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }else{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[SessionModule instance]getAllUnreadMessageCount]];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

// 退出程序，杀死进程(完全退出)
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setObject:@"cameraClose" forKey:@"currentCameraStatus"];
}

//#ifdef __IPHONE_8_0
//- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
//{
//    //register to receive notifications
//    [application registerForRemoteNotifications];
//}
//
//- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
//{
//    //handle the actions
//    if ([identifier isEqualToString:@"declineAction"]){
//    }
//    else if ([identifier isEqualToString:@"answerAction"]){
//    }
//}
//#endif

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    NSString *dt = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *dn = [dt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    TheRuntime.pushToken= [dn stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
    NSLog(@"获取令牌失败:  %@",error_str);
}

// 处理推送消息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UIApplicationState state = application.applicationState;
    if ( state != UIApplicationStateBackground) {
        return;
    }
    NSString *jsonString = [userInfo safeObjectForKey:@"custom"];
    NSData* infoData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* info = [NSJSONSerialization JSONObjectWithData:infoData options:0 error:nil];
    NSInteger from_id =[[info safeObjectForKey:@"from_id"] integerValue];
    SessionType type = (SessionType)[[info safeObjectForKey:@"msg_type"] integerValue];
    NSInteger group_id =[[info safeObjectForKey:@"group_id"] integerValue];
    if (from_id) {
        NSInteger sessionId = type==1?from_id:group_id;
        MTTSessionEntity *session = [[MTTSessionEntity alloc] initWithSessionID:[MTTUtil changeOriginalToLocalID:(UInt32)sessionId SessionType:(int)type] type:type] ;
        [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
    }
}
             
@end
