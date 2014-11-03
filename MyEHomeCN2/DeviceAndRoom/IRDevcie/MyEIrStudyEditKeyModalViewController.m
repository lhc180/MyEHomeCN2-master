//
//  MyEIrStudyEditKeyModalViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/3/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEIrStudyEditKeyModalViewController.h"

#define IR_DEVICE_DELETE_KEY_UPLOADER_NMAE @"IRDeviceDeleteKeyUploader"
#define IR_DEVICE_STUDY_KEY_LOADER_NMAE @"IRDeviceStudyKeyUploader"
#define IR_DEVICE_QUERY_STUDY_KEY_LOADER_NMAE @"IRDeviceQueryStudyKeyLoader"
#define IR_DEVICE_GET_STATUS_LOADER_NMAE @"IRDeviceStatusoader"
#define IR_DEVICE_SEND_KEY_STUDY_TIMEOUT_LOADER_NMAE @"IRDeviceSendKeyStudyTimeoutLoader"
#define IR_DEVICE_VALIDATE_KEY_LOADER_NMAE @"IRDeviceValidateKeyLoader"


@interface MyEIrStudyEditKeyModalViewController (){
    NSTimer *_timer;
}

@end

@implementation MyEIrStudyEditKeyModalViewController
@synthesize key = _key, device = _device;

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                [btn.layer setMasksToBounds:YES];
                [btn.layer setCornerRadius:4];
                [btn.layer setBorderWidth:1];
                [btn.layer setBorderColor:btn.tintColor.CGColor];
            }
        }
    }
    [self defineTapGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)setKey:(MyEIrKey *)key
