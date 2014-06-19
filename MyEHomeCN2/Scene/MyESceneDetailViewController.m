//
//  MyESceneDetailViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-4.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyESceneDetailViewController.h"
#import "MyEScenesViewController.h"

@interface MyESceneDetailViewController ()

@end

@implementation MyESceneDetailViewController
@synthesize accountData,scene,byOrder,instructionRecived,toolbar,tableview,saveEditorBtn,reorderBtn,applySceneBtn;

#pragma mark - life circle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableview.tableFooterView = [[UIView alloc] init];
    tableviewArray = [NSMutableArray array];
    
    for (int i=0; i<[scene.deviceControls count]; i++) {
        MyEDeviceControl *deviceControl = scene.deviceControls[i];
        NSDictionary *dic = [deviceControl JSONDictionary];
        [tableviewArray addObject:dic];
    }
    self.nameTextField.text = scene.name;
    
    tableview.delegate = self;
    tableview.dataSource = self;
    
    [byOrder setOn:scene.byOrder == 1?YES:NO animated:YES];
    self.saveEditorBtn.enabled = NO; //刚进来的时候不允许用户点击【保存修改】按钮，这个按钮应置灰
    [self defineTapGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}
-(void)hideKeyboard{
    [self.nameTextField resignFirstResponder];
}
-(void)refreshUI{
    if ([scene.deviceControls count] == 0) {
        applySceneBtn.enabled = NO;
    }
    if ([scene.deviceControls count] <2) {
        reorderBtn.enabled = NO;
    }else
        reorderBtn.enabled = YES;
    
    if ([tableviewArray count] == 0) {
        saveEditorBtn.enabled = NO;
        reorderBtn.enabled = NO;
        [MyEUniversal dothisWhenTableViewIsEmptyWithMessage:@"您还没有在当前场景添加设备，请点击左下角按键添加" andFrame:CGRectMake(0,0,260,60) andVC:self];
    } else {
        if ([self.view.subviews containsObject:[self.view viewWithTag:999]]) {
            [[self.view viewWithTag:999] removeFromSuperview];
        }
    }
}
-(void)reuseableCell:(UITableViewCell *)cell{
    cell.showsReorderControl = YES;
    UILabel *deviceNameLabel,*roomLabel,*controlKey,*controlKeyDetail;
    if (IS_IOS6) {
        deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 7, 103, 21)];
        roomLabel = [[UILabel alloc] initWithFrame:CGRectMake(213, 10, 48, 15)];
        controlKey = [[UILabel alloc] initWithFrame:CGRectMake(62, 31, 53, 15)];
        controlKeyDetail = [[UILabel alloc] initWithFrame:CGRectMake(125, 31, 159, 15)];
    }else{
        deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 7, 103, 21)];
        roomLabel = [[UILabel alloc] initWithFrame:CGRectMake(213, 10, 48, 15)];
        controlKey = [[UILabel alloc] initWithFrame:CGRectMake(72, 31, 53, 15)];
        controlKeyDetail = [[UILabel alloc] initWithFrame:CGRectMake(135, 31, 159, 15)];
    }
    deviceNameLabel.tag = 100;
    roomLabel.tag = 101;
    controlKey.tag = 102;
    controlKeyDetail.tag = 103;
    deviceNameLabel.font = [UIFont systemFontOfSize:18];
    roomLabel.font = [UIFont systemFontOfSize:12];
    controlKey.font = [UIFont systemFontOfSize:12];
    controlKeyDetail.font = [UIFont systemFontOfSize:12];
    controlKey.textColor = [UIColor darkGrayColor];
    roomLabel.textAlignment = NSTextAlignmentRight;
    controlKey.text = @"控制状态:";
    [cell.contentView addSubview:deviceNameLabel];
    [cell.contentView addSubview:roomLabel];
    [cell.contentView addSubview:controlKey];
    [cell.contentView addSubview:controlKeyDetail];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
