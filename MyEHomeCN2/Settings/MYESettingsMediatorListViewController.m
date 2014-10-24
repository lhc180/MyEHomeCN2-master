//
//  MYESettingsMediatorListViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/23.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYESettingsMediatorListViewController.h"

@interface MYESettingsMediatorListViewController ()<UIAlertViewDelegate,MyEDataLoaderDelegate>{
    NSIndexPath *_selectedIndex;
    MBProgressHUD *HUD;
}

@end

@implementation MYESettingsMediatorListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"网关列表";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return MainDelegate.accountData.mediators.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellStr = indexPath.section == 0?@"cell":@"add";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr forIndexPath:indexPath];
    if (indexPath.section == 0) {
        MyEMediator *mediator = MainDelegate.accountData.mediators[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:mediator.isOn?@"signal4":@"signal0"];
        cell.textLabel.text = mediator.mid;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        MyEMediator *mediator = MainDelegate.accountData.mediators[indexPath.row];
        UITableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mediatorDetail"];
        [vc setValue:mediator forKey:@"mediator"];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        UITableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addNewMediator"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _selectedIndex = indexPath;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"确定删除此网关吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 100;
        [alert show];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}
#pragma mark - UIAlertView delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        MyEMediator *m = MainDelegate.accountData.mediators[_selectedIndex.row];
        if(HUD == nil) {
            HUD = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        } else
            [HUD show:YES];
        NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&action=0&mId=%@",GetRequst(URL_FOR_SETTINGS_BIND_MEDIATOR), MainDelegate.accountData.userId,m.mid];
        MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsDeleteMedatorUploader" userDataDictionary:nil];
        NSLog(@"SettingsDeleteMedatorUploader is %@",loader.name);
    }
}
#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"%@",string);
    NSInteger i = [MyEUtil getResultFromAjaxString:string];
    if (i == -3) {
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
        return;
    }
    if (i == 1) {
        if ([name isEqualToString:@"SettingsDeleteMedatorUploader"]) {
            [MainDelegate.accountData.mediators removeObjectAtIndex:_selectedIndex.row];
            [self.tableView deleteRowsAtIndexPaths:@[_selectedIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }else
        [MyEUtil showMessageOn:nil withMessage:@"操作失败"];
}
@end