//{
//    if (_key != key) {
//        _key = key;
//        self.keyNameTextfield.text = key.keyName;
//        if(_key.status == 1){
//            self.validateKeyBtn.enabled = YES;
//        }
//        else{
//            self.validateKeyBtn.enabled = NO;
//            [self.validateKeyBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        }
//
//        if(_key.type == 2){
//            self.keyNameTextfield.enabled = YES;
//            self.deleteKeyBtn.enabled = YES;
//        }
//        else{
//            self.keyNameTextfield.enabled = NO;
//            [self.keyNameTextfield setTextColor:[UIColor grayColor]];
//            self.deleteKeyBtn.enabled = NO;
//            [self.deleteKeyBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        }
//    }
//}
#pragma mark - IBAction methods
- (IBAction)studyKey:(id)sender {
    learnHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    learnHUD.removeFromSuperViewOnHide = YES;
    learnHUD.userInteractionEnabled = YES;
    learnHUD.delegate = self;
    //初始化label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,500)];
    //设置自动行数与字符换行
    [label setNumberOfLines:0];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = _device.type > 11?@"请按下RF设备按键进行学习": @"当智控星屏幕显示Lr--时,请按下遥控器按键进行学习";
    
    UIFont *font = [UIFont fontWithName:@"Arial" size:12];
    //设置一个行高上限
    CGSize size = CGSizeMake(320,2000);
    //计算实际frame大小，并将label的frame变成实际大小
    CGSize labelsize = [label.text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    CGRect newFrame = label.frame;
    newFrame.size.height = labelsize.height;
    label.frame = newFrame;
    [label sizeToFit];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    learnHUD.customView = label;
    //	HUD.color = [UIColor whiteColor];
    learnHUD.mode = MBProgressHUDModeCustomView;
    learnHUD.cornerRadius = 2;
    learnHUD.margin = 10;
    learnHUD.dimBackground = YES;
    
    if (_device.type > 11) {
        NSLog(@"%i",self.key.keyId);
        [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?id=%i&deviceId=%i&keyName=%@&irType=%i&instructionType=%i",GetRequst(URL_FOR_RFDEVICE_INSTRUCTION_STUDY),self.key.keyId,self.device.deviceId,self.keyNameTextfield.text,self.device.type,self.key.type] postData:nil delegate:self loaderName:IR_DEVICE_STUDY_KEY_LOADER_NMAE userDataDictionary:nil];
        return;
    }
    
    NSString * urlStr= [NSString stringWithFormat:@"%@?gid=%@&id=%ld&deviceId=%ld&keyName=%@&tId=%@&irType=%ld&instructionType=%ld",
                        GetRequst(URL_FOR_IR_DEVICE_STUDY_KEY),
                        MainDelegate.accountData.userId,
                        (long)self.key.keyId,
                        (long)self.device.deviceId,
                        self.keyNameTextfield.text,
                        self.device.tId,
                        (long)self.device.type,
                        (long)self.key.type];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self loaderName:IR_DEVICE_STUDY_KEY_LOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
- (IBAction)validateKey:(id)sender {
    if (self.key.status == 0) {
        [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"指令未学习"];
        return;
    }
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?id=%ld",
                                              GetRequst(_device.type>11?URL_FOR_RFDEVICE_INSTRUCTION_VALIDATE:URL_FOR_IR_DEVICE_VALIDATE_KEY),
                                              (long)self.key.keyId] postData:nil delegate:self loaderName: IR_DEVICE_VALIDATE_KEY_LOADER_NMAE userDataDictionary:nil];
}
- (IBAction)deleteKey:(id)sender {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    if (_device.type > 11) {
        [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?deviceId=%i&action=2&id=%i&keyName=%@",GetRequst(URL_FOR_RFDEVICE_INSTRUCTION_EDIT),self.device.deviceId,self.key.keyId,self.keyNameTextfield.text] postData:nil delegate:self loaderName:IR_DEVICE_DELETE_KEY_UPLOADER_NMAE userDataDictionary:nil];
        return;
    }
    NSString * urlStr= [NSString stringWithFormat:@"%@?gid=%@&id=%ld&deviceId=%ld&keyName=%@&tId=%@&type=2&action=2",
                        GetRequst(URL_FOR_IR_DEVICE_ADD_EDIT_KEY_SAVE),
                        MainDelegate.accountData.userId,
                        (long)self.key.keyId,
                        (long)self.device.deviceId,
                        self.key.keyName,
                        self.device.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self loaderName:IR_DEVICE_DELETE_KEY_UPLOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

- (IBAction)closeModal:(id)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
//    NSString * urlStr= [NSString stringWithFormat:@"%@?deviceId=%ld",
//                        GetRequst(URL_FOR_IR_DEVICE_GET_STATUS),
//                        (long)self.device.deviceId];
//    MyEDataLoader *downloader = [[MyEDataLoader alloc]
//                                 initLoadingWithURLString:urlStr
//                                 postData:nil
//                                 delegate:self
//                                 loaderName:IR_DEVICE_GET_STATUS_LOADER_NMAE
//                                 userDataDictionary:nil];
//    NSLog(@"%@",downloader.name);
}

#pragma mark -
#pragma mark UITextField Delegate Methods 委托方法
// 添加每个textfield的键盘的return按钮的后续动作
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.keyNameTextfield ) {
        [textField resignFirstResponder];
        //        [keyNameTextfield becomeFirstResponder];
    }
    
    return  YES;
}
#pragma mark -
#pragma mark private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

- (void) queryStudayProgressTimerFired:(NSTimer *)aTimer
{
    [self queryStudayProgress];
}
#pragma mark - URL private methods
-(void)queryStudayProgress
{
    
    studyQueryTimes ++;
    
    if (self.device.type > 11) {
        [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?id=%i",GetRequst(URL_FOR_RFDEVICE_INSTRUCTION_STUDY_CHECK),self.key.keyId] postData:nil delegate:self loaderName:IR_DEVICE_QUERY_STUDY_KEY_LOADER_NMAE userDataDictionary:nil];
        return;
    }
    
    NSString * urlStr= [NSString stringWithFormat:@"%@?id=%ld&tId=%@",
                        GetRequst(URL_FOR_IR_DEVICE_STUDY_KEY_QUERY_PROGRESS),
                        (long)self.key.keyId,
                        self.device.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self
                                 loaderName:IR_DEVICE_QUERY_STUDY_KEY_LOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
    
}
-(void) sendInstructionStudyTimeout
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString * urlStr= [NSString stringWithFormat:@"%@?tId=%ld",
                        GetRequst(URL_FOR_IR_DEVICE_SEND_STUDY_TIMEOUT),
                        (long)self.device.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self
                                 loaderName:IR_DEVICE_SEND_KEY_STUDY_TIMEOUT_LOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL delegate methods
// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"ajax json = %@", string);
    if ([MyEUtil getResultFromAjaxString:string] == -3) {
        [HUD hide:YES];
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
        return;
    }
    if([name isEqualToString:IR_DEVICE_DELETE_KEY_UPLOADER_NMAE]) {
        [HUD hide:YES];
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"删除按键时发生错误！"];
        } else if ([MyEUtil getResultFromAjaxString:string] == 1){
            [self.device.irKeySet removeKeyById:self.key.keyId];
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            }];
            MainDelegate.accountData.needDownloadInstructionsForScene = YES;
        }
    }
    if([name isEqualToString:IR_DEVICE_STUDY_KEY_LOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"发送按键学习请求时发生错误！"];
            [learnHUD hide:YES];
        } else if ([MyEUtil getResultFromAjaxString:string] == 1){
            self.key.keyName = self.keyNameTextfield.text;
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            // 把JSON转为字典
            NSDictionary *result_dict = [parser objectWithString:string];
            id keyId = [result_dict objectForKey:@"id"];
            if (keyId) { // 设置此按键的id
                self.key.keyId = [keyId intValue];
            }
            studyQueryTimes = 0;
            [self queryStudayProgress];
        }
    }

    if([name isEqualToString:IR_DEVICE_QUERY_STUDY_KEY_LOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == 1){
            [learnHUD hide:YES];
            [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"指令学习成功"];
            // 把这个指令的学习成功标志在数据model里面修改了
            self.key.status = 1;
            // 把校验按钮enable
            self.validateKeyBtn.enabled = YES;
            //            [self.validateKeyBtn setTitleColor:[UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0] forState:UIControlStateNormal];
            MainDelegate.accountData.needDownloadInstructionsForScene = YES;
        } else{
            if(studyQueryTimes >= 6){
                [_timer invalidate];
                [learnHUD hide:YES];
                if (_device.type < 11) {
                    [self sendInstructionStudyTimeout];
                }
                studyQueryTimes = 0;
                [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"学习超时,请重新开始!"];
                //[MyEUtil showErrorOn:self.navigationController.view withMessage:@"学习超时，请重新开始!" ];
                self.key.status = 0;
            } else {
                _timer = [NSTimer scheduledTimerWithTimeInterval:self.device.type > 11?2:5 target:self selector:@selector(queryStudayProgressTimerFired:) userInfo:nil repeats:NO];
            }
        }
    }
    if([name isEqualToString:IR_DEVICE_GET_STATUS_LOADER_NMAE]) {
        NSLog(@"IR_DEVICE_GET_STATUS_LOADER_NMAE string is %@",string);
        [HUD hide:YES];
        // 关闭对话框
        [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        }];
    }
    if([name isEqualToString:IR_DEVICE_SEND_KEY_STUDY_TIMEOUT_LOADER_NMAE]) {
        [HUD hide:YES];
        self.key.status = 0;
    }
    if([name isEqualToString:IR_DEVICE_VALIDATE_KEY_LOADER_NMAE]) {
        [HUD hide:YES];
        if ([MyEUtil getResultFromAjaxString:string] == 1){
            [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"校验指令发送成功！"];
        } else if ([MyEUtil getResultFromAjaxString:string] == -1){
            [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"校验指令发送失败！"];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:IR_DEVICE_DELETE_KEY_UPLOADER_NMAE])
        msg = @"删除按键通信错误，请稍后重试.";
    else if ([name isEqualToString:IR_DEVICE_STUDY_KEY_LOADER_NMAE])
        msg = @"发送按键学习请求通信错误，请稍后重试.";
    else if ([name isEqualToString:IR_DEVICE_QUERY_STUDY_KEY_LOADER_NMAE])
        msg = @"查询按键学习进度通信错误，请稍后重试.";
    else if ([name isEqualToString:IR_DEVICE_GET_STATUS_LOADER_NMAE])
        msg = @"指令学习通知通信错误.";
    else if ([name isEqualToString:IR_DEVICE_SEND_KEY_STUDY_TIMEOUT_LOADER_NMAE])
        msg = @"指令学习通知超时通信错误.";
    else if ([name isEqualToString:IR_DEVICE_VALIDATE_KEY_LOADER_NMAE])
        msg = @"指令校验超时通信错误.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}

@end
