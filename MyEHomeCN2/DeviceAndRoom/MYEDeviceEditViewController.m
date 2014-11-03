//
//  MYEDeviceEditViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-9-12.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEDeviceEditViewController.h"
#import "MBProgressHUD.h"
#import "MyESwitchInfo.h"
#import "MYEACInitStepViewController.h"

@interface MYEDeviceEditViewController (){
    MBProgressHUD *HUD;
    MyEDevice *_deviceCache;
    MyERoom *_roomCache;
    MyEDeviceType *_deviceTypeCache;
    MyETerminal *_terminalCache;
    MyESwitchInfo *_switchInfo;
    NSString *_selectedMid;
    
    MBProgressHUD *tips;
    NSTimer *_timer;
    NSInteger _times;
    
    NSArray *_deviceTypeArray;
    
    BOOL _editInstruction;
    NSMutableArray *_validTerminals;
}

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *roomLbl;
@property (weak, nonatomic) IBOutlet UILabel *typeLbl;
@property (weak, nonatomic) IBOutlet UILabel *terminalLbl;     //用于显示设备的TID
@property (weak, nonatomic) IBOutlet UILabel *terminalTypeLbl; //用于显示[智控星]还是[设备ID]
@property (weak, nonatomic) IBOutlet UILabel *lblMid;
@property (weak, nonatomic) IBOutlet UILabel *valueLbl;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;

//以下属性主要针对[智能开关]
@property (weak, nonatomic) IBOutlet UILabel *powerFactorLbl;

@end

@implementation MYEDeviceEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = _saveBtn;
    self.title = _isAdd?@"新增设备":@"设备编辑";
    _deviceCache = [_device newDevice:_device];
    [self getDeviceData];
    if (_isAdd) {
        _deviceTypeArray = [MainDelegate.accountData validDeviceTypeToAddWithAC:[MainDelegate.accountData validTerminalsForAC].count];
        _deviceTypeCache = _deviceTypeArray[0];
    }
    
    if (_deviceCache.type == 7) {
        [self urlLoaderWithUrlString:[NSString stringWithFormat:@"%@?deviceId=%li",GetRequst(URL_FOR_SWITCH_VIEW),(long)self.device.deviceId] loaderName:@"downloadSwitchInfo"];
    }
    _validTerminals = [NSMutableArray arrayWithArray:[MainDelegate.accountData validTerminalsForAC]];
    if (!_isAdd) {
        if (_deviceTypeCache.dtId == 1) {
            if (_terminalCache != nil) {
                [_validTerminals insertObject:_terminalCache atIndex:0];
            }
        }
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self performSelector:@selector(refreshUI) withObject:nil afterDelay:0];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - private methods
-(void)getDeviceData{
    _roomCache = [MainDelegate.accountData findDeviceRoomWithDevice:_deviceCache];
    _deviceTypeCache = [MainDelegate.accountData findDeviceDeviceTypeWithDevice:_deviceCache];
    NSLog(@"%@",_deviceTypeCache);
    if (_deviceCache.type < 6) {
        _terminalCache = [MainDelegate.accountData findDeviceTerminalWithDevice:_deviceCache];
    }
}
-(void)refreshUI{
    NSLog(@"%@",_deviceCache);

    _deviceNameLbl.text = _deviceCache.name;
    _roomLbl.text = _roomCache.name;
    _typeLbl.text = _deviceTypeCache.name;
    
    if (_deviceTypeCache.dtId < 6) {
        _terminalTypeLbl.text = @"智控星";
        _terminalLbl.text = [_deviceCache.tId isEqualToString:@""]?@"请选择智控星":_deviceCache.tId;  //不管什么情况下都显示的设备的TID,这个得注意
    }else if(_deviceTypeCache.dtId < 12){
        _terminalTypeLbl.text = @"设备ID";
        _terminalLbl.text = [_deviceCache.tId isEqualToString:@""]?@"手动输入ID":_deviceCache.tId;  //不管什么情况下都显示的设备的TID,这个得注意
    }else{
        _terminalTypeLbl.text = @"网关";
        _terminalLbl.text = (_selectedMid == nil || [_selectedMid isEqualToString:@""])?@"选择绑定网关":_selectedMid;
    }
    
    if (_isAdd) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UITableViewCell *cell0 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        if (_deviceTypeCache.dtId < 12) {
            cell0.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else
            cell0.accessoryType = UITableViewCellAccessoryNone;
//        if (_deviceTypeCache.dtId > 7 && _deviceTypeCache.dtId < 12 && _deviceCache.tId.length < 8) {
//            _terminalLbl.text = _deviceCache.tId;
//        }
    }else{
        if (_deviceCache.type == 7) {  //如果是[智能开关]
            _valueLbl.text = [_switchInfo changeTypeToString];
            _powerFactorLbl.text = _switchInfo.powerFactor;
        }
        if (_deviceCache.type == 6) {
            _valueLbl.text = [NSString stringWithFormat:@"%ld A", (long)self.device.status.maxElectricCurrent];
        }
        if (_deviceCache.type == 1) {
            _valueLbl.text = [NSString stringWithFormat:@"%@/%@",_deviceCache.brand,_deviceCache.model];
        }
    }
    [self.tableView reloadData];
}
-(void)showAlertToEnterWithTitle:(NSString *)title tag:(NSInteger)tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = tag;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *txt = [alert textFieldAtIndex:0];
    txt.textAlignment = NSTextAlignmentCenter;
    if (tag == 100) {
        txt.text = [_deviceCache.name isEqualToString:@"新设备"]?@"":_deviceCache.name;
    }
    if (tag == 101) {
        txt.text = [_deviceCache.tId isEqualToString:@"手动输入ID"]?@"":_deviceCache.tId;
    }
    [alert show];
    
}

