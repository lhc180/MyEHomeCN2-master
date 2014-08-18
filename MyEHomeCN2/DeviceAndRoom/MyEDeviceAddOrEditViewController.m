//
//  MyEDeviceAddOrEditViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/13/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEDeviceAddOrEditViewController.h"
#import "MyEDevicesViewController.h"
#import "MyERoomsViewController.h"

#define DEVICE_ADD_EDIT_UPLOADER_NMAE @"DeviceAddEditUploader"
#define DEVICE_DELETE_UPLOADER_NAME @"DeviceDeleteUploader"

@interface MyEDeviceAddOrEditViewController (){
    MBProgressHUD *tips;
    NSTimer *_timer;
    NSInteger _times;
}

@end

@implementation MyEDeviceAddOrEditViewController
@synthesize accountData, device, preivousPanelType;
#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //这个更新UI放在此处是为了能够实时更新
    if ([self.device.brand isEqualToString:@""]) {
        [self.brandBtn setTitle:@"空调未初始化" forState:UIControlStateNormal];
        [self.brandBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }else{
        [self.brandBtn setTitleColor:self.brandBtn.tintColor forState:UIControlStateNormal];
        [self.brandBtn setTitle:[NSString stringWithFormat:@"%@| %@",self.device.brand,self.device.model] forState:UIControlStateNormal];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //如果没有绑定智控星，那么[指令库管理]btn不允许用户点击，因为指令库管理跟tid有关，如果没有tid会发生错误
    //    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *noti){
    //        if (![self.nameField.text isEqualToString:self.device.name]) {
    //            self.navigationItem.rightBarButtonItem.enabled = YES;
    //        }else
    //            self.navigationItem.rightBarButtonItem.enabled = NO;
    //    }];
    if (self.device.isOrphan){
        self.downloadInstructionBtn.enabled = NO;
    }else{
        self.downloadInstructionBtn.enabled = YES;
    }
    //这里是用来更新button的UI
    for (UIButton *btn in self.view.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            if (btn.tag == 103) {
                [btn.layer setMasksToBounds:YES];
                [btn.layer setCornerRadius:3];
                [btn.layer setBorderWidth:1];
                [btn.layer setBorderColor:btn.tintColor.CGColor];
            }else if (btn.tag != 100 && btn.tag != 102){
                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn-ios6"] forState:UIControlStateDisabled];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
            }
        }
    }
    if (_safeMainView != nil && !IS_IOS6) {
        for (UIButton *btn in self.safeMainView.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                [btn.layer setMasksToBounds:YES];
                [btn.layer setCornerRadius:3];
                [btn.layer setBorderWidth:1];
                [btn.layer setBorderColor:btn.tintColor.CGColor];
            }
        }
    }
    //以下是对所有的数组进行初始化，对数据进行支持
    
    //找出accountData里面的terminals中的智控星，也就是忽略掉插座(这里也是找到有效的红外设备)
    //这里要特别注意下，对于一般设备使用的就是这个数组，对于空调的话则要使用专门针对空调的数组
    _terminalArray = [NSMutableArray array];
    for (MyETerminal *terminal in self.accountData.terminals) {
        //这里其实不需要对前缀进行判断，之前是以为这里面会有插座，其实里面只有智控星，之前确实有，可能后来更改了接口
        if ([[terminal.tId substringToIndex:2] intValue] == 1) {
            [_terminalArray addObject:terminal];
        }
    }
    
    MyETerminal *t;
    MyERoom *room;
    MyEDeviceType *dt;
    if (self.actionType == 0) { //表示新增设备，不管是从什么面板跳转过来的都可以,只有房间名称有些变化
        //UI更新
        self.navigationController.topViewController.title = @"添加设备";
        _safeIdTxt.pattern = @"^([0-9a-fA-F]{2}(?:-)){7}[0-9a-fA-F]{2}$";
        self.deleteBtn.hidden = YES;   //之前这里是更改了btn的名称，现在是将这个btn进行隐藏
        
        //找出accountData里面的有效设备类型，也就是忽略掉插座,开关等  (特别注意此处,因为插座和开关是自动绑定的，用户不能自己添加)
        _validTypeArray = [NSMutableArray array];
        for (MyEDeviceType *type in self.accountData.deviceTypes) {
            if (type.dtId < 6 || type.dtId > 7) {
                [_validTypeArray addObject:type];
            }
        }
        dt = _validTypeArray[1];
        [self.typeBtn setTitle:dt.name forState:UIControlStateNormal];
        
        if (preivousPanelType == 0) {  //0表示登录后直接到设备面板在到此面板
            room = self.accountData.rooms[0];
            [self.roomBtn setTitle:room.name forState:UIControlStateNormal];
        }else{
            [self.roomBtn setTitle:self.room.name forState:UIControlStateNormal];
        }
        if (_terminalArray.count) {
            t = _terminalArray[0];
            [_terminalBtn setTitle:t.name forState:UIControlStateNormal];
        }
    }else{  //这个表示编辑设备，不管从什么面板跳转过来都可以
        //UI更新
        self.navigationController.topViewController.title = @"设备编辑";
        //        if ([self.device.tId isEqualToString:@""]) {
        //            self.navigationItem.rightBarButtonItem.enabled = YES;
        //        }else
        //            self.navigationItem.rightBarButtonItem.enabled = NO;
        
        [self.nameField setText:self.device.name];
        
        self.typeBtn.enabled = NO;
        //这个是一个技巧,编辑设备的时候不能对设备类型进行限定
        dt = [self.accountData.deviceTypes objectAtIndex:(self.device.type - 1)];
        [self.typeBtn setTitle:dt.name forState:UIControlStateNormal];
        
        room = [self.accountData findFirstRoomWithRoomId:self.device.roomId];
        [self.roomBtn setTitle:room.name forState:UIControlStateNormal];
        
        if ([self.device.tId length] == 0) { //表示该设备没有绑定智控星，这时要对这个设备进行判断，如果为空调，则取有效智控星，如果为其他设备，则全部数组
            if (self.device.type == 1) {
                self.downloadInstructionBtn.enabled = NO; //如果tid为空，那么不允许用户点击【指令库管理】
                _terminalArrayForAc = [self getTerminalArrayForAC];
                t = _terminalArrayForAc[0];
                if ([t.name isEqualToString:@"无有效智控星"]) {
                    self.terminalBtn.enabled = NO;
                    //                    self.navigationItem.rightBarButtonItem.enabled = NO;
                    self.alertLabel.hidden = NO;
                }
            }else
                if (_terminalArray.count) {
                    t = _terminalArray[0];
                }
        }else{
            if (self.device.type == 1) { //之前如果是空调的话不允许用户修改智控星，现在修改的是重新寻找有效的智控星数组
                NSMutableArray *array = [NSMutableArray arrayWithArray:[self getTerminalArrayForAC]];
                for (MyETerminal *t in array) {
                    if ([t.name isEqualToString:@"无有效智控星"]) {
                        [array removeObject:t];
                    }
                }
                for (MyETerminal *t in _terminalArray) {
                    if ([t.tId isEqualToString:self.device.tId]) {
                        [array addObject:t];
                    }
                }
                _terminalArrayForAc = array;
            }
            for (MyETerminal *terminal in _terminalArray) {
                if ([terminal.tId isEqualToString:self.device.tId]) {
                    t = terminal;
                }
            }
            [self.terminalBtn setTitle:t.name forState:UIControlStateNormal];
        }
        
        //       _initDic = @{@"name":self.nameField.text?self.nameField.text:[NSNull null],
        //                     @"room":self.roomBtn.currentTitle?self.roomBtn.currentTitle:[NSNull null],
        //                     @"terminal":self.terminalBtn.currentTitle?self.terminalBtn.currentTitle:[NSNull null]};  //这里记录最开始的值，以便进行比较
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - private methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}
-(void)hideKeyboard{
    [self.nameField endEditing:YES];
}
-(NSArray *)getTerminalArrayForAC{
    NSMutableArray *array = [NSMutableArray array];
    for (MyETerminal *t in self.accountData.terminals) {
        if ([[t.tId substringToIndex:2] isEqualToString:@"01"]) {
            [array addObject:t];
        }
    }
    for (int i=0; i<[self.accountData.devices count]; i++) {
        MyEDevice *d = self.accountData.devices[i];
        if (d.type == 1) {
            for (int j =0; j<[array count]; j++) {
                MyETerminal *t = array[j];
                if ([d.tId isEqualToString:t.tId]) {
                    [array removeObject:t];
                }
            }
        }
    }
    //这里必须要注意，在遍历的里面不能再进行遍历
    //        for (MyEDevice *d in self.accountData.devices) {
    //            if (d.type == 1) {
    //                for (MyETerminal *t in array) {
    //                    if ([d.tId isEqualToString:t.tId]) {
    //                        [array removeObject:t];
    //                    }
    //                }
    //            }
    //        }
    if ([array count] == 0) {
        MyETerminal *t = [[MyETerminal alloc] init];
        t.tId = @"01-00-00-00-00-00-00-00";
        t.name = @"无有效智控星";
        [array addObject:t];//此处使用add方法不影响，因为此时的array是空的，里面什么也没有
    }
    //    }
    NSLog(@"%@",array);
    return array;
}
-(NSString *)getDeviceTidByName:(NSString *)name{
    for (MyETerminal *t in self.accountData.terminals) {
        if ([t.name isEqualToString:name]) {
            return t.tId;
        }
    }
    return nil;
}
-(NSInteger)getDeviceRoomIdByName:(NSString *)name{
    for (MyERoom *room in self.accountData.rooms) {
        if ([room.name isEqualToString:name]) {
            return room.roomId;
        }
    }
    return 0;
}
-(NSInteger)getDeviceTypeByName:(NSString *)name{
    for (MyEDeviceType *dt in self.accountData.deviceTypes) {
        if ([dt.name isEqualToString:name]) {
            return dt.dtId;
        }
    }
    return -1;
}

