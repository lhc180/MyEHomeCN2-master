//
//  MyECameraTableViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/27/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraTableViewController.h"
#import "MyECamera.h"
#import "MyECameraViewController.h"
#import "SBJson.h"
#import "MyEEditCameraViewController.h"
#import "MyECameraAddOptionViewController.h"
#import "PPPP_API.h"
#import "PPPPDefine.h"
#import "obj_common.h"
#import "MyAudioSession.h"

@interface MyECameraTableViewController ()
{
    NSCondition* _m_PPPPChannelMgtCondition;
    CPPPPChannelManagement* _m_PPPPChannelMgt;
    BOOL _isDetailView; //用于指定大view视图
    MBProgressHUD *HUD;
    NSIndexPath *_selectedIndex;
    BOOL _jumpToSubControllers;
}
@end

@implementation MyECameraTableViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self getCameraStatus];
    }
    if (IS_IOS6) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if (!_jumpToSubControllers) {  //如果是跳转到子控制器，则只是
        _jumpToSubControllers = NO;
        [self didEnterBackground];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.cameraList = [NSMutableArray array];
    // 这里的代码可以被替换成从服务器获取camera数据的代码.
//    MyECamera *camera = [[MyECamera alloc] init];
//    camera.UID = @"VSTC134699JBVUB";
//    camera.name = @"Camera";
//    camera.username = @"admin";
//    camera.password = @"888888";
//    [self.cameraList addObject:camera];
//    MyECamera *camera1 = [[MyECamera alloc] init];
//    camera1.UID = @"VSTC323869KTUZJ";
//    camera1.name = @"MovingCamera";
//    camera1.username = @"admin";
//    camera1.password = @"888888";
//    [self.cameraList addObject:camera1];
    
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [rc addTarget:self action:@selector(getCameraStatus) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
    
    _m_PPPPChannelMgtCondition = [[NSCondition alloc] init];
    _m_PPPPChannelMgt = new CPPPPChannelManagement();

    dispatch_async(dispatch_get_main_queue(), ^{
        InitAudioSession();
        [self initialize];
    });
    [self downloadCameraListFromServer];

    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(downloadCameraListFromServer)];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCamera:)];
    self.navigationItem.rightBarButtonItems = @[add,refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - data save methods
-(void)_loadData{
    NSMutableArray *array = nil;
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        for (NSDictionary *d in array) {
            [self.cameraList addObject:[[MyECamera alloc] initWithDictionary:d]];
        }
        NSLog(@"%@",array);
    }else
        array = [NSMutableArray array];
}
-(void)_saveData{
    NSMutableArray *array = [NSMutableArray array];
    for (MyECamera *c in self.cameraList) {
        [array addObject:[c JSONDictionary]];
    }
    [array writeToFile:[self dataFilePath] atomically:YES];
}
-(NSString *)dataFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:@"cameras.plist"];
}
#pragma mark - private methods
-(void)endGetCameraStatus{
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
}
-(void)getCameraStatus{
    if (self.refreshControl.isRefreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中..."];
    }
    if (![self.cameraList count]) {
        [self performSelector:@selector(endGetCameraStatus) withObject:nil afterDelay:0.3];
        return;
    }
    _jumpToSubControllers = NO;
    _m_PPPPChannelMgt->pCameraViewController = self;
    [self didEnterBackground];  //这里要将所有的都断开，然后再进行连接
   
    dispatch_async(dispatch_get_main_queue(), ^{
        for (MyECamera *c in _cameraList) {
            [self ConnectCamWithCamera:c];
            _m_PPPPChannelMgt->Snapshot([c.UID UTF8String]);
        }
    });
}
- (void)initialize{
    PPPP_Initialize((char*)[@"EBGBEMBMKGJMGAJPEIGIFKEGHBMCHMJHCKBMBHGFBJNOLCOLCIEBHFOCCHKKJIKPBNMHLHCPPFMFADDFIINOIABFMH" UTF8String]);
    st_PPPP_NetInfo NetInfo;
    PPPP_NetworkDetect(&NetInfo, 0);
}
- (void)ConnectCamWithCamera:(MyECamera *)camera{
    [_m_PPPPChannelMgtCondition lock];
    if (_m_PPPPChannelMgt == NULL) {
        [_m_PPPPChannelMgtCondition unlock];
        return;
    }
    _m_PPPPChannelMgt->Start([camera.UID UTF8String],[camera.username UTF8String],[camera.password UTF8String]);
    [_m_PPPPChannelMgtCondition unlock];
}

