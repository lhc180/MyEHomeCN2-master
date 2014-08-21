//
//  MyETvUserViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/31/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEIrUserKeyViewController.h"
#import "MyEIrDeviceAddKeyModalViewController.h"


#define IR_KEY_SET_DOWNLOADER_NMAE @"IrKeySetDownloader"
#define IR_DEVICE_DELETE_KEY_UPLOADER_NMAE @"IRDeviceDeleteKeyUploader"
#define IR_DEVICE_SEND_CONTROL_KEY_UPLOADER_NMAE @"IRDeviceSencControlKeyUploader"

@interface MyEIrUserKeyViewController ()

@end

@implementation MyEIrUserKeyViewController
@synthesize accountData, device, needDownloadKeyset,jumpFromCurtain,jumpFromTv;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isControlMode = YES;
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
//    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
//    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
//    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
    
    if (self.needDownloadKeyset) {
        [self downloadKeySetFromServer];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods
- (IBAction)changeMode:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"学习模式"]) {
        self.view.backgroundColor = [UIColor colorWithRed:0.84 green:0.93 blue:0.95 alpha:1];
        sender.title = @"退出学习";
//        MyEIrUserKeyTableViewController *vc = self.childViewControllers[0];
//        vc.tableView.backgroundColor = [UIColor colorWithRed:0.84 green:0.93 blue:0.95 alpha:1];
        self.isControlMode = NO;
    }else{
        self.view.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
        sender.title = @"学习模式";
//        MyEIrUserKeyTableViewController *vc = self.childViewControllers[0];
//        vc.tableView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
        self.isControlMode = YES;
    }
}

- (IBAction)addNewKey:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IrDevice" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"IRDeviceAddNewKeyModal"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
//    formSheet.shouldCenterVerticallyWhenKeyboardAppears = YES;
    //    formSheet.shouldMoveToTopWhenKeyboardAppears = NO;
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        navController.topViewController.title = @"添加新按键";
        
        MyEIrDeviceAddKeyModalViewController *modalVc = (MyEIrDeviceAddKeyModalViewController *)navController.topViewController;
        modalVc.accountData = self.accountData;
        modalVc.device = self.device;
        modalVc.delegate = self;
    };
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
    
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController) {
        [self.tableView reloadData];
    };
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.device.irKeySet.userStudiedKeyList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellTvKey";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIButton *btn = (UIButton *)[cell.contentView viewWithTag:100];
    //现在终于明白了，原来这里并没有进行传值，而是直接读取内存中的值，这个做法值得学习
    MyEIrKey *key = [self.device.irKeySet.userStudiedKeyList objectAtIndex:indexPath.row];
    //    [cell.textLabel setText:key.keyName];
    [btn setTitle:key.keyName forState:UIControlStateNormal];