//#pragma mark - UITextField Delegate Methods 委托方法
//// 添加每个textfield的键盘的return按钮的后续动作
//- (BOOL) textFieldShouldReturn:(UITextField *)textField {
//    if (textField == self.nameField ) {
//        [textField resignFirstResponder];
//    }
//    return  YES;
//}
#pragma mark - IBAction methods
- (IBAction)deleteDevice:(UIButton *)sender {
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告" contentText:@"此操作将清空该设备的所有数据，您确定继续么？" leftButtonTitle:@"取消" rightButtonTitle:@"确定"];
    [alert show];
    alert.rightBlock = ^() {
        [self deleteDeviceFromServer];
    };
}
- (IBAction)setFeedbackTone:(UISwitch *)sender {
    [self setFeedbackToneToServerWithBool:!sender.isOn];
}
- (IBAction)acInstructionManage:(UIButton *)sender {
    
    //这里更改了框架
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"AcInstruction" bundle:nil];
    MyEInstructionManageViewController *vc = [story instantiateViewControllerWithIdentifier:@"instructionVC"];
    vc.accountData = self.accountData;
    vc.device = self.device;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)confirmAction:(id)sender {
    [_nameField resignFirstResponder];
    [_safeIdTxt resignFirstResponder];
    if([self.nameField.text length] == 0){
        [MyEUtil showErrorOn:self.navigationController.view withMessage:@"请输入设备名称！"];
        return;
    }
    if (_actionType == 0) {
        for (MyETerminal *t in self.accountData.terminals) {
            if ([t.tId isEqualToString:_safeIdTxt.text]) {
                [MyEUtil showErrorOn:self.navigationController.view withMessage:@"该设备已存在"];
                return;
            }
        }
        if ([self.typeBtn.currentTitle isEqualToString:@"红外入侵探测器"] || [self.typeBtn.currentTitle isEqualToString:@"烟雾探测器"] || [self.typeBtn.currentTitle isEqualToString:@"门窗磁"]) {
            
            NSString *str = _safeIdTxt.text;
            NSInteger i = 0;
            if ([str hasPrefix:@"08"]) {
                i = 8;
            }else if ([str hasPrefix:@"09"]){
                i = 9;
            }else if ([str hasPrefix:@"0A"] || [str hasPrefix:@"0a"]){
                i = 10;
            }else{
                [MyEUtil showMessageOn:nil withMessage:@"设备ID输入有误,请重试"];
                return;
            }

            if (HUD == nil) {
                HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            }else
                [HUD show:YES];
            MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?id=0&tId=%@&name=%@&type=%i&action=0&roomId=%i",URL_FOR_DEVICE_IR_ADD_EDIT_SAVE,_safeIdTxt.text,_nameField.text,i,[self getDeviceRoomIdByName:_roomBtn.currentTitle]] postData:nil delegate:self loaderName:@"safeEdit" userDataDictionary:nil];
            NSLog(@"loader name is %@",loader.name);
            return;
        }
    }
    if ([self.terminalBtn.currentTitle isEqualToString:@"无有效智控星"]) {
        [MyEUtil showErrorOn:self.navigationController.view withMessage:@"无有效智控星,现在不能添加空调"];
        return;
    }
    if (self.actionType == 0) {  //新增设备时在本地进行名字重复性判断
        for (MyEDevice *d in self.accountData.devices) {
            if ([d isKindOfClass:[MyEDevice class]]) {
                if ([self.nameField.text isEqualToString:d.name]) {
                    [MyEUtil showMessageOn:nil withMessage:@"设备名称已存在"];
                    return;
                }
            }
        }
    }
    [self submitResult];
}