-(void)urlLoaderWithUrlString:(NSString *)url loaderName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    [MyEDataLoader startLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
}

#pragma mark - IBAction methods
- (void)getDeviceIdByUseIt{
    if (_selectedMid == nil || [_selectedMid isEqualToString:@""]) {
        [MyEUtil showMessageOn:nil withMessage:@"请先选择网关"];
        return;
    }
    tips = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    tips.removeFromSuperViewOnHide = YES;
    tips.userInteractionEnabled = YES;
    //初始化label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,100)];
    //设置自动行数与字符换行
    [label setNumberOfLines:0];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = @"请在10秒内手动触发设备";
    
    UIFont *font = [UIFont fontWithName:@"Arial" size:13];
    //设置一个行高上限
    CGSize size = CGSizeMake(320,2000);
    //计算实际frame大小，并将label的frame变成实际大小
    CGSize labelsize = [label.text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    CGRect newFrame = label.frame;
    newFrame.size.height = labelsize.height;
    label.frame = newFrame;
    [label sizeToFit];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    tips.customView = label;
    //	HUD.color = [UIColor whiteColor];
    tips.mode = MBProgressHUDModeCustomView;
    tips.cornerRadius = 2;
    tips.margin = 10;
    tips.dimBackground = YES;
    
    _times = 0; //对times进行初始化
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?mId=%@",GetRequst(URL_FOR_SAFE_REQUEST),_selectedMid] postData:nil delegate:self loaderName:@"safeDeviceRequest" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}
- (void)scanCodeToGetDeviceId{
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"settings" bundle:nil] instantiateViewControllerWithIdentifier:@"QRNav"];
    MyEQRScanViewController *vc = nav.childViewControllers[0];
    vc.delegate = self;
    vc.isAddCamera = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)save:(UIBarButtonItem *)sender {
    if ((_deviceCache.type < 12 && !_isAdd) || (_deviceTypeCache.dtId < 12 && _isAdd)) {
        if (_deviceCache.tId.length < 23) {
            [MyEUtil showMessageOn:nil withMessage:@"设备ID或智控星有误"];
            return;
        }
    }
    if (_deviceCache.name.length == 0 || _deviceCache.name.length > 10) {
        [MyEUtil showMessageOn:nil withMessage:@"名称长度不符合要求"];
        return;
    }
    
    if (_isAdd) {
        for (MyEDevice *d in MainDelegate.accountData.devices) {
            if ([_deviceNameLbl.text isEqualToString:d.name]) {
                [MyEUtil showMessageOn:nil withMessage:@"设备名称已存在"];
                return;
            }
        }
    }
    if (_terminalCache == nil && _deviceTypeCache.dtId < 6) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未选定智控星" message:nil delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    _deviceCache.roomId = _roomCache.roomId;
    _deviceCache.type = _deviceTypeCache.dtId;

    NSLog(@"%@",_deviceCache);

    if (_deviceTypeCache.dtId > 11) {  //RF设备
        [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?id=%i&action=%i&name=%@&type=%i&roomId=%i&mId=%@",GetRequst(URL_FOR_RFDEVICE_EDIT),_deviceCache.deviceId,!_isAdd,_deviceCache.name,_deviceCache.type,_deviceCache.roomId,_selectedMid] postData:nil delegate:self loaderName:@"deviceEdit" userDataDictionary:nil];
    }else if (_deviceTypeCache.dtId != 6 && _deviceTypeCache.dtId != 7) {   //不是插座,不是开关
        [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?id=%i&name=%@&tId=%@&roomId=%i&type=%i&action=%i&mId=%@",
                                                  GetRequst(_deviceTypeCache.dtId == 1?URL_FOR_AC_ADD_EDIT_SAVE:URL_FOR_DEVICE_IR_ADD_EDIT_SAVE),_deviceCache.deviceId,_deviceCache.name,_deviceCache.tId,_deviceCache.roomId,_deviceCache.type,!_isAdd,_selectedMid] postData:nil delegate:self loaderName:@"deviceEdit" userDataDictionary:nil];
    }else if(_deviceTypeCache.dtId == 6){
        [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?id=%i&name=%@&tId=%@&roomId=%i&maxElectricCurrent=%.0f&action=%i",GetRequst(URL_FOR_DEVICE_SOCKET_ADD_EDIT_SAVE), _deviceCache.deviceId, _deviceCache.name, _deviceCache.tId, _deviceCache.roomId, _deviceCache.status.maxElectricCurrent,_isAdd] postData:nil delegate:self loaderName:@"deviceEdit" userDataDictionary:nil];
    }else{
        [self urlLoaderWithUrlString:[NSString stringWithFormat:@"%@?deviceId=%li&name=%@&roomId=%li&loadType=%i&powerFactor=%@",GetRequst(URL_FOR_SWITCH_SAVE),(long)_deviceCache.deviceId,_deviceCache.name,(long)_deviceCache.roomId,_switchInfo.type,_switchInfo.powerFactor] loaderName:@"deviceEdit"];

    }
    
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (!_isAdd) {
        if (_deviceCache.type == 1 && [_deviceCache isInitialized]) {
            return 3;
        }
        if (_deviceCache.type == 6) {
            return 3;
        }
        if (_deviceCache.type == 7) {
            return 3;
        }
        if (_deviceCache.type > 11) {
            return 1;
        }
    }
    if (_isAdd) {
        if (_deviceTypeCache.dtId > 7 && _deviceTypeCache.dtId < 12) {
            return 3;
        }
    }
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        if (_isAdd && (_deviceTypeCache.dtId > 7 && _deviceTypeCache.dtId < 12)) {
            return 2;
        }
        return 1;
    }
    if (section == 2) {
        if (!_isAdd && _deviceTypeCache.dtId == 7) return 2;
        if (_isAdd && _deviceTypeCache.dtId >7) {
            return 2;
        }
        return 1;
    }
    return 3;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self showAlertToEnterWithTitle:@"请输入设备名称" tag:100];
        }
        if (indexPath.row == 1) {  //无论什么情况下都可以修改房间
            LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"请选择房间" options:MainDelegate.accountData.rooms];
            lplv.tag = 101;
            lplv.delegate = self;
            [lplv showInView:MainDelegate.window animated:YES];
        }
        if (indexPath.row == 2 && _isAdd) {   //只有在新增的情况下才能修改设备类型
            LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"请选择设备类型" options:[MainDelegate.accountData validDeviceTypeToAddWithAC:[MainDelegate.accountData validTerminalsForAC].count]];
            lplv.tag = 102;
            lplv.delegate = self;
            [lplv showInView:self.view.window animated:YES];
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (_deviceTypeCache.dtId < 6) {
                NSMutableArray *array = nil;
                if (_deviceTypeCache.dtId == 1) {
                    array = _validTerminals;
                }else
                    array = [NSMutableArray arrayWithArray:MainDelegate.accountData.terminals];
                LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"请选择智控星" options:array];
                lplv.tag = 103;
                lplv.delegate = self;
                [lplv showInView:self.view.window animated:YES];
            }
            if (_isAdd) {
                if (_deviceTypeCache.dtId >7 && _deviceTypeCache.dtId < 12) {
                    [self showAlertToEnterWithTitle:@"请输入设备ID" tag:101];
                }
                if (_deviceTypeCache.dtId > 11) {
                    LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"请选择网关" options:[MainDelegate.accountData validMeditors]];
                    lplv.tag = 107;
                    lplv.delegate = self;
                    [lplv showInView:self.view.window animated:YES];
                }
            }
        }
        if (indexPath.row == 1) {
            LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"请选择网关" options:[MainDelegate.accountData validMeditors]];
            lplv.tag = 107;
            lplv.delegate = self;
            [lplv showInView:self.view.window animated:YES];
        }
    }
    if (indexPath.section == 2) {  //只有[空调][插座][开关]才有这个功能

        if (indexPath.row == 0) {
            if (_deviceTypeCache.dtId == 1) {
                MYEACInitStepViewController *vc = [[UIStoryboard storyboardWithName:@"ACInit" bundle:nil] instantiateViewControllerWithIdentifier:@"select"];
                vc.device = self.device;
                vc.step = 1;
//                UIStoryboard *story = [UIStoryboard storyboardWithName:@"AcInstruction" bundle:nil];
//                MYEACInstructionManageViewController *vc = [story instantiateViewControllerWithIdentifier:@"manager"];
////                MyEInstructionManageViewController *vc = [story instantiateViewControllerWithIdentifier:@"instructionVC"];
//                vc.device = _deviceCache;
//                _editInstruction = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }else if (_deviceTypeCache.dtId == 6){
                LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"请选择最大电流" options:[_deviceCache maxElecArray]];
                lplv.tag = 104;
                lplv.delegate = self;
                [lplv showInView:self.view.window animated:YES];
            }else if (_deviceTypeCache.dtId == 7){
                LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"请选择灯具类型" options:[_switchInfo typeArray]];
                lplv.tag = 105;
                lplv.delegate = self;
                [lplv showInView:self.view.window animated:YES];
            }else{
                [self getDeviceIdByUseIt];
            }
        }
        if (indexPath.row == 1) {
            if (_switchInfo.type == 1) {
                return;
            }
            if (_isAdd && _deviceTypeCache.dtId > 7) {
                [self scanCodeToGetDeviceId];
                return;
            }
            LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"请选择功率因数" options:[_switchInfo powerFactorArray]];
            lplv.tag = 106;
            lplv.delegate = self;
            [lplv showInView:self.view.window animated:YES];
        }
    }
}

