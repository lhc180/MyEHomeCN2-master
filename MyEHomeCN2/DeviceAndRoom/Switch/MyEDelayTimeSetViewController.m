//
//  MyEDelayTimeSetViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-5.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyEDelayTimeSetViewController.h"

@interface MyEDelayTimeSetViewController ()

@end

@implementation MyEDelayTimeSetViewController

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
    _selectedRow = 61;  //对该值进行初始化
    _tableArray = [NSMutableArray arrayWithCapacity:60];
    for (int i = 1; i <= 60; i++) {
        [_tableArray addObject:[NSString stringWithFormat:@"%i分钟",i]];  //可变数组在使用前一定要先初始化
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)submitResult:(id)sender {
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li&channels=%@&action=1",URL_FOR_SWITCH_TIME_DELAY,(long)self.device.deviceId,[NSString stringWithFormat:@"%i",self.index.row+1]] andName:@"checkIfRight"];
}
- (IBAction)cancel:(id)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}
#pragma mark - private methods
-(void)doThisWhenNeedDownLoadOrUploadInfoWithURLString:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    NSLog(@"%@ string is %@",name,url);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@ is %@",name,loader.name);
}
-(void)doThisToChangeStatus{
    self.status.delayStatus = 1;
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?allChannel=%@",URL_FOR_SWITCH_TIME_DELAY_SAVE,[[MyESwitchChannelStatus alloc] jsonStringWithStatus:self.status]] andName:@"uploadDelayInfo"];
}
#pragma mark - url delegate Methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:@"checkIfRight"]){
        NSLog(@"checkIfRight string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示" contentText:@"当前开关路数与启用的定时控制有冲突,确定需要保存么?" leftButtonTitle:@"取消" rightButtonTitle:@"确定"];
            alert.rightBlock = ^{
                [self doThisToChangeStatus];
            };
            alert.leftBlock = ^{
                [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
            };
            [alert show];
        }
        if ([MyEUtil getResultFromAjaxString:string] == 2) {
            [self doThisToChangeStatus];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:@"数据获取失败"];
        }
        if ([MyEUtil getResultFromAjaxString:string] == 0) {
            [MyEUtil showMessageOn:nil withMessage:@"传入的数据有误"];
        }
    }
    if ([name isEqualToString:@"uploadDelayInfo"]) {
        NSLog(@"uploadDelayInfo string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            self.selectedBtnIndex = 100;
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == 0) {
            [MyEUtil showMessageOn:nil withMessage:@"上传数据有误"];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:@"下载数据出错"];
        }
        
    }

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_tableArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = _tableArray[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedRow = indexPath.row;
    self.status.delayMinute = indexPath.row+1;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    int  row  = [indexPath row];
    if(row == _selectedRow)
        return UITableViewCellAccessoryCheckmark;
    return UITableViewCellAccessoryNone;
}
@end
