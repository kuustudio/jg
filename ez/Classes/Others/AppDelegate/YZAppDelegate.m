//
//  YZAppDelegate.m
//  ez
//
//  Created by apple on 14-7-30.
//  Copyright (c) 2014年 9ge. All rights reserved.
//

#import <HyphenateLite/HyphenateLite.h>
#import "YZAppDelegate.h"
#import "YZTabBarViewController.h"
#import "YZNewFeatureViewController.h"
#import "YZStatusCacheTool.h"
#import "AFNetworkReachabilityManager.h"
#import "IQKeyboardManager.h"
#import "JPUSHService.h"
#import "UMMobClick/MobClick.h"
#import "YZThirdPartyStatus.h"
#import "UPPaymentControl.h"
#import <UMSocialCore/UMSocialCore.h>
#import <AlipaySDK/AlipaySDK.h>
#import "YZWinNumberViewController.h"
#import "JSON.h"

@interface YZAppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation YZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //处理键盘
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].toolbarDoneBarButtonItemText = @"完成";
    
    //删除userId，以重新登录
    [YZUserDefaultTool removeObjectForKey:@"userId"];
    
    //微信注册
#if JG
    [WXApi registerApp:WXAppIdOld withDescription:@"九歌彩票"];
#elif ZC
    [WXApi registerApp:WXAppIdOld withDescription:@"中彩啦"];
#elif CS
    [WXApi registerApp:WXAppIdOld withDescription:@"财多多"];
#endif
    //极光注册
    [JPUSHService setLogOFF];
    [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |UIUserNotificationTypeSound | UIUserNotificationTypeAlert)
                                          categories:nil];
    [JPUSHService setupWithOption:launchOptions
                           appKey:JPushId
                          channel:@"App Store"
                 apsForProduction:YES];
    
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"jg_dev";
#else
    apnsCertName = @"jg_dis";
#endif
    HOptions *option = [[HOptions alloc] init];
    option.appkey = CECAppKey;
    option.tenantId = CECTenantId;