- (IBAction)terminalBtnAction:(UIButton *)sender {
    [self.view endEditing:YES];
    NSArray *terminalArray = nil;
    NSMutableArray *array = [NSMutableArray array];
    if ([self.typeBtn.currentTitle isEqualToString:@"空调"]) {
        terminalArray = _terminalArrayForAc;
    }else{
        terminalArray = _terminalArray;
    }
    for (MyETerminal *t in terminalArray) {
        [array addObject:t.name];
    }
    
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择智控星" andDelegate:self andTag:1 andArray:array andSelectRow:[array containsObject:_terminalBtn.currentTitle]?[array indexOfObject:_terminalBtn.currentTitle]:0 andViewController:self];
}

- (IBAction)roomBtnAction:(id)sender {
    [self.view endEditing:YES];
    NSMutableArray *roomArray = [NSMutableArray array];
    for (MyERoom *r in self.accountData.rooms) {
        [roomArray addObject:r.name];
    }
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择房间" andDelegate:self andTag:2 andArray:roomArray andSelectRow:[roomArray containsObject:_roomBtn.currentTitle]?[roomArray indexOfObject:_roomBtn.currentTitle]:0 andViewController:self];
}
- (IBAction)typeBtnAction:(id)sender {
    [self.view endEditing:YES];
    NSMutableArray *array = [NSMutableArray array];
    for (MyEDeviceType *dt in _validTypeArray) {
        [array addObject:dt.name];
    }
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择设备类型" andDelegate:self andTag:3 andArray:array andSelectRow:[array containsObject:_typeBtn.currentTitle]?[array indexOfObject:_typeBtn.currentTitle]:0 andViewController:self];
}
- (IBAction)scanQRToGetID:(UIButton *)sender {
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"settings" bundle:nil] instantiateViewControllerWithIdentifier:@"QRNav"];
    MyEQRScanViewController *vc = nav.childViewControllers[0];
    vc.delegate = self;
    vc.isAddCamera = YES;
    [self presentViewController:nav animated:YES completion:nil];
}
- (IBAction)getIDByUsingIt:(UIButton *)sender {
    tips = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    tips.removeFromSuperViewOnHide = YES;
    tips.userInteractionEnabled = YES;
    tips.delegate = self;
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
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@",URL_FOR_SAFE_REQUEST] postData:nil delegate:self loaderName:@"safeDeviceRequest" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}


#pragma mark - URL Loading System methods
-(void)getResponseFromServer{
    _times++;
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@",URL_FOR_SAFE_RESPONSE] postData:nil delegate:self loaderName:@"safeDeviceResponse" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}
-(void)setFeedbackToneToServerWithBool:(BOOL)feedbackToneSwitch{
    NSString *urlStr= [NSString stringWithFormat:@"%@?tId=%@&feedbackToneSwitch=%@",URL_FOR_AC_FEEDBACK_TONE_SWITCH,device.tId,[NSNumber numberWithBool:feedbackToneSwitch]];
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"acFeedbackTone"  userDataDictionary:nil];
    NSLog(@"%@",uploader);
}

- (void) deleteDeviceFromServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSString *urlStr;
    MyEDataLoader *uploader;
    switch (device.type){
        case 1: // AC
            urlStr= [NSString stringWithFormat:@"%@?id=%ld&name=%@&tId=%@&roomId=%ld&action=2",URL_FOR_AC_ADD_EDIT_SAVE, (long)device.deviceId, device.name, device.tId, (long)device.roomId];
            uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:DEVICE_DELETE_UPLOADER_NAME  userDataDictionary:nil];
            break;
        case 6: // Socket
            urlStr= [NSString stringWithFormat:@"%@?id=%ld&name=%@&tId=%@&roomId=%ld&maxElectricCurrent=%ld&action=2",URL_FOR_DEVICE_SOCKET_ADD_EDIT_SAVE, (long)device.deviceId, device.name, device.tId, (long)device.roomId, (long)device.status.maxElectricCurrent];
            uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:DEVICE_DELETE_UPLOADER_NAME  userDataDictionary:nil];
            break;
        default:// other IR device
            urlStr= [NSString stringWithFormat:@"%@?id=%ld&name=%@&tId=%@&roomId=%ld&type=%ld&action=2",URL_FOR_DEVICE_IR_ADD_EDIT_SAVE, (long)device.deviceId, device.name, device.tId, (long)device.roomId,(long)device.type];
            uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:DEVICE_DELETE_UPLOADER_NAME  userDataDictionary:nil];
            break;
    }
    NSLog(@"%@",uploader.name);
}

