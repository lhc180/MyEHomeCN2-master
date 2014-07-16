//
//  MyECameraWIFISetViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-6-30.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraWIFISetViewController.h"

@interface MyECameraWIFISetViewController (){
    NSMutableArray *_data;
    NSString *_wifiName;
}

@end

@implementation MyECameraWIFISetViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self refreshData];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@",_camera);
    _data = [NSMutableArray array];
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [rc addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
    [self refreshData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - private methods
-(void)refreshData{
    if (self.refreshControl.isRefreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中..."];
    }
    _m_PPPPChannelMgt->SetWifiParamDelegate((char*)[_camera.UID UTF8String], self);
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_GET_PARAMS, NULL, 0);
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_WIFI_SCAN, NULL, 0);
}
-(void)endRefresh{
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    }
    [self.tableView reloadData];
}
#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"当前已连接WIFI";
    }else
        return @"可用WIFI";
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else
        return _data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell0" forIndexPath:indexPath];
        cell.textLabel.text = _wifiName;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        UILabel *name = (UILabel *)[cell.contentView viewWithTag:100];
        UIImageView *signal = (UIImageView *)[cell.contentView viewWithTag:101];
        UIImageView *lock = (UIImageView *)[cell.contentView viewWithTag:102];
        MyECameraWifi *wifi = _data[indexPath.row];
        name.text = wifi.name;
        signal.image = [wifi changeSignalToImage];
        if (wifi.security == 0) {
            lock.hidden = YES;
        }else
            lock.hidden = NO;
    }
    return cell;
}
#pragma mark Wifi Param Protocol
- (void) WifiParams: (NSString*)strDID enable:(NSInteger)enable ssid:(NSString*)strSSID channel:(NSInteger)channel mode:(NSInteger)mode authtype:(NSInteger)authtype encryp:(NSInteger)encryp keyformat:(NSInteger)keyformat defkey:(NSInteger)defkey strKey1:(NSString*)strKey1 strKey2:(NSString*)strKey2 strKey3:(NSString*)strKey3 strKey4:(NSString*)strKey4 key1_bits:(NSInteger)key1_bits key2_bits:(NSInteger)key2_bits key3_bits:(NSInteger)key3_bits key4_bits:(NSInteger)key4_bits wpa_psk:(NSString*)wpa_psk{
    NSLog(@"Camera WifiParams.....strDID: %@, enable:%d, ssid:%@, channel:%d, mode:%d, authtype:%d, encryp:%d, keyformat:%d, defkey:%d, strKey1:%@, strKey2:%@, strKey3:%@, strKey4:%@, key1_bits:%d, key2_bits:%d, key3_bits:%d, key4_bits:%d, wap_psk:%@", strDID, enable, strSSID, channel, mode, authtype, encryp, keyformat, defkey, strKey1, strKey2, strKey3, strKey4, key1_bits, key2_bits, key3_bits, key4_bits, wpa_psk);
    _wifiName = [strSSID isEqualToString:@"ChinaNet"]?@"网线连接":strSSID;
}

- (void) WifiScanResult: (NSString*)strDID ssid:(NSString*)strSSID mac:(NSString*)strMac security:(NSInteger)security db0:(NSInteger)db0 db1:(NSInteger)db1 mode:(NSInteger)mode channel:(NSInteger)channel bEnd:(NSInteger)bEnd{
    NSLog(@"WifiScanResult.....strDID:%@, ssid:%@, mac:%@, security:%d, db0:%d, db1:%d, mode:%d, channel:%d, bEnd:%d", strDID, strSSID, strMac, security, db0, db1, mode, channel, bEnd);
    MyECameraWifi *wifi = [[MyECameraWifi alloc] init];
    wifi.UID = strDID;
    wifi.name = strSSID;
    wifi.security = security;
    wifi.signal = db0;
    BOOL hasOne = NO;
    for (MyECameraWifi *w in _data) {
        if ([w.name isEqualToString:wifi.name]) {
            hasOne = YES;
            break;
        }
    }
    if (!hasOne && wifi.name.length > 0) {
        [_data addObject:wifi];
    }
    [self performSelectorOnMainThread:@selector(endRefresh) withObject:nil waitUntilDone:YES];
    /**
     *  Set Wifi
     *
     *
     char *pkey = NULL;
     char *pwpa_psk = NULL;
     
     switch (m_security) {
     case 0: //none
     pkey = (char*)"";
     pwpa_psk = (char*)"";
     break;
     case 1: //wep
     pkey = (char*)[m_strPwd UTF8String];
     pwpa_psk = (char*)"";
     break;
     case 2: //wpa-psk(AES)
     case 3://wpa-psk(TKIP)
     case 4://wpa2-psk(AES)
     case 5://wpa3-psk(TKIP)
     pkey = (char*)"";
     pwpa_psk = (char*)[m_strPwd UTF8String];
     break;
     default:
     break;
     }
     m_pChannelMgt->SetWifi((char*)[m_strDID UTF8String], 1, (char*)[m_strSSID UTF8String], m_channel, 0, m_security, 0, 0, 0, pkey, (char*)"", (char*)"", (char*)"", 0, 0, 0, 0, pwpa_psk);
     */
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MyECameraWIFIConnectViewController *vc = segue.destinationViewController;
    MyECameraWifi *wifi = _data[[self.tableView indexPathForCell:sender].row];
    vc.wifi = wifi;
    vc.m_PPPPChannelMgt = self.m_PPPPChannelMgt;
}

@end
