//
//  MyEIrDeviceAddKeyModalViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/2/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEIrDeviceAddKeyModalViewController.h"

#define IR_DEVICE_ADD_KEY_UPLOADER_NMAE @"IRDeviceAddKeyUploader"

@interface MyEIrDeviceAddKeyModalViewController ()

@end

@implementation MyEIrDeviceAddKeyModalViewController

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
    [self defineTapGestureRecognizer];
}
#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods
- (IBAction)cancelEdit:(UIButton *)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

- (IBAction)confirmNewKey:(id)sender {
    [self.keyNameTextfield resignFirstResponder];
    if ([self.keyNameTextfield.text length] == 0) {
        [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"指令名称不能为空"];
        return;
    }
    if (_device.type < 11) {
        for (int i = 0; i < [self.device.irKeySet.userStudiedKeyList count]; i++) {
            MyEIrKey *key = [self.device.irKeySet.userStudiedKeyList objectAtIndex:i];
            if ([self.keyNameTextfield.text isEqualToString:key.keyName]) {
                [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"按键名称已存在"];
                return;
            }
        }
    }
    [self submitNewKeyToServer];
//    if([self.keyNameTextfield.text length] >= 2){
//        [self submitNewKeyToServer];
//    } else{
//        [MyEUtil showMessageOn:nil withMessage:@"按键名至少2字符"];
//    }
}
#pragma mark - URL private methods
- (void)submitNewKeyToServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    if (_device.type > 11) {
        [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?deviceId=%i&action=0&id=0&keyName=%@",GetRequst(URL_FOR_RFDEVICE_INSTRUCTION_EDIT),self.device.deviceId,self.keyNameTextfield.text] postData:nil delegate:self loaderName:IR_DEVICE_ADD_KEY_UPLOADER_NMAE userDataDictionary:nil];
        return;
    }
    
    NSString *urlStr;
    MyEDataLoader *uploader;
    urlStr= [NSString stringWithFormat:@"%@?gid=%@&id=0&deviceId=%ld&keyName=%@&tId=%@&type=2&action=0",
             GetRequst(URL_FOR_IR_DEVICE_ADD_EDIT_KEY_SAVE),
             self.accountData.userId,
             (long)self.device.deviceId,
             self.keyNameTextfield.text,
             self.device.tId];
    uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:IR_DEVICE_ADD_KEY_UPLOADER_NMAE  userDataDictionary:nil];
    NSLog(@"%@",uploader.name);
}
#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:IR_DEVICE_ADD_KEY_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"添加设备按键时发生错误！"];
        } else{
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *result_dict = [parser objectWithString:string];
            MyEIrKey *key = [[MyEIrKey alloc] initWithId:[[result_dict objectForKey:@"id"] intValue]
                                                 keyName:self.keyNameTextfield.text
                                                    type:2
                                                  status:0];
            [self.device.irKeySet.mainArray addObject:key];
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            }];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:IR_DEVICE_ADD_KEY_UPLOADER_NMAE])
        msg = @"添加红外设备通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}

#pragma mark - UITextField Delegate Methods 委托方法
// 添加每个textfield的键盘的return按钮的后续动作
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.keyNameTextfield ) {
        [textField resignFirstResponder];
        //        [keyNameTextfield becomeFirstResponder];
    }
    return  YES;
}
@end
