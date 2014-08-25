//
//  MyEDeviceEditOrAddViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-4.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEScenesDeviceEditOrAddViewController.h"

@interface MyEScenesDeviceEditOrAddViewController ()

@end

@implementation MyEScenesDeviceEditOrAddViewController
@synthesize accountData,deviceControl,instructionRecived,deviceBtn,deviceArray,
deviceTypeArray,deviceTypeBtn,modeArray,modeBtn,powerBtn,powerArray,
windLevelArray,windLevelBtn,temperatureArray,temperatureBtn,powerLabel,
windLevelLabel,modeLabel,temperatureLabel,jumpFromBarBtn,dictionaryRecived,
sceneIndex,saveEditorBtn;


#pragma mark - private methods for UI
-(void)setLabelAndButtonForSystemDefinedAC{//当为标准库的空调时，要将下面的三对控件显示出来
    [self setLabelAndButtonHidden:NO];
}
-(void)setLabelAndButtonForOthers{//不是空调时，隐藏下面三对控件
    [self setLabelAndButtonHidden:YES];
}
-(void)setLabelAndButtonForSwitch{
    powerLabel.hidden = YES;
    powerBtn.hidden = YES;
    self.tableView.hidden = NO;
    [self setLabelAndButtonHidden:YES];
}
-(void)setLabelAndButtonHidden:(BOOL)yes{
    modeBtn.hidden = yes;
    modeLabel.hidden = yes;
    windLevelBtn.hidden = yes;
    windLevelLabel.hidden = yes;
    temperatureBtn.hidden = yes;
    temperatureLabel.hidden = yes;
}
-(void)getDeviceArrayAndPowerArrayByDeviceType:(NSInteger)dcType andIndex:(NSInteger)i{
    NSArray *instructionArray = [NSArray array];
    NSMutableArray *instructions = [NSMutableArray array];
    NSMutableArray *instructionIds = [NSMutableArray array];
    //特别注意，只有2 3 4 5 这四个设备类型才有instructionArray
    switch (dcType) {
        case 1:{
            deviceArray = _acArray[1];
            self.deviceIdArray = _acArray[0];
            
            MyEDevice *device = [self.accountData findDeviceWithDeviceId:[_acArray[0][i] intValue]];
            if (device.isSystemDefined) {  //系统默认空调
                powerArray = @[@"开",@"关"];
                [self setLabelAndButtonForSystemDefinedAC];
                [self getModeArrayByDeviceId:[_acArray[0][0] intValue]]; //获取当前deviceid设备的运行模式数组
                [modeBtn setTitle:modeArray[_selectedRunmodeIndex] forState:UIControlStateNormal];
                [windLevelBtn setTitle:windLevelArray[_selectedWindlevelIndex] forState:UIControlStateNormal];
                [temperatureBtn setTitle:temperatureArray[_selectedSetpointIndex] forState:UIControlStateNormal];
            }else{  //用户自学习空调
                [self setLabelAndButtonForOthers];
                NSMutableArray *instructionNames = [NSMutableArray array];
                for (MyESceneDeviceInstruction *instruction in _acArray[2][_selectedDeviceIndex]) {
                    [instructionNames addObject:[NSString stringWithFormat:@"%@|%@|%@|%@",
                                                 [MyEAcUtil getStringForPowerSwitch:instruction.powerSwitch],
                                                 [MyEAcUtil getStringForRunMode:instruction.runMode],
                                                 [MyEAcUtil getStringForSetpoint:instruction.setpoint],
                                                 [MyEAcUtil getStringForWindLevel:instruction.windLevel]]];
                }
                powerArray = instructionNames;
            }
        }
            break;
        case 2:
            instructionArray = _tvArray[2][i];
            deviceArray = _tvArray[1];
            self.deviceIdArray = _tvArray[0];
            [self setLabelAndButtonForOthers];
            break;
        case 3:
            instructionArray = _curturnArray[2][i];
            deviceArray = _curturnArray[1];
            self.deviceIdArray = _curturnArray[0];
            [self setLabelAndButtonForOthers];
            break;
        case 4:
            instructionArray = _audioArray[2][i];
            deviceArray = _audioArray[1];
            self.deviceIdArray = _audioArray[0];
            [self setLabelAndButtonForOthers];
            break;
        case 5:
            instructionArray = _otherArray[2][i];
            deviceArray = _otherArray[1];
            self.deviceIdArray = _otherArray[0];
            [self setLabelAndButtonForOthers];
            break;
        case 6:
            deviceArray = _socketArray[1];
            self.deviceIdArray = _socketArray[0];
            powerArray = @[@"开",@"关"];
            [self setLabelAndButtonForOthers];
            break;
        case 7:
            deviceArray = _smartArray[1];
            self.deviceIdArray = _smartArray[0];
            NSLog(@"%@",_smartArray[0]);
            _device = [self.accountData findDeviceWithDeviceId:[self.deviceIdArray[_selectedDeviceIndex] intValue]];
            NSLog(@"_device.status.switchStatus is %@",_device.status.switchStatus);
            //            NSMutableArray *array = [NSMutableArray array];
            
            //            modeArray = @[@"开",@"关"];
            [self setLabelAndButtonForSwitch];
            [self.tableView reloadData];
            break;
        case 8:
            deviceArray = _irArray[1];
            self.deviceIdArray = _irArray[0];
            powerArray = @[@"布防",@"撤防"];
            [self setLabelAndButtonForOthers];
            break;
        case 9:
            deviceArray = _smokeArray[1];
            self.deviceIdArray = _smokeArray[0];
            powerArray = @[@"布防",@"撤防"];
            [self setLabelAndButtonForOthers];
            break;
        case 10:
            deviceArray = _doorArray[1];
            self.deviceIdArray = _doorArray[0];
            powerArray = @[@"布防",@"撤防"];
            [self setLabelAndButtonForOthers];
            break;
        default:
            deviceArray = _slalarmArray[1];
            self.deviceIdArray = _slalarmArray[0];
            powerArray = @[@"布防",@"撤防"];
            [self setLabelAndButtonForOthers];
            break;
    }
    if ([instructionArray count]) {
        for (MyESceneDeviceInstruction *is in instructionArray) {
            [instructionIds addObject:[NSNumber numberWithInteger:is.instructionId]];
            [instructions addObject:is.keyName];
        }
        powerArray = instructions;
        self.instructionIdArray = instructionIds;
    }
    [powerBtn setTitle:powerArray[_selectedPowerIndex] forState:UIControlStateNormal];
    //    NSLog(@"%@",deviceArray);
    [deviceBtn setTitle:deviceArray[_selectedDeviceIndex] forState:UIControlStateNormal];
}
-(void)setWindlevelBtnTitle{
    switch ([dictionaryRecived[@"controlKey"][@"windLevel"] intValue]) {
        case 0:
            [windLevelBtn setTitle:@"自动" forState:UIControlStateNormal];
            break;
        case 1:
            [windLevelBtn setTitle:@"一级" forState:UIControlStateNormal];
            break;
        case 2:
            [windLevelBtn setTitle:@"二级" forState:UIControlStateNormal];
            break;
        default:
            [windLevelBtn setTitle:@"三级" forState:UIControlStateNormal];
            break;
    }
}
-(void)setModeBtnTitle{
    switch ([dictionaryRecived[@"controlKey"][@"runMode"] intValue]) {
        case 1:
            [modeBtn setTitle:@"自动" forState:UIControlStateNormal];
            break;
        case 2:
            [modeBtn setTitle:@"制热" forState:UIControlStateNormal];
            break;
        case 3:
            [modeBtn setTitle:@"制冷" forState:UIControlStateNormal];
            break;
        case 4:
            [modeBtn setTitle:@"除湿" forState:UIControlStateNormal];
            break;
        default:
            [modeBtn setTitle:@"通风" forState:UIControlStateNormal];
            break;
    }
}
#pragma mark - private methods
-(IBAction)cellBtnPressed:(UIButton *)btn forEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:btn] anyObject];
    CGPoint location = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    btn.selected = !btn.selected;
    _device.status.switchStatus = [NSMutableString stringWithString:[_device.status.switchStatus stringByReplacingCharactersInRange:NSMakeRange(indexPath.row, 1) withString:btn.selected?@"0":@"1"]];;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}