#pragma mark - LeveyPopListView delegates
- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSInteger)index
{
    if (popListView.tag == 101) {
        _roomCache = MainDelegate.accountData.rooms[index];
    }else if (popListView.tag == 102){
        _deviceTypeCache = _deviceTypeArray[index];
        if (_deviceTypeCache.dtId < 6) {
            _deviceCache.tId = @"未指定智控星";
        }else
            _deviceCache.tId = @"手动输入ID";
    }else if (popListView.tag == 103){
//        NSMutableArray *array = _deviceTypeCache.dtId == 1?[[MainDelegate.accountData validTerminalsForAC] mutableCopy]: MainDelegate.accountData.terminals;
//        if (!_isAdd && _terminalCache != nil) {
//            [array insertObject:_terminalCache atIndex:0];
//        }
        NSMutableArray *array = nil;
        if (_deviceTypeCache.dtId == 1) {
            array = _validTerminals;
        }else
            array = [NSMutableArray arrayWithArray:MainDelegate.accountData.terminals];
        _terminalCache = array[index];
        _deviceCache.tId = _terminalCache.tId;
    }else if (popListView.tag == 104){
        _deviceCache.status.maxElectricCurrent = index + 1;   //对于插座而言，选择最大电流
    }else if (popListView.tag == 105){
        _switchInfo.type = index;
        if (index == 0) {
            _switchInfo.powerFactor = @"0.65";
        }else
            _switchInfo.powerFactor = @"1";
    }else if (popListView.tag == 106){
        _switchInfo.powerFactor = [_switchInfo powerFactorArray][index];
    }else if (popListView.tag == 107){
        MyEMediator *mediator = [MainDelegate.accountData validMeditors][index];
        _selectedMid = mediator.mid;
        self.lblMid.text = _selectedMid;
    }
    [self performSelector:@selector(refreshUI) withObject:nil afterDelay:0];
}
- (void)leveyPopListViewDidCancel{}


