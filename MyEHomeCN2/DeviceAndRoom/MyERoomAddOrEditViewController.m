//
//  MyERoomEditViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/13/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyERoomAddOrEditViewController.h"
#import "MyERoomsViewController.h"

#define ROOM_ADD_EDIT_UPLOADER_NMAE @"RoomAddEditUploader"

@interface MyERoomAddOrEditViewController ()

@end

@implementation MyERoomAddOrEditViewController
@synthesize accountData, room, actionType,saveBtn;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life circle methods
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if (self.actionType == 1) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.roomNameField.textAlignment = NSTextAlignmentCenter;
    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]] && btn.tag == 110) {
                btn.layer.masksToBounds = YES;
                btn.layer.cornerRadius = 4;
                btn.layer.borderColor = btn.tintColor.CGColor;
                btn.layer.borderWidth = 1;
            }
        }
    }
    if (self.actionType == 1) { //编辑房间
        [self.roomNameField setText:self.room.name];
        self.saveBtn.enabled= YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(doThisWhenTextChange)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:nil];
    }else{
        self.navigationItem.title = @"新增房间";
        self.saveBtn.hidden = YES;
        [self.deleteBtn setTitle:@"确定" forState:UIControlStateNormal];

    }
        [self defineTapGestureRecognizer];
}
#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self.roomNameField endEditing:YES];
}
-(void)doThisWhenTextChange{
    if (![self.roomNameField.text isEqualToString:self.room.name] || ![self.roomNameField.text isEqualToString:@""]) {
        self.saveBtn.enabled = YES;
    }else{
        self.saveBtn.enabled = NO;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods
- (IBAction)deleteRoom:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"确定"]) {
        [self confirmAction:sender];
        return;
    }
    if ([room.devices count] == 0) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                    contentText:@"您正在删除此房间，确定继续么？"
                                                leftButtonTitle:@"取消"
                                               rightButtonTitle:@"确定"];
        [alert show];
        alert.rightBlock = ^() {
            [self deleteRoomFromServer];
        };
    }else{
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                    contentText:@"房间内存在有效的可控制设备，此时不允许删除该房间"
                                                leftButtonTitle:nil
                                               rightButtonTitle:@"知道了"];
        [alert show];
    }
}

- (IBAction)confirmAction:(id)sender {
    if ([self.roomNameField.text length] == 0) {
        [MyEUtil showErrorOn:self.navigationController.view withMessage:@"房间名称不能为空！"];
        return;
    }
    for (MyERoom *r in self.accountData.rooms) {
        if ([r isKindOfClass:[MyERoom class]]) {
            if ([self.roomNameField.text isEqualToString:r.name]) {
                [MyEUtil showMessageOn:nil withMessage:@"房间名称已存在"];
                return;
            }
        }
    }
    [self submitResult];
}

#pragma mark - URL Loading System methods
- (void) deleteRoomFromServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%ld&name=%@&action=2",URL_FOR_ROOM_ADD_EDIT_SAVE, (long)room.roomId, room.name];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"deleteRoom"  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

- (void) submitResult
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%ld&name=%@&action=%ld",URL_FOR_ROOM_ADD_EDIT_SAVE, (long)self.room.roomId, self.roomNameField.text, (long)self.actionType];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:ROOM_ADD_EDIT_UPLOADER_NMAE  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:ROOM_ADD_EDIT_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            if ([[dict objectForKey:@"actionType"] integerValue] == 0) {
                [MyEUtil showErrorOn:self.navigationController.view withMessage:@"添加房间失败，请修改名称后重试！"];
            } else
             [MyEUtil showErrorOn:self.navigationController.view withMessage:@"修改房间失败，请修改名称后重试！"];
        } else{
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *result_dict = [parser objectWithString:string];
            self.room.name = self.roomNameField.text;
            //            [MyEUtil showToastOn:self.navigationController.view withMessage:@"发送空调指令成功！"];
            MyERoomsViewController *rvc = [[self.navigationController childViewControllers] objectAtIndex:0];
            if (self.actionType == 0) {
                [MyEUtil showSuccessOn:self.navigationController.view withMessage:@"添加房间成功！"];
                self.room.roomId = [[result_dict objectForKey:@"roomId"] integerValue];
                [self.accountData.rooms addObject:self.room];
                [rvc.tableView reloadData];
            } else{
                [MyEUtil showSuccessOn:self.navigationController.view withMessage:@"修改房间成功！"];
                for (MyERoom *r in self.accountData.rooms) {//遍历数据，进行全部的名称变更
                    if (r.roomId == self.room.roomId) {
                        r.name = self.roomNameField.text;
                    }
                }
                [rvc.tableView reloadData];
            }
            [self.navigationController popToViewController:rvc animated:YES];
            self.room = nil;
        }
    }
    if([name isEqualToString:@"deleteRoom"]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"删除房间失败，请稍后重试！"];
        } else{
            [MyEUtil showSuccessOn:self.navigationController.view withMessage:@"删除房间成功！"];
            [self.accountData.rooms removeObjectAtIndex:self.index.row];
            //            [self.rooms removeObjectAtIndex:indexPath.row];
            MyERoomsViewController *vc = [self.navigationController childViewControllers][0];
            [vc.tableView deleteRowsAtIndexPaths:@[self.index] withRowAnimation:UITableViewRowAnimationFade];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:ROOM_ADD_EDIT_UPLOADER_NMAE])
        msg = @"添加或修改房间属性通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}

@end
