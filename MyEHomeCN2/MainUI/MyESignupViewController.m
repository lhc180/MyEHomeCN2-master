//
//  MyERegisterViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-31.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyESignupViewController.h"

#import "MyEsettingsMediatorViewController.h"


@interface MyESignupViewController ()

@end

@implementation MyESignupViewController
@synthesize userName,passWord;

- (void)viewDidLoad
{
    [super viewDidLoad];
    userName.pattern = @"^([0-9a-zA-Z]{2}(?:-)){7}[0-9a-zA-Z]{2}$";
    [self defineTapGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)scan:(UIButton *)sender {
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    int i = 0;
    for (UIView *temp in [reader.view subviews]) {
        for (UIView *view in temp.subviews) {
            if ([view isKindOfClass:[UIToolbar class]]) {
                for (UIView *v in view.subviews) {
                    if (i==3) {
                        [v removeFromSuperview];
                    }
                    i++;
                }
            }
        }
//        for (UIButton *button in temp.subviews) {
//            if ([button isKindOfClass:[UIButton class]]) {
//                [button removeFromSuperview];
//            }
//        }
//        if ([temp isKindOfClass:[UIView class]]) {
//            [temp setFrame:CGRectMake(0, 0, 320, 45)];
//            UILabel *nav = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 220, 45)];
//            nav.font = [UIFont boldSystemFontOfSize:17];
//            nav.textColor = [UIColor clearColor];
//            nav.text = @"正在扫描";
//            nav.backgroundColor = [UIColor clearColor];
//            nav.textAlignment = NSTextAlignmentCenter;
//            nav.baselineAdjustment = UIBaselineAdjustmentNone;
//            nav.lineBreakMode = NSLineBreakByTruncatingTail;
//            [temp addSubview:nav];
//        }
    }
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    
    reader.tracksSymbols = YES;
    reader.showsZBarControls = YES;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentViewController:reader animated:YES completion:nil];
}
- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
    if ([symbol.data length] == 30) {
        userName.text = [symbol.data substringToIndex:23];
        passWord.text = [symbol.data substringFromIndex:24];
    }else{
        [MyEUtil showMessageOn:nil withMessage:@"请扫描智能网关背后的二维码"];
    }
    
    // EXAMPLE: do something useful with the barcode image
//    self.resultImage.image =
//    [info objectForKey: UIImagePickerControllerOriginalImage];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:nil];
    if ([userName.text length] == 23 && [passWord.text length] == 6) {
        [self doRegister];
    }
}

- (IBAction)cancle:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registerToServer:(UIButton *)sender {
    [self doRegister];
}

-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [userName endEditing:YES];
    [passWord endEditing:YES];
}

-(void)doRegister {
    // 如果用户名和密码的输入不足长度，提示后退出
    if([self.userName.text  length] < 4 || [self.passWord.text length] < 6) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"提示"
                                                      message:@"用户名或密码不正确，请检查."
                                                     delegate:nil
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil];
        [alert show];
        return;
    }
    // 1.判断是否联网：
    if (![MyEDataLoader isConnectedToInternet]) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"提示"
                                                      message:@"没有网络连接，请打开网络后重试."
                                                     delegate:nil
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
        HUD.labelText = @"正在注册";
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?username=%@&password=%@&type=1", URL_FOR_LOGIN, self.userName.text, self.passWord.text] ;
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"registerUploader" userDataDictionary:nil];
    NSLog(@"registerUploader is  %@ urlStr =  %@",downloader.name, urlStr);
}
#pragma mark -
#pragma mark URL Loading System methods

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"register JSON String from server is \n%@",string);
    if([name isEqualToString:@"registerUploader"]) {
        
        MyEAccountData *anAccountData = [[MyEAccountData alloc] initWithJSONString:string];
            if(anAccountData && anAccountData.loginSuccess) {
                self.accountData = anAccountData;
            }
        if (self.accountData.loginSuccess == -3) {
            [MyEUtil showMessageOn:self.view withMessage:@"用户已禁用！"];
        }else if (self.accountData.loginSuccess == 1){
            if ([self.accountData.mId length] == 0) {
                [self performSegueWithIdentifier:@"signUpToMediator" sender:self];
            }
        }else if(self.accountData.loginSuccess == -1){
            [MyEUtil showMessageOn:self.view withMessage:@"PIN码输入错误！"];
        }else{
            [MyEUtil showMessageOn:self.view withMessage:@"注册失败，请检查是否输入有误！"];
        }
    }
    
    [HUD hide:YES];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"错误"
                                                  message:@"通信错误，请稍后重试."
                                                 delegate:nil
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil];
    [alert show];
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [HUD hide:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"signUpToMediator"]) {
        MyEsettingsMediatorViewController *vc = segue.destinationViewController;
        vc.changeValue = 1;
        vc.accountData = self.accountData;
    }
}

@end
