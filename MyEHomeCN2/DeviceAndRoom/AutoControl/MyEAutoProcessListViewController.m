//
//  MyEAcAutoControlProcessListViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/17/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAutoProcessListViewController.h"
#import "MyEAutoControlProcessList.h"
#import "MyEAutoControlProcess.h"
#import "MyEAutoProcessViewController.h"
#import "MyEAutoControlViewController.h"
#import "MyEAutoControlViewController.h"
#import "MyEAccountData.h"
#import "MyEDevice.h"
#import "MyEUtil.h"
#import "SBJson.h"

#define AUTO_CONTROL_PROCESS_UPLOADER_NMAE @"AutoControlProcessUploader"

@interface MyEAutoProcessListViewController ()

@end

@implementation MyEAutoProcessListViewController

@synthesize processList = _processList, accountData, device;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - setter methods
- (void)setProcessList:(MyEAutoControlProcessList *)processList{
    _processList = processList;
    [self.tableView reloadData];//重新加载Table数据,这一步骤是重要的，用来现实更新后的数据。
}
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IS_IPHONE5) {
        self.tableView.frame = CGRectMake(0, 0, 320, 366);
    }else
        self.tableView.frame = CGRectMake(0, 0, 320, 278);
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor whiteColor];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning 特别注意此处的东西，有很多值得深刻学习的，一是要写在return的前面，二是下面的方法放在这里很必要，这样以后类似的方法都可以放到这里了
    if ([self.processList.mainArray count] != 0) {
        for (UILabel *l in self.tableView.subviews) {
            if (l.tag == 999) {
                [l removeFromSuperview];
            }
        }
        MyEAutoControlViewController *vc = (MyEAutoControlViewController *)self.parentViewController;
        [vc.enableProcessSegmentedControl setEnabled:YES forSegmentAtIndex:0];
    }else{
        [MyEUniversal dothisWhenTableViewIsEmptyWithMessage:@"当前没有任何有效进程，请先添加" andFrame:CGRectMake(30,40,260,50) andVC:self];
    }
    return [self.processList.mainArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AcAutoControlProcessCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    MyEAutoControlProcess *process = [self.processList.mainArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:process.name];
    NSString *dayString = @"星期：";
    for (NSNumber *day in process.days) {
        dayString = [NSString stringWithFormat:@"%@ %@", dayString, day];
    }
    [cell.detailTextLabel setText:dayString];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

#pragma mark - tableView delegate methods
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        
        if(HUD == nil) {
            HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            HUD.delegate = self;
        } else
            [HUD show:YES];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObject:indexPath forKey:@"indexPath"];
        MyEAutoControlViewController *parentVC = (MyEAutoControlViewController *)self.parentViewController;
        MyEAutoControlProcess *process = [self.processList.mainArray objectAtIndex:indexPath.row];
        
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *dataString = [writer stringWithObject:[process JSONDictionary]];
        if (self.device.type == 1){
            NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&id=%ld&deviceId=%ld&action=2&data=%@",
                                GetRequst(URL_FOR_AC_UPLOAD_AC_AUTO_PROCESS_SAVE),
                                parentVC.accountData.userId,
                                (long)process.pId,
                                (long)parentVC.device.deviceId,
                                dataString];
            MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                         initLoadingWithURLString:urlStr
                                         postData:nil
                                         delegate:self loaderName:AUTO_CONTROL_PROCESS_UPLOADER_NMAE
                                         userDataDictionary:dict];
            NSLog(@"%@",downloader.name);
        }
        if (self.device.type == 6){
            NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&id=%ld&deviceId=%ld&action=2&data=%@",
                                GetRequst(URL_FOR_UPLOAD_SOCKET_AUTO_PROCESS_SAVE),
                                parentVC.accountData.userId,
                                (long)process.pId,
                                (long)parentVC.device.deviceId,
                                dataString];
            MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                         initLoadingWithURLString:urlStr
                                         postData:nil
                                         delegate:self loaderName:AUTO_CONTROL_PROCESS_UPLOADER_NMAE
                                         userDataDictionary:dict];
            NSLog(@"%@",downloader.name);
        }
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"AcProcessListToEditProcess"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        MyEAutoControlViewController *parentVC = (MyEAutoControlViewController *)self.parentViewController;
        MyEAutoProcessViewController *pvc = [segue destinationViewController];

        MyEAutoControlProcess *process = [self.processList.mainArray objectAtIndex:selectedIndexPath.row];
        pvc.process = [process copy];
        pvc.unavailableDays = [self.processList getUnavailableDaysForProcessWithId:process.pId];
        pvc.delegate = self;
        pvc.isAddNew = NO;
        pvc.device = parentVC.device;
        pvc.accountData = parentVC.accountData;
    }
}

#pragma mark - method for MyEAcProcessViewControllerDelegate
- (void)didFinishEditProcess:(MyEAutoControlProcess *)process isAddNew:(BOOL)flag
{
    if (flag) {
        [[NSException exceptionWithName:@"代理类型错误" reason:@"此处不应该是添加新的进程，而应该是编辑进程" userInfo:Nil] raise];
    }
    NSLog(@"更新数据");
    [self.processList updateProcessWith:process];

    [self.tableView reloadData];
}

#pragma mark - URL Loading System methods
// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:AUTO_CONTROL_PROCESS_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"上传空调自动控制进程时发生错误！"];
        } else  if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
  //          [MyEUtil showErrorOn:self.navigationController.view withMessage:@"用户会话超时，需要重新登录！"];
        } else{
            NSIndexPath *indexPath = (NSIndexPath *)[dict objectForKey:@"indexPath"];
            // Delete the row from the data source
            [self.processList.mainArray removeObjectAtIndex:indexPath.row];
            [self.processList renameProcessInList];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            MyEAutoControlViewController *vc = (MyEAutoControlViewController *)self.parentViewController;
            
/*            MyEAutoControlViewController *vc = (MyEAutoControlViewController *)self.view.superview.superview.nextResponder;  这里是两种不同的寻找VC的方法,这个得注意咯
*/
            if (!vc.navigationItem.rightBarButtonItem.enabled) {
                vc.navigationItem.rightBarButtonItem.enabled = YES;
            }
            if ([self.processList.mainArray count] == 0) {
                [MyEUniversal dothisWhenTableViewIsEmptyWithMessage:@"当前没有任何有效进程，请先添加" andFrame:CGRectMake(0,0,200,50) andVC:self];
                [vc.enableProcessSegmentedControl setEnabled:NO forSegmentAtIndex:0];
                [vc.enableProcessSegmentedControl setSelectedSegmentIndex:1];
            }
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