#pragma mark - URL method
-(void)downloadCameraListFromServer{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@",GetRequst(URL_FOR_CAMERA_LIST)] postData:nil delegate:self loaderName:@"download" userDataDictionary:nil];
}

#pragma mark - IBAction methods
- (IBAction)addCamera:(UIBarButtonItem *)sender {
    MyECameraAddOptionViewController *vc = [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:@"cameraAdd"];
    vc.cameraList = self.cameraList;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)cameraDetailInfo:(UIBarButtonItem *)sender {
    _isDetailView = !_isDetailView;
    [self.tableView reloadData];
}
- (IBAction)editCamera:(UIButton *)sender {
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    _jumpToSubControllers = YES;
    MyECamera *c = self.cameraList[indexPath.row];
    NSLog(@"%li",(long)indexPath.row);
    MyEEditCameraViewController *viewController = [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:@"edit"];
    viewController.camera = c;
    viewController.m_PPPPChannelMgt = _m_PPPPChannelMgt;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Notification methods
- (void) didEnterBackground{
    [_m_PPPPChannelMgtCondition lock];
    if (_m_PPPPChannelMgt == NULL) {
        [_m_PPPPChannelMgtCondition unlock];
        return;
    }
    _m_PPPPChannelMgt->StopAll();
    [_m_PPPPChannelMgtCondition unlock];
}

- (void) willEnterForeground{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initialize];
        InitAudioSession();
    });
    if (self.cameraList.count) {
        [self getCameraStatus];
    }
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cameraList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    MyECamera *camera = self.cameraList[indexPath.row];
//    NSLog(@"%@",camera);
    if (_isDetailView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cameraDetail" forIndexPath:indexPath];
        UIImageView *image = (UIImageView *)[cell.contentView viewWithTag:100];
        image.image = [UIImage imageWithContentsOfFile:camera.imagePath];
        UILabel *name = (UILabel *)[cell.contentView viewWithTag:101];
        name.text = camera.name;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"cameracell" forIndexPath:indexPath];
        UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:2];
        nameLabel.text = camera.name;
        UIImageView *imgMain = (UIImageView *)[cell.contentView viewWithTag:1];
        imgMain.image = [UIImage imageWithContentsOfFile:camera.imagePath];
        UILabel *lblStatus = (UILabel *)[cell.contentView viewWithTag:3];
        lblStatus.text = camera.status;
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:11];
        UIActivityIndicatorView *act = (UIActivityIndicatorView *)[cell.contentView viewWithTag:100];
        [act startAnimating];
        act.hidden = ![camera.imagePath isEqualToString:@""];
        if (camera.isOnline) {
            imageView.image = [UIImage imageNamed:@"signal4"];
        }else{
            imageView.image = [UIImage imageNamed:@"signal0"];
        }
    }
    return cell;
}
#pragma mark - table view delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyECamera *camera = self.cameraList[indexPath.row];
    if (!camera.isOnline) {
        [MyEUtil showMessageOn:nil withMessage:@"摄像头不在线"];
        return;
    }
    _jumpToSubControllers = YES;
    MyECameraViewController *viewController = [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:@"cameraInfo"];
    viewController.camera = camera;
    viewController.m_PPPPChannelMgt = _m_PPPPChannelMgt;
    viewController.modalPresentationStyle = UIModalPresentationNone;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:viewController animated:YES completion:nil];
//    [self.navigationController pushViewController:viewController animated:YES];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _selectedIndex = indexPath;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除该摄像机么?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 100;
//        alert.rightBlock = ^{
//            _selectedIndex = indexPath;
//            MyECamera *_camera = _cameraList[indexPath.row];
//            [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?id=%li&did=%@&user=%@&pwd=%@&name=%@&action=3",GetRequst(URL_FOR_CAMERA_EDIT),(long)_camera.deviceId,_camera.UID,_camera.username,_camera.password,_camera.name] postData:nil delegate:self loaderName:@"edit" userDataDictionary:nil];
//
////            [self.cameraList removeObjectAtIndex:indexPath.row];
////            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
////            NSLog(@"%@",self.cameraList);
////            [self _saveData];
//        };
        [alert show];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isDetailView) {
        return 186;
    }else
        return 70;
}

