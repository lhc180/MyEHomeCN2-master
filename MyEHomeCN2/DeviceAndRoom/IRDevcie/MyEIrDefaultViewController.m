//
//  MyEIrDefaultViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/4/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEIrDefaultViewController.h"
#import "MyEIrStudyEditKeyModalViewController.h"

#define IR_KEY_SET_DOWNLOADER_NMAE @"IrKeySetDownloader"
#define IR_DEVICE_SEND_CONTROL_KEY_UPLOADER_NMAE @"IRDeviceSencControlKeyUploader"

@interface MyEIrDefaultViewController ()

@end

@implementation MyEIrDefaultViewController
@synthesize isControlMode;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self downloadKeySetFromServer];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark private methods
- (IBAction) keyTapped:(id)sender
{
    for (NSDictionary *dict in _keyMap) {
        if ([dict objectForKey:@"button"] == sender) {
            MyEIrKey *key = [self.device.irKeySet getDefaultKeyByType:[[dict objectForKey:@"type"] integerValue]];
            if (isControlMode) {
                if (key.status >0) {
                    [self sendControlKeyToServer:key andRunTimes:1];
                }else{
                    
//                    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
//                                                                contentText:@"此按键没有学习，请点击右上角【学习模式】学习此按键"
//                                                            leftButtonTitle:nil
//                                                           rightButtonTitle:@"知道了"];
//                    [alert show];
                }
            } else
                [self editStudyKey:key];
            //这里加return有个好处，一旦达到了目的，就可以停止了，这个要记住
            return;
        }
    }
}
-(void)editStudyKey:(MyEIrKey *)key
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IrDevice" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"IRDeviceStudyEditKeyModal"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.presentedFormSheetSize = CGSizeMake(280, 250);
    formSheet.shouldDismissOnBackgroundViewTap = NO;  //点击背景是否关闭
    formSheet.shouldCenterVertically = YES;
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        navController.topViewController.title = @"按键学习";
        MyEIrStudyEditKeyModalViewController *modalVc = (MyEIrStudyEditKeyModalViewController *)navController.topViewController;
        modalVc.device = self.device;
