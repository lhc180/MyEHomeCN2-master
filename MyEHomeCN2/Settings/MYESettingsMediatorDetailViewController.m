//
//  MYESettingsMediatorDetailViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/24.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYESettingsMediatorDetailViewController.h"

@interface MYESettingsMediatorDetailViewController ()<MyEDataLoaderDelegate,UIAlertViewDelegate>{
    MBProgressHUD *HUD;
    NSIndexPath *_selectedIndex;
    NSTimer *_checkTimer;   //用于检测红外设备是否成功删除的定时器
    NSInteger _checkTimes;  //用于表示检测的次数
}

@end

@implementation MYESettingsMediatorDetailViewController

#pragma mark - life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"终端列表";
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [rc addTarget:self
           action:@selector(downloadInfoFromServer)
 forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
    [self downloadInfoFromServer];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - private method
-(void)doThisWhenDeleteTerminal{
    [self.mediator.terminals removeObjectAtIndex:_selectedIndex.row];
}
#pragma mark - URL methods
-(void)downloadInfoFromServer{
    if (self.refreshControl.isRefreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中..."];
    }
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?mId=%@",GetRequst(URL_FOR_SETTINGS_MEDIATOR_DETAIL),self.mediator.mid] postData:nil delegate:self loaderName:@"info" userDataDictionary:nil];
}

-(void)deleteTerminalFromServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    MyETerminal *terminal = [self.mediator.terminals objectAtIndex:_selectedIndex.row];
    NSString *urlStr= [NSString stringWithFormat:@"%@?tId=%@",GetRequst(URL_FOR_SETTINGS_TERMINAL_DELETE),terminal.tId];
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"deleteTerminalFromServer"  userDataDictionary:nil];
    NSLog(@"deleteTerminalFromServer is %@",uploader.name);
}
-(void)checkTerminalDelete{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    NSString *str = nil;
    if (_selectedIndex.section == 0) {
        MyETerminal *terminal = [self.mediator.terminals objectAtIndex:_selectedIndex.row];
        str = terminal.tId;
    }else{
        MyESettingSubSwitch *subSwitch = [self.mediator.subSwitchList objectAtIndex:_selectedIndex.row];
        str = subSwitch.tid;
    }
    NSString *urlStr= [NSString stringWithFormat:@"%@?tId=%@&mId=%@",GetRequst(URL_FOR_SETTINGS_TERMINAL_DELETE_CHECK),str,self.mediator.mid];
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"checkDeleteTerminalFromServer"  userDataDictionary:nil];
    NSLog(@"checkDeleteTerminalFromServer is %@",uploader.name);
    
}
-(void)deleteSubSwitchFromServer{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    MyESettingSubSwitch *subSwitch = self.mediator.subSwitchList[_selectedIndex.row];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?gid=%@",GetRequst(URL_FOR_SUBSWITCH_DELETE),subSwitch.gid] postData:nil delegate:self loaderName:@"deleteTerminalFromServer" userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.mediator.subSwitchList.count == 0) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return self.mediator.subSwitchList.count;
    }
    return self.mediator.terminals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        MyETerminal *terminal = self.mediator.terminals[indexPath.row];
        cell.textLabel.text = terminal.name;
        
        if (terminal.irType < 4) {
            switch (terminal.conSignal) {
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"signal1"];
                    break;
                case 2:
                    cell.imageView.image = [UIImage imageNamed:@"signal2"];
                    break;
                case 3:
                    cell.imageView.image = [UIImage imageNamed:@"signal3"];
                    break;
                case 4:
                    cell.imageView.image = [UIImage imageNamed:@"signal4"];
                    break;
                default:
                    cell.imageView.image = [UIImage imageNamed:@"signal0"]; //这个是不在线的图标
                    break;
            }
        }else{
            NSArray *array = @[@"ir",@"smoke",@"door",@"slalarm"];
            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-off",array[terminal.irType - 4]]];
        }
        NSArray *nameArray = @[@"智控星",@"智能插座",@"智能开关",@"红外入侵探测器",@"烟雾探测器",@"门窗磁",@"声光报警器"];
        cell.detailTextLabel.text = nameArray[terminal.irType - 1];
    }else{
        MyESettingSubSwitch *subSwitch = self.mediator.subSwitchList[indexPath.row];
        cell.textLabel.text = subSwitch.name;
        cell.imageView.image = [subSwitch getImage];
        cell.detailTextLabel.text = subSwitch.mainTid.length>0?@"已绑定":@"未绑定";
    }
    
    return cell;
}
#pragma mark - UITableView delegate methods
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0 && self.mediator.terminals.count > 0) {
        return @"智能终端";
    }else if (section == 1 && self.mediator.subSwitchList.count > 0){
        return @"主从开关";
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        MyETerminal *terminal = self.mediator.terminals[indexPath.row];
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:terminal.irType == 1? @"t":@"other"];
        [vc setValue:terminal forKey:@"terminal"];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"subSwitchEdit"];
        MyESettingSubSwitch *subSwitch = self.mediator.subSwitchList[indexPath.row];
        [vc setValue:subSwitch forKey:@"subSwitch"];
        [vc setValue:self.mediator forKey:@"mediator"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _selectedIndex = indexPath;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除" message:@"确定删除此终端吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 100;
        [alert show];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"%@",string);
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    }
    NSInteger i = [MyEUtil getResultFromAjaxString:string];
    if (i == -3) {
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
        return;
    }
    if (i == 1) {
        if ([name isEqualToString:@"info"]) {
            MyEMediator *m = [[MyEMediator alloc] initWithJSONString:string];
            self.mediator.terminals = m.terminals;
            self.mediator.subSwitchList = m.subSwitchList;
            [self.tableView reloadData];
        }
        if([name isEqualToString:@"deleteTerminalFromServer"]){
            [self.mediator.terminals removeObjectAtIndex:_selectedIndex.row];
            if (_selectedIndex.section == 0) {
                [self.mediator.terminals removeObjectAtIndex:_selectedIndex.row];
            }else{
                [self.mediator.subSwitchList removeObjectAtIndex:_selectedIndex.row];
            }
            [self.tableView reloadData];
//            [self.tableView deleteRowsAtIndexPaths:@[_selectedIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            UINavigationController *nav = self.tabBarController.childViewControllers[0];
            UITableViewController *vc = nav.childViewControllers[0];
            [vc setValue:@(YES) forKey:@"needRefresh"];
        }
        if ([name isEqualToString:@"checkDeleteTerminalFromServer"]) {
            if (_selectedIndex.section == 0) {
                [self.mediator.terminals removeObjectAtIndex:_selectedIndex.row];
            }else{
                [self.mediator.subSwitchList removeObjectAtIndex:_selectedIndex.row];
            }
            [self.tableView reloadData];
//            [self.tableView deleteRowsAtIndexPaths:@[_selectedIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            UINavigationController *nav = self.tabBarController.childViewControllers[0];
            UITableViewController *vc = nav.childViewControllers[0];
            [vc setValue:@(YES) forKey:@"needRefresh"];
        }
        if ([name isEqualToString:@"delete"]) {
            [self.mediator.subSwitchList removeObjectAtIndex:_selectedIndex.row];
            [self.tableView deleteRowsAtIndexPaths:@[_selectedIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            UINavigationController *nav = self.tabBarController.childViewControllers[0];
            UITableViewController *vc = nav.childViewControllers[0];
            [vc setValue:@(YES) forKey:@"needRefresh"];
        }
    }else if (i == 2){
        if([name isEqualToString:@"deleteTerminalFromServer"]){
            _checkTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                           target:self
                                                         selector:@selector(checkTerminalDelete)
                                                         userInfo:nil
                                                          repeats:NO];
        }else if ([name isEqualToString:@"checkDeleteTerminalFromServer"]){
            _checkTimes++;
            if (_checkTimes < 6) {
                _checkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTerminalDelete) userInfo:nil repeats:NO];
            } else {
                [_checkTimer invalidate];
                [MyEUtil showErrorOn:self.navigationController.view withMessage:@"删除红外终端失败，请稍后重试！"];
            }
        }
    }else
        [MyEUtil showMessageOn:nil withMessage:@"操作失败"];
    [HUD hide:YES];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [MyEUtil showMessageOn:nil withMessage:@"与服务器连接失败"];
}

#pragma mark - UIAlertView delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        if (_selectedIndex.section == 0) {
            [self deleteTerminalFromServer];
        }else{
            [self deleteSubSwitchFromServer];
        }
    }
}
@end