#pragma mark - UIAlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    UITextField *txt = [alertView textFieldAtIndex:0];
    if (alertView.tag == 100 && buttonIndex == 1) {
        _deviceCache.name = txt.text;
    }
    if (alertView.tag == 101 && buttonIndex == 1) {
        _deviceCache.tId = txt.text;
        WTReTextField *txtw = (WTReTextField *)[alertView viewWithTag:1000];
        _deviceCache.tId = txtw.text;
    }
    [self refreshUI];
}
#pragma mark - QRScan delegate method
-(void)passCameraUID:(NSString *)UID{
    _terminalLbl.text = UID;
    _deviceCache.tId = UID;
}

#pragma mark - URL Loading System methods
-(void)getResponseFromServer{
    _times++;
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?mId=%@",GetRequst(URL_FOR_SAFE_RESPONSE),_selectedMid] postData:nil delegate:self loaderName:@"safeDeviceResponse" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}

#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    [HUD hide:YES];
    NSInteger i = [MyEUtil getResultFromAjaxString:string];
    if (i == -3) {
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
        return;
    }
    
    if ([name isEqualToString:@"deviceEdit"]) {
        if (i == -2) {
            [MyEUtil showMessageOn:nil withMessage:@"设备名称已存在，请修改后重试"];
            return;
        }
        if (i != 1) {
            if (i == -4) {
                [MyEUtil showMessageOn:nil withMessage:@"该设备ID已存在"];
            }else
                [MyEUtil showMessageOn:nil withMessage:@"操作失败"];
        }else{
            if (_isAdd) {
                NSDictionary *dic = [string JSONValue];
                _deviceCache.deviceId = [dic[@"id"] intValue];
                [MainDelegate.accountData addOrDeleteDevice:_deviceCache isAdd:_isAdd];
                UIViewController *vc = self.navigationController.childViewControllers[0];
                [vc setValue:@(YES) forKey:@"isAddSuccessed"];
            }else{
                _deviceCache.status.connection = 4;
                [MainDelegate.accountData editDevice:_device withNewDevice:_deviceCache];
            }

            MainDelegate.accountData.needDownloadInstructionsForScene = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    if ([name isEqualToString:@"safeDeviceRequest"]) {
        if (i == 1) {
            [self getResponseFromServer];
        }else if (i == -3){
            [tips hide:YES];
            [MyEUtil showMessageOn:nil withMessage:@"用户已注销"];
        }else{
            [tips hide:YES];
            [MyEUtil showMessageOn:nil withMessage:@"操作失败,请重试"];
        }
    }
    if ([name isEqualToString:@"safeDeviceResponse"]) {
        if (i == 1) {
            [tips hide:YES];
            NSDictionary *dic = [string JSONValue];
            NSString *sufix = dic[@"msgContent"];
            NSArray *array = @[@"08",@"09",@"0A",@"0B"];
            if (_deviceTypeCache.dtId == 11) {
                NSString *str = [sufix substringToIndex:5];
                sufix = [NSString stringWithFormat:@"%@-00",str];
            }
            NSString *tid = [NSString stringWithFormat:@"%@-01-00-00-00-%@",array[_deviceTypeCache.dtId - 8],sufix];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"检测到新设备" message:tid delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            _terminalLbl.text = tid;
            _deviceCache.tId = tid;
        }else{
            if (_times < 6) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getResponseFromServer) userInfo:nil repeats:NO];
            }else{
                [tips hide:YES];
                if (i == 3){
                    [MyEUtil showMessageOn:nil withMessage:@"查询超时"];
                }else if (i == 4){
                    [MyEUtil showMessageOn:nil withMessage:@"解析失败"];
                }else if (i == 5){
                    [MyEUtil showMessageOn:nil withMessage:@"在指定的15秒内未收到学习结果"];
                }else
                    [MyEUtil showMessageOn:nil withMessage:@"未获取到设备ID,请重试"];
            }
        }
    }
    if ([name isEqualToString:@"downloadSwitchInfo"]) {
        NSLog(@"download switch string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            MyESwitchInfo *info = [[MyESwitchInfo alloc] initWithString:string];
            _switchInfo = info;
            [self refreshUI];  //这里一定要记得更新表格
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:nil withMessage:@"下载数据时发生错误"];
        }
    }

}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [MyEUtil showMessageOn:nil withMessage:@"与服务器连接失败,请稍后重试"];
}
@end
