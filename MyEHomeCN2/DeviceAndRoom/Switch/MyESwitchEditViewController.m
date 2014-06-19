//
//  MyESwitchEditViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchEditViewController.h"

@interface MyESwitchEditViewController ()

@end

@implementation MyESwitchEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
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
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *noti){
        if (![self.nameTextField.text isEqualToString:self.device.name]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }else
            self.navigationItem.rightBarButtonItem.enabled = NO;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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
        _selectedIndex = indexPath.row;
        if (indexPath.row == 0) {
            self.table0.accessoryType = UITableViewCellAccessoryCheckmark;
            self.table1.accessoryType = UITableViewCellAccessoryNone;
            [self checkIfChange];
        }else{
            self.table1.accessoryType = UITableViewCellAccessoryCheckmark;
            self.table0.accessoryType = UITableViewCellAccessoryNone;
            NSMutableArray *array = [NSMutableArray array];
            for (int i = 1; i < 7; i++) {
                [array addObject:[NSString stringWithFormat:@"%i分钟",i*10]];
            }
            [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择定时上报的时间" andDelegate:self andTag:2 andArray:array andSelectRow:_reportTime/10-1 andViewController:self];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (IBAction)saveEdit:(UIBarButtonItem *)sender {
    if ([self.nameTextField.text length] < 1 || [self.nameTextField.text length] > 10) {
        [MyEUtil showMessageOn:nil withMessage:@"名称长度不符合要求"];
        return;
    }
    [self urlLoaderWithUrlString:[NSString stringWithFormat:@"%@?deviceId=%li&name=%@&roomId=%li&powerType=%li&reporteTime=%li",URL_FOR_SWITCH_SAVE,(long)self.device.deviceId,self.nameTextField.text,(long)_room.roomId,(long)_selectedIndex,(long)_reportTime] loaderName:@"uploadSwitchInfo"];
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
    if (_selectedIndex == 0) {
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
-(void)checkIfChange{
    NSArray *array = @[self.nameTextField.text,self.roomLabel.text,@(_reportTime),@(_selectedIndex)];
    if (![array isEqualToArray:_initArray]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}
#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if ([name isEqualToString:@"downloadSwitchInfo"]) {
        NSLog(@"download switch string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            MyESwitchInfo *info = [[MyESwitchInfo alloc] initWithString:string];
            self.switchInfo = info;
            _selectedIndex = self.switchInfo.powerType; //这里进行赋值是为了更新UI
            [self setPowerStatus];
            _reportTime = self.switchInfo.reportTime;
            self.tableLabel.text = [NSString stringWithFormat:@"定时上报(%li分钟)",(long)_reportTime==0?10:(long)_reportTime];
            
            _initArray = @[self.nameTextField.text,self.roomLabel.text,@(_reportTime),@(_selectedIndex)];  //这里使用的新的语法书写这个数组，值得注意
            
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
    }else{
        self.tableLabel.text = [NSString stringWithFormat:@"定时上报(%@)",titles[0]];
        _reportTime = [[titles[0] substringToIndex:2] intValue];
    }
    [self checkIfChange];
}
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didDismissWithButtonIndex:(NSInteger)index{
    if (pickerView.tag == 2) {
        if (_reportTime == 0) {
            _reportTime = 10;
            self.tableLabel.text = [NSString stringWithFormat:@"定时上报(%li分钟)",(long)_reportTime];
        }
        [self checkIfChange];
    }
}
@end
