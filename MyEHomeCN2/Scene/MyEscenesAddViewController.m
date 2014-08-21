//
//  MyEscenesAddViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-9.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEscenesAddViewController.h"
#import "MyEScenesViewController.h"

@interface MyEscenesAddViewController ()

@end

@implementation MyEscenesAddViewController
@synthesize byOrderSwitch,sceneNameLabel,tableview,sceneName,tableviewArray,accountData,instructionRecived,saveEditorBtn,reorderBtn;

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    tableviewArray = [NSMutableArray array];
	sceneNameLabel.text = sceneName;
    
    tableview.tableFooterView = [[UIView alloc] init];
    tableview.tableFooterView.backgroundColor = [UIColor clearColor];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
-(void)refreshUI{
    if ([tableviewArray count] > 1) {
        self.reorderBtn.enabled = YES;
    }else
        self.reorderBtn.enabled = NO;
    
    if ([tableviewArray count] == 0) {
        saveEditorBtn.enabled = NO;
        reorderBtn.enabled = NO;
        [MyEUniversal dothisWhenTableViewIsEmptyWithMessage:@"您还没有在当前场景添加设备，请点击左下角按键添加" andFrame:CGRectMake(0,0,260,60) andVC:self];
    } else {
        saveEditorBtn.enabled = YES;
        if ([self.view.subviews containsObject:[self.view viewWithTag:999]]) {
            [[self.view viewWithTag:999] removeFromSuperview];
        }
    }
}
-(void)reusableCell:(UITableViewCell *)cell{
    cell.showsReorderControl = YES;
    UILabel *deviceNameLabel,*roomLabel,*controlKey,*controlKeyDetail;
    if (IS_IOS6) {
        deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 7, 103, 21)];
        roomLabel = [[UILabel alloc] initWithFrame:CGRectMake(201, 10, 60, 15)];
        controlKey = [[UILabel alloc] initWithFrame:CGRectMake(62, 31, 53, 15)];
        controlKeyDetail = [[UILabel alloc] initWithFrame:CGRectMake(125, 31, 159, 15)];
    }else{
        deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 7, 103, 21)];
        roomLabel = [[UILabel alloc] initWithFrame:CGRectMake(201, 10, 60, 15)];
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
#pragma mark - tableView dataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    [self refreshUI];
    return [tableviewArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"sceneList";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) { //特别注意的这里才是定制cell的地方，之前犯了一个很大的错误，那就是将定制的部分放到了外面，导致在赋值的时候发生了偏差。这部分是自己仔细想到的，当记住
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [self reusableCell:cell];
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
    }else if ([dic[@"isAc"] intValue] == 3 || [dic[@"isAc"] intValue] == 4 || [dic[@"isAc"] intValue] == 5){  //安防设备
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
//    UIImage *image;
//    //找出deviceId所对应的设备类型,从而对每一行进行图标的处理
//    for (i=0; i<[accountData.deviceTypes count]; i++) {
//        MyEDeviceType *deviceType = accountData.deviceTypes[i];
//        if ([deviceType.devices count] != 0) {
//            for (j=0; j<[deviceType.devices count]; j++) {
//                if ([dic[@"id"] intValue] == [deviceType.devices[j] intValue]) {
//                    image = [MyEAcUtil getImageForDeviceType:deviceType.dtId];// by YY
//                }
//            }
//        }
//    }
//
//    for (i=0; i<[accountData.devices count]; i++) {
//        MyEDevice *device = accountData.devices[i];
//        
//        if ([dic[@"id"] intValue] == device.deviceId) {
//            deviceName = device.name;
//            
//        }
//    }
//    
//    //找出deviceId所对应的房间名称
//    for (i=0; i<[accountData.rooms count]; i++) {
//        MyERoom *room = accountData.rooms[i];
//        if ([room.devices count] != 0) {
//            for (j=0; j<[room.devices count]; j++) {
//                if ([dic[@"id"] intValue] == [room.devices[j] intValue]) {
//                    roomName = room.name;
//                }
//            }
//        }
//    }
//    
//    if ([dic[@"isAc"] intValue] == 1 ) {
//        if ([dic[@"controlKey"][@"powerSwitch"] intValue] == 0) {
//            controlKeyName = @"关";
//        }else{
//            runMode = [MyEAcUtil getStringForRunMode:[dic[@"controlKey"][@"runMode"] integerValue]]; //by YY
//            windLevel = [MyEAcUtil getStringForWindLevel:[dic[@"controlKey"][@"windLevel"] integerValue]];//by YY
//            setpoint = [MyEAcUtil getStringForSetpoint:[dic[@"controlKey"][@"setpoint"] integerValue]];//by YY
//            controlKeyName = [NSString stringWithFormat:@"%@|%@|%@", runMode, setpoint, windLevel];//by YY
//        }
//        
//    }else{
//        //找出指令
//        //前两个判断表示设备是插座
//        if ([dic[@"controlKey"][@"keyId"] intValue] == 1) {
//            controlKeyName = @"开";
//        }else if([dic[@"controlKey"][@"keyId"] intValue] == 0){
//            controlKeyName = @"关";
//        }else if ([dic[@"controlKey"][@"keyId"] intValue] == -1){   //新增了这个判断来解决部分情况下指令未指定的情况
//            controlKeyName = @"指令未指定";
//        }else{
//        for (i=0; i<[instructionRecived.allInstructions count]; i++) {
//            MyESceneDevice *sceneDevice = instructionRecived.allInstructions[i];
//            if ([dic[@"id"] intValue] == sceneDevice.deviceId) {
//                for (j=0; j<[sceneDevice.instructions count]; j++) {
//                    MyESceneDeviceInstruction *allInstruction = sceneDevice.instructions[j];
//                    if ([dic[@"controlKey"][@"keyId"] intValue] == allInstruction.instructionId && allInstruction.status == 1) {
//                        controlKeyName = allInstruction.keyName;
//                    }
//                }
//            }
//        }
//        }
//    }
//        
//    [cell.imageView setImage:image];
//
//    UILabel *deviceNameLabel = (UILabel *)[cell.contentView viewWithTag:100];
//    UILabel *roomLabel = (UILabel *)[cell.contentView viewWithTag:101];
//    UILabel *controlKeyDetail = (UILabel *)[cell.contentView viewWithTag:103];
//    
//    deviceNameLabel.text = deviceName;
//    roomLabel.text = roomName;
//    controlKeyDetail.text = controlKeyName;
//    
//    return cell;
}

