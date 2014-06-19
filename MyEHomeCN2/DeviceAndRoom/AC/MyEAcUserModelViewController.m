//
//  MyEAcUserModelControlViewController.m
//  MyEHome
//
//  Created by Ye Yuan on 10/9/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcUserModelViewController.h"

#define AC_CONTROL_UPLOADER_NMAE @"AcControlUploader"

@interface MyEAcUserModelViewController ()

@end

@implementation MyEAcUserModelViewController
@synthesize accountData, device;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    [self downloadInstructionSetFromServer];
    
    [_humidityLabel setText:[NSString stringWithFormat:@"%li%%", (long)self.device.status.humidity]];
    [self.tempLabel setText:[NSString stringWithFormat:@"%li℃",(long)self.device.status.temperature]];
    timerToRefreshTemperatureAndHumidity = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(downloadTemperatureHumidityFromServer) userInfo:nil repeats:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [timerToRefreshTemperatureAndHumidity invalidate];
}
#pragma mark - URL private methods
- (void) downloadInstructionSetFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&moduleId=%ld",URL_FOR_USER_AC_INSTRUCTION_SET_VIEW, self.device.tId, (long)self.device.modelId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"AC_INSTRUCTION_SET_DOWNLOADER_NMAE"  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
- (void) downloadTemperatureHumidityFromServer
{
    // this is a dumb download, don't add progress indicator or spinner here
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&id=%ld",URL_FOR_AC_TEMPERATURE_HUMIDITY_VIEW, self.device.tId, (long)self.device.deviceId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"acStatus"  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
- (void) submitControlToServerPower:(NSInteger)powerSwitch runMode:(NSInteger)runMode setpoint:(NSInteger)setpoint windLevel:(NSInteger)windLevel
{
    
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:powerSwitch], @"powerSwitch",
                          [NSNumber numberWithInteger:runMode], @"runMode",
                          [NSNumber numberWithInteger:setpoint], @"setpoint",
                          [NSNumber numberWithInteger:windLevel], @"windLevel",
                          nil ];
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%ld&switch_=%ld&runMode=%ld&setpoint=%ld&windLevel=%ld",URL_FOR_AC_CONTROL_SAVE, (long)self.device.deviceId, (long)powerSwitch,
                        (long)runMode, (long)setpoint, (long)windLevel];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:AC_CONTROL_UPLOADER_NMAE  userDataDictionary:dict];
    NSLog(@"%@",downloader.name);
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.device.acInstructionSet.mainArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"row0" forIndexPath:indexPath];
        return cell;
    }
    static NSString *CellIdentifier = @"AcInstructionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    MyEAcInstruction *instruction = [self.device.acInstructionSet.mainArray objectAtIndex:indexPath.row - 1];
    // Configure the cell...
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:11];
    [label setText:[MyEAcUtil getStringForPowerSwitch:instruction.powerSwitch]];
    
    UIImageView *iv = (UIImageView *)[cell.contentView viewWithTag:12];
    [iv setImage:[UIImage imageNamed:[MyEAcUtil getFilenameForRunMode:instruction.runMode]]];
    
    label = (UILabel *)[cell.contentView viewWithTag:13];
    [label setText:[MyEAcUtil getStringForSetpoint:instruction.setpoint]];
    
    label = (UILabel *)[cell.contentView viewWithTag:14];
    [label setText:[MyEAcUtil getStringForWindLevel:instruction.windLevel]];
    
    return cell;
}
#pragma mark - tableView delegate methods
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return nil;
    }
    return indexPath;
}
// Tap on table Row
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    MyEAcInstruction *instruction = [self.device.acInstructionSet.mainArray objectAtIndex:indexPath.row -1];
    NSLog(@"power=%ld, runmode=%ld, setpoint=%ld, windlevel=%ld", (long)instruction.powerSwitch, (long)instruction.runMode, (long)instruction.setpoint, (long)instruction.windLevel);
    [self submitControlToServerPower:instruction.powerSwitch runMode:instruction.runMode setpoint:instruction.setpoint windLevel:instruction.windLevel];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - URL delegate methods
// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:@"acStatus"]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
  //          [MyEUtil showMessageOn:nil withMessage:@"用户已注销登录"];
        }else if ([MyEUtil getResultFromAjaxString:string] != 1){
            [MyEUtil showMessageOn:nil withMessage:@"下载数据失败"];
        }else{
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict = [parser objectWithString:string];
            self.device.status.temperature = [[dict objectForKey:@"temperature"] intValue];
            self.device.status.humidity = [[dict objectForKey:@"humidity"] intValue];
            self.tempLabel.text = [NSString stringWithFormat:@"%li℃",(long)self.device.status.temperature];
            self.humidityLabel.text = [NSString stringWithFormat:@"%li%%",(long)self.device.status.humidity];
        }
    }
    if([name isEqualToString:@"AC_INSTRUCTION_SET_DOWNLOADER_NMAE"]) {
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:nil withMessage:@"下载空调数据失败"];
        } else{
            NSLog(@"ajax json = %@", string);
            MyEAcInstructionSet *instructionSet = [[MyEAcInstructionSet alloc] initWithJSONString:string];
            self.device.acInstructionSet = instructionSet;
            [self.tableView reloadData];
        }
    }
    if([name isEqualToString:AC_CONTROL_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] != 1 && [MyEUtil getResultFromAjaxString:string] != 2) {
        } else{
            self.device.status.powerSwitch = [[dict objectForKey:@"powerSwitch"] intValue];
            self.device.status.runMode = [[dict objectForKey:@"runMode"] intValue];
            self.device.status.setpoint = [[dict objectForKey:@"setpoint"] intValue];
            self.device.status.windLevel = [[dict objectForKey:@"windLevel"] intValue];
            [MyEUtil showSuccessOn:self.navigationController.view withMessage:@"发送空调指令成功！"];

        }
    }
    [HUD hide:YES];
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:AC_CONTROL_UPLOADER_NMAE])
        msg = @"发送控制指令通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showErrorOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}
@end