//        modalVc.delegate = self;
        modalVc.key = key;
        modalVc.keyNameTextfield.enabled = NO;
        modalVc.deleteKeyBtn.enabled = NO;
        if (key.status > 0) {
            [modalVc.learnBtn setTitle:@"再学习" forState:UIControlStateNormal];
        }else
            modalVc.validateKeyBtn.enabled = NO;
    };
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        UINavigationController *navController = (UINavigationController *)formSheetController.presentedFSViewController;
        MyEIrStudyEditKeyModalViewController *vc = (MyEIrStudyEditKeyModalViewController *)(navController.topViewController);
        vc.keyNameTextfield.text = key.keyName;
    }];
    
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController) {
        [self refreshUI];
    };
}
- (void) refreshUI
{
    for (NSDictionary *dict in _keyMap) {
        MyEIrKey *key = [self.device.irKeySet getDefaultKeyByType:[[dict objectForKey:@"type"] integerValue]];
        UIButton *btn = [dict objectForKey:@"button"];
        if (key.status > 0) {
            UIImage *image = [UIImage imageNamed:@"control-enable-normal"];
            UIImage *image2 = [UIImage imageNamed:@"control-enable-highlight"];
            [btn setBackgroundImage:[image stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
            [btn setBackgroundImage:[image2 stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:69/255 green:200/255 blue:220/255 alpha:1] forState:UIControlStateHighlighted];
        }else{
            UIImage *image = [UIImage imageNamed:@"control-disable-normal"];
            UIImage *image2 = [UIImage imageNamed:@"control-disable-highlight"];
            [btn setBackgroundImage:[image stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
            [btn setBackgroundImage:[image2 stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        }
        [btn addTarget:self action:@selector(keyTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        if ((btn.tag == 100 || btn.tag == 101 ||
            btn.tag == 102|| btn.tag == 103)
            && key.status >0) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            longPress.minimumPressDuration = 0.7;
            [btn addGestureRecognizer:longPress];
        }
    }
}
-(void) sendControlKeyToServer:(MyEIrKey *)key andRunTimes:(NSInteger)runTimes
{
    NSDictionary *dict;
    if (key) {
       dict = [NSDictionary dictionaryWithObject:key forKey:@"key"];
    }
        
    NSString * urlStr= [NSString stringWithFormat:@"%@?gid=%@&id=%ld&deviceId=%ld&type=%ld&runCount=%li",
                        GetRequst(URL_FOR_IR_DEVICE_SEND_CONTROL_KEY),
                        MainDelegate.accountData.userId,
                        (long)key.keyId,
                        (long)self.device.deviceId,
                        (long)key.type,(long)runTimes];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self loaderName:IR_DEVICE_SEND_CONTROL_KEY_UPLOADER_NMAE
                                 userDataDictionary:dict];
    NSLog(@"%@",downloader.name);
}
-(void) handleLongPress: (UIGestureRecognizer *)longPress {
    if (!isControlMode) {
        return;
    }
    MyEIrKey *irKey;
    UIButton *btn = (UIButton *)longPress.view;
    for (NSDictionary *dict in _keyMap) {
        if ([dict objectForKey:@"button"] == btn) {
            MyEIrKey *key = [self.device.irKeySet getDefaultKeyByType:[[dict objectForKey:@"type"] integerValue]];
            irKey = key;
        }
    }
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:{
//            MYEAppDelegate *delegate = [UIApplication sharedApplication].delegate;
            progressHUD = [MBProgressHUD showHUDAddedTo:MainDelegate.window animated:YES];
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
            image.image = [UIImage imageNamed:@"Volume"];
            progressHUD.mode = MBProgressHUDModeCustomView;
            progressHUD.customView = image;
            progressHUD.opacity = 0.4;  //透明度
            progressHUD.margin = 5;
            progressHUD.cornerRadius = 5;
            progressHUD.yOffset = - 150;
            progressHUD.minSize = CGSizeMake(100, 100);
            progressHUD.userInteractionEnabled = NO;
            valueChange = 0;
            secondsFromNow = 0;
            //长按手势刚开始时就要发送一条指令
            [self sendControlKeyToServer:irKey andRunTimes:1];
            valueChange = 1;
            progressHUD.labelText = [NSString stringWithFormat:@"%i",valueChange];
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doSomethingWhenTimerBegin) userInfo:irKey repeats:YES];}
            break;
        case UIGestureRecognizerStateEnded:
            [timer invalidate];
            secondsFromNow = 0;
            valueChange = 0;
            [progressHUD hide:YES afterDelay:1];
            break;
        default:
            break;
    }
}
-(void)doSomethingWhenTimerBegin{
    secondsFromNow ++;
    switch (secondsFromNow) {
        case 1:
            [self sendControlKeyToServer:timer.userInfo andRunTimes:1];
            valueChange = valueChange + 1;
            break;
        case 2:
            [self sendControlKeyToServer:timer.userInfo andRunTimes:2];
            valueChange = valueChange + 2;
            break;
        default:
            if (valueChange <= 30) {
                [self sendControlKeyToServer:timer.userInfo andRunTimes:3];
            }
            valueChange = valueChange + 3;
            break;
    }
    if (valueChange <= 30)  {
//        progressHUD.progress = valueChange/30;
        progressHUD.labelText = [NSString stringWithFormat:@"%i",valueChange];
    }else{
//        progressHUD.progress = 1.0;
        progressHUD.labelText = @"30";
    }
}
#pragma mark - URL private methods
- (void) downloadKeySetFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&tId=%@&id=%ld",GetRequst(URL_FOR_KEY_SET_VIEW), MainDelegate.accountData.userId, self.device.tId, (long)self.device.deviceId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:IR_KEY_SET_DOWNLOADER_NMAE  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:IR_KEY_SET_DOWNLOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"下载红外设备指令时发生错误！"];
        } else  if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else  if ([MyEUtil getResultFromAjaxString:string] == 1){
            NSLog(@"ajax json = %@", string);
            MyEIrKeySet *keySet = [[MyEIrKeySet alloc] initWithJSONString:string];
            self.device.irKeySet = keySet;
            NSLog(@"%@",self.view.superview.superview.nextResponder.nextResponder);
            NSLog(@"%@",self.view.superview.subviews[1]);
            UITableView *view = self.view.superview.subviews[1];
            MyEIrUserKeyViewController *vc = (MyEIrUserKeyViewController *)view.nextResponder;
            [vc.tableView reloadData];
            [self refreshUI];
        }
    }
    if([name isEqualToString:IR_DEVICE_SEND_CONTROL_KEY_UPLOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:@"发送按键控制时发生错误!"];
        } else if ([MyEUtil getResultFromAjaxString:string] == 1){
            if([MyEUtil getResultFromAjaxString:string] == 1){
//                [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"指令发送成功"];
            } else if([MyEUtil getResultFromAjaxString:string] == -1){
                [MyEUtil showMessageOn:nil withMessage:@"指令发送失败"];
            } else
                [MyEUtil showMessageOn:nil withMessage:@"指令发送失败"];
//                [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"指令发送产生错误"];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:IR_KEY_SET_DOWNLOADER_NMAE])
        msg = @"获取指令通信错误，请稍后重试.";
    else if ([name isEqualToString:IR_DEVICE_SEND_CONTROL_KEY_UPLOADER_NMAE])
        msg = @"发送按键控制通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showErrorOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}

@end
