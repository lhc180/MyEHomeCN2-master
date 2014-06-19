//
//  MyEDevicesViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/4/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEDevicesViewController.h"
#import "MyEAcManualControlViewController.h"
#import "MyEAcEnergySavingViewController.h"
#import "MyEAcTempMonitorViewController.h"
#import "MyEDeviceAddOrEditViewController.h"
#import "MyEAutoControlViewController.h"
#import "MyEIrControlPageViewController.h"
#import "MyESocketManualControlViewController.h"
#import "MyESocketTimedControlViewController.h"
#import "MyESocketEditViewController.h"
#import "MyESocketElecViewController.h"
#import "MyECameraTableViewController.h"
#import "MyESettingsViewController.h"

#define DEVICE_ADD_EDIT_UPLOADER_NMAE @"DeviceAddEditUploader"
#define SOCKET_SWITCH_CONTROL_UPLOADER_NMAE @"SocketSwitchChangeUploader"
#define DEVICE_HOME_LIST_DOWNLOAD_NAME @"deviceAndRoomListDownloader"
@interface MyEDevicesViewController ()

@end

@implementation MyEDevicesViewController
@synthesize accountData, preivousPanelType = _preivousPanelType, devices = _devices,jumpFromMediator,deviceAddBtn,needRefresh;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _preivousPanelType = 0;
    }
    return self;
}
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    if (self.preivousPanelType == 0) {
        longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesturepress:)];
        longGesture.minimumPressDuration = 0.7;
        [self.tableView addGestureRecognizer:longGesture];
    }
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [rc addTarget:self
           action:@selector(downloadDeviceAndRoomListFromServer)
 forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
    if (jumpFromMediator == 1) {
        jumpFromMediator = 0;
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                    contentText:@"检测到您未连接智控星，此时所有设备都将不可操作，请连接智控星后重试；如果已连接，请给智控星断电后重试！"
                                                leftButtonTitle:nil
                                               rightButtonTitle:@"知道了"];
        [alert show];
    }else if (!accountData.mId ||[accountData.mId isEqualToString:@""]) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                    contentText:@"检测到未绑定网关，此时设备都将不可操作，请绑定网关后重试"
                                                leftButtonTitle:nil
                                               rightButtonTitle:@"知道了"];
        [alert show];
    }else if(!accountData.mStatus || accountData.mStatus == 0){
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                    contentText:@"检测到网关离线，请连接网关后重试"
                                                leftButtonTitle:nil
                                               rightButtonTitle:@"知道了"];
        [alert show];
    }else{
        if ([accountData.terminals count] == 0) {
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                        contentText:@"检测到未连接智控星,请连接智控星后重试！"
                                                    leftButtonTitle:nil
                                                   rightButtonTitle:@"知道了"];
            [alert show];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    //之前的主数据刷新陷入了一个误区，从正常角度讲应该是谁污染谁治理，谁需要最新数据就应该是谁负责刷新。之前的想法是在别的地方下载并更新数据，然后再把数据传递给VC。现在是谁需要下载谁就自己下载，我只负责给一个特征值就可以了
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self downloadDeviceAndRoomListFromServer];
        //如果开始下载的话那么下面的所有都不必继续运行了，从而加快运行速度
        return;
    }
    //此处特别注意，数据更新要放在viewWillAppear里面
    self.devices = [NSMutableArray array];
    if(self.preivousPanelType == 1){
        NSMutableArray *array = [NSMutableArray array];
        for (int i=0; i<[self.room.devices count]; i++) {
            NSInteger deviceId = [self.room.devices[i] intValue];
            for (int j=0; j<[self.accountData.devices count]; j++) {
                MyEDevice *device = self.accountData.devices[j];
                if (deviceId == device.deviceId) {
                    [array addObject:self.accountData.devices[j]];
                }
            }
        }
        self.devices = array;
    }else{
        self.devices = self.accountData.devices;
    }
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
- (void)longGesturepress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.tableView.editing) {
            return;
        }
        [self.tableView setEditing:!self.tableView.editing animated:YES];
        tapOnTableView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTableView:)];
        tapOnTableView.numberOfTapsRequired = 1;
        [self.tableView addGestureRecognizer:tapOnTableView];
    }
}
// 对于双击和单击事件，不需要对状态进行判断，主要是他这个状态维持的时间很短
-(void)tapOnTableView:(UITapGestureRecognizer *)sender{
    if (!self.tableView.editing) {
        return;
    }
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    [self.tableView removeGestureRecognizer:tapOnTableView];
    [self reorderDeviceToServer];
}
-(void)doThisWhenNeedAlert{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                contentText:@"您没有连接智控星,此时不能够添加或者编辑红外设备"
                                            leftButtonTitle:nil
                                           rightButtonTitle:@"知道了"];
    [alert show];
}
-(void)setPowerOnOrOffLabelWithIndexPath:(NSIndexPath *)index AndDevice:(MyEDevice *)dv{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
    UILabel *onLabel = (UILabel *)[cell.contentView viewWithTag:200];
    UILabel *offLabel = (UILabel *)[cell.contentView viewWithTag:201];
    if(dv.status.powerSwitch == 0){  //关
        onLabel.hidden = YES;
        offLabel.hidden = NO;
    }else{   //开
        onLabel.hidden = NO;
        offLabel.hidden = YES;
    }
}
-(void)doThisWhenNeedChangeBtnImage:(MyEDevice *)device andBtn:(UIButton *)deviceBtn{
    NSString *str = nil;
    switch (device.type) {   //这个方法还可以写的简单些，
        case 1:
            str = @"ac";
            break;
        case 2:
            str = @"tv";
            break;
        case 3:
            str = @"curtain";
            break;
        case 4:
            str = @"audio";
            break;
        case 5:
            str = @"other";
            break;
        case 6:
            str = @"socket";
            break;
        default:
            str = @"switch";
            break;
    }
    if (device.type == 7) {
        if ([device.status.switchStatus integerValue] == 0) {
            [deviceBtn setImage:[UIImage imageNamed:@"switch-off"] forState:UIControlStateNormal];
        }else{
            [deviceBtn setImage:[UIImage imageNamed:@"switch-on"] forState:UIControlStateNormal];
        }
        return;
    }
    if (device.status.powerSwitch == 0) {
        [deviceBtn setImage:[UIImage imageNamed:[str stringByAppendingString:@"-off"]] forState:UIControlStateNormal];
    }else
        [deviceBtn setImage:[UIImage imageNamed:[str stringByAppendingString:@"-on"]] forState:UIControlStateNormal];
    
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.devices count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    static NSString *CellIdentifier = @"deviceCell";
    UITableViewCell *cell;
    MyEDevice *device = self.devices[indexPath.row];
    NSString *roomName = nil;
    for (int i=0; i<[accountData.rooms count]; i++) {
        MyERoom *room = accountData.rooms[i];
        if (device.roomId == room.roomId) {
            roomName = room.name;
        }
    }
    if (device.type == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ac" forIndexPath:indexPath];
        UILabel *tempLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UILabel *humidityLabel = (UILabel *)[cell.contentView viewWithTag:101];
        tempLabel.text = [NSString stringWithFormat:@"温度:%li℃",(long)device.status.temperature];
        humidityLabel.text = [NSString stringWithFormat:@"湿度:%li%%",(long)device.status.humidity];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"others" forIndexPath:indexPath];
    }
    UIButton *deviceBtn = (UIButton *)[cell.contentView viewWithTag:1];
    UILabel *deviceNameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *roomLabel = (UILabel *)[cell.contentView viewWithTag:3];
    UIImageView *signalImage = (UIImageView *)[cell.contentView viewWithTag:11];
    UIActivityIndicatorView *act = (UIActivityIndicatorView *)[cell.contentView viewWithTag:202];
    if (!act.hidden) {
        act.hidden = YES;
    }
    if (deviceBtn.hidden) {
        deviceBtn.hidden = NO;
    }
    [self doThisWhenNeedChangeBtnImage:device andBtn:deviceBtn];
    
    NSString *imageFilename;
    if (device.isOrphan) {
        imageFilename= @"noconnection";
    } else
        imageFilename= [NSString stringWithFormat:@"signal%ld", (long)device.status.connection];
    
    [signalImage setImage:[UIImage imageNamed:imageFilename]];
    
    deviceNameLabel.text = device.name;
    roomLabel.text = roomName;
    return cell;
}

