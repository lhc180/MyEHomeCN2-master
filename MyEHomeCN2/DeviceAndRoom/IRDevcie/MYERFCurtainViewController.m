//
//  MYERFCurtainViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-8-25.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYERFCurtainViewController.h"
#import "MyEIrStudyEditKeyModalViewController.h"

@interface MYERFCurtainViewController (){
    MBProgressHUD *HUD;
    BOOL _isControlMode;
}

@end

@implementation MYERFCurtainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _device.name;
    _isControlMode = YES;
    [self downloadInstructionsFromServer];
    [self refreshUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - private methods
-(void)downloadInstructionsFromServer{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?id=%i",GetRequst(URL_FOR_RFDEVICE_INSTRUCTIONS),self.device.deviceId] postData:nil delegate:self loaderName:@"instruction" userDataDictionary:nil];
}
-(void)refreshUI{
    for (int i = 601; i < 604; i++) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i];
        NSString *control = nil;
        MyEIrKey *key;
        if (self.device.irKeySet.mainArray.count) {
            key = self.device.irKeySet.mainArray[i - 601];
            control = key.status > 0?@"enable":@"disable";
        }else
            control = @"disable";
        
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"control-%@-normal",control]];
        UIImage *image2 = [UIImage imageNamed:[NSString stringWithFormat:@"control-%@-highlight",control]];
        [btn setBackgroundImage:[image stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
        [btn setBackgroundImage:[image2 stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:69/255 green:200/255 blue:220/255 alpha:1] forState:UIControlStateHighlighted];
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
        modalVc.key = key;
        modalVc.keyNameTextfield.enabled = NO;
        modalVc.deleteKeyBtn.enabled = NO;
        if (key.status > 0) {
            [modalVc.learnBtn setTitle:@"再学习" forState:UIControlStateNormal];
        }else
            modalVc.validateKeyBtn.enabled = NO;
        [modalVc viewDidLoad];
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
#pragma mark - IBAction methods
- (IBAction)deviceControl:(UIButton *)sender {
    if (!self.device.irKeySet.mainArray.count) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"未获取到当前指令信息,服务器返回数据出错" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    MyEIrKey *key = self.device.irKeySet.mainArray[sender.tag - 601];
    if (_isControlMode) {
        if (key.status>0) {
            [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?id=%i&deviceId=%i&type=%i",GetRequst(URL_FOR_RFDEVICE_SEND_INSTRUCTION),key.keyId,_device.deviceId,key.type] postData:nil delegate:self loaderName:@"control" userDataDictionary:nil];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"此按键没有学习，请点击右上角【学习】学习此按键" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
        }
    }else
        [self editStudyKey:key];
}
- (IBAction)studyMode:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"学习"]) {
        sender.title = @"退出学习";
        self.view.backgroundColor = [UIColor colorWithRed:0.84 green:0.93 blue:0.95 alpha:1];
        _isControlMode = NO;
    }else{
        sender.title = @"学习";
        self.view.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
        _isControlMode = YES;
    }
}

#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"string is %@",string);
    NSInteger i = [MyEUtil getResultFromAjaxString:string];
    if ([name isEqualToString:@"instruction"]) {
        if (i == 1) {
            MyEIrKeySet *set = [[MyEIrKeySet alloc] initWithJSONString:string];
            self.device.irKeySet = set;
            [self refreshUI];
        }else if (i == -3){
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备指令下载失败" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
//            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示" contentText:@"该设备的指令没有下载成功!" leftButtonTitle:@"取消" rightButtonTitle:@"重试"];
//            alert.rightBlock = ^{
//                [self downloadInstructionsFromServer];
//            };
            [alert show];
        }
    }
    if ([name isEqualToString:@"control"]) {
        if (i == 1) {
            [MyEUtil showMessageOn:nil withMessage:@"指令发送成功"];
        }else if (i == -3){
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }else{
            [MyEUtil showMessageOn:nil withMessage:@"指令发送失败"];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [MyEUtil showMessageOn:nil withMessage:@"与服务器连接失败"];
}
@end
