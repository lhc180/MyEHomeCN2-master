//
//  MyELoginViewController.m
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyELoginViewController.h"

#import "MyEMainTabBarController.h"

#import "MyEDevicesViewController.h"
#import "MyEScenesViewController.h"
#import "MyERoomsViewController.h"
#import "MyESettingsViewController.h"
#import "MyECameraTableViewController.h"

#import "MyEsettingsMediatorViewController.h"

@implementation MyELoginViewController

@synthesize usernameInput = _usernameInput;
@synthesize passwordInput = _passwordInput;
@synthesize accountData = _accountData;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.topView.frame = CGRectMake(25, -6, 270, 99);
    self.centerView.frame = CGRectMake(25, 208, 270, 235);
    [self setViewAnimate];
    [self setViewDate];
    //之所以会有这一行，是因为xcode5自带的images。xcassets对于iPhone5支持不是很好，所以要特别注明这一句代码
    if (IS_IPHONE5) {
        //特别注意，对于iPhone5只有retina屏幕，所以只需要使用@2x的image就可以了
        [self.loginImage setImage:[UIImage imageNamed:@"login-568h@2x"]];
    }
    //以下代码为修改placeholder的文字颜色，这种技巧应该多加注意
    [self.usernameInput setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwordInput setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    //此处注明delegate主要是为了点击键盘return键时可以进行相应操作
    self.usernameInput.delegate = self;
    self.passwordInput.delegate = self;
    
    //这里需要注意的是如何获取到系统的版本信息
    //    version.text = [NSString stringWithFormat:@"Version  %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    [self loadSettings];
    if ([[self getUsersFromPlist] count] <= 1) {  //只有当登录的用户至少为两个时，才允许用户切换账户
        self.showBtn.hidden = YES;
    }else
        [self reloadUsersTableViewContents];
}

// 下面使用9宫格可缩放图片作为按钮背景
//    UIImage *buttonBackImage = [UIImage imageNamed:@"buttonbg.png" ];
//    buttonBackImage = [buttonBackImage stretchableImageWithLeftCapWidth:10 topCapHeight:10];
//    [self.loginButton setBackgroundImage:buttonBackImage forState:UIControlStateNormal];


//以下部分应该特别注意，这里的观察者主要是针对键盘而存在的。在使用完了之后还应该特别注意在viewDidDisapper中释放内存(以后可以写成block的形式，比这个更为容易和简单)
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(hideKeyboardBeforeResignActive:)
//                                                 name:UIApplicationWillResignActiveNotification
//                                               object:nil];


