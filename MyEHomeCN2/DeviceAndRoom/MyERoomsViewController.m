//
//  MyERoomsViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/3/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyERoomsViewController.h"
#import "MyEDevicesViewController.h"
#import "MyESettingsViewController.h"

#define ROOM_DELETE_UPLOADER_NMAE @"RoomDeleteUploader"

@interface MyERoomsViewController (){
    BOOL _isAdd;
    MyERoom *_editRoom,*_oldRoom;
    NSString *_roomName;
    MBProgressHUD *HUD;
    NSIndexPath *_selectIndex;
}

@end

@implementation MyERoomsViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [rc addTarget:self action:@selector(downloadDeviceAndRoomListFromServer) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - private methods
-(void)doThisToAddOrEditRoom{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_isAdd?@"添加新房间":@"编辑此房间" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *text = [alert textFieldAtIndex:0];
    text.textAlignment = NSTextAlignmentCenter;
    text.font = [UIFont systemFontOfSize:20];
    if (_isAdd) {
        text.placeholder = @"请输入房间名称";
    }else{
        text.text = _editRoom.name;
    }
    alert.tag = 100;
    [alert show];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [MainDelegate.accountData.rooms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RoomCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *detailLabel = (UILabel *)[cell.contentView viewWithTag:3];
    UIButton *btn = (UIButton *)[cell.contentView viewWithTag:4];
    if (indexPath.row == 0) {
        btn.enabled = NO;
    }
    MyERoom *room = [MainDelegate.accountData.rooms objectAtIndex:indexPath.row];
    [titleLabel setText:room.name];
    [detailLabel setText:[NSString stringWithFormat:@"设备数: %lu",(unsigned long)[room.devices count]]];
    return cell;
}

#pragma mark - tableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyEDevicesViewController *devicesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"devicesVC"];
    devicesViewController.preivousPanelType = 1;
    
    MyERoom *room = [MainDelegate.accountData.rooms objectAtIndex:indexPath.row];
    [devicesViewController setTitle:room.name];
    devicesViewController.room = room;
    //        devicesViewController.devices = room.devices;
    [self.navigationController pushViewController:devicesViewController animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //这里可以判断是否进行编辑，不管是插入，删除还是排序
    if (indexPath.row > 0) {
        return YES;
    }else
        return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _selectIndex = indexPath;
        MyERoom *room = [MainDelegate.accountData.rooms objectAtIndex:indexPath.row];
        if ([room.devices count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"确定删除此房间吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
            alert.tag = 101;
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"该房间内已存在相应设备,此时不允许删除" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
#pragma mark - IBAction methods
- (IBAction)addRoom:(UIBarButtonItem *)sender {
    _editRoom = [[MyERoom alloc] init];
    _isAdd = YES;
    [self doThisToAddOrEditRoom];
}

- (IBAction)editDevice:(UIButton *)sender forEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:sender] anyObject];
    CGPoint location = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    _oldRoom = MainDelegate.accountData.rooms[indexPath.row];
    _editRoom = [_oldRoom copy];
    _isAdd = NO;  //表示此时是在编辑房间
    [self doThisToAddOrEditRoom];
}

#pragma mark - URL Loading System methods
-(void)downloadDeviceAndRoomListFromServer{
    if (self.refreshControl.isRefreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中..."];
    }
    NSString *urlStr= [NSString stringWithFormat:@"%@?gid=%@",GetRequst(URL_FOR_DEVICE_ROOM_LIST),MainDelegate.accountData.userId];
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"deviceAndRoomList"  userDataDictionary:nil];
    NSLog(@"deviceAndRoomList is %@",uploader.name);
}

- (void) deleteRoomFromServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    
    _editRoom = MainDelegate.accountData.rooms[_selectIndex.row];
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%ld&name=%@&action=2",GetRequst(URL_FOR_ROOM_ADD_EDIT_SAVE), (long)_editRoom.roomId, _editRoom.name];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"deleteRoom"  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL Delegate methods
// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"ajax json = %@", string);
    NSInteger i = [MyEUtil getResultFromAjaxString:string];
    if([name isEqualToString:@"deviceAndRoomList"]) {
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
        //        NSLog(@"string is %@",string);
        if (i == -3){
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if (i != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"获取数据失败,请稍后重试!"];
        } else{
            
            MyEAccountData *account = [[MyEAccountData alloc] initWithJSONString:string];
            MainDelegate.accountData = [MainDelegate.accountData newAccoutData:account];
//            MainDelegate.accountData.devices = account.devices;
//            MainDelegate.accountData.rooms = account.rooms;
//            MainDelegate.accountData.terminals = account.terminals;
//            MainDelegate.accountData.deviceTypes = account.deviceTypes;
        }
    }
    if ([name isEqualToString:@"roomEdit"]) {
        if (i == 1) {
            if (_isAdd) {
                NSDictionary *dic = [string JSONValue];
                _editRoom.roomId = [dic[@"roomId"] intValue];
                [MainDelegate.accountData addOrDeleteRoom:_editRoom isAdd:YES];
            }else{
                [MainDelegate.accountData editRoom:_oldRoom withNewRoom:_editRoom];
            }
        }else
            [MyEUtil showMessageOn:nil withMessage:@"操作失败"];
    }
    if ([name isEqualToString:@"deleteRoom"]) {
        if (i == 1) {
            [MainDelegate.accountData addOrDeleteRoom:_editRoom isAdd:NO];
        }else
            [MyEUtil showMessageOn:nil withMessage:@"操作失败"];
    }
    [self.tableView reloadData];
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:ROOM_DELETE_UPLOADER_NMAE])
        msg = @"删除房间通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}

#pragma mark - UIAlertView delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        UITextField *txt = [alertView textFieldAtIndex:0];
        _editRoom.name = txt.text;
        if (txt.text.length < 2 || txt.text.length > 11) {
            [MyEUtil showMessageOn:nil withMessage:@"房间名称长度不对"];
            [alertView performSelector:@selector(show) withObject:nil afterDelay:1.5];
            return;
        }
        BOOL hasOne = NO;
        for (MyERoom *r in MainDelegate.accountData.rooms) {
            if ([r isKindOfClass:[MyERoom class]]) {
                if ([_roomName isEqualToString:r.name]) {
                    hasOne = YES;
                    break;
                }
            }
        }
        if (hasOne) {
            [MyEUtil showMessageOn:nil withMessage:@"该房间名称已存在"];
            [alertView performSelector:@selector(show) withObject:nil afterDelay:1.5];
        }else{
            if(HUD == nil) {
                HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            } else
                [HUD show:YES];
            
            NSString *urlStr = [NSString stringWithFormat:@"%@?id=%ld&name=%@&action=%i",GetRequst(URL_FOR_ROOM_ADD_EDIT_SAVE),_isAdd?0:(long)_editRoom.roomId,_editRoom.name, _isAdd?0:1];
            MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"roomEdit"  userDataDictionary:nil];
            NSLog(@"%@",downloader.name);
        }
    }
    if (alertView.tag == 101 && buttonIndex == 1) {
        [self deleteRoomFromServer];
    }
}
@end