#pragma mark - tableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    MyEScenesDeviceEditOrAddViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"deviceAddOrEdit"];
    NSIndexPath *index = indexPath;
    NSDictionary *dic = [tableviewArray objectAtIndex:index.row];
    vc.accountData = self.accountData;
    vc.sceneIndex = indexPath;
    vc.instructionRecived = self.instructionRecived;
    vc.dictionaryRecived = dic;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableviewArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView reloadData]; //删除之后一定要刷新一下数据
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewCellEditingStyleNone;
//}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    id object = [self.tableviewArray objectAtIndex:sourceIndexPath.row];
    [self.tableviewArray removeObjectAtIndex:sourceIndexPath.row];
    [self.tableviewArray insertObject:object atIndex:destinationIndexPath.row];
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}
#pragma mark - IBAction methods

- (IBAction)reorder:(UIBarButtonItem *)sender {
    [self.tableview setEditing:!self.tableview.editing animated:YES];
    if (self.tableview.editing) {
        [reorderBtn setTitle:@"完成排序"];
    }else{
        [reorderBtn setTitle:@"设备排序"];
    }
}

- (IBAction)saveEditor:(UIBarButtonItem *)sender {

    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *str = [writer stringWithObject:tableviewArray];
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&action=0&name=%@&id=0&byOrder=%@&deviceControls=%@&custom=1",URL_FOR_SCENES_EDIT,accountData.userId,sceneName,[NSNumber numberWithBool:byOrderSwitch.isOn],str];
    NSLog(@"%@",[urlStr description]);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"addSceneUploader" userDataDictionary:nil];
    NSLog(@"addSceneUploader is %@",loader.name);
}

#pragma mark
#pragma mark - MyEDataLoader Delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:@"addSceneUploader"]) {
        NSLog(@"addSceneUploader JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"场景添加失败，请重试！"];
        }else{
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"场景添加成功成功！"];
            //这里这两种方式具有异曲同工之妙
            self.accountData.needDownloadInstructionsForScene = YES;
//            MyEScenesViewController *vc = [self.navigationController childViewControllers][0];
//            vc.needRefresh = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg = @"与服务器通信时发生错误，请稍后重试.";
    
    [MyEUtil showMessageOn:nil withMessage:msg];
    [HUD hide:YES];
}

#pragma mark - navigation methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"scenesAddDevice"]) {
        MyEScenesDeviceEditOrAddViewController *vc = segue.destinationViewController;
        vc.jumpFromBarBtn = 1;  //新增设备
        vc.instructionRecived = self.instructionRecived;
        vc.accountData = self.accountData;
        vc.delegate = self;
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *d in tableviewArray) {
            [array addObject:d[@"id"]];
        }
        vc.deviceIdArrayRecived = array;
    }
    if ([segue.identifier isEqualToString:@"sceneDeviceEdit"]) {
        MyEScenesDeviceEditOrAddViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        NSDictionary *dic = [tableviewArray objectAtIndex:indexPath.row];
        vc.accountData = self.accountData;
        vc.sceneIndex = indexPath;
        vc.instructionRecived = self.instructionRecived;
        vc.dictionaryRecived = dic;
        vc.delegate = self;
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *d in tableviewArray) {
            [array addObject:d[@"id"]];
        }
        vc.deviceIdArrayRecived = array;
    }
}
#pragma mark - MyEScenesDeviceEditOrAddViewControllerDelegate methods
-(void)passValue:(NSDictionary *)dic{
    saveEditorBtn.enabled = YES;
    [tableviewArray addObject:dic];
    [self.tableview reloadData];
}
-(void)refreshData:(NSDictionary *)dic byIndexPath:(NSIndexPath *)index{
    [self.tableviewArray replaceObjectAtIndex:index.row withObject:dic];
    [self.tableview reloadData];
}
@end