#pragma mark - PPPPStatus Delegate methods
- (void) PPPPStatus: (NSString*) strDID statusType:(NSInteger) statusType status:(NSInteger) status{
    NSString* strPPPPStatus;
    BOOL isOnline = NO;
    switch (status) {
        case PPPP_STATUS_UNKNOWN:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusUnknown", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_CONNECTING:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnecting", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_INITIALING:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusInitialing", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_CONNECT_FAILED:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnectFailed", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_DISCONNECT:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusDisconnected", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_INVALID_ID:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusInvalidID", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_ON_LINE:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusOnline", @STR_LOCALIZED_FILE_NAME, nil);
            isOnline = YES;
            break;
        case PPPP_STATUS_DEVICE_NOT_ON_LINE:
            strPPPPStatus = NSLocalizedStringFromTable(@"CameraIsNotOnline", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_CONNECT_TIMEOUT:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnectTimeout", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_INVALID_USER_PWD:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusInvaliduserpwd", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        default:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusUnknown", @STR_LOCALIZED_FILE_NAME, nil);
            break;
    }
    NSLog(@"PPPPStatus  %@",strPPPPStatus);
    for (MyECamera *c in self.cameraList) {
        if ([c.UID isEqualToString:strDID]) {
            c.status = strPPPPStatus;
            c.isOnline = isOnline;
            if (status > 2) {
                c.imagePath = @"noImage";
            }
        }
    }
    if (self.refreshControl.isRefreshing) {
        [self performSelectorOnMainThread:@selector(endGetCameraStatus) withObject:nil waitUntilDone:NO];
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
-(void)SnapshotNotify:(NSString *)strDID data:(char *)data length:(int)length{
    NSLog(@"receive image");
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    for (MyECamera *c in self.cameraList) {
        if ([c.UID isEqualToString:strDID]) {
			NSString *savedImagePath=[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",c.UID]];
			[[NSData dataWithBytes:data length:length] writeToFile:savedImagePath atomically:YES];
            c.imagePath = savedImagePath;
        }
    }
    if (self.refreshControl.isRefreshing) {
        [self performSelectorOnMainThread:@selector(endGetCameraStatus) withObject:nil waitUntilDone:NO];
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"reveive string is %@",string);
    if ([name isEqualToString:@"download"]) {
        NSInteger i = [MyEUtil getResultFromAjaxString:string];
        if (i==1) {
            NSDictionary *dic = [string JSONValue];
            [_cameraList removeAllObjects];
            for (NSDictionary *d in dic[@"cameraList"]) {
                [_cameraList addObject:[[MyECamera alloc] initWithDictionary:d]];
            }
            if (_cameraList.count) {
                [self getCameraStatus];
            }
        }else if (i == -3){
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }else if (i == 0){
            [MyEUtil showMessageOn:nil withMessage:@"传入数据有问题"];
        }else
            [MyEUtil showMessageOn:nil withMessage:@"接收数据失败"];
    }
    if ([name isEqualToString:@"edit"]) {
        NSInteger i = [MyEUtil getResultFromAjaxString:string];
        if (i==1) {
            [_cameraList removeObjectAtIndex:_selectedIndex.row];
            [self.tableView deleteRowsAtIndexPaths:@[_selectedIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else if (i == -3){
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }else if (i == 0){
            [MyEUtil showMessageOn:nil withMessage:@"传入数据有问题"];
        }else
            [MyEUtil showMessageOn:nil withMessage:@"接收数据失败"];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [MyEUtil showErrorOn:nil withMessage:@"与服务器连接超时"];
}

#pragma mark - UIAlertView delegate 
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        MyECamera *_camera = _cameraList[_selectedIndex.row];
        [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?id=%li&did=%@&user=%@&pwd=%@&name=%@&action=3",GetRequst(URL_FOR_CAMERA_EDIT),(long)_camera.deviceId,_camera.UID,_camera.username,_camera.password,_camera.name] postData:nil delegate:self loaderName:@"edit" userDataDictionary:nil];
    }
}
@end