//- (void)viewDidDisappear:(BOOL)animated
//{
//    //此处为释放观察者
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
//}
#pragma mark - navigation methods
//这个方法多用于storyboard中，主要工作就是传值，并且只能是向下一级VC传值，要想从下级VC向上传值，需要使用代理模式
//通过这个方法主要是要学会怎么在storyboard中找到自己需要的VC
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"ShowMainTabViewDirectly"]) {
        MyEMainTabBarController *tabBarController = [segue destinationViewController];
        //在这里为每个tab view设置houseId和userId, 同时要为每个tab viewController中定义这两个变量，并实现一个统一的签名方法，以保存这个变量。
        //        [tabBarController setTitle:self.accountData.userName];
        tabBarController.accountData = self.accountData;
        
        UINavigationController *nc = [[tabBarController childViewControllers] objectAtIndex:0];
        MyEDevicesViewController *devicesViewController = [[nc childViewControllers] objectAtIndex:0];
        devicesViewController.accountData = self.accountData;
        devicesViewController.preivousPanelType = 0;
        
        //这里以后要放置camera的东西
        nc = tabBarController.childViewControllers[2];
        MyERoomsViewController *roomsViewController = [[nc childViewControllers] objectAtIndex:0];
        roomsViewController.accountData = self.accountData;
        
        nc = [[tabBarController childViewControllers] objectAtIndex:3];
        MyEScenesViewController *scenesViewController = [[nc childViewControllers] objectAtIndex:0];
        scenesViewController.accountData = self.accountData;
        
        nc = [[tabBarController childViewControllers] objectAtIndex:4];
        MyESettingsViewController *settingsViewController = [[nc childViewControllers] objectAtIndex:0];
        settingsViewController.accountData = self.accountData;
    }
    
    if ([[segue identifier] isEqualToString:@"mediator"]) {
        UINavigationController *nav = segue.destinationViewController;
        MyEsettingsMediatorViewController *vc = [nav childViewControllers][0];
        vc.changeValue = 1;
        vc.accountData = self.accountData;
    }
}
#pragma mark - private methods
-(void)setViewAnimate{
    [UIView animateWithDuration:1 animations:^{
        CGRect topFrame = self.topView.frame;
        CGRect centerFrame = self.centerView.frame;
        topFrame.origin.y += 50;
        centerFrame.origin.y -=50;
        self.topView.frame = topFrame;
        self.centerView.frame = centerFrame;
        self.topView.alpha = 1;
        self.centerView.alpha = 1;
    } completion:^(BOOL finished){
        self.bottomView.hidden = NO;
    }];
}
-(void)setViewDate{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    comps = [calendar components:unitFlags fromDate:now];
    NSString *week = nil;
    NSLog(@"%@",comps);
    switch ([comps weekday]) {
        case 1:
            week = @"星期日";
            break;
        case 2:
            week = @"星期一";
            break;
        case 3:
            week = @"星期二";
            break;
        case 4:
            week = @"星期三";
            break;
        case 5:
            week = @"星期四";
            break;
        case 6:
            week = @"星期五";
            break;
        default:
            week = @"星期六";
            break;
    }
    UILabel *dateLabel = (UILabel *)[self.topView viewWithTag:903];
    dateLabel.text = [NSString stringWithFormat:@"%li月%li日 %@",(long)[comps month],(long)[comps day],week];
    _lastHour = [comps hour];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if ([def objectForKey:@"hour"]) {    //hour使用的是24小时制
        if ([[def objectForKey:@"hour"] intValue] - [comps hour] > 1 ||
            [comps hour] - [[def objectForKey:@"hour"] intValue] > 1) {  //只要有一个是大于1的就刷新
            [def setObject:@([comps hour]) forKey:@"hour"];  //并把当前的时间信息存储
            [self getCurrentLocation];
        }else{
            NSDictionary *dic = [def objectForKey:@"weather"];
            [self setTopViewWeatherWithDictionary:dic];
        }
    }else{
        [self getCurrentLocation];
    }
}
-(void)setTopViewWeatherWithDictionary:(NSDictionary *)weather{
    self.activityView.hidden = YES;
    UIView *mainView = (UIView *)[self.view viewWithTag:1000];
    UIImageView *dayImg = (UIImageView *)[mainView viewWithTag:800];
    //    UIImageView *nightImg = (UIImageView *)[mainView viewWithTag:801];
    UILabel *cityLabel = (UILabel *)[mainView viewWithTag:900];
    UILabel *weatherLabel = (UILabel *)[mainView viewWithTag:901];
    UILabel *tmpLabel = (UILabel *)[mainView viewWithTag:902];
    dayImg.image = [UIImage imageNamed:[weather[@"img1"] substringToIndex:2]];
    //    nightImg.image = [UIImage imageNamed:[weather[@"img2"] substringToIndex:2]];
    cityLabel.text = weather[@"city"];
    weatherLabel.text = weather[@"weather"];
    if ([weather[@"temp1"] intValue] > [weather[@"temp2"] intValue]) {
        tmpLabel.text = [NSString stringWithFormat:@"%@-%@",weather[@"temp2"],weather[@"temp1"]];
    }else
        tmpLabel.text = [NSString stringWithFormat:@"%@-%@",weather[@"temp1"],weather[@"temp2"]];
}
-(void)setTopViewStatusWithString:(NSString *)string{
    for (UIView *view in self.topView.subviews) {
        if (view.tag != 2000 && view.tag != 903 && view.tag != 900) {
            view.hidden = YES;
        }
    }
    UILabel *lbl = (UILabel *)[self.topView viewWithTag:900];
    lbl.text = string;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if ([def objectForKey:@"hour"]) {
        [def removeObjectForKey:@"hour"];
    }
}
- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    //    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    //    CGRect keyboardRect = [aValue CGRectValue];
    //    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    //    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    //newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    //newTextViewFrame.origin.y = 220 - keyboardTop;
    
    // move the main view frame upward by half of the gap
    // between the navigation bar title (MyE) and the Username input text box
    newTextViewFrame.origin.y = self.view.bounds.origin.y -
    self.usernameInput.frame.origin.y / 2.0;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.view.frame = newTextViewFrame;
    
    [UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = self.view.bounds;
    [UIView commitAnimations];
}
- (void)hideKeyboardBeforeResignActive:(NSNotification *)notification{
    [self.usernameInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(NSMutableArray *)getUsersFromPlist{
    NSMutableArray *array = nil;
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    }else
        array = [NSMutableArray array];
    return array;
}
-(void)reloadUsersTableViewContents{
    NSMutableArray *users = [self getUsersFromPlist];
    [_usersTableView reloadData];
    [_usersTableView initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSUInteger section){
        return [users count];
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        static NSString *cellIdetifier = @"cell";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdetifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdetifier];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
            label.font = [UIFont systemFontOfSize:15];
            label.tag = 998;
            label.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label];
        }
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:998];
        label.text = [users[indexPath.row] objectForKey:@"username"];
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        UITableViewCell *cell=(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:998];
        self.usernameInput.text = label.text;
        for (NSDictionary *d in users) {
            if ([d[@"username"] isEqualToString:label.text]) {
                self.passwordInput.text = d[@"password"];
            }
        }
        
        [_showBtn sendActionsForControlEvents:UIControlEventTouchUpInside];   //这句代码的意思就是说让按钮的方法运行一遍，这个想法不错
    } beginEditingStyleForRowAtIndexPath :^(UITableView* tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath* indexPath){
        [users removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [users writeToFile:[self dataFilePath] atomically:YES];
    }];
    _usersTableView.tableFooterView = [[UIView alloc] init];
    [_usersTableView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_usersTableView.layer setBorderWidth:1];
    
}
-(void)loadSettings{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    UIButton *btn = (UIButton *)[self.view viewWithTag:100];
    btn.selected = [prefs boolForKey:@"rememberme"];
    if (btn.selected) {
        self.usernameInput.text = [prefs objectForKey:@"username"];
        self.passwordInput.text = [prefs objectForKey:@"password"];
    }
}
- (IBAction)saveUserInfo:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:sender.selected forKey:@"rememberme"];
    [prefs synchronize];

}
-(NSString *)dataFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:@"users.plist"];
}
-(void)writeUserInfoInPlist{
    NSMutableArray *array = [self getUsersFromPlist];
    BOOL canWrite = YES;
    if ([array count]) {
        for (NSDictionary *d in [NSArray arrayWithArray:array]) {     //只有不存在的情况下才可以添加
            if ([d[@"username"] isEqualToString:self.usernameInput.text] &&
                [d[@"password"] isEqualToString:self.passwordInput.text]) {
                canWrite = NO;
                break;
            }else if ([d[@"username"] isEqualToString:self.usernameInput.text] &&
                      ![d[@"password"] isEqualToString:self.passwordInput.text]){
                [d setValue:self.passwordInput.text forKey:@"password"];
                [array writeToFile:[self dataFilePath] atomically:YES];
                return;
            }
        }
    }
    if (canWrite) {
        [array addObject:@{@"username": self.usernameInput.text,
                           @"password": self.passwordInput.text}];
        [array writeToFile:[self dataFilePath] atomically:YES];
    }
}
-(void)saveSettings{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    UIButton *btn = (UIButton *)[self.view viewWithTag:100];
    if (btn.selected) {
        [prefs setObject:self.usernameInput.text forKey:@"username"];
        [prefs setObject:self.passwordInput.text forKey:@"password"];
        [prefs setBool:YES forKey:@"rememberme"];
        [self writeUserInfoInPlist];
    }else {
        [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"rememberme"];
    }
    [prefs synchronize];
}

