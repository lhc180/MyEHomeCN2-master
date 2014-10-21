//
//  MYEACProcessListViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/12.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEACProcessListViewController.h"




#define AUTO_CONTROL_PROCESS_DOWNLOADER_NMAE @"AutoControlProcessDownloader"
#define ENABLE_AUTO_PROCESS_UPLOADER_NMAE @"EnableAutoProcessUploader"
#define AUTO_CONTROL_PROCESS_UPLOADER_NMAE @"AutoControlProcessUploader"


@interface MYEACProcessListViewController ()<MyEDataLoaderDelegate>{
    MBProgressHUD *HUD;
    NSIndexPath *_selectedIndex;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;


@end

@implementation MYEACProcessListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (IS_IOS6) {
        self.segControl.layer.borderColor = MainColor.CGColor;
        self.segControl.layer.borderWidth = 1.0f;
        self.segControl.layer.cornerRadius = 4.0f;
        self.segControl.layer.masksToBounds = YES;
    }
    
    [self downloadProcessListFromServer];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self refreshUI];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Private methods
- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)refreshUI{
    [self.segControl setSelectedSegmentIndex:!self.list.enable];
}

#pragma mark - IBAction methods
- (IBAction)controlProcess:(UISegmentedControl *)sender {
    if (self.list.mainArray.count == 0) {
        [self refreshUI];
        return;
    }
    self.list.enable = 1 - sender.selectedSegmentIndex;
    [self enableAllProcess];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.mainArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MyEAutoControlProcess *process = self.list.mainArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"进程 %i",indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"星期: %@",[process.days componentsJoinedByString:@","]];
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"进程列表:";
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _selectedIndex = indexPath;
        [self deleteProcess];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = segue.destinationViewController;
    [vc setValue:self.device forKey:@"device"];
    MyEAutoControlProcess *process = nil;
    if ([segue.identifier isEqualToString:@"add"]) {
        [vc setValue:@(YES) forKey:@"isAddNew"];
        process = [[MyEAutoControlProcess alloc] init];
    }else
        process = self.list.mainArray[[self.tableView indexPathForCell:sender].row];
    [vc setValue:process forKey:@"process"];
    [vc setValue:self.list forKey:@"list"];
    [vc setValue:[self.list getUnavailableDaysForProcessWithId:process.pId] forKey:@"unavailableDays"];
}

#pragma mark - URL Loading System methods

- (void) downloadProcessListFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&id=%ld",GetRequst(URL_FOR_AC_DOWNLOAD_AC_AUTO_CONTROL_VIEW), MainDelegate.accountData.userId,(long)self.device.deviceId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:AUTO_CONTROL_PROCESS_DOWNLOADER_NMAE  userDataDictionary:Nil];
    NSLog(@"%@",downloader.name);
}
-(void)enableAllProcess{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&deviceId=%ld&enable=%i",
                        GetRequst(URL_FOR_AC_ENABLE_AC_AUTO_PROCESS_SAVE),
                        MainDelegate.accountData.userId,
                        (long)self.device.deviceId,
                        self.list.enable];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:ENABLE_AUTO_PROCESS_UPLOADER_NMAE  userDataDictionary:Nil];
    NSLog(@"%@",downloader.name);
}
-(void)deleteProcess{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    MyEAutoControlProcess *process = [self.list.mainArray objectAtIndex:_selectedIndex.row];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *dataString = [writer stringWithObject:[process JSONDictionary]];
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&id=%ld&deviceId=%ld&action=2&data=%@",
                        GetRequst(URL_FOR_AC_UPLOAD_AC_AUTO_PROCESS_SAVE),
                        MainDelegate.accountData.userId,
                        (long)process.pId,
                        (long)self.device.deviceId,
                        dataString];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self loaderName:AUTO_CONTROL_PROCESS_UPLOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);

}
#pragma mark - URL delegate Methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:AUTO_CONTROL_PROCESS_DOWNLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"下载空调自动控制进程时发生错误！"];
        } else  if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else{
            MyEAutoControlProcessList *processList = [[MyEAutoControlProcessList alloc] initWithJSONString:string];
            if(processList){
                self.list = processList;
            }
            [self refreshUI];
            [self.tableView reloadData];
        }
    }
    if([name isEqualToString:ENABLE_AUTO_PROCESS_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
        } else  if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else{
            self.list.enable = !self.list.enable;
            [self refreshUI];
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"启用/停用进程时发生错误！"];
        }
    }
    if([name isEqualToString:AUTO_CONTROL_PROCESS_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"上传空调自动控制进程时发生错误！"];
        } else  if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            //          [MyEUtil showErrorOn:self.navigationController.view withMessage:@"用户会话超时，需要重新登录！"];
        } else{

            [self.list.mainArray removeObjectAtIndex:_selectedIndex.row];
            [self.tableView deleteRowsAtIndexPaths:@[_selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
            self.list.enable = YES;   //删除进程也会导致进程开始
            if ([self.list.mainArray count] == 0) {
                self.list.enable = NO;
            }
            [self refreshUI];
            [self.tableView reloadData];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:AUTO_CONTROL_PROCESS_DOWNLOADER_NMAE])
        msg = @"获取进程列表通信错误，请稍后重试.";
    else if ([name isEqualToString:ENABLE_AUTO_PROCESS_UPLOADER_NMAE])
        msg = @"启用/停用进程通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
    [self refreshUI];
}
@end
