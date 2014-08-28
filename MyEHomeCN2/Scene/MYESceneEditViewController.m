//
//  MYESceneEditViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-8-21.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYESceneEditViewController.h"

@interface MYESceneEditViewController (){
    MBProgressHUD *HUD;
    NSMutableArray *tableviewArray;
}

@end

@implementation MYESceneEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    tableviewArray = [NSMutableArray array];
    for (MyEDeviceControl *control in _scene.deviceControls) {
        [tableviewArray addObject:[control JSONDictionary]];
    }
    if (self.isAdd) {
        self.title = @"新增场景";
    }else
        self.title = @"编辑场景";
    _nameTxt.text = _scene.name;
    _orderBtn.selected = _scene.byOrder==1;
    [self defineTapGestureRecognizer];
}
#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}
-(void)hideKeyboard{
    [self.nameTxt resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)orderAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}
- (IBAction)editDevices:(UIButton *)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing) {
        [sender setTitle:@"完成排序" forState:UIControlStateNormal];
    }else{
        [sender setTitle:@"设备排序" forState:UIControlStateNormal];
    }
}
- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    [_nameTxt resignFirstResponder];
    if ([_nameTxt.text isEqualToString:@""]) {
        [MyEUtil showMessageOn:nil withMessage:@"请输入场景名称"];
        return;
    }
    if (tableviewArray.count==0) {
        [MyEUtil showMessageOn:nil withMessage:@"请添加设备"];
        return;
    }
    _scene.name = self.nameTxt.text;
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *str = [writer stringWithObject:tableviewArray];
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&action=%i&name=%@&id=%li&byOrder=%i&deviceControls=%@&custom=1",GetRequst(URL_FOR_SCENES_EDIT),_accountData.userId,_isAdd?0:1,_isAdd?self.nameTxt.text:self.scene.name,_isAdd?0:(long)self.scene.sceneId,_orderBtn.selected,str];
    NSLog(@"%@",[urlStr description]);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"saveChangesUploader" userDataDictionary:nil];
    NSLog(@"saveChangesUploader is %@",loader.name);
}