#pragma mark - tableView delegate methods
//这个方法已经被废弃了，不再使用了
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        deleteDeviceIndex = indexPath;
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                    contentText:@"此操作将清空该设备的所有数据，您确定继续么？"
                                                leftButtonTitle:@"取消"
                                               rightButtonTitle:@"确定"];
        [alert show];
        alert.rightBlock = ^{
            [self deleteDeviceFromServerforRowAtIndexPath:indexPath];
        };
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyEDevice *device = [self.devices objectAtIndex:indexPath.row];
    
    if([device isOrphan]){
        [MyEUtil showMessageOn:self.view withMessage:@"该设备没有绑定到智控星"];
        return;
    }
    if(![device isConnected]){
        [MyEUtil showMessageOn:self.view withMessage:@"该设备没有连接, 请检查"];
        return;
    }
    
    if(device.type == 1 ){
        if(![device isInitialized]){
            self.device = device;
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                        contentText:@"检测到空调未初始化，需要下载指令库，现在需要下载么？"
                                                    leftButtonTitle:@"取消"
                                                   rightButtonTitle:@"确定"];
            [alert show];
            alert.rightBlock = ^() {
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"AcInstruction" bundle:nil];
                MyEInstructionManageViewController *vc = [story instantiateViewControllerWithIdentifier:@"instructionVC"];
                vc.accountData = self.accountData;
                vc.device = self.device;
                [self.navigationController pushViewController:vc animated:YES];
            };
            return;
        }
    }
    
    if (device.type == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AcDevice" bundle:nil];
        UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"AcTabBarVC"];
        //        if (!IS_IOS6) {
        //            tabBarController.edgesForExtendedLayout = UIRectEdgeNone;
        //        }
        
        UINavigationController *nav0 = [tabBarController childViewControllers][0];
        UINavigationController *nav1 = [tabBarController childViewControllers][1];
        UINavigationController *nav2 = [tabBarController childViewControllers][2];
        UINavigationController *nav3 = [tabBarController childViewControllers][3];
        //判断是否开启了温度监控功能，从而限制这两个tabbarItem的点击    上次这个接口是怎么修改的
        if (device.status.tempMornitorEnabled == 1) {
            nav1.tabBarItem.enabled = NO;
            nav2.tabBarItem.enabled = NO;
        }else{
            nav1.tabBarItem.enabled = YES;
            nav2.tabBarItem.enabled = YES;
        }
        //当为自学习空调时，节能控制不能使用
        if (!device.isSystemDefined) {
            nav2.tabBarItem.enabled = NO;
        }
        MyEAcManualControlViewController *acManualControlViewController = [[nav0 childViewControllers] objectAtIndex:0];
        MyEAutoControlViewController *acAutoControlViewController = [[nav1 childViewControllers] objectAtIndex:0];
        MyEAcEnergySavingViewController *acComfortViewController = [[nav2 childViewControllers] objectAtIndex:0];
        MyEAcTempMonitorViewController *tempVC = [[nav3 childViewControllers] objectAtIndex:0];
        
        tabBarController.hidesBottomBarWhenPushed = YES; // 隐藏 hide  bottom tabbar
        acManualControlViewController.device = device;
        acManualControlViewController.accountData = self.accountData;
        
        acAutoControlViewController.device = device;
        acAutoControlViewController.accountData = self.accountData;
        
        acComfortViewController.device = device;
        acComfortViewController.accountData = self.accountData;
        
        tempVC.device = device;
        tempVC.accountData = self.accountData;
        
        [self presentViewController:tabBarController animated:YES completion:nil];
    }
    if(device.type == 2 || device.type == 4){// TV或者AUDIO
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IrDevice" bundle:nil];
        MyEIrControlPageViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"irControlPage"];
        viewController.hidesBottomBarWhenPushed = YES; // 隐藏 hide  bottom tabbar
        viewController.device = device;
        viewController.accountData = self.accountData;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    if(device.type == 5 ||device.type == 3){//Other
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IrDevice" bundle:nil];
        MyEIrUserKeyViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"IrUserKeyVC"];
        
        viewController.hidesBottomBarWhenPushed = YES; // 隐藏 hide  bottom tabbar
        viewController.device = device;
        viewController.accountData = self.accountData;
        viewController.needDownloadKeyset = YES;
        if (device.type == 3) {
            viewController.title = @"窗帘控制";
        }else
            viewController.title = @"其他设备";
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    if(device.type == 6){//Socket
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Socket" bundle:nil];
        UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"SocketTabBarVC"];
        
        UINavigationController *nav0 = [tabBarController childViewControllers][0];
        UINavigationController *nav1 = [tabBarController childViewControllers][1];
        UINavigationController *nav2 = [tabBarController childViewControllers][2];
        UINavigationController *nav3 = [tabBarController childViewControllers][3];
        MyESocketManualControlViewController *socketManualControlViewController = [[nav0 childViewControllers] objectAtIndex:0];
        MyESocketTimedControlViewController *socketTimedControlViewController = [[nav1 childViewControllers] objectAtIndex:0];
        MyEAutoControlViewController *socketAutoControlViewController = [[nav2 childViewControllers] objectAtIndex:0];
        MyESocketElecViewController *vc = nav3.childViewControllers[0];
        tabBarController.hidesBottomBarWhenPushed = YES; // 隐藏 hide  bottom tabbar
        socketManualControlViewController.device = device;
        socketManualControlViewController.accountData = self.accountData;
        
        
        socketTimedControlViewController.device = device;
        socketTimedControlViewController.accountData = self.accountData;
        
        socketAutoControlViewController.device = device;
        socketAutoControlViewController.accountData = self.accountData;
        
        vc.device = device;
        
        [self presentViewController:tabBarController animated:YES completion:nil];
    }
    if (device.type == 7) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Switch" bundle:nil];
        UITabBarController *tab = [story instantiateInitialViewController];
        
        UINavigationController *nav1 = [tab childViewControllers][0];
        UINavigationController *nav2 = [tab childViewControllers][1];
        UINavigationController *nav3 = [tab childViewControllers][2];
        MyESwitchAutoViewController *vc1 = nav1.childViewControllers[0];
        vc1.device = device;
        
        MyESwitchAutoViewController *vc2 = nav2.childViewControllers[0];
        vc2.device = device;
        
        MyESwitchElecInfoViewController *vc3 = nav3.childViewControllers[0];
        vc3.device = device;
        
        [self presentViewController:tab animated:YES completion:nil];
    }
}
// Tap on row accessory
- (void) tableView: (UITableView *) tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath
{
    MyEDevice *device = [self.devices objectAtIndex:indexPath.row];
    if(device.type !=6 ){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IrDevice" bundle:nil];
        MyEDeviceAddOrEditViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AddOrEDitIrDeviceVC"];
        viewController.device = device;
        viewController.room = self.room;
        viewController.accountData = self.accountData;
        viewController.preivousPanelType = self.preivousPanelType;
        viewController.actionType = 1;
        viewController.hidesBottomBarWhenPushed = YES; // 隐藏 hide  bottom tabbar
        [self.navigationController pushViewController:viewController animated:YES];
    } else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Socket" bundle:nil];
        MyESocketEditViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"EditSocketVC"];
        
        viewController.device = device;
        viewController.accountData = self.accountData;
        viewController.preivousPanelType = self.preivousPanelType;
        viewController.hidesBottomBarWhenPushed = YES; // 隐藏 hide  bottom tabbar
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < [self.devices count]) {
        MyEDevice *device = self.devices[indexPath.row];
        if (device.type == 1 && [device.brand isEqualToString:@""]) {
            cell.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        }else
            cell.backgroundColor = [UIColor whiteColor];
    }
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    MyEDevice *device = self.devices[fromIndexPath.row];
    [self.devices removeObject:device];
    [self.devices insertObject:device atIndex:toIndexPath.row];
}
#pragma mark - Navigation methods
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"DevicesToDeviceAC"] ||
       [identifier isEqualToString:@"DevicesToDeviceTV"] ||
       [identifier isEqualToString:@"DevicesToDeviceAudio"] ||
       [identifier isEqualToString:@"DevicesToDeviceCurtain"] ||
       [identifier isEqualToString:@"DevicesToDeivceOther"] ||
       [identifier isEqualToString:@"DevicesToDeviceSocket"])
    {
        NSInteger index = [self.tableView indexPathForCell:sender].row; // use this one to get the index of the accessory taped
        MyEDevice *device = [self.accountData.devices objectAtIndex:index];
        if (device.isOrphan){
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"此设备是孤儿设备，请指定智控星"];
            return NO;
        }
        if (!device.isConnected){
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"此设备没有连接，请检查"];
            return NO;
        }
    }
    return YES;
}
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"DevicesToDeviceAC"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        UITabBarController *tabBarController= [segue destinationViewController];
        
        MyEAcManualControlViewController *acManualControlViewController = [[tabBarController childViewControllers] objectAtIndex:0];
        MyEAutoControlViewController *acAutoControlViewController = [[tabBarController childViewControllers] objectAtIndex:1];
        
        tabBarController.hidesBottomBarWhenPushed = YES; // 隐藏 hide  bottom tabbar
        MyEDevice *device = [self.accountData.devices objectAtIndex:selectedIndexPath.row];
        acManualControlViewController.device = device;
        acManualControlViewController.accountData = self.accountData;
        
        acAutoControlViewController.device = device;
        acAutoControlViewController.accountData = self.accountData;
        
    }
}
#pragma mark - IBAction methods
- (IBAction)addDeviceAction:(id)sender {
    //如果terminal数组为零，此时不能添加
    NSMutableArray *array = [NSMutableArray array];
    for (MyETerminal *t in self.accountData.terminals) {
        if ([[t.tId substringToIndex:2] isEqualToString:@"01"]) {
            [array addObject:t];
        }
    }
    if ([array count] == 0) {
        [self doThisWhenNeedAlert];
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IrDevice" bundle:nil];
    MyEDeviceAddOrEditViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AddOrEDitIrDeviceVC"];
    MyEDevice *device = [[MyEDevice alloc] init];
    viewController.hidesBottomBarWhenPushed = YES; // 隐藏 hide  bottom tabbar
    viewController.device = device;
    viewController.room = _room;
    viewController.accountData = self.accountData;
    
    viewController.preivousPanelType = self.preivousPanelType;
    viewController.actionType = 0;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)editDevice:(UIButton *)sender forEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:sender] anyObject];
    CGPoint location = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    MyEDevice *device = [self.devices objectAtIndex:indexPath.row];
    if (device.type != 7 && device.type != 6) {
        NSMutableArray *array = [NSMutableArray array];
        for (MyETerminal *t in self.accountData.terminals) {
            if ([[t.tId substringToIndex:2] isEqualToString:@"01"]) {
                [array addObject:t];
            }
        }
        if ([array count] == 0) {
            [self doThisWhenNeedAlert];
            return;
        }
    }
    if (device.type == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IrDevice" bundle:nil];
        MyEDeviceAddOrEditViewController *vc = (MyEDeviceAddOrEditViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ACAddOrEDitIrDeviceVC"];
        vc.device = device;
        vc.room = self.room;
        vc.accountData = self.accountData;
        vc.preivousPanelType = self.preivousPanelType;
        vc.actionType = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(device.type == 6){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Socket" bundle:nil];
        MyESocketEditViewController *viewController = (MyESocketEditViewController *)[storyboard instantiateViewControllerWithIdentifier:@"EditSocketVC"];
        viewController.device = device;
        viewController.accountData = self.accountData;
        viewController.preivousPanelType = self.preivousPanelType;
        viewController.hidesBottomBarWhenPushed = YES; // 隐藏 hide  bottom tabbar
        [self.navigationController pushViewController:viewController animated:YES];
    }else if (device.type == 7){
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Switch" bundle:nil];
        MyESwitchEditViewController *vc = [story instantiateViewControllerWithIdentifier:@"switchEdit"];
        vc.accountData = self.accountData;
        vc.device = device;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IrDevice" bundle:nil];
        MyEDeviceAddOrEditViewController *viewController = (MyEDeviceAddOrEditViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AddOrEDitIrDeviceVC"];
        viewController.device = device;
        viewController.room = self.room;
        viewController.accountData = self.accountData;
        viewController.preivousPanelType = self.preivousPanelType;
        viewController.actionType = 1;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
- (IBAction)powerOffOrOn:(UIButton *)sender forEvent:(UIEvent *)event {
    //至此，一共有两种方法获取点击的cell所在的行，一个是下面注释掉的这两行，另外一个就是现在使用的这一行
    //    UITouch *touch = [[event touchesForView:sender] anyObject];
    //    CGPoint location = [touch locationInView:self.tableView];
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    MyEDevice *device = self.devices[indexPath.row];
    if (device.type == 3 || device.type == 5) {
        return;
    }
    
    if([device isOrphan]){
        [MyEUtil showMessageOn:self.view withMessage:@"设备没有绑定智控星,无法进行操作"];
        return;
    }
    if(![device isConnected]){
        [MyEUtil showMessageOn:self.view withMessage:@"智控星没有信号, 无法进行控制"];
        return;
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *act = (UIActivityIndicatorView *)[cell.contentView viewWithTag:202];
    act.hidden = NO;
    [act startAnimating];
    sender.hidden = YES;
    _selectIndexPath = indexPath;
    
    if (device.type == 7) {
        NSString *url = [NSString stringWithFormat:@"%@?id=%li&switchStatus=%i&action=1",URL_FOR_SWITCH_CONTROL,(long)device.deviceId,[device.status.switchStatus integerValue]==0?1:0];  //数组中只要有1路是开的，那么就发送关闭的消息
        NSLog(@"control switch string is  %@",url);
        MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:@"switchControl" userDataDictionary:nil];
        NSLog(@"switch control is %@",loader.name);
        return;  //这里要return，否则有问题
    }
    NSDictionary *dic = @{@"index": indexPath}; //放在此处是为了使程序运行更为快捷
    if (device.type != 6) {
        [self controlDeviceToPowerOnOrOff:device withDictionary:dic];
    }else{
        if(device.status.connection >0){ //这个判断很好，因为如果设备没有连接，那么此时控制设备是多余的
            NSString *urlStr = [NSString stringWithFormat:
                                @"%@?gid=%@&id=%ld&powerSwitch=%d",
                                URL_FOR_SOCKET_SWITCH_CONTROL,
                                self.accountData.userId,
                                (long)device.deviceId,
                                1-device.status.powerSwitch];
            NSLog(@"urlStr = %@", urlStr);
            
            MyEDataLoader *uploader =[[MyEDataLoader alloc]
                                      initLoadingWithURLString:urlStr
                                      postData:nil
                                      delegate:self
                                      loaderName:SOCKET_SWITCH_CONTROL_UPLOADER_NMAE
                                      userDataDictionary:dic];
            NSLog(@"uploader.name = %@", uploader.name);
        }
    }
}
- (IBAction)switchSocketAction:(id)sender forEvent:(UIEvent *)event {
    UIView *button = (UIView *)sender;
    UITouch *touch = [[event touchesForView:button] anyObject];
    CGPoint location = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    MyEDevice *device = self.devices[indexPath.row];
    if(device.status.connection >0){
        if(HUD == nil) {
            HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            HUD.delegate = self;
        } else
            [HUD show:YES];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              indexPath, @"indexPath",
                              nil ];
        
        NSString *urlStr = [NSString stringWithFormat:
                            @"%@?gid=%@&id=%ld&powerSwitch=%d",
                            URL_FOR_SOCKET_SWITCH_CONTROL,
                            self.accountData.userId,
                            (long)device.deviceId,
                            1-device.status.powerSwitch];
        NSLog(@"urlStr = %@", urlStr);
        
        MyEDataLoader *uploader =[[MyEDataLoader alloc]
                                  initLoadingWithURLString:urlStr
                                  postData:nil
                                  delegate:self
                                  loaderName:SOCKET_SWITCH_CONTROL_UPLOADER_NMAE
                                  userDataDictionary:dict];
        NSLog(@"uploader.name = %@", uploader.name);
    }
}

#pragma mark -
#pragma mark URL Loading System methods
-(void)reorderDeviceToServer{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i<[self.devices count]; i++) {
        MyEDevice *device = self.devices[i];
        NSDictionary *dic = @{
                              @"deviceId": [NSNumber numberWithInteger:device.deviceId],
                              @"sortId":[NSNumber numberWithInt:i+1]};
        [array addObject:dic];
    }
    NSDictionary *dic = @{@"deviceListSort": array};
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *str = [writer stringWithObject:dic];
    NSLog(@"%@",str);
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&data=%@",URL_FOR_DEVICE_REORDER_DEVICE, self.accountData.userId,str];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"reorderDevice"  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
-(void)controlDeviceToPowerOnOrOff:(MyEDevice *)device withDictionary:(NSDictionary *)dic{
    NSIndexPath *index = dic[@"index"];
    NSLog(@"send index is  %li",(long)index.row);
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&switch_=%i&deviceId=%li",URL_FOR_DEVICE_CONTROL_BY_CLICK_BUTTON, self.accountData.userId, 1-device.status.powerSwitch,(long)device.deviceId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"powerOnOrOff"  userDataDictionary:dic];
    NSLog(@"%@",downloader.name);
}
-(void)downloadDeviceAndRoomListFromServer{
    if (self.refreshControl.isRefreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中..."];
    }
    UINavigationController *nav = self.tabBarController.childViewControllers[4];
    MyESettingsViewController *vc = nav.childViewControllers[0];
    vc.isFresh = YES;
    
    NSString *urlStr= [NSString stringWithFormat:@"%@?gid=%@&ver=2",URL_FOR_DEVICE_ROOM_LIST,accountData.userId];
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:DEVICE_HOME_LIST_DOWNLOAD_NAME  userDataDictionary:nil];
    NSLog(@"deviceAndRoomList is %@",uploader.name);
}

- (void) deleteDeviceFromServerforRowAtIndexPath:(NSIndexPath *)indexPath{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    MyEDevice *device = [self.devices objectAtIndex:indexPath.row];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          indexPath, @"indexPath",
                          nil ];
    NSString *urlStr;
    MyEDataLoader *uploader;
    switch (device.type){
        case 1: // AC
            urlStr= [NSString stringWithFormat:@"%@?id=%ld&name=%@&tId=%@&roomId=%ld&action=2",URL_FOR_AC_ADD_EDIT_SAVE, (long)device.deviceId, device.name, device.tId, (long)device.roomId];
            uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:DEVICE_ADD_EDIT_UPLOADER_NMAE  userDataDictionary:dict];
            break;
        case 6: // Socket
            urlStr= [NSString stringWithFormat:@"%@?id=%ld&name=%@&tId=%@&roomId=%ld&maxElectricCurrent=%ld&action=2",URL_FOR_DEVICE_SOCKET_ADD_EDIT_SAVE, (long)device.deviceId, device.name, device.tId, (long)device.roomId, (long)device.status.maxElectricCurrent];
            uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:DEVICE_ADD_EDIT_UPLOADER_NMAE  userDataDictionary:dict];
            break;
        default:// other IR device
            urlStr= [NSString stringWithFormat:@"%@?id=%ld&name=%@&tId=%@&roomId=%ld&type=%ld&action=2",URL_FOR_DEVICE_IR_ADD_EDIT_SAVE, (long)device.deviceId, device.name, device.tId, (long)device.roomId,(long)device.type];
            uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:DEVICE_ADD_EDIT_UPLOADER_NMAE  userDataDictionary:dict];
            break;
    }
    NSLog(@"%@",uploader.name);
}

