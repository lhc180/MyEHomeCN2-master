//
//  MyEACManualControlNavController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-19.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyEACManualControlNavController.h"
#import "MyEAcUserModelViewController.h"
#import "MyEAcManualControlViewController.h"
@interface MyEACManualControlNavController ()

@end

@implementation MyEACManualControlNavController

#pragma mark - life cycle method
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.device.isSystemDefined) {
        MyEAcUserModelViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"customControl"];
        vc.accountData = self.accountData;
        vc.device = self.device;
        [self setViewControllers:@[vc] animated:YES];
//        [self addChildViewController:vc];
//        [self.view addSubview:vc.view];
    }else{
        MyEAcManualControlViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"standerdControl"];
        vc.accountData = self.accountData;
        vc.device = self.device;
        [self setViewControllers:@[vc] animated:YES];
//        [self addChildViewController:vc];
//        [self.view addSubview:vc.view];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
