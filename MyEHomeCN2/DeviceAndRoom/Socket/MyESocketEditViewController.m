//
//  MyESocketEditViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/13/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyESocketEditViewController.h"

#import "MyEDevicesViewController.h"

#define SOCKET_EDIT_UPLOADER_NMAE @"DeviceAddEditUploader"

@interface MyESocketEditViewController ()

@end

@implementation MyESocketEditViewController
@synthesize accountData, device = _device, preivousPanelType;
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
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *noti){
        if (![self.nameField.text isEqualToString:self.device.name]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }else
            self.navigationItem.rightBarButtonItem.enabled = NO;
    }];

//    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                if (btn.tag == 100 || btn.tag == 101) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
                }
            }
        }
//    }else{
//        for (UIButton *btn in self.view.subviews) {
//            if ([btn isKindOfClass:[UIButton class]]) {
//                if (btn.tag == 100 || btn.tag == 101) {
//                    [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn-ios6"] forState:UIControlStateNormal];
//                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
//                }
//            }
//        }
//    }
    self.nameField.text = self.device.name;
    MyERoom *room = [self.accountData findFirstRoomWithRoomId:self.device.roomId];
    NSString *roomName = @"";
    if (room) {
        roomName = room.name;
    }
    if (self.preivousPanelType == 0) {
        self.roomBtn.enabled = YES;
    } else
        self.roomBtn.enabled = NO;
    
    [self.roomBtn setTitle:roomName forState:UIControlStateNormal];
    [self.maxCurrentBtn setTitle:[NSString stringWithFormat:@"%ld 安培", (long)self.device.status.maxElectricCurrent] forState:UIControlStateNormal];
    
    _roomArray = [NSMutableArray array];
    for (MyERoom *r in self.accountData.rooms) {
        [_roomArray addObject:r.name];
    }

    _maxElecArray = [NSMutableArray array];
    for (int i = 1; i < 13; i++) {
        [_maxElecArray addObject:[NSString stringWithFormat:@"%i 安培",i]];
    }
   
    _initDic = @{@"name": self.nameField.text,
                 @"room": self.roomBtn.currentTitle,
                 @"elct": self.maxCurrentBtn.currentTitle};
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - setter methods
-(void)setDevice:(MyEDevice *)device
{
    if(_device != device){
        _device = device;
        _isAdvanced = [device.tId rangeOfString:@"02-00"].location != NSNotFound ;
    }
}

#pragma mark - private methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
#pragma mark - IBAction methods
- (IBAction)deleteDevice:(UIButton *)sender {
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                contentText:@"此操作将清空该设备的所有数据，您确定继续么？"
                                            leftButtonTitle:@"取消"
                                           rightButtonTitle:@"确定"];
    [alert show];
    alert.rightBlock = ^() {
        [self deleteDeviceFromServer];
    };

}
- (IBAction)confirmAction:(id)sender {
    //    [self.view makeToast:@"This is a piece of toast."];
    if([self.nameField.text length] == 0){
        [MyEUtil showErrorOn:self.navigationController.view withMessage:@"请输入插座名称！"];
        return;
    } else
        self.device.name = self.nameField.text;
    for (MyERoom *r in self.accountData.rooms) {
        if ([r.name isEqualToString:self.roomBtn.currentTitle]) {
            self.device.roomId = r.roomId;
        }
    }
    self.device.status.maxElectricCurrent = [_maxElecArray indexOfObject:self.maxCurrentBtn.currentTitle]+1;
    [self submitResult];
}
- (IBAction)roomBtnAction:(id)sender {
    [self.nameField resignFirstResponder];
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择所在房间" andDelegate:self andTag:1 andArray:_roomArray andSelectRow:[_roomArray indexOfObject:self.roomBtn.currentTitle] andViewController:self];
}
- (IBAction)maxCurrentBtnAction:(id)sender {
    [self.nameField resignFirstResponder];
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择插座的最大电流" andDelegate:self andTag:2 andArray:_maxElecArray andSelectRow:[_maxElecArray indexOfObject:self.maxCurrentBtn.currentTitle] andViewController:self];
    //self.device.status.maxElectricCurrent 刚好1到12安培，减一就是序号
}
#pragma mark - UIPickerViewDelegate Protocol and UIPickerViewDataSource Method
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles{
    if (pickerView.tag == 1) {
        [self.roomBtn setTitle:titles[0] forState:UIControlStateNormal];
    }else{
        [self.maxCurrentBtn setTitle:titles[0] forState:UIControlStateNormal];
    }
    NSDictionary *dic = @{@"name": self.nameField.text,
                          @"room": self.roomBtn.currentTitle,
                          @"elct": self.maxCurrentBtn.currentTitle};
    if (![dic isEqualToDictionary:_initDic]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else
        self.navigationItem.rightBarButtonItem.enabled = NO;
}
#pragma mark - URL Loading System methods
- (void) deleteDeviceFromServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSString *urlStr= [NSString stringWithFormat:@"%@?id=%ld&name=%@&tId=%@&roomId=%ld&maxElectricCurrent=%ld&action=2",URL_FOR_DEVICE_SOCKET_ADD_EDIT_SAVE, (long)self.device.deviceId, self.device.name, self.device.tId, (long)self.device.roomId, (long)self.device.status.maxElectricCurrent];
   MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"socketDelete"  userDataDictionary:nil];
    NSLog(@"%@",uploader.name);
}
- (void) submitResult
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
     NSString *urlStr= [NSString stringWithFormat:@"%@?id=%ld&name=%@&tId=%@&roomId=%ld&maxElectricCurrent=%ld&action=0",URL_FOR_DEVICE_SOCKET_ADD_EDIT_SAVE, (long)self.device.deviceId, self.device.name, self.device.tId, (long)self.device.roomId, (long)self.device.status.maxElectricCurrent];
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:SOCKET_EDIT_UPLOADER_NMAE  userDataDictionary:nil];
    
    NSLog(@"%@",uploader.name);
}

#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:@"socketDelete"]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -3){
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"删除设备失败，请稍后重试！"];
        } else{
            MyEDevicesViewController *vc = [self.navigationController viewControllers][0];
            [vc.devices removeObject:self.device];
            [vc.tableView reloadData];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    if([name isEqualToString:SOCKET_EDIT_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"修改插座失败，请修改名称后重试！"];
        } else{
            MyEDevicesViewController *dvc = [[self.navigationController childViewControllers] objectAtIndex:0];
            [MyEUtil showSuccessOn:self.navigationController.view withMessage:@"修改插座成功！"];
            [dvc.tableView reloadData];
            [self.navigationController popToViewController:dvc animated:YES];
            self.device = nil;
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:SOCKET_EDIT_UPLOADER_NMAE])
        msg = @"修改插座通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}
@end