- (void) submitResult
{
    if ([self.terminalBtn.currentTitle length] == 0) {
        [MyEUtil showMessageOn:nil withMessage:@"未指定智控星"];
        return;
    }
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr;
    MyEDataLoader *uploader;
    NSInteger typeId = [self getDeviceTypeByName:self.typeBtn.currentTitle];
    if (typeId == -1) {
        [MyEUtil showMessageOn:nil withMessage:@"未找到合适的设备类型"];
        return;
    }
    switch (typeId){
        case 1: // AC
            urlStr= [NSString stringWithFormat:@"%@?id=%ld&name=%@&tId=%@&roomId=%li&action=%li",
                     URL_FOR_AC_ADD_EDIT_SAVE,
                     (long)self.device.deviceId,
                     self.nameField.text,
                     [self getDeviceTidByName:self.terminalBtn.titleLabel.text],
                     (long)[self getDeviceRoomIdByName:self.roomBtn.titleLabel.text],
                     (long)self.actionType];
            uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:DEVICE_ADD_EDIT_UPLOADER_NMAE  userDataDictionary:nil];
            break;
        default:// other IR device
            urlStr= [NSString stringWithFormat:@"%@?id=%ld&name=%@&tId=%@&roomId=%li&type=%li&action=%ld",
                     URL_FOR_DEVICE_IR_ADD_EDIT_SAVE,
                     (long)self.device.deviceId,
                     self.nameField.text,
                     [self getDeviceTidByName:self.terminalBtn.titleLabel.text],
                     (long)[self getDeviceRoomIdByName:self.roomBtn.titleLabel.text],
                     (long)[self getDeviceTypeByName:self.typeBtn.titleLabel.text],
                     (long)self.actionType];
            uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:DEVICE_ADD_EDIT_UPLOADER_NMAE  userDataDictionary:nil];
            break;
    }
    NSLog(@"%@",uploader.name);
}

