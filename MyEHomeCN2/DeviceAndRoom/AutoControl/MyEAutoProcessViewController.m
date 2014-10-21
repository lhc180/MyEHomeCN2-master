//
//  MyEAcProcessViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/19/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAutoProcessViewController.h"
#import "MyEAutoControlProcess.h"
#import "MyEAutoControlPeriod.h"
#import "MyEAutoPeriodListViewController.h"
#import "MyEAutoPeriodViewController.h"
#import "MyEAutoControlViewController.h"
#import "MyEAutoProcessListViewController.h"
#import "MyEAccountData.h"
#import "MyEDevice.h"
#import "SBJson.h"
#import "MyEUtil.h"

#define AUTO_CONTROL_PROCESS_UPLOADER_NMAE @"AutoControlProcessUploader"

@interface MyEAutoProcessViewController ()

@end

@implementation MyEAutoProcessViewController
@synthesize process = _process,
    unavailableDays = _unavailableDays,
    isAddNew = _isAddNew, device,saveProcessBtn;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isAddNew = NO;
    }
    return self;
}
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    //进来之后找到VC，直接进行传值
    MyEAutoPeriodListViewController *vc = [self.childViewControllers objectAtIndex:0];
    vc.device = self.device;
    vc.periodList = self.process.periods;
    [vc.tableView reloadData];
    
    [self refreshDaySegmentedControl];
    
    if (!IS_IOS6) {
        [saveProcessBtn.layer setMasksToBounds:YES];
        [saveProcessBtn.layer setCornerRadius:3];
        [saveProcessBtn.layer setBorderWidth:1];
        [saveProcessBtn.layer setBorderColor:saveProcessBtn.tintColor.CGColor];
    }
    if (IS_IOS6) {
        self.daySegmentedControl.layer.borderColor = MainColor.CGColor;
        self.daySegmentedControl.layer.borderWidth = 1.0f;
        self.daySegmentedControl.layer.cornerRadius = 4.0f;
        self.daySegmentedControl.layer.masksToBounds = YES;
    }

    self.daySegmentedControl.mydelegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self decideIfProcessedChanged];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - setter
- (void)setProcess:(MyEAutoControlProcess *)process{
    if (_process != process) {
        _process = process;
        process_copy = [process copy];
    }
}

#pragma mark - private methods
//- (void)addNewPeriod
//{
//    [self performSegueWithIdentifier:@"AcProcessViewToAddPeriod" sender:self];
//}

- (void)refreshDaySegmentedControl{  //这里是设置星期的
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    for (NSNumber *day in self.process.days) {
        [mutableIndexSet addIndex:[day intValue] - 1];
    }
    [self.daySegmentedControl setSelectedSegmentIndexes: mutableIndexSet];
    for (NSNumber *day in self.unavailableDays) {
        [self.daySegmentedControl setEnabled:NO forSegmentAtIndex:[day intValue] - 1];
    }
}
#pragma mark - utilities
- (BOOL)decideIfProcessedChanged
{
    BOOL changed = NO;
    if (self.process != Nil && process_copy != Nil) {
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *original = [writer stringWithObject:[self.process JSONDictionary]];
        NSString *copy = [writer stringWithObject:[process_copy JSONDictionary]];
        NSLog(@"original len = %lu, copy loen = %lu", (unsigned long)[original length], (unsigned long)[copy length]);
        if ([original isEqualToString:copy]) {
            self.saveProcessBtn.hidden = YES;
            changed = NO;
        }else{
            self.saveProcessBtn.hidden = NO;
            changed = YES;
        }
    }
    return changed;
}

#pragma mark - MultiSelectedSegmentedControlDelegate method
- (void)multiSelect:(MultiSelectSegmentedControl *)multiSelecSegmendedControl didChangeValue:(BOOL)value atIndex:(NSUInteger)index{
    if (value) {
        NSLog(@"multiSelect with tag %li selected button at index: %lu", (long)multiSelecSegmendedControl.tag, (unsigned long)index);
    } else {
        NSLog(@"multiSelect with tag %li deselected button at index: %lu", (long)multiSelecSegmendedControl.tag, (unsigned long)index);
    }
    [self.process.days removeAllObjects];
    //below Iterating Through Index Sets, to update the days array
    NSIndexSet *anIndexSet = self.daySegmentedControl.selectedSegmentIndexes;
    if ([anIndexSet count] == 0) {
        [MyEUtil showMessageOn:self.view withMessage:@"必须选择应用到某一天"];
        return;
    }
    NSUInteger idx=[anIndexSet firstIndex];
    
    while(idx != NSNotFound)
    {
        [self.process.days addObject:[NSNumber numberWithInteger:idx + 1]];
        idx=[anIndexSet indexGreaterThanIndex: idx];
    }
    [self decideIfProcessedChanged];
}

#pragma mark - Navigation methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"AcProcessViewToAddPeriod"]) {
        MyEAutoPeriodViewController *pvc = [segue destinationViewController];
        pvc.delegate = self;
        MyEAutoControlPeriod *period = [[MyEAutoControlPeriod alloc] init];
        period.stid = [self.process firstAvailablePeriodStid];
        period.etid = period.stid + 1;
        pvc.period = period;
        pvc.device = self.device;
        pvc.isAddNew = YES;
    }
}

