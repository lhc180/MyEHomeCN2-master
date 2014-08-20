//
//  MyECurtainControlViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-12-11.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyECurtainControlViewController.h"

#define IR_KEY_SET_DOWNLOADER_NMAE @"IrKeySetDownloader"
#define IR_DEVICE_SEND_CONTROL_KEY_UPLOADER_NMAE @"IRDeviceSencControlKeyUploader"

@interface MyECurtainControlViewController ()

@end

@implementation MyECurtainControlViewController

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
    isControlMode = YES;
    [self downloadKeySetFromServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)curtainControl:(UIButton *)sender {
   // 关键是这里容易出问题，测试的时候注意些
    MyEIrKey *key = nil;
    if (isControlMode) {
        if ([self.device.irKeySet.mainArray count] != 0) {
            key = self.device.irKeySet.mainArray[0];
            [self sendControlKeyToServer:key andRunTimes:1];
        }else{
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                        contentText:@"此按键尚未学习，请点击右上角【学习模式】学习此按键"
                                                    leftButtonTitle:nil
                                                   rightButtonTitle:@"知道了"];
            [alert show];
        }
    }else{
        [self editStudyKey:key];
    }
}
- (IBAction)studyInstruction:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"学习模式"]) {
        sender.title = @"退出学习";
        isControlMode = NO;
    }else{
        sender.title = @"学习模式";
        isControlMode = YES;
    }
}
#pragma mark - private methods
-(void)editStudyKey:(MyEIrKey *)key
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IrDevice" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"IRDeviceStudyEditKeyModal"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.shouldCenterVerticallyWhenKeyboardAppears = YES;
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
    };
    
    [self presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        UINavigationController *navController = (UINavigationController *)formSheetController.presentedFSViewController;
        MyEIrStudyEditKeyModalViewController *vc = (MyEIrStudyEditKeyModalViewController *)(navController.topViewController);
        vc.keyNameTextfield.text = @"窗帘开/关";
        vc.keyNameTextfield.enabled = NO;
        vc.deleteKeyBtn.enabled = NO;
    }];
    
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController) {
    };
}

#pragma mark - URL private methods
- (void) downloadKeySetFromServer
{
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&tId=%@&id=%ld",URL_FOR_KEY_SET_VIEW, self.accountData.userId, self.device.tId, (long)self.device.deviceId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:IR_KEY_SET_DOWNLOADER_NMAE  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
-(void) sendControlKeyToServer:(MyEIrKey *)key andRunTimes:(NSInteger)runTimes
{
    NSDictionary *dict;
    if (key) {
        dict = [NSDictionary dictionaryWithObject:key forKey:@"key"];
    }
    
    NSString * urlStr= [NSString stringWithFormat:@"%@?gid=%@&id=%ld&deviceId=%ld&type=%ld&runCount=%i",
                        URL_FOR_IR_DEVICE_SEND_CONTROL_KEY,
                        self.accountData.userId,
                        (long)key.keyId,
                        (long)self.device.deviceId,
                        (long)key.type,runTimes];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self loaderName:IR_DEVICE_SEND_CONTROL_KEY_UPLOADER_NMAE
                                 userDataDictionary:dict];
    NSLog(@"%@",downloader.name);
}
#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:IR_KEY_SET_DOWNLOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"下载红外设备指令时发生错误！"];
        } else  if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"用户会话超时，需要重新登录！"];
        } else  if ([MyEUtil getResultFromAjaxString:string] == 1){
            NSLog(@"ajax json = %@", string);
            MyEIrKeySet *keySet = [[MyEIrKeySet alloc] initWithJSONString:string];
            self.device.irKeySet = keySet;
        }
    }
    if([name isEqualToString:IR_DEVICE_SEND_CONTROL_KEY_UPLOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"发送按键控制时发生错误！"];
        } else if ([MyEUtil getResultFromAjaxString:string] == 1){
            if([MyEUtil getResultFromAjaxString:string] == 1){
                [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"指令发送成功"];
            } else if([MyEUtil getResultFromAjaxString:string] == -1){
                [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"指令发送失败"];
            } else
                [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"指令发送产生错误"];
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
}

@end
