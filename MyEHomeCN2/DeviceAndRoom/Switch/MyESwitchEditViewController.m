//
//  MyESwitchEditViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchEditViewController.h"
#import "MyESettingsViewController.h"

@interface MyESwitchEditViewController ()

@end

@implementation MyESwitchEditViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.nameTextField.text = self.device.name;
    _room = [self.accountData findFirstRoomWithRoomId:self.device.roomId];
    self.roomLabel.text = _room.name;
    self.terminalID.text = self.device.tId;
    //下载开关信息
    [self urlLoaderWithUrlString:[NSString stringWithFormat:@"%@?deviceId=%li",URL_FOR_SWITCH_VIEW,(long)self.device.deviceId] loaderName:@"downloadSwitchInfo"];
    [self defineTapGestureRecognizer];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.nameTextField becomeFirstResponder];
        }else if (indexPath.row == 1){
            [self.nameTextField endEditing:YES];
            NSMutableArray *array = [NSMutableArray array];
            for (MyERoom *r in self.accountData.rooms) {
                [array addObject:r.name];
            }
            [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择房间" andDelegate:self andTag:1 andArray:array andSelectRow:[array indexOfObject:self.roomLabel.text] andViewController:self];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择灯具类型" andDelegate:self andTag:2 andArray:[self.switchInfo typeArray] andSelectRow:self.switchInfo.type andViewController:self];
        }else if(indexPath.row == 1) {
            if (self.switchInfo.type == 1) {
                return;
            }
            NSArray *array = @[@"0.5",@"0.55",@"0.6",@"0.65",@"0.7",@"0.75",@"0.8",@"0.85",@"0.9",@"0.95",@"1"];
            NSInteger i = [array containsObject:self.switchInfo.powerFactor]?[array indexOfObject:self.switchInfo.powerFactor]:0;
            [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择功率因数" andDelegate:self andTag:3 andArray:array andSelectRow:i andViewController:self];
        }else if (indexPath.row == 2){
            self.switchInfo.powerType = 0;
            self.table0.accessoryType = UITableViewCellAccessoryCheckmark;
            self.table1.accessoryType = UITableViewCellAccessoryNone;
        }else{
            self.switchInfo.powerType = 1;
            self.table1.accessoryType = UITableViewCellAccessoryCheckmark;
            self.table0.accessoryType = UITableViewCellAccessoryNone;
            NSMutableArray *array = [NSMutableArray array];
            for (int i = 1; i < 7; i++) {
                [array addObject:[NSString stringWithFormat:@"%i分钟",i*10]];
            }
            [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择定时上报的时间" andDelegate:self andTag:4 andArray:array andSelectRow:_reportTime/10-1 andViewController:self];
        }
    }
}
- (IBAction)saveEdit:(UIBarButtonItem *)sender {
    if ([self.nameTextField.text length] < 1 || [self.nameTextField.text length] > 10) {
        [MyEUtil showMessageOn:nil withMessage:@"名称长度不符合要求"];
        return;
    }
    [self urlLoaderWithUrlString:[NSString stringWithFormat:@"%@?deviceId=%li&name=%@&roomId=%li&powerType=%li&reporteTime=%li&loadType=%i&powerFactor=%@",URL_FOR_SWITCH_SAVE,(long)self.device.deviceId,self.nameTextField.text,(long)_room.roomId,(long)self.switchInfo.powerType,(long)self.switchInfo.reportTime,self.switchInfo.type,self.switchInfo.powerFactor] loaderName:@"uploadSwitchInfo"];
}

#pragma mark - private methods
-(void)urlLoaderWithUrlString:(NSString *)url loaderName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    NSLog(@"%@ string is %@",name,url);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}
-(void)setPowerStatus{
    if (self.switchInfo.powerType == 0) {
        self.table0.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        self.table1.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self.nameTextField endEditing:YES];
}

#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if ([name isEqualToString:@"downloadSwitchInfo"]) {
        NSLog(@"download switch string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            MyESwitchInfo *info = [[MyESwitchInfo alloc] initWithString:string];
            self.switchInfo = info;
            [self setPowerStatus];
            self.tableLabel.text = [NSString stringWithFormat:@"定时上报(%li分钟)",(long)self.switchInfo.reportTime==0?10:(long)self.switchInfo.reportTime];
            self.typeLbl.text = [self.switchInfo changeTypeToString];
            self.valueLbl.text = self.switchInfo.powerFactor;
            [self.tableView reloadData];  //这里一定要记得更新表格
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:nil withMessage:@"下载数据时发生错误"];
        }
    }
    if ([name isEqualToString:@"uploadSwitchInfo"]) {
        NSLog(@"uploadSwitchInfo string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            self.device.name = self.nameTextField.text;
            self.device.roomId = _room.roomId;
            UINavigationController *nav = self.navigationController.tabBarController.childViewControllers[4];
            MyESettingsViewController *vc = nav.childViewControllers[0];
            vc.isFresh = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:nil withMessage:@"上传数据时发生错误"];
        }
    }
}
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles{
    if (pickerView.tag == 1) {
        self.roomLabel.text = titles[0];
        for (MyERoom *r in self.accountData.rooms) {
            if ([r.name isEqualToString:titles[0]]) {
                _room = r;
            }
        }
    }else if(pickerView.tag == 2){
        self.typeLbl.text = titles[0];
        if ([titles[0] isEqualToString:@"白炽灯"]) {
            self.valueLbl.text = @"1";
            self.switchInfo.powerFactor = @"1";
            self.switchInfo.type = 1;
        }else{
            self.valueLbl.text = @"0.9";
            self.switchInfo.powerFactor = @"0.9";
            self.switchInfo.type = 0;
        }
    }else if (pickerView.tag == 3){
        self.valueLbl.text = titles[0];
        self.switchInfo.powerFactor = titles[0];
    }else{
        self.tableLabel.text = [NSString stringWithFormat:@"定时上报(%@)",titles[0]];
        self.switchInfo.reportTime = [[titles[0] substringToIndex:2] intValue];
    }
}
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didDismissWithButtonIndex:(NSInteger)index{
    if (pickerView.tag == 4) {
        if (self.switchInfo.reportTime == 0) {
            self.switchInfo.reportTime = 10;
            self.tableLabel.text = [NSString stringWithFormat:@"定时上报(%li分钟)",(long)self.switchInfo.reportTime];
        }
    }
}
@end