- (IBAction)showUsers:(UIButton *)sender {
    if ([sender isSelected]) {   //isSelected 就是selected
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=_usersTableView.frame;
            
            frame.size.height=0;
            [_usersTableView setFrame:frame];
            
        } completion:^(BOOL finished){
            [sender setSelected:NO];
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=_usersTableView.frame;
            
            NSMutableArray *array = [self getUsersFromPlist];
            if ([array count] < 6 ) {
                frame.size.height = 35 * array.count;
            }else
                frame.size.height=150;
            
            [_usersTableView setFrame:frame];
        } completion:^(BOOL finished){
            [sender setSelected:YES];
        }];
    }
}
- (IBAction)btnClicked:(UIButton *)sender {
    NSString *urlString = @"http://shop101822140.taobao.com/";
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)login:(id)sender {
    [self _doLogin];
}

-(void)_doLogin {
    // 如果用户名和密码的输入不足长度，提示后退出
    if([self.usernameInput.text  length] < 4 || [self.passwordInput.text length] < 6) {
        [MyEUtil showMessageOn:nil withMessage:@"用户名或密码长度不正确，请重新输入"];
        return;
    }
    
    // 1.判断是否联网：
    if (![MyEDataLoader isConnectedToInternet]) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                    contentText:@"没有网络连接，请打开网络后重试"
                                                leftButtonTitle:nil
                                               rightButtonTitle:@"知道了"];
        [alert show];
        return;
    }
    MyEAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //        HUD.dimBackground = YES; //容易产生灰条
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?username=%@&password=%@&deviceType=0&deviceToken=%@&deviceAlias=%@&appVersion=%@&ver=2", URL_FOR_LOGIN, self.usernameInput.text, self.passwordInput.text,delegate.deviceTokenStr,delegate.alias,[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] ;
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"LoginDownloader" userDataDictionary:nil];
    NSLog(@"downloader.name is  %@ urlStr =  %@",downloader.name, urlStr);
}