#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:DEVICE_ADD_EDIT_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] == -2) {
            [MyEUtil showMessageOn:nil withMessage:@"设备名称已存在，请修改后重试"];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            if (self.actionType == 0) {
                if([self getDeviceTypeByName:self.typeBtn.titleLabel.text] == 1)
                    [MyEUtil showToastOn:nil withMessage:@"添加空调失败，请检查名称，并且一个智控星只能添加一个空调！" backgroundColor:nil];
                else
                    [MyEUtil showErrorOn:self.navigationController.view withMessage:@"添加设备失败，请修改名称后重试！"];
            } else
                [MyEUtil showErrorOn:self.navigationController.view withMessage:@"修改设备失败，请修改名称后重试！"];
        } else{
            //            //这里是新增设备时候的返回值
            //            SBJsonParser *parser = [[SBJsonParser alloc] init];
            //            NSDictionary *result_dict = [parser objectWithString:string];
            MyEDevicesViewController *vc;
            if (preivousPanelType == 1) { //房间面板跳转过来
                //如果是从房间面板跳转过来的时候，此时新增设备所进行本地数据更新太过复杂，所以开始从服务器请求数据
                //房间面板刷新数据
                vc = [self.navigationController childViewControllers][1];
                vc.needRefresh = YES;
            }else{
                //让设备列表刷新数据
                vc = [self.navigationController childViewControllers][0];
                vc.needRefresh = YES;
            }
            [self.navigationController popViewControllerAnimated:YES];
            //这里不再使用接口里面定义的数据来刷新，而是使用自定义的变量来刷新
            self.accountData.needDownloadInstructionsForScene = YES;
        }
    }
    if([name isEqualToString:DEVICE_DELETE_UPLOADER_NAME]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -3){
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"删除设备失败，请稍后重试！"];
        } else{
            MyEDevicesViewController *vc;
            if (preivousPanelType == 1) {
                vc = [self.navigationController viewControllers][1];
                vc.needRefresh = YES;
            }else{
                vc = [self.navigationController viewControllers][0];
                vc.needRefresh = YES;
            }
            self.accountData.needDownloadInstructionsForScene = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    if ([name isEqualToString:@"safeEdit"]) {
        NSLog(@"safeEdit is %@",string);
        NSInteger i = [MyEUtil getResultFromAjaxString:string];
        if (i == 1) {
            [MyEUtil showMessageOn:nil withMessage:@"操作成功"];
            NSInteger i = [self.navigationController.childViewControllers indexOfObject:self];
            MyEDevicesViewController *vc = self.navigationController.childViewControllers[i - 1];
            vc.needRefresh = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }else if (i == 0){
            [MyEUtil showMessageOn:nil withMessage:@"传入的数据有误"];
        }else if (i == 2){
            [MyEUtil showMessageOn:nil withMessage:@"没有删除,还需继续查找"];
        }else if (i == -3){
            [MyEUtil showMessageOn:nil withMessage:@"用户已注销"];
        }else
            [MyEUtil showMessageOn:nil withMessage:@"操作失败"];
    }
    if ([name isEqualToString:@"safeDeviceRequest"]) {
        NSLog(@"request is %@",string);
        NSInteger i = [MyEUtil getResultFromAjaxString:string];
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
        NSLog(@"response string is %@",string);
        NSInteger i = [MyEUtil getResultFromAjaxString:string];
        if (i == 2) {
            [tips hide:YES];
            NSDictionary *dic = [string JSONValue];
            NSString *sufix = dic[@"msgContent"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"检测到新设备后六位为 %@",sufix] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            if ([self.typeBtn.currentTitle isEqualToString:@"红外入侵探测器"]) {
                _safeIdTxt.text = [NSString stringWithFormat:@"08-01-00-00-00-%@",sufix];
            }else if ([self.typeBtn.currentTitle isEqualToString:@"烟雾探测器"]){
                _safeIdTxt.text = [NSString stringWithFormat:@"09-01-00-00-00-%@",sufix];
            }else
                _safeIdTxt.text = [NSString stringWithFormat:@"0A-01-00-00-00-%@",sufix];
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
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg = @"与服务器通信时发生错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:nil withMessage:msg];
    [HUD hide:YES];
    [tips hide:YES];
}
#pragma mark IBActionSheet delegate method
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    switch (pickerView.tag)
    {
        case 1:
            [_terminalBtn setTitle:titles[0] forState:UIControlStateNormal];
            break;
        case 2:
            [_roomBtn setTitle:titles[0] forState:UIControlStateNormal];
            break;
        default:
            [_typeBtn setTitle:titles[0] forState:UIControlStateNormal];
            if ([titles[0] isEqualToString:@"红外入侵探测器"] || [titles[0] isEqualToString:@"烟雾探测器"] || [titles[0] isEqualToString:@"门磁"] || [titles[0] isEqualToString:@"门窗磁"]) {
                _safeMainView.hidden = NO;
                if ([titles[0] isEqualToString:@"红外入侵探测器"]) {
                    _safeIdTxt.text = @"08-01-00-00-00-00-00-00";
                }else if ([titles[0] isEqualToString:@"烟雾探测器"]) {
                    _safeIdTxt.text = @"09-01-00-00-00-00-00-00";
                }else{
                    _safeIdTxt.text = @"0A-01-00-00-00-00-00-00";
                }
            }else{
                _safeMainView.hidden = YES;
                //这里的btn有个联动的要求
                if ([titles[0] isEqualToString:@"空调"]) {
                    _terminalArrayForAc = [self getTerminalArrayForAC];
                    MyETerminal *t = _terminalArrayForAc[0];
                    [self.terminalBtn setTitle:t.name forState:UIControlStateNormal];
                    if ([t.name isEqualToString:@"无有效智控星"]) {
                        self.terminalBtn.enabled = NO;
                        self.navigationItem.rightBarButtonItem.enabled = NO;
                        self.alertLabel.hidden = NO;
                    }
                }else{
                    MyETerminal *t = _terminalArray[0];
                    [self.terminalBtn setTitle:t.name forState:UIControlStateNormal];
                    self.terminalBtn.enabled = YES;
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    self.alertLabel.hidden = YES;
                }
            }
            break;
    }
    //下面这段代码用于对现在状态进行判断，看看是否已经修改了该设备的相关信息
    
    //    NSDictionary *dic = @{@"name": self.nameField.text?self.nameField.text:[NSNull null],
    //                          @"room":self.roomBtn.currentTitle?self.roomBtn.currentTitle:[NSNull null],
    //                          @"terminal": self.terminalBtn.currentTitle?self.terminalBtn.currentTitle:[NSNull null]};
    //    if (![dic isEqualToDictionary:_initDic]) {
    //        self.navigationItem.rightBarButtonItem.enabled = YES;
    //    }else
    //        self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - QRScan delegate method
-(void)passCameraUID:(NSString *)UID{
    _safeIdTxt.text = UID;
}
@end