#pragma mark - method for MyEAcPeriodViewControllerDelegate
- (void)didFinishEditPeriod:(MyEAutoControlPeriod *)period isAddNew:(BOOL)flag
{
    // 这里除了刷新底下的时段列表之外什么都不用做，因为我们进行的是地址传递，在period面部修改的内容，在这里会体现。
    if (!flag) {
        [[NSException exceptionWithName:@"代理类型错误" reason:@"此处应该是添加新的时段，而不应该是编辑时段" userInfo:Nil] raise];
    }
    NSLog(@"新曾时段%li",(long)period.pId);
    if (period != nil) {
        [self.process.periods addObject:period];
    }
    MyEAutoPeriodListViewController *plvc = [self.childViewControllers objectAtIndex:0];
    [plvc.tableView reloadData];
}
- (BOOL)isTimeFrameValidForPeriod:(MyEAutoControlPeriod *)period{
    return [self.process validatePeriodWithId:period.pId newStid:period.stid newEtid:period.etid];
}

#pragma mark - IBAction methods
- (IBAction)saveProcessAction:(id)sender {
    if([self.process.periods count] == 0){
        [MyEUtil showMessageOn:self.view withMessage:@"进程必须至少有一个时段"];
        return;
    }
    if([self.process.days count] == 0){
        [MyEUtil showMessageOn:self.view withMessage:@"进程必须至少应用到某一天"];
        return;
    }
    if([ self.process isValid])
        [self uploadProcessToServerAndReturn];
    else
        [MyEUtil showMessageOn:self.view withMessage:@"进程无效，请确保时段没有重叠"];
    
}
- (IBAction)saveAndReturnAction:(id)sender {
    if (![self decideIfProcessedChanged]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        NSString *msg;
        BOOL hasError = NO;
        if([self.process.periods count] == 0){
            msg = @"进程必须至少有一个时段。";
            hasError = YES;
        }
        if([self.process.days count] == 0){
            msg = @"进程必须至少应用到某一天。";
            hasError = YES;
        }
        if(![ self.process isValid]){
            msg = @"进程无效，请确保时段没有重叠。";
            hasError = YES;
        }
        if(hasError){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"修改进程" otherButtonTitles:@"返回上级", nil];
            alert.tag = 100;
        } else
            [self uploadProcessToServerAndReturn];
    }
}
#pragma mark -
#pragma mark URL Loading System methods
- (void) uploadProcessToServerAndReturn
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSInteger action = 1; // 0 for add new, 1 for edit, 2 for delete
    if (self.isAddNew) {
        action = 0;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:action], @"action",
                          [NSNumber numberWithInteger:self.process.pId], @"pId",
                          nil];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *dataString = [writer stringWithObject:[self.process JSONDictionary]];
    
    if (self.device.type == 1) {
        NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&id=%ld&deviceId=%ld&action=%ld&data=%@",
                            GetRequst(URL_FOR_AC_UPLOAD_AC_AUTO_PROCESS_SAVE),
                            MainDelegate.accountData.userId,
                            (long)self.process.pId,
                            (long)self.device.deviceId,
                            (long)action,
                            dataString];
        NSLog(@"json string for uploading Process is :\n %@", urlStr);
        MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                     initLoadingWithURLString:urlStr
                                     postData:Nil
                                     delegate:self loaderName:AUTO_CONTROL_PROCESS_UPLOADER_NMAE
                                     userDataDictionary:dict];
        NSLog(@"%@",downloader.name);
    }
    if (self.device.type == 6) {
        NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&id=%ld&deviceId=%ld&action=%ld&data=%@",
                            GetRequst(URL_FOR_UPLOAD_SOCKET_AUTO_PROCESS_SAVE),
                            MainDelegate.accountData.userId,
                            (long)self.process.pId,
                            (long)self.device.deviceId,
                            (long)action,
                            dataString];
        NSLog(@"json string for uploading Process is :\n %@", urlStr);
        MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                     initLoadingWithURLString:urlStr
                                     postData:Nil
                                     delegate:self loaderName:AUTO_CONTROL_PROCESS_UPLOADER_NMAE
                                     userDataDictionary:dict];
        NSLog(@"%@",downloader.name);
    }
}

// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:AUTO_CONTROL_PROCESS_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"上传空调自动控制进程时发生错误！"];
        } else  if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
//            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"用户会话超时，需要重新登录！"];
        } else{
            process_copy = [self.process copy];
            [self decideIfProcessedChanged]; //  for test

            NSInteger action = [[dict objectForKey:@"action"] intValue];
//            NSInteger processId = [[dict objectForKey:@"pId"] intValue]; // original process id, not useful now
            if(action == 0){ // 新添加的， 更新其进程id
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                // 把JSON转为字典
                NSDictionary *result_dict = [parser objectWithString:string];
                NSInteger processId = [[result_dict objectForKey:@"id"] intValue];
                self.process.pId = processId;
            }
            self.saveProcessBtn.hidden = YES;
            // 添加代理方法上传次进程到上一级，保存在进程列表里面。
            if ([_delegate respondsToSelector:@selector(didFinishEditProcess:isAddNew:)])
                [_delegate didFinishEditProcess:self.process isAddNew:self.isAddNew];
            self.process = Nil;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:AUTO_CONTROL_PROCESS_UPLOADER_NMAE])
        msg = @"上传进程通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}

#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
