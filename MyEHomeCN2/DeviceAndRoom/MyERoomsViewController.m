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
    MyERoom *_editRoom;
    NSString *_roomName;
}

@end

@implementation MyERoomsViewController
@synthesize accountData;

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

-(void)viewWillAppear:(BOOL)animated{
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self downloadDeviceAndRoomListFromServer];
    }
    [self.tableView reloadData];
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
    return [self.accountData.rooms count];
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
    MyERoom *room = [self.accountData.rooms objectAtIndex:indexPath.row];
    [titleLabel setText:room.name];
    [detailLabel setText:[NSString stringWithFormat:@"设备数: %lu",(unsigned long)[room.devices count]]];
    return cell;
}

#pragma mark - tableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyEDevicesViewController *devicesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"devicesVC"];
    devicesViewController.preivousPanelType = 1;
    
    MyERoom *room = [self.accountData.rooms objectAtIndex:indexPath.row];
    [devicesViewController setTitle:room.name];
    devicesViewController.room = room;
    //        devicesViewController.devices = room.devices;
    devicesViewController.accountData = self.accountData;
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
        // Delete the row from the data source
        MyERoom *room = [self.accountData.rooms objectAtIndex:indexPath.row];
        if ([room.devices count] == 0) {
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                        contentText:@"您正在删除此房间，确定继续么？"
                                                    leftButtonTitle:@"取消"
                                                   rightButtonTitle:@"确定"];
            [alert show];
            alert.rightBlock = ^() {
                [self deleteRoomFromServerforRowAtIndexPath:indexPath];
            };
        }else{
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                        contentText:@"此房间内已存在相应设备，此时不允许删除该房间"
                                                    leftButtonTitle:nil
                                                   rightButtonTitle:@"知道了"];
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
    _editRoom = self.accountData.rooms[indexPath.row];
    _isAdd = NO;  //表示此时是在编辑房间
    [self doThisToAddOrEditRoom];
//    MyERoomAddOrEditViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"roomAddOrEdit"];
//    MyERoom *room = [self.accountData.rooms objectAtIndex:indexPath.row];
//    [vc setTitle:room.name];
//    vc.room = room;
//    vc.accountData = self.accountData;
//    vc.actionType = 1; // indicate edit new room
//    vc.index = indexPath;
//    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - Navigation methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"RoomToDevices"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        MyEDevicesViewController *devicesViewController = [segue destinationViewController];
        devicesViewController.preivousPanelType = 1;
        
        //        [tabBarController setTitle:@"Dashboard"];
        MyERoom *room = [self.accountData.rooms objectAtIndex:selectedIndexPath.row];
        [devicesViewController setTitle:room.name];
        devicesViewController.room = room;
//        devicesViewController.devices = room.devices;
        devicesViewController.accountData = self.accountData;
    }
//    if ([[segue identifier] isEqualToString:@"RoomToRoomEdit"]) {
//        // @see http://stackoverflow.com/questions/13517414/get-indexpath-for-selected-accessory-button-in-uitableview?answertab=active#tab-top
//        UITableViewCell *cell = (UITableViewCell *)[sender superview];
//        NSInteger index = [self.tableView indexPathForCell:cell].row; // use this one to get the index of the accessory taped
////        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];// we can not use this, because there is no selected row when accessory buttong taped
//        MyERoomAddOrEditViewController *vc = [segue destinationViewController];
//        
//        MyERoom *room = [self.accountData.rooms objectAtIndex:index];
//        [vc setTitle:room.name];
//        vc.room = room;
//        vc.accountData = self.accountData;
//        vc.actionType = 1; // indicate edit new room
//    }
//    if ([[segue identifier] isEqualToString:@"RoomToRoomAdd"]) {
//        MyERoomAddOrEditViewController *vc = [segue destinationViewController];
//        MyERoom *room = [[MyERoom alloc] init];
//        vc.room = room;
//        vc.accountData = self.accountData;
//        vc.actionType = 0; // indicate add new room
//    }
}
#pragma mark - URL Loading System methods
-(void)downloadDeviceAndRoomListFromServer{
    if (self.refreshControl.isRefreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中..."];
    }
    NSString *urlStr= [NSString stringWithFormat:@"%@?gid=%@",URL_FOR_DEVICE_ROOM_LIST,accountData.userId];
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"deviceAndRoomList"  userDataDictionary:nil];
    NSLog(@"deviceAndRoomList is %@",uploader.name);
}

- (void) deleteRoomFromServerforRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    
    MyERoom *room = [self.accountData.rooms objectAtIndex:indexPath.row];

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          indexPath, @"indexPath",
                          nil ];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%ld&name=%@&action=2",URL_FOR_ROOM_ADD_EDIT_SAVE, (long)room.roomId, room.name];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:ROOM_DELETE_UPLOADER_NMAE  userDataDictionary:dict];
    NSLog(@"%@",downloader.name);
}

// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:ROOM_DELETE_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"删除房间失败，请稍后重试！"];
        } else{
            NSIndexPath *indexPath = [dict objectForKey:@"indexPath"];
            [MyEUtil showSuccessOn:self.navigationController.view withMessage:@"删除房间成功！"];
            [self.accountData.rooms removeObjectAtIndex:indexPath.row];
//            [self.rooms removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    if([name isEqualToString:@"deviceAndRoomList"]) {
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
        //        NSLog(@"string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3){
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"获取设备房间列表失败，请稍后重试！"];
        } else{
            MyEAccountData *account = [[MyEAccountData alloc] initWithJSONString:string];
            accountData.devices = account.devices;
            accountData.rooms = account.rooms;
            [self.tableView reloadData];
        }
    }
    if([name isEqualToString:@"edit"]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            if (_isAdd) {
                [MyEUtil showErrorOn:self.navigationController.view withMessage:@"添加房间失败，请修改名称后重试！"];
            } else
                [MyEUtil showErrorOn:self.navigationController.view withMessage:@"修改房间失败，请修改名称后重试！"];
        } else{
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *result_dict = [parser objectWithString:string];
            _editRoom.name = _roomName;
            if (_isAdd) {
                _editRoom.roomId = [[result_dict objectForKey:@"roomId"] integerValue];
                [self.accountData.rooms addObject:_editRoom];
            }
            [self.tableView reloadData];
        }
    }
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
        _roomName = txt.text;
        if (_roomName.length < 2 || _roomName.length > 11) {
            [MyEUtil showMessageOn:nil withMessage:@"房间名称长度不对"];
            [alertView performSelector:@selector(show) withObject:nil afterDelay:1.5];
            return;
        }
        BOOL hasOne = NO;
        for (MyERoom *r in self.accountData.rooms) {
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
            
            NSString *urlStr = [NSString stringWithFormat:@"%@?id=%ld&name=%@&action=%i",URL_FOR_ROOM_ADD_EDIT_SAVE,_isAdd?0:(long)_editRoom.roomId,_roomName, _isAdd?0:1];
            MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"edit"  userDataDictionary:nil];
            NSLog(@"%@",downloader.name);
        }
    }
}
@end
