//
//  MyEInstructionManageViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-2-17.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyEInstructionManageViewController.h"
#import "MyEAcStandardInstructionViewController.h"
#import "MyEAcCustomInstructionViewController.h"

@interface MyEInstructionManageViewController (){
    MyEAcStandardInstructionViewController *standard;
    MyEAcCustomInstructionViewController *custom;
}

@end

@implementation MyEInstructionManageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"指令库管理";
    if (![self.device.brand isEqualToString:@""]) {
        self.brandLabel.text = [NSString stringWithFormat:@"%@   %@",self.device.brand,self.device.model];
    }else{
        self.brandLabel.text = @"空调未初始化";
    }
    if (IS_IOS6) {
        self.selectSeg.layer.borderColor = MainColor.CGColor;
        self.selectSeg.layer.borderWidth = 1.0f;
        self.selectSeg.layer.cornerRadius = 4.0f;
        self.selectSeg.layer.masksToBounds = YES;
    }

    standard = [self.storyboard instantiateViewControllerWithIdentifier:@"standard"];
    custom = [self.storyboard instantiateViewControllerWithIdentifier:@"custom"];
    standard.device = self.device;
    custom.device = self.device;
    
    //特别注意此处的delegate的赋值，使用点语法无法正确赋值，但是使用下面的方法可以正确赋值，这对于以后的代码书写有着很好的提示作用
    [standard setValue:custom forKey:@"delegate"];
    [self.mainView addSubview:standard.view];
}
- (IBAction)changeView:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        if (custom.view) {
            [custom.view removeFromSuperview];
        }
        [self.mainView addSubview:standard.view];
    }else{
        if (standard.brandsAndModels == nil) { //做这个处理是为了防止数据还没有下载完成时用户就点击切换了，此时不允许这样操作
            [sender setSelectedSegmentIndex:0];
            return;
        }
        if (standard.view) {
            [standard.view removeFromSuperview];
        }
        [self.mainView addSubview:custom.view];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
