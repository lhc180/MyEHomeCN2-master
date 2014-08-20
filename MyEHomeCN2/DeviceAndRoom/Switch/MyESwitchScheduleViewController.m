//
//  MyESwitchScheduleViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchScheduleViewController.h"
#import "MyESwitchAutoViewController.h"
@interface MyESwitchScheduleViewController ()

@end

@implementation MyESwitchScheduleViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init]; //table的下部没有表格视图
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MyESwitchAutoViewController *vc = (MyESwitchAutoViewController *)self.parentViewController;
    if (![self.control.SSList count]) {
        [vc.enableSeg setEnabled:NO forSegmentAtIndex:0];
        [vc.enableSeg setSelectedSegmentIndex:1];
        [MyEUniversal dothisWhenTableViewIsEmptyWithMessage:@"当前没有有效进程,请点击右上角“+”进行添加" andFrame:CGRectMake(20, 20, 280, 50) andVC:self];
    }else{
        [vc.enableSeg setEnabled:YES forSegmentAtIndex:0];
        //以下两种方式都可以，明显上面这个更好些
        if([self.view.subviews containsObject:[self.view viewWithTag:999]]){
            [[self.view viewWithTag:999] removeFromSuperview];
        }
    }
    return [self.control.SSList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MyESwitchSchedule *s = self.control.SSList[indexPath.row];
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *channelLabel = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *weekLabel = (UILabel *)[cell.contentView viewWithTag:103];
    timeLabel.text = [NSString stringWithFormat:@"%@ - %@",s.onTime,s.offTime];
    channelLabel.text = [s.channels componentsJoinedByString:@","];  //这里也算是个技巧，需要留意
    weekLabel.text = [s.weeks componentsJoinedByString:@","];
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MyESwitchSchedule *s = self.control.SSList[indexPath.row];
        _index = indexPath;
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示" contentText:@"确定删除此进程么?" leftButtonTitle:@"取消" rightButtonTitle:@"确定"];
        alert.rightBlock = ^{
            [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li&scheduleId=%li&action=3",URL_FOR_SWITCH_SCHEDULE_SAVE,(long)self.device.deviceId,(long)s.scheduleId] andName:@"deleteSchedule"];
        };
        [alert show];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *indexPath = (NSIndexPath *)[self.tableView indexPathForSelectedRow];   //这里要重点留意一下,先试试，看看效果怎么样
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    MyESwitchScheduleSettingViewController *vc = segue.destinationViewController;
    vc.device = self.device;
    vc.actionType = 2;
    vc.control = self.control;
    vc.schedule = self.control.SSList[indexPath.row];
}
#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"deleteSchedule string is %@",string);
    if ([MyEUtil getResultFromAjaxString:string] == 1) {
        //先删除数据源，再删除行,顺序不能颠倒
        [self.control.SSList removeObjectAtIndex:_index.row];
        [self.tableView deleteRowsAtIndexPaths:@[_index] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if ([MyEUtil getResultFromAjaxString:string] == -3) {
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
    }
    if ([MyEUtil getResultFromAjaxString:string] == -1) {
        [MyEUtil showMessageOn:nil withMessage:@"删除进程失败"];
    }
}
@end