//    option.enableConsoleLog = YES;
    //推送证书名字
    option.apnsCertName = apnsCertName;//(集成离线推送必填)
    //Kefu SDK 初始化,初始化失败后将不能使用Kefu SDK
    HError *initError = [[HChatClient sharedClient] initializeSDKWithOptions:option];
    if (initError) { // 初始化错误
        YZLog(@"环信初始化错误");
    }
    
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    YZLog(@"userInfo：%@",userInfo);
    if (!YZDictIsEmpty(userInfo)) {
        //刷新是否有新消息
        [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataHaveNewMessage" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMessageNote" object:nil];
    }
    
    //友盟统计
    UMConfigInstance.appKey = UMengId;
    [MobClick startWithConfigure:UMConfigInstance];
    
    //友盟分享
    [[UMSocialManager defaultManager] openLog:NO];
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:UMengId];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession
                                          appKey:WXAppIdOld
                                       appSecret:WXAppSecretOld
                                     redirectURL:@"http://mobile.umeng.com/social"];
    
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ
                                          appKey:QQAPPId
                                       appSecret:QQAppSecret
                                     redirectURL:@"http://mobile.umeng.com/social"];
    
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina
                                          appKey:SinaAPPId
                                       appSecret:SinaAppSecret
                                     redirectURL:@"https://api.weibo.com/oauth2/default.html"];
    
    //开启网络监控
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //自动登录
    [self autoLogin];
    
    //获取分享活动数据
    [self getShareData];
    
    //取出上次使用的的版本号
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"CFBundleShortVersionString"];
    //获得当前版本号
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    
    if([lastVersion isEqualToString:currentVersion])
    {   //版本相同，说明已经使用过该版本app,直接进入
        [UIApplication sharedApplication].statusBarHidden = NO;
        application.keyWindow.rootViewController = [[YZTabBarViewController alloc] init];
    }else
    {   //版本不一样，说明是首次使用该版本app,展示新特性
        application.keyWindow.rootViewController = [[YZNewFeatureViewController alloc] init];
        //存储新版本
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"CFBundleShortVersionString"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return YES;
}
#pragma mark - 自动登录
- (void)autoLogin
{
    //是否自动登录
    int autoLoginType = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"autoLogin"];
    if (autoLoginType == 2) {
        NSString * loginWay = [YZUserDefaultTool getObjectForKey:@"loginWay"];
        YZThirdPartyStatus *thirdPartyStatus = [YZUserDefaultTool thirdPartyStatus];
        BOOL haveThirdPartyData = thirdPartyStatus && [thirdPartyStatus isKindOfClass:[YZThirdPartyStatus class]] && thirdPartyStatus.platformType && !YZStringIsEmpty(thirdPartyStatus.uid) && !YZStringIsEmpty(thirdPartyStatus.openid);
        BOOL haveAccountData = !YZStringIsEmpty([YZUserDefaultTool getObjectForKey:@"userName"]) && !YZStringIsEmpty([YZUserDefaultTool getObjectForKey:@"userPwd"]);
        if ([loginWay isEqualToString:@"thirdPartyLogin"] && haveThirdPartyData) {//第三方登录
            [self thirdPartyLogin];
        }else if([loginWay isEqualToString:@"accountLogin"] && haveAccountData)
        {
            [self accountLogin];
        }else
        {
            [YZTool setAlias];
        }
    }else
    {
        [YZTool setAlias];
    }
}
- (void)thirdPartyLogin
{
    YZThirdPartyStatus *thirdPartyStatus = [YZUserDefaultTool thirdPartyStatus];
    if (!thirdPartyStatus || ![thirdPartyStatus isKindOfClass:[YZThirdPartyStatus class]]) return;
    if (!thirdPartyStatus.platformType || !thirdPartyStatus.uid || !thirdPartyStatus.openid) return;
    NSString * paramJson;
    NSNumber *type;
    if (thirdPartyStatus.platformType == UMSocialPlatformType_WechatSession) {
        paramJson = [@{@"uId":thirdPartyStatus.uid,@"openId":thirdPartyStatus.openid} JSONRepresentation];
        type = @(2);
    }else if (thirdPartyStatus.platformType == UMSocialPlatformType_QQ)
    {
        paramJson = [@{@"uId":thirdPartyStatus.uid,@"openId":thirdPartyStatus.openid} JSONRepresentation];
        type = @(1);
    }else if (thirdPartyStatus.platformType == UMSocialPlatformType_Sina)//微博登录只需uid
    {
        paramJson = [@{@"uId":thirdPartyStatus.uid} JSONRepresentation];
        type = @(3);
    }
    NSString * imei = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSDictionary *dict = @{
                           @"cmd":@(10630),
                           @"type":type,
                           @"param":paramJson,
                           @"imei":imei
                           };
    [[YZHttpTool shareInstance] postWithParams:dict success:^(id json) {
        //检查账号密码返回数据
        if(SUCCESS)
        {
            if ([json[@"bindStatus"] isEqualToNumber:@(1)]) {
                //成功登录
                [YZUserDefaultTool saveObject:json[@"userId"] forKey:@"userId"];
                //发送登录成功通知
                [[NSNotificationCenter defaultCenter] postNotificationName:loginSuccessNote object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showVoucherLoginSuccessNote" object:nil];
                [YZTool setAlias];
            }
        }
    } failure:^(NSError *error) {
         YZLog(@"自动登录error");
    }];
}
- (void)accountLogin
{
    NSDictionary *dict = @{
                           @"cmd":@(8004),
                           @"userName":[YZUserDefaultTool getObjectForKey:@"userName"],
                           @"password":[YZUserDefaultTool getObjectForKey:@"userPwd"],
                           @"loginType":@(1)
                           };
    [[YZHttpTool shareInstance] postWithParams:dict success:^(id json) {
        //检查账号密码返回数据
        if(SUCCESS)
        {
            //成功登录
            [YZUserDefaultTool saveObject:json[@"userId"] forKey:@"userId"];
            //发送登录成功通知
            [[NSNotificationCenter defaultCenter] postNotificationName:loginSuccessNote object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showVoucherLoginSuccessNote" object:nil];
            [YZTool setAlias];
        }
    } failure:^(NSError *error) {
        YZLog(@"自动登录error");
    }];
}
#pragma mark - 获取分享活动数据
- (void)getShareData {
    NSString * seqId = [YZTool uuidString];//获取uuid
    NSDictionary *dict = @{
                           @"sequence":seqId,
                           };
    [[YZHttpTool shareInstance] postWithURL:BaseUrlShare(@"/getShareFriendSwitch") params:dict success:^(id json) {
        if (SUCCESS) {
            [YZUserDefaultTool saveInt:[json[@"open"] intValue] forKey:@"share_open"];
        }else
        {
            [YZUserDefaultTool saveInt:0 forKey:@"share_open"];
        }
    }failure:^(NSError *error)
    {
        [YZUserDefaultTool saveInt:0 forKey:@"share_open"];
    }];
}

#pragma mark - 独立客户端回调函数
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    //银联支付
    [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
        if([code isEqualToString:@"success"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:UPayRechargeSuccessNote object:nil];
        }
    }];
    // 支付跳转支付宝钱包进行支付，处理支付结果
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSString *resultStatus = resultDic[@"resultStatus"];
            if([resultStatus isEqualToString:@"9000"])//成功代码
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:AliPayRechargeSuccessNote object:nil];
            }
        }];
    }

    if([[url absoluteString] rangeOfString:[NSString stringWithFormat:@"%@://pay",WXAppIdNew]].location == 0) {//微信支付
        return [WXApi handleOpenURL:url delegate:self];
    }else
    {
        return [[UMSocialManager defaultManager] handleOpenURL:url];//友盟回调
    }
}
// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    //银联支付
    [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
        if([code isEqualToString:@"success"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:UPayRechargeSuccessNote object:nil];
        }
    }];
    // 支付跳转支付宝钱包进行支付，处理支付结果
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSString *resultStatus = resultDic[@"resultStatus"];
            if([resultStatus isEqualToString:@"9000"])//成功代码
            {
                 [[NSNotificationCenter defaultCenter] postNotificationName:AliPayRechargeSuccessNote object:nil];
            }
        }];
    }

    if([[url absoluteString] rangeOfString:[NSString stringWithFormat:@"%@://pay",WXAppIdNew]].location == 0) {//微信支付
        return [WXApi handleOpenURL:url delegate:self];
    }else
    {
        return [[UMSocialManager defaultManager] handleOpenURL:url];//友盟回调
    }
}
/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
-(void)onResp:(BaseResp*)resp
{
    //支付
    if ([resp isKindOfClass:[PayResp class]])
    {
        PayResp *response = (PayResp *)resp;
        if (response.errCode == WXSuccess)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:WeiXinRechargeSuccessNote object:nil];
        }
    }
}


- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    [[HChatClient sharedClient] bindDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    YZLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (!YZDictIsEmpty(userInfo)) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//震动
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"您有新的消息" message:userInfo[@"aps"][@"alert"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:alertAction];
        [KEY_WINDOW.rootViewController presentViewController:alertController animated:YES completion:nil];
        //刷新是否有新消息
        [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataHaveNewMessage" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMessageNote" object:nil];
    }    
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)(void))completionHandler
{
    //刷新是否有新消息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataHaveNewMessage" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMessageNote" object:nil];
    completionHandler();
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RefreshCountdownNote object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:RefreshNotificationStatusNote object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [YZStatusCacheTool deleteAllStatus];//删除数据
}

@end