//
//  MyESettingFeedbackViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-23.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyESettingFeedbackViewController.h"

@interface MyESettingFeedbackViewController ()

@end

@implementation MyESettingFeedbackViewController

@synthesize titleTextField,contentTextView;


#pragma mark
#pragma mark View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    contentTextView.delegate = self;
    //这里是使用代码给textview加上边框，之前采用的是最搓的方式，就是在textview的四周加上了四个宽度为1的view
    contentTextView.layer.masksToBounds = YES;
    contentTextView.layer.cornerRadius = 5;
    contentTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    contentTextView.layer.borderWidth = 0.5;
}

#pragma mark
#pragma mark private methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(void)doThisWhenNeedPopUp{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark
#pragma mark textView Delegate methods
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"请在此输入您想要反馈的内容"]) {
        textView.text = @"";
    }
}

#pragma mark
#pragma mark memory methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark
#pragma mark downloadOrUpload data methods
- (void) uploadUserFeedBackContentsToServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@?title=%@&viewsContent=%@",URL_FOR_SETTINGS_USER_FEEDBACK,titleTextField.text,contentTextView.text];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"uploadUserFeedBackContentsToServer" userDataDictionary:nil];
    NSLog(@"uploadUserFeedBackContentsToServer is %@",downloader.name);
}

#pragma mark
#pragma mark MyEDataLoader Delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    
    [HUD hide:YES];
    if([name isEqualToString:@"uploadUserFeedBackContentsToServer"]) {
        NSLog(@"uploadUserFeedBackContentsToServer JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:nil withMessage:@"与服务器通讯发生异常，请重试"];
        } else{
            [MyEUtil showThingsSuccessOn:self.view WithMessage:@"发送成功" andTag:YES];
            [self performSelector:@selector(doThisWhenNeedPopUp) withObject:nil afterDelay:1.5];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg = @"与服务器通信时发生错误，请稍后重试.";
    
    [MyEUtil showMessageOn:nil withMessage:msg];
    [HUD hide:YES];
}

#pragma mark
#pragma mark IBAction methods
- (IBAction)sendEdit:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    if ([titleTextField.text length] == 0 || [contentTextView.text isEqualToString:@"请在此输入您想要反馈的内容"]) {
        [MyEUtil showMessageOn:nil withMessage:@"请输入内容后再点击【发送】按钮"];
    }else{
        [self uploadUserFeedBackContentsToServer];
    }
}

@end