// by YY
// 获取具有有效指令设备的设备类型, 因为我们只显示有学习过指令的设备的类型(以前我的思路是，全部显示，遇到没有指令或者设备的时候，就显示“没有设备”或者“没有控制码”)

//对于以下这个方法的要求，必须要做到以下几点
//1.设备数为空的type不能保留  2.设备数里面有设备，但是设备没有学习成功的指令

-(NSMutableArray *)getValidDeviceTypes{
    _acArray = [NSMutableArray array];
    _tvArray = [NSMutableArray array];
    _audioArray = [NSMutableArray array];
    _otherArray = [NSMutableArray array];
    _curturnArray = [NSMutableArray array];
    _socketArray = [NSMutableArray array];
    _smartArray = [NSMutableArray array];
    _irArray = [NSMutableArray array];
    _smokeArray = [NSMutableArray array];
    _doorArray = [NSMutableArray array];
    _slalarmArray = [NSMutableArray array];
    NSMutableArray *dTArray = [NSMutableArray arrayWithArray:self.accountData.deviceTypes];
    
    for (int i=0; i<[self.accountData.deviceTypes count];i++) {   //终于算是找到了问题的根源了
        NSMutableArray *deviceIdArray = [NSMutableArray array]; //里面存放的是一个设备类型的所有设备ID
        NSMutableArray *instructionAll = [NSMutableArray array]; //里面存放的是一个设备ID对应的所有指令
        NSMutableArray *instructionArray = [NSMutableArray array]; //里面存放的是所有可用设备的指令集合
        NSMutableArray *deviceNameArray = [NSMutableArray array];
        MyEDeviceType *dt = self.accountData.deviceTypes[i];
        if ([dt.devices count] == 0) {  //如果里面没有设备，那么就移除这个type
            [dTArray removeObject:dt];
        }else{
            deviceIdArray = [NSMutableArray arrayWithArray:dt.devices];
            for (int j=0;j<[dt.devices count];j++) {
                
                NSInteger deviceId = [dt.devices[j] integerValue];
                for (MyEDevice *d in self.accountData.devices) {
                    if (deviceId == d.deviceId) {
                        if (d.type == 1 ) { // 如果是空调
                            if ([d.brand isEqualToString:@""]) {
                                [deviceIdArray removeObject:[NSNumber numberWithInteger:deviceId]];
                            }else{
                                for (int m=0;m<[instructionRecived.allInstructions count];m++) {
                                    MyESceneDevice *sd = instructionRecived.allInstructions[m];
                                    if (deviceId == sd.deviceId) {
                                        
                                        instructionAll = [NSMutableArray arrayWithArray:sd.instructions];
                                        for (MyESceneDeviceInstruction *sdi in sd.instructions) {
                                            if (sdi.status == 0) {
                                                [instructionAll removeObject:sdi];
                                            }
                                        }
                                        break;
                                    }
                                }
                            }
                        }
                        else if (d.type > 5){
                            NSLog(@"开关或插座 %i",deviceId);
                        }else {
                            for (int m=0;m<[instructionRecived.allInstructions count];m++) {
                                MyESceneDevice *sd = instructionRecived.allInstructions[m];
                                if (deviceId == sd.deviceId) {
                                    
                                    instructionAll = [NSMutableArray arrayWithArray:sd.instructions];  //这种写法相当于将这个数组初始化了一下
                                    for (MyESceneDeviceInstruction *sdi in sd.instructions) {
                                        if (sdi.status == 0) {
                                            [instructionAll removeObject:sdi];
                                        }
                                    }
                                    if ([instructionAll count] == 0) {
                                        [deviceIdArray removeObject:[NSNumber numberWithInteger:deviceId]];
                                    }
                                    break;
                                }
                            }
                        }
                        
                        if ([deviceIdArray containsObject:[NSNumber numberWithInteger:deviceId]]) {
                            [deviceNameArray addObject:d.name];
                            [instructionArray addObject:instructionAll];
                        }
                    }
                }
            }
            if ([deviceIdArray count] == 0) {
                [dTArray removeObject:dt];
            }
        }
        switch (dt.dtId) {
            case 1:
                _acArray = [NSMutableArray arrayWithObjects:deviceIdArray,deviceNameArray,instructionArray, nil];
                break;
            case 2:
                _tvArray = [NSMutableArray arrayWithObjects:deviceIdArray,deviceNameArray,instructionArray, nil];
                break;
            case 3:
                _curturnArray = [NSMutableArray arrayWithObjects:deviceIdArray,deviceNameArray,instructionArray, nil];
                break;
            case 4:
                _audioArray = [NSMutableArray arrayWithObjects:deviceIdArray,deviceNameArray,instructionArray, nil];
                break;
            case 5:
                _otherArray = [NSMutableArray arrayWithObjects:deviceIdArray,deviceNameArray,instructionArray, nil];
                break;
            case 6:
                _socketArray = [NSMutableArray arrayWithObjects:deviceIdArray,deviceNameArray,instructionArray, nil];
                break;
            case 7:
                _smartArray = [NSMutableArray arrayWithObjects:deviceIdArray,deviceNameArray,instructionArray, nil];
                break;
            case 8:
                _irArray = [NSMutableArray arrayWithObjects:deviceIdArray,deviceNameArray,instructionArray, nil];
                break;
            case 9:
                _smokeArray = [NSMutableArray arrayWithObjects:deviceIdArray,deviceNameArray,instructionArray, nil];
                break;
            case 10:
                _doorArray = [NSMutableArray arrayWithObjects:deviceIdArray,deviceNameArray,instructionArray, nil];
                break;
            default:
                _slalarmArray = [NSMutableArray arrayWithObjects:deviceIdArray,deviceNameArray,instructionArray, nil];
                break;
        }
    }
    NSLog(@"%@",_acArray);
    NSLog(@"%@",_tvArray);
    NSLog(@"%@",_curturnArray);
    NSLog(@"%@",_audioArray);
    NSLog(@"%@",_otherArray);
    NSLog(@"%@",_socketArray);
    NSLog(@"%@",_smartArray);
    NSLog(@"%@",_irArray);
    NSLog(@"%@",_smokeArray);
    NSLog(@"%@",_doorArray);
    NSMutableArray *nameArray = [NSMutableArray array];
    for (MyEDeviceType *t in dTArray) {
        [nameArray addObject:t.name];
        //        NSLog(@"%@",t.name);
    }
    self.deviceTypeNameArray = nameArray;
    
    return dTArray;
}
-(void)getModeArrayByDeviceId:(NSInteger)dcId{  //针对不同的空调会有不同的运行模式数组，这里要专门写一下这个方法
    for (MyEDevice *d in self.accountData.devices) {
        if (d.deviceId == dcId) {
            if (d.instructionMode == 1) {   //值为1表示【通风模式】存在
                modeArray = @[@"自动",@"制热",@"制冷",@"除湿",@"通风"];
            }else
                modeArray = @[@"自动",@"制热",@"制冷",@"除湿"];
        }
    }
}
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    //这部分代码主要用于更新带picker的btn的UI
    //    if (!IS_IOS6) {
    for (UIButton *btn in self.view.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn-ios6"] forState:UIControlStateDisabled];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
        }
    }
    //    }else{
    //        for (UIButton *btn in self.view.subviews) {
    //            if ([btn isKindOfClass:[UIButton class]]) {
    //                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn-ios6"] forState:UIControlStateNormal];
    //                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    //            }
    //        }
    //    }
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
    /*----------------------------------初始化各个数组--------------------------------------------*/
    
    //对于永远不变的数组，先提前初始化好
    windLevelArray = @[@"自动",@"一级",@"二级",@"三级"];
    //获取温度数组
    NSMutableArray *array = [NSMutableArray array];
    for (int i=18; i<=30; i++) {
        [array addObject:[NSString stringWithFormat:@"%i℃",i]];  //特别注意此处数组中的内容为字符串
    }
    temperatureArray = array;
    _device = [[MyEDevice alloc] init];
    if (jumpFromBarBtn != 1) {  //表示现在是编辑模式(此模式中，设备类型和设备名称都不能变更，所以只需要更新指令数组就可以了)
        //首先判断btn的可点击状态
        self.navigationItem.rightBarButtonItem.enabled = NO;
        deviceTypeBtn.enabled = NO;
        deviceBtn.enabled = NO;
        
        NSString *instructionName;
        //获取当前设备的控制码数组
        NSMutableArray *instructionNameArray = [NSMutableArray array];
        NSMutableArray *instructionIds = [NSMutableArray array];
        NSInteger deviceId = [dictionaryRecived[@"id"] intValue];  //这个表示的是设备ID
        
        MyEDevice *device = [self.accountData findDeviceWithDeviceId:deviceId];  //通过deviceId找到device
        MyEDeviceType *dt = [self.accountData findDeviceTypeWithId:device.type]; //通过device找到deviceType
        _deviceTypeIndex = dt.dtId;  //这里必须要对_deviceTypeIndex赋值，因为在后面会用到 这里也叫记录一下类型ID
        //更新btn的title
        [deviceTypeBtn setTitle:dt.name forState:UIControlStateNormal];
        [deviceBtn setTitle:device.name forState:UIControlStateNormal];
        
        //设备不是系统定义的空调(自定义空调, 或一般红外设备, 或插座)
        if (device.type != DT_AC ||
            (device.type == DT_AC && !device.isSystemDefined)) {//可以理解为不是空调或者不是系统肯定的空调
            
            //然后更新数据
            if(device.type == DT_SOCKET){ //如果是插座
                [self setLabelAndButtonForOthers];
                if ([dictionaryRecived[@"controlKey"][@"keyId"] intValue] == 1) {
                    [powerBtn setTitle:@"开" forState:UIControlStateNormal];
                    _selectedPowerIndex = 0;
                }else if([dictionaryRecived[@"controlKey"][@"keyId"] intValue] == 0){
                    [powerBtn setTitle:@"关" forState:UIControlStateNormal];
                    _selectedPowerIndex = 1;
                }
                powerArray = @[@"开",@"关"];
            }else if(device.type == 7){
                [self setLabelAndButtonForSwitch];
                _device.status.switchStatus = dictionaryRecived[@"controlKey"][@"channel"];
                [self.tableView reloadData];
            }else if (device.type == 8 || device.type == 9 || device.type == 10 || device.type == 11){
                [self setLabelAndButtonForOthers];
                self.powerArray = @[@"布防",@"撤防"];
                if ([dictionaryRecived[@"controlKey"][@"powerSwitch"] intValue] == 1) {
                    [powerBtn setTitle:@"布防" forState:UIControlStateNormal];
                    _selectedPowerIndex = 0;
                }else{
                    [powerBtn setTitle:@"撤防" forState:UIControlStateNormal];
                    _selectedPowerIndex = 1;
                }
            }else{
                [self setLabelAndButtonForOthers];
                //找到当前设备的控制码数组
                for (int i=0; i<[instructionRecived.allInstructions count]; i++) {
                    MyESceneDevice *sceneDevice = instructionRecived.allInstructions[i];
                    if (deviceId == sceneDevice.deviceId) {
                        for (MyESceneDeviceInstruction *instruction in sceneDevice.instructions) {
                            if (device.type == 1 && !device.isSystemDefined) {  //自学习的空调设备
                                _scendDevice = sceneDevice;
                                NSString *str = nil;
                                if (instruction.status > 0) {
                                    str = [NSString stringWithFormat:@"%@|%@|%@|%@",
                                           [MyEAcUtil getStringForPowerSwitch:instruction.powerSwitch],
                                           [MyEAcUtil getStringForRunMode:instruction.runMode],
                                           [MyEAcUtil getStringForSetpoint:instruction.setpoint],
                                           [MyEAcUtil getStringForWindLevel:instruction.windLevel]];
                                    [instructionNameArray addObject:str];
                                }else{
                                    [_scendDevice.instructions removeObject:instruction];
                                }
                            }
                            else{   //一般设备
                                if (instruction.status > 0) {
                                    [instructionIds addObject:[NSNumber numberWithInteger:instruction.instructionId]];
                                    [instructionNameArray addObject:instruction.keyName];
                                }
                            }
                        }
                    }
                }
                self.powerArray = instructionNameArray;
                self.instructionIdArray = instructionIds;
                
                //找到该设备所对应的指令
                if (device.type == 1 && !device.isSystemDefined) {
                    instructionName = [NSString stringWithFormat:@"%@|%@|%@|%@",
                                       [MyEAcUtil getStringForPowerSwitch:[dictionaryRecived[@"controlKey"][@"powerSwitch"] intValue]],
                                       [MyEAcUtil getStringForRunMode:[dictionaryRecived[@"controlKey"][@"runMode"] intValue]],
                                       [MyEAcUtil getStringForSetpoint:[dictionaryRecived[@"controlKey"][@"setpoint"] intValue]],
                                       [MyEAcUtil getStringForWindLevel:[dictionaryRecived[@"controlKey"][@"windLevel"] intValue]]];
                    if ([instructionNameArray containsObject:instructionName]) {
                        _selectedPowerIndex = [instructionNameArray indexOfObject:instructionName];
                    } else {
                        if ([instructionNameArray count] != 0) {
                            _selectedPowerIndex = 0;
                            instructionName = instructionNameArray[0];
                            self.navigationItem.rightBarButtonItem.enabled = YES;
                        }else{
                            instructionName = @"无有效指令";
                        }
                    }
                } else {
                    if ([dictionaryRecived[@"controlKey"][@"keyId"] intValue] == -1) { //如果是-1表示指令出错了,一般都是指令被删除了
                        if ([instructionNameArray count] != 0) {
                            _selectedPowerIndex = 0;
                            instructionName = instructionNameArray[0];
                            self.navigationItem.rightBarButtonItem.enabled = YES;
                        }else{
                            instructionName = @"无有效指令";
                        }
                    }else{
                        for (int i=0; i<[instructionRecived.allInstructions count]; i++) {
                            MyESceneDevice *sceneDevice = instructionRecived.allInstructions[i];
                            for (MyESceneDeviceInstruction *instruction in sceneDevice.instructions) {
                                if ([dictionaryRecived[@"controlKey"][@"keyId"] intValue] == instruction.instructionId) {//此处应该加上对于status的判断，只有当status=1的时候才能够添加控制码
                                    if (instruction.status >0) {
                                        instructionName = instruction.keyName;
                                        _selectedPowerIndex = [instructionNameArray indexOfObject:instructionName];
                                    }else{
                                        if ([instructionNameArray count] != 0) {
                                            _selectedPowerIndex = 0;
                                            instructionName = instructionNameArray[0];
                                            self.navigationItem.rightBarButtonItem.enabled = YES;
                                        } else {
                                            instructionName = @"无有效指令";
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
                [powerBtn setTitle:instructionName forState:UIControlStateNormal];
            }
        }else{  //设备是系统定义的空调
            powerArray = @[@"开",@"关"];
            [self getModeArrayByDeviceId:deviceId];  //针对不同的空调有不同的模式,这里是重中之重，需要特别注意
            if ([dictionaryRecived[@"controlKey"][@"powerSwitch"] intValue] == 1) {  //如果控制码是“开”的话，所有的label和button都是可见的
                _selectedPowerIndex = 0;
                //首先更新UI
                [self setLabelAndButtonForSystemDefinedAC];
                [powerBtn setTitle:@"开" forState:UIControlStateNormal];
                
                //然后设置每个btn的title
                [self setWindlevelBtnTitle];
                _selectedWindlevelIndex = [dictionaryRecived[@"controlKey"][@"windLevel"] intValue];
                [self setModeBtnTitle];
                _selectedRunmodeIndex = [dictionaryRecived[@"controlKey"][@"runMode"] intValue] - 1;  //这里需要注意的是运行模式是从1开始的
                
                int setpoint = [dictionaryRecived[@"controlKey"][@"setpoint"] intValue];
                _selectedSetpointIndex = setpoint - 18;
                [temperatureBtn setTitle:[NSString stringWithFormat:@"%i℃",setpoint] forState:UIControlStateNormal];
            }else{
                _selectedPowerIndex = 1;
                _selectedRunmodeIndex = 0;//runmode此处必须指定
                _selectedSetpointIndex = 0;//setpoint此处必须指定
                _selectedWindlevelIndex = 0;//windlevel此处必须指定
                [powerBtn setTitle:@"关" forState:UIControlStateNormal];
                [self setLabelAndButtonForOthers];
            }
        }
    }else{  //这里表示的是新增设备
        //刚开始进来的时候就初始化各个select的值
        _selectedDeviceTypeIndex = 0;
        _selectedDeviceIndex = 0;
        _selectedPowerIndex = 0;
        _selectedRunmodeIndex = 0;
        _selectedWindlevelIndex = 0;
        _selectedSetpointIndex = 7;  //这里之所以值为7，是为了让温度显示为25℃
        
        //初始化设备类型数组
        deviceTypeArray = [self getValidDeviceTypes];   //这句代码可谓是重中之重
        
        MyEDeviceType *dt = deviceTypeArray[_selectedDeviceTypeIndex];
        _deviceTypeIndex = dt.dtId;
        [deviceTypeBtn setTitle:dt.name forState:UIControlStateNormal];
        
        [self getDeviceArrayAndPowerArrayByDeviceType:_deviceTypeIndex andIndex:_selectedDeviceIndex];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)deviceType:(id)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择设备类型" andDelegate:self andTag:1 andArray:self.deviceTypeNameArray andSelectRow:_selectedDeviceTypeIndex andViewController:self];
}

- (IBAction)device:(id)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择设备" andDelegate:self andTag:2 andArray:deviceArray andSelectRow:_selectedDeviceIndex andViewController:self];
}

- (IBAction)power:(id)sender {
    if ([powerBtn.currentTitle isEqualToString:@"无有效指令"]) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示" contentText:@"此设备没有可用的指令，建议将其删除" leftButtonTitle:nil rightButtonTitle:@"知道了！"];
        alert.rightBlock = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
        [alert show];
        return;
    }
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择控制码" andDelegate:self andTag:3 andArray:powerArray andSelectRow:_selectedPowerIndex andViewController:self];
}

- (IBAction)windLever:(id)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择风力大小" andDelegate:self andTag:5 andArray:windLevelArray andSelectRow:_selectedWindlevelIndex andViewController:self];
}

- (IBAction)changeMode:(id)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择运行模式" andDelegate:self andTag:4 andArray:modeArray andSelectRow:_selectedRunmodeIndex andViewController:self];
}

- (IBAction)temperature:(id)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择温度" andDelegate:self andTag:6 andArray:temperatureArray andSelectRow:_selectedSetpointIndex andViewController:self];
}
- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    // 现在我们已经记录了 _selectedDeviceTypeIndex, _selectedDeviceIndex,  考虑删除原有的sceneDetailDictionary, 删除原有的controlKeyDictionary来, 在这里重新形成该变量
    NSInteger deviceId = 0;
    if (jumpFromBarBtn == 1) {  //新增设备
        deviceId = [self.deviceIdArray[_selectedDeviceIndex] integerValue];
        //特别注意，只有在新增设备的时候才运行进行重复性判断
        if ([self.deviceIdArrayRecived containsObject:[NSNumber numberWithInteger:deviceId]]) {
            [MyEUtil showMessageOn:nil withMessage:@"该设备已存在，不允许重复添加"];
            return;
        }
    } else {
        deviceId = [dictionaryRecived[@"id"] intValue];
    }
    MyEDevice *device = [self.accountData findDeviceWithDeviceId:deviceId];
    
    NSMutableDictionary *sceneDetailDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *controlKeyDictionary = [NSMutableDictionary dictionary];
    [sceneDetailDictionary setObject:[NSNumber numberWithInteger:deviceId] forKey:@"id"];
    
    if (device.type != DT_AC ) {//不是空调, 或是用户定义的空调
        [sceneDetailDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"isAc"];
        [controlKeyDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"windLevel"];
        [controlKeyDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"runMode"];
        [controlKeyDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"setpoint"];
        [controlKeyDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"powerSwitch"];
        [controlKeyDictionary setObject:@"" forKey:@"channel"];
        if(device.type == DT_SOCKET){
            if ([powerBtn.currentTitle isEqualToString:@"关"]) {
                [controlKeyDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"keyId"];
            }else{
                [controlKeyDictionary setObject:[NSNumber numberWithInteger:1] forKey:@"keyId"];
            }
        }else if (device.type == 7){
            [sceneDetailDictionary setObject:[NSNumber numberWithInteger:2] forKey:@"isAc"];
            NSMutableString *string = [NSMutableString stringWithString:_device.status.switchStatus];
            [string replaceOccurrencesOfString:@"2" withString:@"0" options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
            [controlKeyDictionary setObject:[NSString stringWithString:string] forKey:@"channel"];
            [controlKeyDictionary setObject:@0 forKey:@"keyId"];
        }else if (device.type == 8 || device.type == 9 || device.type == 10 || device.type ==11){
            [sceneDetailDictionary setObject:[NSNumber numberWithInteger:device.type - 5] forKey:@"isAc"];
            [controlKeyDictionary setObject:@0 forKey:@"keyId"];
            if ([powerBtn.currentTitle isEqualToString:@"布防"]) {
                [controlKeyDictionary setObject:[NSNumber numberWithInteger:1] forKey:@"powerSwitch"];
            }else{
                [controlKeyDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"powerSwitch"];
            }
        }else{//一般设备
            [controlKeyDictionary setObject:self.instructionIdArray[_selectedPowerIndex] forKey:@"keyId"];
        }
    }else{  //空调（这个逻辑没有问题）
        [sceneDetailDictionary setObject:[NSNumber numberWithInteger:1] forKey:@"isAc"];
        if (device.isSystemDefined) {
            [controlKeyDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"keyId"];
            [controlKeyDictionary setObject:[NSNumber numberWithInteger:_selectedWindlevelIndex]forKey:@"windLevel"];
            [controlKeyDictionary setObject:[NSNumber numberWithInteger:_selectedRunmodeIndex + 1] forKey:@"runMode"];
            [controlKeyDictionary setObject:[NSNumber numberWithInteger:_selectedSetpointIndex + 18] forKey:@"setpoint"];
            if ([powerBtn.titleLabel.text isEqualToString:@"关"]) {
                [controlKeyDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"powerSwitch"];
            }else{
                [controlKeyDictionary setObject:[NSNumber numberWithInteger:1] forKey:@"powerSwitch"];
            }
        } else {
            MyESceneDeviceInstruction *inst;
            if (jumpFromBarBtn == 1) { //新增设备时
                inst = _acArray[2][_selectedDeviceIndex][_selectedPowerIndex] ;
            }else
                inst = _scendDevice.instructions[_selectedPowerIndex];
            
            [controlKeyDictionary setObject:[NSNumber numberWithInteger:inst.instructionId] forKey:@"keyId"];
            [controlKeyDictionary setObject:[NSNumber numberWithInteger:inst.windLevel] forKey:@"windLevel"];
            [controlKeyDictionary setObject:[NSNumber numberWithInteger:inst.runMode] forKey:@"runMode"];
            [controlKeyDictionary setObject:[NSNumber numberWithInteger:inst.setpoint] forKey:@"setpoint"];
            [controlKeyDictionary setObject:[NSNumber numberWithInteger:inst.powerSwitch] forKey:@"powerSwitch"];
        }
        
    }
    [sceneDetailDictionary setObject:controlKeyDictionary forKey:@"controlKey"];
    
    if (jumpFromBarBtn == 1) {  //这是新增设备的
        jumpFromBarBtn = 0;
        [self.delegate passValue:sceneDetailDictionary];
        [self.navigationController popViewControllerAnimated:YES];
    }else{   //这是编辑设备的
        [self.delegate refreshData:sceneDetailDictionary byIndexPath:sceneIndex];
        [self.navigationController popViewControllerAnimated:YES];
    }
    NSLog(@"%@",sceneDetailDictionary);
}
#pragma mark - IQActionSheet delegate methods
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles{
    switch (pickerView.tag) {
        case 1:
            [deviceTypeBtn setTitle:titles[0] forState:UIControlStateNormal];
            _selectedDeviceTypeIndex = [self.deviceTypeNameArray indexOfObject:titles[0]];
            for (MyEDeviceType *dt in self.accountData.deviceTypes) {
                if ([dt.name isEqualToString:titles[0]]) {
                    _deviceTypeIndex = dt.dtId;
                }
            }
            _selectedDeviceIndex = 0;
            _selectedPowerIndex = 0;
            [self getDeviceArrayAndPowerArrayByDeviceType:_deviceTypeIndex andIndex:_selectedDeviceIndex];
            break;
        case 2:
            [deviceBtn setTitle:titles[0] forState:UIControlStateNormal];
            _selectedDeviceIndex = [deviceArray indexOfObject:titles[0]];
            _selectedPowerIndex = 0;
            [self getDeviceArrayAndPowerArrayByDeviceType:_deviceTypeIndex andIndex:_selectedDeviceIndex];
            break;
        case 3:
            [powerBtn setTitle:titles[0] forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            _selectedPowerIndex = [powerArray indexOfObject:titles[0]];
            if (_deviceTypeIndex < 2) {  //注意看一下这里的判断是否会出现错误
                if ([titles[0] isEqualToString:@"开"]) {
                    [self setLabelAndButtonForSystemDefinedAC];
                    [modeBtn setTitle:modeArray[_selectedRunmodeIndex] forState:UIControlStateNormal];
                    [windLevelBtn setTitle:windLevelArray[_selectedWindlevelIndex] forState:UIControlStateNormal];
                    [temperatureBtn setTitle:temperatureArray[_selectedSetpointIndex] forState:UIControlStateNormal];
                }else
                    [self setLabelAndButtonForOthers];
            }
            break;
        case 4:
            [modeBtn setTitle:titles[0] forState:UIControlStateNormal];
            _selectedRunmodeIndex = [modeArray indexOfObject:titles[0]];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            break;
        case 5:
            [windLevelBtn setTitle:titles[0] forState:UIControlStateNormal];
            _selectedWindlevelIndex = [windLevelArray indexOfObject:titles[0]];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            break;
        default:
            [temperatureBtn setTitle:titles[0] forState:UIControlStateNormal];
            _selectedSetpointIndex = [temperatureArray indexOfObject:titles[0]];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            break;
    }
}
#pragma mark - tableviewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_device.status.switchStatus length];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];;
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    UIButton *btn = (UIButton *)[cell.contentView viewWithTag:101];
    btn.enabled = NO;
    label.text = [NSString stringWithFormat:@"通道%i",indexPath.row+1];
    NSInteger i = [[_device.status.switchStatus substringWithRange:NSMakeRange(indexPath.row, 1)] integerValue];
    NSLog(@"%i",i);
    if (i == 2) {
        btn.enabled = NO;
    }else{
        btn.enabled = YES;
        btn.selected = i == 1?NO:YES;
    }
    return cell;
}
@end
