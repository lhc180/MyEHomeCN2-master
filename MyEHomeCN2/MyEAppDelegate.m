//
//  MyEAppDelegate.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 9/30/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAppDelegate.h"
#import "MyEUtil.h"
#import "MyELoginViewController.h"
#import "ZBarReaderView.h"

@implementation MyEAppDelegate

#pragma mark - private methods
//通过指定颜色和尺寸，生成一张该颜色的图片
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
-(void)refreshUI{
    if (!IS_IOS6) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"barImage.png"]  forBarMetrics:UIBarMetricsDefault];   //这个貌似跟位置有关系，之前放在方法最后面竟然没有执行成功，放在这里才算成功了
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        //这种给导航栏修改title颜色的方法简直太赞了，特别值得注意
        //首先获得这个dictionary，然后对相应的键值进行赋值，特别注意只有可变的dictionary才能进行赋值，然后把修改好的dic赋值给navbar
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[UINavigationBar appearance].titleTextAttributes];
        [dic setValue:[UIColor whiteColor] forKey:UITextAttributeTextColor];
        [[UINavigationBar appearance] setTitleTextAttributes:dic];
        
        [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
        [[UITabBar appearance] setBarStyle:UIBarStyleBlack];
        [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
        [[UIToolbar appearance] setBarStyle:UIBarStyleBlack];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UINavigationBar appearance] setBackgroundImage:[self imageWithColor:[UIColor blackColor] size:CGSizeMake(1, 44)] forBarMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage new]
                                                forState:UIControlStateNormal
                                              barMetrics:UIBarMetricsDefault];
        //设置导航栏返回按钮的UI
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 18, 0, 0)]
                                                          forState:UIControlStateNormal
                                                        barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(5, -2)
                                                             forBarMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setTitleTextAttributes:
         @{ UITextAttributeFont: [UIFont systemFontOfSize:17],
            UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero]} forState:UIControlStateNormal];
        
        [[UITabBar appearance] setBackgroundImage:[self imageWithColor:[UIColor blackColor] size:CGSizeMake(1, 49)]];
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage new]];
        [[UIToolbar appearance] setBackgroundImage:[self imageWithColor:[UIColor blackColor] size:CGSizeMake(1, 49)] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
}

#pragma mark - appDelegate methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self refreshUI];
    // for test reading property from Info.plist
    //@see https://developer.apple.com/library/ios/documentation/general/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html
    // @see http://stackoverflow.com/questions/9530075/ios-access-app-info-plist-variables-in-code
    
//    //以下为APNS部分
//    // Required
//    
//    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
//                                                   UIRemoteNotificationTypeSound |
//                                                   UIRemoteNotificationTypeAlert)];
//    // Required
//    [APService setupWithOption:launchOptions];
    //    UILocalNotification *localNotif =
    //    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    //    if (localNotif) {
    //        application.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber-1;
    //    }
    [ZBarReaderView class];
    
    //    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    //
    //    [defaultCenter addObserver:self selector:@selector(networkDidSetup:) name:kAPNetworkDidSetupNotification object:nil];
    //    [defaultCenter addObserver:self selector:@selector(networkDidClose:) name:kAPNetworkDidCloseNotification object:nil];
    //    [defaultCenter addObserver:self selector:@selector(networkDidRegister:) name:kAPNetworkDidRegisterNotification object:nil];
    //    [defaultCenter addObserver:self selector:@selector(networkDidLogin:) name:kAPNetworkDidLoginNotification object:nil];
    //    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kAPNetworkDidReceiveMessageNotification object:nil];
    
    
    /**
     说明与备忘：
     下面这一段的目的是为程序添加一个Startup Introduction ScrollView。
     当用户在第一次进入APP时，就沿着Storyboard里面确定的rootViewController顺序进行加载，
     并且在standardUserDefaults里面记载程序已经加载过了。
     在程序第二次加载时，就从storyBoard里面取得标示符为"LoginViewController"的程序的主体VC，
     就用这个VC代替程序原来的self.window.rootViewController，这样程序就略过Startup Introduction ScrollView，
     而直接进入MainNavViewController.
     **/
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_FOR_APP_HAS_LAUNCHED_ONCE])
    {
        UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        UIViewController *vc =[storybord instantiateInitialViewController];// 这个是默认的第一个viewController
        
        // 获取程序的主Navigation VC, 这里可以类似地从stroyboard获取任意的VC，然后设置它为rootViewController，这样就可以显示它
        
        MyELoginViewController *controller = (MyELoginViewController*)[storybord instantiateViewControllerWithIdentifier: @"LoginViewController"];
        self.window.rootViewController = controller;// 用主Navigation VC作为程序的rootViewController
        [self.window makeKeyAndVisible];
        
        return YES;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_FOR_APP_HAS_LAUNCHED_ONCE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return YES;
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@",deviceToken);
    NSString *deviceTokenString = [[[deviceToken description]
                                    stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                   stringByReplacingOccurrencesOfString:@" "
                                   withString:@""];
    NSString *alias = [NSString stringWithFormat:@"mye%@",[deviceTokenString MD5]];
    self.deviceTokenStr = deviceTokenString;
    self.alias = alias;
    [APService setTags:[NSSet setWithObjects:@"myecn", @"MyE", @"smarthome", nil] alias:alias callbackSelector:nil target:nil];
    // Required
    [APService registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
//这个方法怎么没有被调用呢？现在算是知道了。以下两个方法在APP内部收到信息时候调用，一个针对iOS6，一个针对iOS7
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    //    NSLog(@"%@",userInfo);
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统消息"
                                                contentText:userInfo[@"aps"][@"alert"]
                                            leftButtonTitle:nil
                                           rightButtonTitle:@"知道了"];
    [alert show];
    // Required
    [APService handleRemoteNotification:userInfo];
}
//avoid compile error for sdk under 7.0
#ifdef __IPHONE_7_0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    //    NSLog(@"%@   %@",userInfo,userInfo[@"aps"][@"alert"]);
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统消息"
                                                contentText:userInfo[@"aps"][@"alert"]
                                            leftButtonTitle:nil
                                           rightButtonTitle:@"知道了"];
    [alert show];
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
}
#endif

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //清空角标
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}
#pragma mark - private methods
- (void)networkDidSetup:(NSNotification *)notification {
    NSLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification {
    NSLog(@"未连接。。。");
}

- (void)networkDidRegister:(NSNotification *)notification {
    NSLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification {
    NSLog(@"已登录");
}
//这个方法主要用于处理程序进入后台时的消息。当程序从后台进入前台时就会调用这个方法(后来证明这种想法是错误的，这个方法只要接收到了消息就会被调用)
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    NSLog(@"%@",content);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"系统消息"
                                                    message:content
                                                   delegate:nil
                                          cancelButtonTitle:@"知道了"
                                          otherButtonTitles:nil, nil];
    [alert show];
}
@end