#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if ([name isEqualToString:@"reorderDevice"]) {
        NSLog(@"reorderDevice string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }else if ([MyEUtil getResultFromAjaxString:string] != 1){
            [MyEUtil showMessageOn:nil withMessage:@"上传数据时发生错误"];
        }else{
            [MyEUtil showMessageOn:nil withMessage:@"设备排序成功"];
        }
    }
    if ([name isEqualToString:@"powerOnOrOff"]) {
        NSLog(@"powerOnOrOff string is %@",string);
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)[cell.contentView viewWithTag:1];
        UIActivityIndicatorView *act = (UIActivityIndicatorView *)[cell.contentView viewWithTag:202];
        act.hidden = YES;
        [act stopAnimating];
        btn.hidden = NO;
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }else if([MyEUtil getResultFromAjaxString:string] == -2){
            [MyEUtil showMessageOn:nil withMessage:@"指令未学习"];
        }else if([MyEUtil getResultFromAjaxString:string] == -1){
            [MyEUtil showMessageOn:nil withMessage:@"指令发送失败"];
        }else{
            //            UILabel *onLabel = (UILabel *)[cell.contentView viewWithTag:200];
            //            UILabel *offLabel = (UILabel *)[cell.contentView viewWithTag:201];
            MyEDevice *device = self.devices[_selectIndexPath.row];
            device.status.powerSwitch = 1 - device.status.powerSwitch;
            [MyEUtil showSuccessOn:self.view withMessage:[NSString stringWithFormat:device.status.powerSwitch==1?@"设备已打开":@"设备已关闭"]];
            [self doThisWhenNeedChangeBtnImage:device andBtn:btn];
            [self.tableView reloadData];
        }
    }
    if([name isEqualToString:DEVICE_ADD_EDIT_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -3){
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"删除设备失败，请稍后重试！"];
        } else{
            NSIndexPath *indexPath = [dict objectForKey:@"indexPath"];
            [MyEUtil showSuccessOn:self.navigationController.view withMessage:@"删除设备成功！"];
            [self.devices removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    if([name isEqualToString:DEVICE_HOME_LIST_DOWNLOAD_NAME]) {
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
        NSLog(@"string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3){
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"获取设备房间列表失败，请稍后重试！"];
        } else{
            MyEAccountData *account = [[MyEAccountData alloc] initWithJSONString:string];
            accountData.devices = account.devices;
            accountData.rooms = account.rooms;
            accountData.deviceTypes = account.deviceTypes;
            //这里要同步场景中的数据,否则不会主动更新的
            UINavigationController *nav = [self.tabBarController childViewControllers][2];
            MyEScenesViewController *vc = [nav childViewControllers][0];
            vc.accountData.devices = account.devices;
            vc.accountData.rooms = account.rooms;
            vc.accountData.deviceTypes = account.deviceTypes;
            
            if (_preivousPanelType == 0) { //直接进入device界面
                self.devices = accountData.devices;
            }else{  //从房间列表进入devices界面
                NSMutableArray *array = [NSMutableArray array];
                for (int j=0; j<[self.accountData.devices count]; j++) {
                    MyEDevice *device = self.accountData.devices[j];
                    if (self.room.roomId == device.roomId) {
                        [array addObject:self.accountData.devices[j]];
                    }
                }
                self.devices = array;
            }
            [self.tableView reloadData];
        }
    }
    if([name isEqualToString:SOCKET_SWITCH_CONTROL_UPLOADER_NMAE]) {
        NSLog(@"socket control string is %@",string);
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)[cell.contentView viewWithTag:1];
        UIActivityIndicatorView *act = (UIActivityIndicatorView *)[cell.contentView viewWithTag:202];
        act.hidden = YES;
        btn.hidden = NO;
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            //            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"用户会话超时，需要重新登录！"];
        } else if ([MyEUtil getResultFromAjaxString:string] == 1) {
            MyEDevice *device = self.devices[_selectIndexPath.row];
            
            device.status.powerSwitch = 1 - device.status.powerSwitch;
            
            [MyEUtil showSuccessOn:self.view withMessage:[NSString stringWithFormat:device.status.powerSwitch==1?@"插座已经打开":@"插座已经关闭"]];
            [self doThisWhenNeedChangeBtnImage:device andBtn:btn];
        }else{
            [MyEUtil showErrorOn:self.view withMessage:[NSString stringWithFormat:@"插座控制失败"]];
        }
    }
    if ([name isEqualToString:@"switchControl"]) {
        NSLog(@"switch Control is %@",string);
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)[cell.contentView viewWithTag:1];
        UIActivityIndicatorView *act = (UIActivityIndicatorView *)[cell.contentView viewWithTag:202];
        act.hidden = YES;
        btn.hidden = NO;
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] == 1) {
            MyEDevice *device = self.devices[_selectIndexPath.row];
            NSMutableString *string = [NSMutableString stringWithString:device.status.switchStatus];
            if ([device.status.switchStatus integerValue] == 0) {
                for (int i = 0; i < [device.status.switchStatus length]; i++) {
                    [string replaceCharactersInRange:NSMakeRange(i, 1) withString:@"1"];
                }
            }else{
                for (int i = 0; i < [device.status.switchStatus length]; i++) {
                    [string replaceCharactersInRange:NSMakeRange(i, 1) withString:@"0"];
                }
            }
            device.status.switchStatus = string;
            [MyEUtil showSuccessOn:self.view withMessage:[NSString stringWithFormat:[device.status.switchStatus integerValue] ==0?@"开关已经关闭":@"开关已经打开"]];
            [self doThisWhenNeedChangeBtnImage:device andBtn:btn];
        }else{
            [MyEUtil showErrorOn:self.view withMessage:[NSString stringWithFormat:@"开关控制失败"]];
        }
        
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:DEVICE_ADD_EDIT_UPLOADER_NMAE])
        msg = @"删除设备通信错误，请稍后重试.";
    else if ([name isEqualToString:DEVICE_HOME_LIST_DOWNLOAD_NAME])
        msg = @"获取房间和设备列表通信错误，请稍后重试.";
    else if ([name isEqualToString:SOCKET_SWITCH_CONTROL_UPLOADER_NMAE]){
        msg = @"插座开关变化通信错误，请稍后重试.";
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)[cell.contentView viewWithTag:1];
        UIActivityIndicatorView *act = (UIActivityIndicatorView *)[cell.contentView viewWithTag:202];
        act.hidden = YES;
        [act stopAnimating];
        btn.hidden = NO;
    }else{
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)[cell.contentView viewWithTag:1];
        UIActivityIndicatorView *act = (UIActivityIndicatorView *)[cell.contentView viewWithTag:202];
        act.hidden = YES;
        [act stopAnimating];
        btn.hidden = NO;
        msg = @"通信错误，请稍后重试.";
    }
    [MyEUtil showErrorOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}
#pragma mark - alertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 101 && buttonIndex == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IrDevice" bundle:nil];
        MyEDeviceAddOrEditViewController *vc = (MyEDeviceAddOrEditViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ACAddOrEDitIrDeviceVC"];
        vc.device = self.device;
        vc.room = self.room;
        vc.accountData = self.accountData;
        vc.preivousPanelType = self.preivousPanelType;
        vc.actionType = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
