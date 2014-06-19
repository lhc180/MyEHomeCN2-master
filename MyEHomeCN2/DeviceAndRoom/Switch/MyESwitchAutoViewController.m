//
//  MyESwitchAutoViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchAutoViewController.h"

@interface MyESwitchAutoViewController ()

@end

@implementation MyESwitchAutoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li",URL_FOR_SWITCH_SCHEDULE_LIST,(long)self.device.deviceId] andName:@"scheduleList"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

}
-(void)viewWillAppear:(BOOL)animated{
    if (self.jumpFromSubView) {
        self.jumpFromSubView = NO;
        [self.enableSeg setEnabled:YES forSegmentAtIndex:0];
        [self.enableSeg setSelectedSegmentIndex:0];
    }
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li",URL_FOR_SWITCH_SCHEDULE_LIST,(long)self.device.deviceId] andName:@"scheduleList"];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction methods
- (IBAction)enableProcess:(UISegmentedControl *)sender {
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li&enable=%i",URL_FOR_SWITCH_SCHEDULE_ENABLE,(long)self.device.deviceId,1-sender.selectedSegmentIndex] andName:@"enableProcess"];
}
#pragma mark - private methods
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)passValueToChildrenVC{
    MyESwitchScheduleViewController *vc = self.childViewControllers[0];
    vc.device = self.device;
    vc.control = self.control;
    [vc.tableView reloadData];
}
-(void)doThisWhenNeedDownLoadOrUploadInfoWithURLString:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    NSLog(@"%@ string is %@",name,url);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@ is %@",name,loader.name);
}
#pragma mark - navigation methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"add"]) {
        MyESwitchScheduleSettingViewController *vc = segue.destinationViewController;
        vc.device = self.device;
        vc.control = self.control;
        vc.actionType = 1;  //表示新增进程
    }
}
#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if ([name isEqualToString:@"enableProcess"]) {
        NSLog(@"enableProcess string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:@"设置进程失败"];
        }
    }
    if ([name isEqualToString:@"scheduleList"]) {
        NSLog(@"scheduleList string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            MyESwitchAutoControl *control = [[MyESwitchAutoControl alloc] initWithString:string];
            self.control = control;
            [self.enableSeg setSelectedSegmentIndex:1- control.enable];
            if (![self.control.SSList count]) {   //如果没有进程，则第一个item不能被点击
                [self.enableSeg setEnabled:NO forSegmentAtIndex:0];
            }
            [self passValueToChildrenVC];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:@"下载进程数据失败"];
        }
    }
}
@end
