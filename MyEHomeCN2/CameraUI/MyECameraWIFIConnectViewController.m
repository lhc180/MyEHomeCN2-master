//
//  MyECameraWIFIConnectViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-6-30.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraWIFIConnectViewController.h"

@interface MyECameraWIFIConnectViewController ()

@end

@implementation MyECameraWIFIConnectViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.wifi.name;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.password becomeFirstResponder];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)connectWifi:(UIBarButtonItem *)sender {
    if (self.password.text.length == 0) {
        return;
    }
    NSInteger result = _m_PPPPChannelMgt->SetWifi((char *)[self.wifi.UID UTF8String], 1, (char *)[self.wifi.name UTF8String], 0, 0, self.wifi.security, 0, 0, 0, (char *)[@"" UTF8String], (char *)[@"" UTF8String], (char *)[@"" UTF8String], (char *)[@"" UTF8String], 0, 0, 0, 0, (char *)[self.password.text UTF8String]);
    if (result == 1) {
        MyECameraWIFISetViewController *vc = self.navigationController.childViewControllers[[self.navigationController.childViewControllers indexOfObject:self] - 1];
        vc.needRefresh = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }else
        [MyEUtil showMessageOn:nil withMessage:@"操作失败,请检测密码是否有误!"];
}

@end
