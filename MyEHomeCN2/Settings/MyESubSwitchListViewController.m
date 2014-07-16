//
//  MyESubSwitchListViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-14.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESubSwitchListViewController.h"

@interface MyESubSwitchListViewController (){
    MBProgressHUD *HUD;
    NSIndexPath *_selectIndex;
}

@end

@implementation MyESubSwitchListViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"开关列表";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.settings.subSwitchList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MyESettingSubSwitch *subSwitch = self.settings.subSwitchList[indexPath.row];
    cell.textLabel.text = subSwitch.name;
    cell.imageView.image = [subSwitch getImage];
    cell.detailTextLabel.text = subSwitch.mainTid.length>0?@"已关联":@"未关联";
    return cell;
}

#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告" contentText:@"确定删除此开关么?" leftButtonTitle:@"取消" rightButtonTitle:@"确定"];
    alert.rightBlock = ^{
        if (HUD == nil) {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }else
            [HUD show:YES];
        _selectIndex = indexPath;
        MyESettingSubSwitch *subSwitch = self.settings.subSwitchList[indexPath.row];
        MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?gid=%@",URL_FOR_SUBSWITCH_DELETE,subSwitch.gid] postData:nil delegate:self loaderName:@"delete" userDataDictionary:nil];
        NSLog(@"%@",loader.name);
    };
    [alert show];
}

#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"receive string is %@",string);
    NSInteger i = [MyEUtil getResultFromAjaxString:string];
    if (i == 1) {
        [self.settings.subSwitchList removeObjectAtIndex:_selectIndex.row];
        [self.tableView deleteRowsAtIndexPaths:@[_selectIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if (i == 0){
        [MyEUtil showErrorOn:nil withMessage:@"传入的数据有误"];
    }else if (i == 2){
        [MyEUtil showMessageOn:nil withMessage:@"已向服务器发送指令"];
    }else
        [MyEUtil showMessageOn:nil withMessage:@"用户已断开"];
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id viewController = segue.destinationViewController;
    MyESettingSubSwitch *subSwitch = self.settings.subSwitchList[[self.tableView indexPathForCell:sender].row];
    [viewController setValue:subSwitch forKey:@"subSwitch"];
}

@end
