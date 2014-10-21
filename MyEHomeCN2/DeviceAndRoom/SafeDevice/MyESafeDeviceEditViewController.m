//
//  MyESafeDeviceEditViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-8-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESafeDeviceEditViewController.h"
#import "MyEDevicesViewController.h"

@interface MyESafeDeviceEditViewController (){
    MBProgressHUD *HUD;
}

@end

@implementation MyESafeDeviceEditViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_roomBtn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
    [_roomBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    
//    [self doThisWhenNeedNetworkWithURL:[NSString stringWithFormat:@"%@?deviceId=%i",GetRequst(URL_FOR_SAFE_INFO),_device.deviceId] andName:@"info"];
    _nameTxt.text = _device.name;
    _idLbl.text = _device.tId;
    if (_device.type == 8) {
        _typeLbl.text = @"红外入侵探测器";
    }else if (_device.type == 9){
        _typeLbl.text = @"烟雾探测器";
    }else if (_device.type == 10){
        _typeLbl.text = @"门窗磁";
    }else if(_device.type == 11){
        _typeLbl.text = @"声光报警器";
    }else if (_device.type == 12){
        _typeLbl.text = @"RF自动窗帘";
    }else
        _typeLbl.text = @"其他RF遥控设备";
    
    if (_device.type > 11) {
        _coverView.hidden = NO;
    }else
        _coverView.hidden = YES;
    [_roomBtn setTitle:[self findRoomNameByRoomId:_device.roomId] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(NSString *)findRoomNameByRoomId:(NSInteger)roomId{
    for (MyERoom *r in self.accountData.rooms) {
        if (r.roomId == roomId) {
            return r.name;
        }
    }
    return @"未知";
}
-(NSInteger)findRoomIdByRoomName:(NSString *)name{
    for (MyERoom *r in self.accountData.rooms) {
        if ([r.name isEqualToString:name]) {
            return r.roomId;
        }
    }
    return 0;
}
#pragma mark - IBAction methods
- (IBAction)selectRoom:(UIButton *)sender {
    NSMutableArray *array = [NSMutableArray array];
    for (MyERoom *r in self.accountData.rooms) {
        [array addObject:r.name];
    }
    MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:1 title:@"选择房间" dataSource:array andSelectRow:[array containsObject:sender.currentTitle]?[array indexOfObject:sender.currentTitle]:0];
    picker.delegate = self;
    [picker show];
//    [MyEUniversal doThisWhenNeedPickerWithTitle:@"选择房间" andDelegate:self andTag:1 andArray:array andSelectRow:[array containsObject:sender.currentTitle]?[array indexOfObject:sender.currentTitle]:0 andViewController:self];
}
- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    [_nameTxt resignFirstResponder];
    if (_nameTxt.text.length < 1 || _nameTxt.text.length > 21) {
        [MyEUtil showMessageOn:nil withMessage:@"设备名称长度不对"];
        return;
    }
    if ([_roomBtn.currentTitle isEqualToString:@"获取中..."] || [_roomBtn.currentTitle isEqualToString:@"未知"]) {
        [MyEUtil showMessageOn:nil withMessage:@"房间未指定"];
        return;
    }
    [self doThisWhenNeedNetworkWithURL:[NSString stringWithFormat:@"%@?id=%i&name=%@&roomId=%i&action=1&type=%i&tId=%@",GetRequst(_device.type > 11?URL_FOR_RFDEVICE_EDIT:URL_FOR_DEVICE_IR_ADD_EDIT_SAVE),_device.deviceId,_nameTxt.text,[self findRoomIdByRoomName:_roomBtn.currentTitle],_device.type,_device.tId] andName:@"save"];
}
- (IBAction)deleteDevice:(UIButton *)sender {
//    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告" contentText:@"确定删除该设备吗?" leftButtonTitle:@"取消" rightButtonTitle:@"确定"];
//    alert.rightBlock = ^{
//        [self doThisWhenNeedNetworkWithURL:[NSString stringWithFormat:@"%@?id=%i&tId=%@&name=%@&type=%i&action=2&roomId=%i",GetRequst(_device.type > 11?URL_FOR_RFDEVICE_EDIT:URL_FOR_DEVICE_IR_ADD_EDIT_SAVE),_device.deviceId,_device.tId,_device.name,_device.type,_device.roomId] andName:@"delete"];
//    };
//    [alert show];
}

#pragma mark - URL methods
-(void)doThisWhenNeedNetworkWithURL:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}
#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"receive string is %@",string);
    NSInteger i = [MyEUtil getResultFromAjaxString:string];
    if (i == 1) {
        if ([name isEqualToString:@"info"]) {
            NSDictionary *dic = [string JSONValue];
            if (dic) {
                NSInteger roomId = [dic[@"roomId"] intValue];
                [_roomBtn setTitle:[self findRoomNameByRoomId:roomId] forState:UIControlStateNormal];
                _nameTxt.text = dic[@"name"];
            }
        }else{
            NSInteger i = [self.navigationController.childViewControllers indexOfObject:self];
            MyEDevicesViewController *vc = self.navigationController.childViewControllers[i - 1];
            vc.needRefresh = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (i == -3){
        [MyEUtil showMessageOn:nil withMessage:@"用户已注销"];
    }else if (i == -2){
        [MyEUtil showMessageOn:nil withMessage:@"设备名称重复"];
    }else if (i == 0){
        [MyEUtil showMessageOn:nil withMessage:@"传入的数据有问题"];
    }else{
        [MyEUtil showMessageOn:nil withMessage:@"操作失败"];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [MyEUtil showMessageOn:nil withMessage:@"与服务器连接失败"];
}

#pragma mark - UIActionSheet Delegate method

-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    [_roomBtn setTitle:title forState:UIControlStateNormal];
}
@end