//    btn.layer.masksToBounds = YES;
//    btn.layer.cornerRadius = 4;
//    btn.layer.borderWidth = 1;
    if (key.status > 0) {
        UIImage *image = [UIImage imageNamed:@"control-enable-normal"];
        UIImage *image2 = [UIImage imageNamed:@"control-enable-highlight"];
        [btn setBackgroundImage:[image stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
        [btn setBackgroundImage:[image2 stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:69/255 green:200/255 blue:220/255 alpha:1] forState:UIControlStateNormal];

//        btn.layer.borderColor = btn.tintColor.CGColor;
//        [btn setTitleColor:btn.tintColor forState:UIControlStateNormal];
    }else{
        UIImage *image = [UIImage imageNamed:@"control-disable-normal"];
        UIImage *image2 = [UIImage imageNamed:@"control-disable-highlight"];
        [btn setBackgroundImage:[image stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
        [btn setBackgroundImage:[image2 stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];

//        btn.layer.borderColor = [UIColor redColor].CGColor;
//        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    
//    cell.backgroundView = [[UIView alloc] init];
//    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
#pragma mark - IBAction methods
- (IBAction)btnPressed:(UIButton *)sender {
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    MyEIrKey *key = [self.device.irKeySet.userStudiedKeyList objectAtIndex:indexPath.row];
    if (self.isControlMode) {
        if (key.status >0) {
            [self sendControlKeyToServer:key];
        }else{
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                        contentText:@"此按键没有学习，请点击右上角【学习模式】学习此按键"
                                                    leftButtonTitle:nil
                                                   rightButtonTitle:@"知道了"];
            [alert show];
        }
    }else{
        [self editStudyKey:key];
    }
}

#pragma mark - private methods
- (void)tapTimerFired:(NSTimer *)aTimer{
    NSIndexPath *indexPath = aTimer.userInfo;
    MyEIrKey *key = [self.device.irKeySet.userStudiedKeyList objectAtIndex:indexPath.row];
    if(key.status == 1)
        [self sendControlKeyToServer:key];
    else
        [self editStudyKey:key];
    //timer fired, there was a single tap on indexPath.row = tappedRow
    if(tapTimer != nil){
        tapCount = 0;
        tappedRow = -1;
    }
}
-(void) handleLongPress: (UIGestureRecognizer *)longPress {
    if (longPress.state==UIGestureRecognizerStateBegan) {
        CGPoint pressPoint = [longPress locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pressPoint];
        MyEIrKey *key = [self.device.irKeySet.userStudiedKeyList objectAtIndex:indexPath.row];
        [self editStudyKey:key];
    }
}
-(void) sendControlKeyToServer:(MyEIrKey *)key
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:key forKey:@"key"];
    
    NSString * urlStr= [NSString stringWithFormat:@"%@?gid=%@&id=%ld&deviceId=%ld&type=%ld",
                        URL_FOR_IR_DEVICE_SEND_CONTROL_KEY,
                        self.accountData.userId,
                        (long)key.keyId,
                        (long)self.device.deviceId,
                        (long)key.type];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self loaderName:IR_DEVICE_SEND_CONTROL_KEY_UPLOADER_NMAE
                                 userDataDictionary:dict];
    NSLog(@"%@",downloader.name);
}
-(void)editStudyKey:(MyEIrKey *)key
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IrDevice" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"IRDeviceStudyEditKeyModal"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.presentedFormSheetSize = CGSizeMake(280, 250);
    //    formSheet.shouldCenterVerticallyWhenKeyboardAppears = YES;
    //    formSheet.shouldMoveToTopWhenKeyboardAppears = NO;
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        navController.topViewController.title = @"按键学习和编辑";
        MyEIrStudyEditKeyModalViewController *modalVc = (MyEIrStudyEditKeyModalViewController *)navController.topViewController;
        modalVc.accountData = self.accountData;
        modalVc.device = self.device;
        //        modalVc.delegate = self;
        modalVc.key = key;
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
        [self.tableView reloadData];
    };
}
#pragma mark - URL private methods
- (void) downloadKeySetFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&tId=%@&id=%ld",URL_FOR_KEY_SET_VIEW, self.accountData.userId, self.device.tId, (long)self.device.deviceId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:IR_KEY_SET_DOWNLOADER_NMAE  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if ([MyEUtil getResultFromAjaxString:string] == -3) {
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
        //       [MyEUtil showErrorOn:self.navigationController.view withMessage:@"用户会话超时，需要重新登录！"];
    }
    if([name isEqualToString:IR_DEVICE_DELETE_KEY_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"删除按键时发生错误！"];
        } else if ([MyEUtil getResultFromAjaxString:string] == 1){
            NSIndexPath *indexPath = (NSIndexPath *)[dict objectForKey:@"indexPath"];
            MyEIrKey *key = [self.device.irKeySet.userStudiedKeyList objectAtIndex:indexPath.row];
            // Delete the row from the data source
            [self.device.irKeySet removeKeyById:key.keyId];
            // Delete the row from the table view
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            self.accountData.needDownloadInstructionsForScene = YES;
        }
    }
    if([name isEqualToString:IR_DEVICE_SEND_CONTROL_KEY_UPLOADER_NMAE]) {
        NSLog(@"sendControlKey string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"发送按键控制时发生错误！"];
        } else if ([MyEUtil getResultFromAjaxString:string] == 1){
            if([MyEUtil getResultFromAjaxString:string] == 1){
//                [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"指令发送成功"];
            } else if([MyEUtil getResultFromAjaxString:string] == -1){
                [MyEUtil showMessageOn:nil withMessage:@"指令发送失败"];
//                [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"指令发送失败"];
            } else
                [MyEUtil showMessageOn:nil withMessage:@"指令发送失败"];
//                [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"指令发送产生错误"];
        }
    }

    if([name isEqualToString:IR_KEY_SET_DOWNLOADER_NMAE]) {
        NSLog(@"%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"下载红外设备指令时发生错误！"];
        } else  if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else  if ([MyEUtil getResultFromAjaxString:string] == 1){
            NSLog(@"ajax json = %@", string);
            MyEIrKeySet *keySet = [[MyEIrKeySet alloc] initWithJSONString:string];
            self.device.irKeySet = keySet;
            [self.tableView reloadData];
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
    else if ([name isEqualToString:IR_DEVICE_DELETE_KEY_UPLOADER_NMAE])
        msg = @"删除按键通信错误，请稍后重试.";
    else if ([name isEqualToString:IR_DEVICE_SEND_CONTROL_KEY_UPLOADER_NMAE])
        msg = @"发送按键控制通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";

    [MyEUtil showErrorOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}
@end