// 特别注意此处在哪里更新UI
    [self refreshUI];
    return [tableviewArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sceneList";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) { //特别注意的这里才是定制cell的地方，之前犯了一个很大的错误，那就是将定制的部分放到了外面，导致在赋值的时候发生了偏差。这部分是自己仔细想到的，当记住
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [self reuseableCell:cell];  //将cell的UI定制放到一个方法里面是为了使得这个dataSource方法看起来更加简单些
    }
    NSDictionary *dic = [tableviewArray objectAtIndex:indexPath.row];

    NSLog(@"%@",dic);
    //deviceId表示传过来的设备的id
    NSString *deviceName,*roomName,*controlKeyName,*runMode,*windLevel, *setpoint;
    BOOL jumpOutCycle = NO;   //这个变量主要是用来控制循环的，当完成指定情况后，直接跳出嵌套循环
    UIImage *image;
    //找出deviceId所对应的设备类型,从而对每一行进行图标的处理
    for (MyEDeviceType *dt in accountData.deviceTypes) {
        if ([dt.devices count]) {
            for (int j=0; j<[dt.devices count]; j++) {
                if ([dic[@"id"] intValue] == [dt.devices[j] intValue]) {
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
    for (MyEDevice *device in accountData.devices) {
        if ([dic[@"id"] intValue] == device.deviceId) {
            deviceName = device.name;
            for (MyERoom *room in accountData.rooms) {
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
//            controlKeyName = [controlKeyName stringByAppendingString:[channel characterAtIndex:i] ==0?@"关":@"开"];
        }
        controlKeyName = [array componentsJoinedByString:@","];
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
            for (MyESceneDevice *sceneDevice in instructionRecived.allInstructions) {
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

    [cell.imageView setImage:image];
    UILabel *deviceNameLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *roomLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *controlKeyDetail = (UILabel *)[cell.contentView viewWithTag:103];
    //对相关label进行赋值
    deviceNameLabel.text = deviceName;
    roomLabel.text = roomName;
    controlKeyDetail.text = controlKeyName;
    
    return cell;
}
#pragma mark - tableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self performSegueWithIdentifier:@"sceneDeviceEdit" sender:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableviewArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    saveEditorBtn.enabled = YES;
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}
#pragma mark - Navigation methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"sceneDeviceEdit"]) {
        MyEScenesDeviceEditOrAddViewController *vc = segue.destinationViewController;
        
        NSIndexPath *indexPath = sender;
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
    if ([segue.identifier isEqualToString:@"scenesAddDevice"]) {
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
#pragma mark - IBAction methods
- (IBAction)byOder:(UISwitch *)sender {
    saveEditorBtn.enabled = YES;
}

- (IBAction)applyScene:(UIBarButtonItem *)sender {
    
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
            
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&id=%li",URL_FOR_SCENES_APPLY,accountData.userId,(long)self.scene.sceneId];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"applySceneUploader" userDataDictionary:nil];
    NSLog(@"applySceneUploader is %@",loader.name);
}

- (IBAction)deleteScene:(UIBarButtonItem *)sender {
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                contentText:@"此操作将删除场景内的所有设备，您确定么？"
                                            leftButtonTitle:@"取消"
                                           rightButtonTitle:@"确定"];
    [alert show];
    alert.rightBlock = ^() {
        [self deleteSceneFromServer];
    };
}
- (IBAction)addDevice:(UIBarButtonItem *)sender {
    reorderBtn.enabled = YES;
}

- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    scene.name = self.nameTextField.text;
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *str = [writer stringWithObject:tableviewArray];
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&action=1&name=%@&id=%li&byOrder=%@&deviceControls=%@&custom=1",URL_FOR_SCENES_EDIT,accountData.userId,self.scene.name, (long)self.scene.sceneId,[NSNumber numberWithBool:byOrder.isOn],str];
    NSLog(@"%@",[urlStr description]);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"saveChangesUploader" userDataDictionary:nil];
    NSLog(@"saveChangesUploader is %@",loader.name);
}

- (IBAction)reorder:(UIBarButtonItem *)sender {
    [self.tableview setEditing:!self.tableview.editing animated:YES];
    if (self.tableview.editing) {
        [reorderBtn setTitle:@"完成设备编辑"];
    }else{
        [reorderBtn setTitle:@"设备排序和删除"];
    }
    saveEditorBtn.enabled = YES;
}
#pragma mark - URL private methods
-(void) deleteSceneFromServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.dimBackground = YES;//容易产生灰条
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&action=2&name=%@&id=%li&byOrder=%li&deviceControls=%@",URL_FOR_SCENES_EDIT,accountData.userId,self.scene.name, (long)self.scene.sceneId,(long)self.scene.byOrder,[scene JSONStringWithDictionary:scene]];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"deleteSceneUploader" userDataDictionary:nil];
    NSLog(@"deleteSceneUploader is %@",loader.name);
}
#pragma mark - URL Delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    
    [HUD hide:YES];
    
    if([name isEqualToString:@"applySceneUploader"]) {
        NSLog(@"applySceneUploader JSON String from server is \n%@",string);
        
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }else if([MyEUtil getResultFromAjaxString:string] == 1){
            [MyEUtil showMessageOn:self.view.window withMessage:@"场景应用成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }else if ([MyEUtil getResultFromAjaxString:string] == 2){
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"场景应用成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"场景应用发送错误，请检查"];
        }
    }
    if([name isEqualToString:@"deleteSceneUploader"]) {
        NSLog(@"deleteSceneUploader JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"删除场景失败，请重试！"];
        }else{
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"删除场景成功！"];
            self.saveEditorBtn.enabled = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    if([name isEqualToString:@"saveChangesUploader"]) {
        NSLog(@"saveChangesUploader JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"场景编辑失败，请重试！"];
        }else{
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"场景编辑成功！"];
//            MyEScenesViewController *vc = [self.navigationController childViewControllers][0];
//            vc.needRefresh = YES;
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
    saveEditorBtn.enabled = YES;
    [tableviewArray addObject:dic];
    [self.tableview reloadData];
}
-(void)refreshData:(NSDictionary *)dic byIndexPath:(NSIndexPath *)index{
    saveEditorBtn.enabled = YES;
    [tableviewArray replaceObjectAtIndex:index.row withObject:dic];
    [self.tableview reloadData];
}
@end