#pragma mark - UITable view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableviewArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dic = [tableviewArray objectAtIndex:indexPath.row];
    
    NSLog(@"%@",dic);
    //deviceId表示传过来的设备的id
    NSString *deviceName,*roomName,*controlKeyName,*runMode,*windLevel, *setpoint;
    BOOL jumpOutCycle = NO;   //这个变量主要是用来控制循环的，当完成指定情况后，直接跳出嵌套循环
    UIImage *image;
    //找出deviceId所对应的设备类型,从而对每一行进行图标的处理
    for (MyEDeviceType *dt in self.accountData.deviceTypes) {
        if ([dt.devices count]) {
            for (NSNumber *i in dt.devices) {
                if ([dic[@"id"] intValue] == [i intValue]) {
                    image = [MyEAcUtil getImageForDeviceType:dt.dtId];// by YY
                    jumpOutCycle = YES;
                    break;
                }
            }
        }
        if (jumpOutCycle) {
            jumpOutCycle = NO;
            break;
        }
    }
    //找出设备的名称
    for (MyEDevice *device in _accountData.devices) {
        if ([dic[@"id"] intValue] == device.deviceId) {
            deviceName = device.name;
            for (MyERoom *room in _accountData.rooms) {
                if (room.roomId == device.roomId) {
                    roomName = room.name;
                    break;
                }
            }
            break;
        }
    }
    //找出deviceId所对应的房间名称
    //如果设备是空调
    if ([dic[@"isAc"] intValue] == 1 ) {
        if ([dic[@"controlKey"][@"powerSwitch"] intValue] == 0) {
            controlKeyName = @"关";
        }else{
            runMode = [MyEAcUtil getStringForRunMode:[dic[@"controlKey"][@"runMode"] integerValue]]; //by YY
            windLevel = [MyEAcUtil getStringForWindLevel:[dic[@"controlKey"][@"windLevel"] integerValue]];//by YY
            setpoint = [MyEAcUtil getStringForSetpoint:[dic[@"controlKey"][@"setpoint"] integerValue]];//by YY
            controlKeyName = [NSString stringWithFormat:@"%@|%@|%@", runMode, setpoint, windLevel];//by YY
        }
    }else if ([dic[@"isAc"] intValue] == 2){  //表示该设备是开关
        NSString *channel = dic[@"controlKey"][@"channel"];
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < [channel length]; i++) {   //注意此处调用的是NSString的哪个方法
            [array addObject:[[channel substringWithRange:NSMakeRange(i, 1)] integerValue] ==0?@"关":@"开"];
        }
        controlKeyName = [array componentsJoinedByString:@","];
    }else if ([dic[@"isAc"] intValue] == 3 || [dic[@"isAc"] intValue] == 4 || [dic[@"isAc"] intValue] == 5 || [dic[@"isAc"] intValue] == 6){  //安防设备
        NSInteger i = [dic[@"controlKey"][@"powerSwitch"] intValue];
        controlKeyName = i == 1?@"布防":@"撤防";
    }else{
        // 可能这里容易出问题
        //前两个判断表示设备是插座
        if ([dic[@"controlKey"][@"keyId"] intValue] == 1) {
            controlKeyName = @"开";
        }else if([dic[@"controlKey"][@"keyId"] intValue] == 0){
            controlKeyName = @"关";
        }else if ([dic[@"controlKey"][@"keyId"] intValue] == -1){   //新增了这个判断来解决部分情况下指令未指定的情况
            controlKeyName = @"指令未指定";
        }else{
            //找出指令
            for (MyESceneDevice *sceneDevice in _instructionRecived.allInstructions) {
                if ([dic[@"id"] intValue] == sceneDevice.deviceId) {
                    for (MyESceneDeviceInstruction *allInstruction in sceneDevice.instructions) {
                        //这里添加了一个限制，只有当这个按键是学习的之后才能被正确的读出来，此处为null的话表示这个指令没有学习
                        if ([dic[@"controlKey"][@"keyId"] intValue] == allInstruction.instructionId) {
                            if (allInstruction.status == 1) {
                                controlKeyName = allInstruction.keyName;
                            }else{
                                controlKeyName = @"指令未学习";
                            }
                            //                            NSLog(@"%@",controlKeyName);
                            break;
                        }
                    }
                    break;
                }
            }
        }
    }
    
    UIImageView *imageV = (UIImageView *)[cell.contentView viewWithTag:100];
    UILabel *nameLbl = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *roomLbl = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *controlLbl = (UILabel *)[cell.contentView viewWithTag:103];

    imageV.image = image;
    nameLbl.text = deviceName;
    roomLbl.text = roomName;
    controlLbl.text = controlKeyName;
    
    return cell;
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableviewArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    //这个默认的是yes，不需要进行更改
    return YES;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    id object = [tableviewArray objectAtIndex:sourceIndexPath.row];
    [tableviewArray removeObjectAtIndex:sourceIndexPath.row];
    [tableviewArray insertObject:object atIndex:destinationIndexPath.row];
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

#pragma mark - Navigation methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"edit"]) {
        MyEScenesDeviceEditOrAddViewController *vc = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *dic = [tableviewArray objectAtIndex:indexPath.row];
        vc.accountData = self.accountData;
        vc.sceneIndex = indexPath;
        vc.instructionRecived = self.instructionRecived;
        vc.dictionaryRecived = dic;
        vc.tableArray = tableviewArray;
        vc.delegate = self;
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *d in tableviewArray) {
            [array addObject:d[@"id"]];
        }
        vc.deviceIdArrayRecived = array;
    }
    if ([segue.identifier isEqualToString:@"add"]) {
        MyEScenesDeviceEditOrAddViewController *vc = segue.destinationViewController;
        vc.jumpFromBarBtn = 1;
        vc.instructionRecived = self.instructionRecived;
        vc.accountData = self.accountData;
        vc.tableArray = tableviewArray;
        vc.delegate = self;
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *d in tableviewArray) {
            [array addObject:d[@"id"]];
        }
        vc.deviceIdArrayRecived = array;
    }
}

#pragma mark - URL Delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    
    [HUD hide:YES];
    if([name isEqualToString:@"saveChangesUploader"]) {
        NSLog(@"saveChangesUploader JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"场景编辑失败，请重试！"];
        }else{
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"场景编辑成功！"];
            self.accountData.needDownloadInstructionsForScene = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg = @"与服务器通信时发生错误，请稍后重试.";
    
    [MyEUtil showMessageOn:nil withMessage:msg];
    [HUD hide:YES];
}
#pragma mark - MyEScenesDeviceEditOrAddViewControllerDelegate methods
-(void)passValue:(NSDictionary *)dic{
    [tableviewArray addObject:dic];
    [self.tableView reloadData];
}
-(void)refreshData:(NSDictionary *)dic byIndexPath:(NSIndexPath *)index{
    [tableviewArray replaceObjectAtIndex:index.row withObject:dic];
    [self.tableView reloadData];
}
@end
