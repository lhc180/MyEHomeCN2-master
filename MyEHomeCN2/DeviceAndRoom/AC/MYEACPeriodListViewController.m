//
//  MYEACPeriodListViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/12.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEACPeriodListViewController.h"
#import "MultiSelectSegmentedControl.h"
#import "MyEAcUtil.h"


#define AUTO_CONTROL_PROCESS_UPLOADER_NMAE @"AutoControlProcessUploader"


@interface MYEACPeriodListViewController ()<MyEDataLoaderDelegate,MultiSelectSegmentedControlDelegate,UIAlertViewDelegate>{
    MBProgressHUD *HUD;
    NSIndexPath *_selectedIndex;
    MyEAutoControlProcess *_processNew;
}
@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *daySegmentedControl;

@end

@implementation MYEACPeriodListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IS_IOS6) {
        self.daySegmentedControl.layer.borderColor = MainColor.CGColor;
        self.daySegmentedControl.layer.borderWidth = 1.0f;
        self.daySegmentedControl.layer.cornerRadius = 4.0f;
        self.daySegmentedControl.layer.masksToBounds = YES;
    }
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    
    self.daySegmentedControl.mydelegate = self;
    _processNew = [self.process copy];
    [self refreshDaySegmentedControl];
    UIButton *btn = (UIButton *)[self.tableView.tableHeaderView viewWithTag:100];
    [MyEUtil makeFlatButton:btn];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"stid" ascending:YES]];
    [_processNew.periods sortUsingDescriptors:sortDescriptors];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Private methods
- (void)refreshDaySegmentedControl{  //这里是设置星期的
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    for (NSNumber *day in _processNew.days) {
        [mutableIndexSet addIndex:[day intValue] - 1];
    }
    [self.daySegmentedControl setSelectedSegmentIndexes: mutableIndexSet];
    for (NSNumber *day in self.unavailableDays) {
        [self.daySegmentedControl setEnabled:NO forSegmentAtIndex:[day intValue] - 1];
    }
}
#pragma mark - IBAction methods
- (IBAction)saveProcess:(UIButton *)sender {
    if([_processNew.periods count] == 0){
        [MyEUtil showMessageOn:self.view withMessage:@"进程必须至少有一个时段"];
        return;
    }
    if([_processNew.days count] == 0){
        [MyEUtil showMessageOn:self.view withMessage:@"进程必须至少应用到某一天"];
        return;
    }
    if([_processNew isValid])
        [self uploadProcessToServerAndReturn];
    else
        [MyEUtil showMessageOn:self.view withMessage:@"进程无效，请确保时段没有重叠"];

}

- (IBAction)selectDays:(MultiSelectSegmentedControl *)sender {
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _processNew.periods.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MyEAutoControlPeriod *period = _processNew.periods[indexPath.row];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@-%@", period.startTimeString, period.endTimeString]];
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@,%@,%@",
                                       [MyEAcUtil getStringForRunMode:period.runMode],
                                       [MyEAcUtil getStringForSetpoint:period.setpoint],
                                       [MyEAcUtil getStringForWindLevel:period.windLevel]]];
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"时段列表:";
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_processNew.periods removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *vc = segue.destinationViewController;
    [vc setValue:_processNew forKey:@"process"];
    [vc setValue:self.device forKey:@"device"];
    MyEAutoControlPeriod *period = nil;
    if ([segue.identifier isEqualToString:@"add"]) {
        [vc setValue:@(YES) forKey:@"isAddNew"];
        period = [[MyEAutoControlPeriod alloc] init];
    }else
        period = _processNew.periods[[self.tableView indexPathForCell:sender].row];
    [vc setValue:period forKey:@"period"];
}

#pragma mark - MultiSelectedSegmentedControlDelegate method
- (void)multiSelect:(MultiSelectSegmentedControl *)multiSelecSegmendedControl didChangeValue:(BOOL)value atIndex:(NSUInteger)index{
    [_processNew.days removeAllObjects];
    //below Iterating Through Index Sets, to update the days array
    NSIndexSet *anIndexSet = self.daySegmentedControl.selectedSegmentIndexes;
    if ([anIndexSet count] == 0) {
        [MyEUtil showMessageOn:self.view withMessage:@"必须选择应用到某一天"];
        return;
    }
    NSUInteger idx=[anIndexSet firstIndex];
    
    while(idx != NSNotFound)
    {
        [_processNew.days addObject:[NSNumber numberWithInteger:idx + 1]];
        idx=[anIndexSet indexGreaterThanIndex: idx];
    }
}

#pragma mark URL Loading System methods
- (void) uploadProcessToServerAndReturn
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    NSInteger action = 1; // 0 for add new, 1 for edit, 2 for delete
    if (self.isAddNew) {
        action = 0;
    }
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *dataString = [writer stringWithObject:[_processNew JSONDictionary]];
    
        NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&id=%ld&deviceId=%ld&action=%ld&data=%@",
                            GetRequst(URL_FOR_AC_UPLOAD_AC_AUTO_PROCESS_SAVE),
                            MainDelegate.accountData.userId,
                            (long)_processNew.pId,
                            (long)self.device.deviceId,
                            (long)action,
                            dataString];
        NSLog(@"json string for uploading Process is :\n %@", urlStr);
        MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                     initLoadingWithURLString:urlStr
                                     postData:Nil
                                     delegate:self loaderName:AUTO_CONTROL_PROCESS_UPLOADER_NMAE
                                     userDataDictionary:nil];
        NSLog(@"%@",downloader.name);
}

#pragma mark - URL Delegate methods
// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:AUTO_CONTROL_PROCESS_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"上传空调自动控制进程时发生错误！"];
        } else  if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else{
            if(_isAddNew){ // 新添加的， 更新其进程id
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                // 把JSON转为字典
                NSDictionary *result_dict = [parser objectWithString:string];
                NSInteger processId = [[result_dict objectForKey:@"id"] intValue];
                _processNew.pId = processId;
                [self.list.mainArray addObject:_processNew];
            }else{
                if ([self.list.mainArray containsObject:self.process]) {
                    NSInteger i = [self.list.mainArray indexOfObject:self.process];
                    [self.list.mainArray removeObjectAtIndex:i];
                    [self.list.mainArray insertObject:_processNew atIndex:i];
                }
            }
            self.list.enable = YES;
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
@end