#pragma mark -
#pragma mark URL Loading System methods

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"Login account JSON String from server is \n%@",string);
    [HUD hide:YES];
    if([name isEqualToString:@"LoginDownloader"]) {
        MyEAccountData *anAccountData = [[MyEAccountData alloc] initWithJSONString:string];
        if(anAccountData && anAccountData.loginSuccess) {
            self.accountData = anAccountData;
        }
        //这里存储MID是为了在网关设置面板中自动填充用户的MID，提高用户体验
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:self.accountData.mId forKey:@"mId"];
        
        //对于多层判断结构，要尽可能将最常见的情况放在前面，这样可以提高判断的速度，优化体验
        if (self.accountData.loginSuccess == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }else if (self.accountData.loginSuccess == 1){
            //登录成功之后首要任务就是保存设置内容
            [self saveSettings];
            if ([self.accountData.mId length] == 0) {
                [self performSegueWithIdentifier:@"mediator" sender:self];
            }else{
                [self performSegueWithIdentifier:@"ShowMainTabViewDirectly" sender:self];
            }
        }else if(self.accountData.loginSuccess == -1){
            [MyEUtil showMessageOn:self.view withMessage:@"密码输入错误！"];
        }else if(self.accountData.loginSuccess == -5){
            [MyEUtil showToastOn:nil withMessage:@"此M-ID对应的账户已经修改了用户名，请使用新用户名和密码登陆" backgroundColor:nil];
        }else if(self.accountData.loginSuccess == 2){
            [MyEUtil showMessageOn:self.view withMessage:@"此网关的MID已注册"];
        }else{
            [MyEUtil showMessageOn:self.view withMessage:@"登录失败，用户名或密码错误"];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"错误"
                                                contentText:@"通信错误，请稍候重试"
                                            leftButtonTitle:nil
                                           rightButtonTitle:@"知道了"];
    [alert show];
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [HUD hide:YES];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index
{
    //这里介绍了怎么打开URL，但是这个对于程序而言没有任何作用
    if([alertView.title isEqualToString:@"Information"] && index == 0) {
        NSString *urlString = @"http://www.myenergydomain.com";
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark -
#pragma mark UITextField Delegate Methods
// 添加每个textfield的键盘的return按钮的后续动作
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    //从一定程度上可以这么理解这个方法，这里的代码块只是顺便被执行了一边，跟函数的返回值没有任何关系
    [textField resignFirstResponder];
    if (textField == self.usernameInput) {
        [self.passwordInput becomeFirstResponder];
    }
    if (textField == self.passwordInput) {
        [self _doLogin];
    }
    return  YES;
}
#pragma mark - URLConnection Delegate methods
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@",[error localizedDescription]);
    [self setTopViewStatusWithString:@"天气获取失败!"];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    //{"weatherinfo":{"city":"宜春","cityid":"101240501","temp1":"25℃","temp2":"19℃","weather":"中雨","img1":"d8.gif","img2":"n8.gif","ptime":"11:00"}}
    NSLog(@"receive string is %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSDictionary *mainDic = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] JSONValue];
    if (mainDic[@"weatherinfo"]) {
        NSDictionary *weather = mainDic[@"weatherinfo"];
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [self setTopViewWeatherWithDictionary:weather];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:weather forKey:@"weather"];
        [def setObject:@(_lastHour) forKey:@"hour"];
        [def synchronize];
    }else
        [self setTopViewStatusWithString:@"天气获取失败!"];
}
#pragma mark - location methods
-(void)getCurrentLocation{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 10.0f;
    [_locationManager startUpdatingLocation];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"定位成功");
    [_locationManager stopUpdatingLocation];
    if (!_hadRunOneTime) {
        _hadRunOneTime = YES;
        _location = [locations lastObject];
        NSLog(@"经度是%3.5f  纬度是%3.5f  高度是%3.5f",_location.coordinate.latitude,_location.coordinate.longitude,_location.altitude);
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error){
            if ([placemarks count] > 0) {
                CLPlacemark *placemark = placemarks[0];
                NSDictionary *addressDic = placemark.addressDictionary;
                NSString *country = [self getAddressByDictionary:addressDic andKey:@"Country"];
                NSString *state = [self getAddressByDictionary:addressDic andKey:@"State"];
                NSString *city = [self getAddressByDictionary:addressDic andKey:@"City"];
                NSLog(@"country is %@  state is %@ city is %@",country,state,city);
                NSString *cityId = nil;
                MyEProvinceAndCity *provinceAndCity = [[MyEProvinceAndCity alloc] init];
                for (MyEProvince *p in provinceAndCity.provinceAndCity) {
                    if ([p.provinceName isEqualToString:[state substringToIndex:2]]) {
                        for (MyECity *c in p.cities) {
                            if ([c.cityName isEqualToString:[city substringToIndex:2]]) {
                                cityId = c.cityId;
                                break;
                            }
                        }
                        break;
                    }
                }
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.weather.com.cn/data/cityinfo/%@.html",cityId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request  delegate:self];
                NSLog(@"%@",theConnection);
            }
        }];
    }
}
- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error {
    [manager stopUpdatingLocation];
    NSString *string = nil;
    NSLog(@"Error: %@",[error localizedDescription]);
    switch([error code]) {
        case kCLErrorDenied:
        {
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            if ([def objectForKey:@"alertTimes"]) {
                NSInteger alertTimes = [[def objectForKey:@"alertTimes"] integerValue];
                if (alertTimes < 3) {
                    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"定位服务已被关闭,此时无法获取所在城市及当前天气信息,请前往设置页面打开!" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil] show];
                    alertTimes++;
                    [def setObject:@(alertTimes) forKey:@"alertTimes"];
                }
            }else{
                [def setObject:@(1) forKey:@"alertTimes"];
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"定位服务已被关闭,此时无法获取所在城市及当前天气信息,请前往设置页面打开!" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil] show];
            }
            [def synchronize];  //这句话真是救了大命了,这句代码一定要写，否则会出现存储不了数据的情况，出现这种情况，可能跟多线程有关系
            string = @"定位功能已关闭!";
        }
            break;
        case kCLErrorLocationUnknown:
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"位置服务不可用!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
            string = @"位置服务不可用";
            break;
        default:
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"定位发生错误!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
            string = @"定位发生错误";
            break;
    }
    [self setTopViewStatusWithString:string];
}
-(NSString *)getAddressByDictionary:(NSDictionary *)dic andKey:(NSString *)key{
    NSString *string = dic[key];
    return string == nil?@"":string;
}

@end
