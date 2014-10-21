//
//  MYEACPeriodSetViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/12.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEACPeriodSetViewController.h"
#import "MyEAcUtil.h"
#import "MYETimePicker.h"
#import "MYEPickerView.h"
#import "MyEAcInstruction.h"

#define AC_AUTO_VALIDATE_PERIOD_UPLOADER_NMAE @"AcAutoControlPeriodValidateInstructionUploader"


@interface MYEACPeriodSetViewController ()<MyEDataLoaderDelegate,MYETimePickerDelegate,MYEPickerViewDelegate,UIAlertViewDelegate>{
    MBProgressHUD *HUD;
    MyEAutoControlPeriod *_periodNew;
    
    // 进行系统定义的指令补全验证的时候，用来保存从服务器获取的替换用的指令参数，然后在UIAlertView的代理回调函数里面使用
    NSInteger replaced_runMode;
    NSInteger replaced_setpoint;
    NSInteger replaced_windLevel;
    NSMutableArray *_instructions;
}

@property (weak, nonatomic) IBOutlet UILabel *lblStart;
@property (weak, nonatomic) IBOutlet UILabel *lblEnd;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;

@end

@implementation MYEACPeriodSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _periodNew = [self.period copy];
    [self refreshUI];
    if (!self.device.isSystemDefined) {
        _instructions = [NSMutableArray array];
        for (MyEAcInstruction *instruction in self.device.acInstructionSet.mainArray) {
            [_instructions addObject:[NSString stringWithFormat:@"%@,%@,%@",
                                      [MyEAcUtil getStringForRunMode:instruction.runMode],
                                      [MyEAcUtil getStringForSetpoint:instruction.setpoint],
                                      [MyEAcUtil getStringForWindLevel:instruction.windLevel]]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - Private methods
-(void)refreshUI{
    self.lblStart.text = [_periodNew startTimeString];
    self.lblEnd.text = [_periodNew endTimeString];
    self.lblStatus.text = [NSString stringWithFormat:@"%@,%@,%@",
                           [MyEAcUtil getStringForRunMode:_periodNew.runMode],
                           [MyEAcUtil getStringForSetpoint:_periodNew.setpoint],
                           [MyEAcUtil getStringForWindLevel:_periodNew.windLevel]];
}
-(void)addOrEditPeriod{
    if (_isAddNew) {
        [self.process.periods addObject:_periodNew];
    }else{
        if ([self.process.periods containsObject:self.period]) {
            NSInteger i = [self.process.periods indexOfObject:self.period];
            [self.process.periods removeObjectAtIndex:i];
            [self.process.periods insertObject:_periodNew atIndex:i];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - IBAction methods
- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    if (_periodNew.stid >= _periodNew.etid) {
        [MyEUtil showMessageOn:nil withMessage:@"开始时间应该小于结束时间"];
        return;
    }
    if (![self.process validatePeriodWithId:_periodNew.pId newStid:_periodNew.stid newEtid:_periodNew.etid]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"时段重叠" message:@"已存在相似时段,请重新选择" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        if (self.device.isSystemDefined) {
            [self validatePeriodInstructionFromServer];
        }else{
            [self addOrEditPeriod];
        }
    }
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            MYETimePicker *timePicker = [[MYETimePicker alloc] initWithView:self.view andTag:1 title:@"请选择开始时间" interval:30 andDelegate:self];
            timePicker.time = self.lblStart.text;
            [timePicker show];
        }else{
            MYETimePicker *timePicker = [[MYETimePicker alloc] initWithView:self.view andTag:2 title:@"请选择结束时间" interval:30 andDelegate:self];
            timePicker.time = self.lblEnd.text;
            [timePicker show];
        }
    }
    if (indexPath.section == 1) {
        if (self.device.isSystemDefined) {
            MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:1 title:@"请选择空调状态" dataSource:@[[MyEAcUtil modesWithAction:self.device.instructionMode],[MyEAcUtil temps],[MyEAcUtil fans]] andSelectRow:0];
            picker.selectedRows = @[@(_periodNew.runMode-1),@(_periodNew.setpoint - 18),@(_periodNew.windLevel)];
            picker.delegate = self;
            [picker show];
        }else{
            MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:1 title:@"请选择空调状态" dataSource:_instructions andSelectRow:0];
            picker.delegate = self;
            [picker show];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - URL Loading System methods
- (void) validatePeriodInstructionFromServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.detailsLabelText = @"验证空调状态...";
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&tId=%@&runMode=%ld&setpoint=%ld&windLevel=%ld",
                        GetRequst(URL_FOR_AC_PERIOD_VALIDATE_INSTRUCTION),
                        MainDelegate.accountData.userId,
                        self.device.tId,
                        (long)_periodNew.runMode,
                        (long)_periodNew.setpoint,
                        (long)_periodNew.windLevel];
    NSLog(@"json string for uploading Process is :\n %@", urlStr);
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:Nil
                                 delegate:self
                                 loaderName:AC_AUTO_VALIDATE_PERIOD_UPLOADER_NMAE
                                 userDataDictionary:Nil];
    NSLog(@"%@",downloader.name);
}

// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:AC_AUTO_VALIDATE_PERIOD_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"时段指令补全验证时发生错误！"];
        } else  if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else  if ([MyEUtil getResultFromAjaxString:string] == 1){//valid instruction, do nothing, pass
            [self addOrEditPeriod];
        } else  if ([MyEUtil getResultFromAjaxString:string] == 2){// invalid instruction, give a suggested one
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            // 把JSON转为字典
            NSDictionary *result_dict = [parser objectWithString:string];
            replaced_runMode = [[result_dict objectForKey:@"runMode"] intValue];
            replaced_setpoint =[[result_dict objectForKey:@"setpoint"] intValue];
            replaced_windLevel =[[result_dict objectForKey:@"windLevel"] intValue];
            
            NSString *messageString = [NSString stringWithFormat:
                                       @"您选择的指令不存在,系统为您选择一个相近的指令:(%@,%@,%@),您确定用这个指令吗?",
                                       [MyEAcUtil getStringForRunMode:replaced_runMode],
                                       [MyEAcUtil getStringForSetpoint:replaced_setpoint],
                                       [MyEAcUtil getStringForWindLevel:replaced_windLevel]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"指令验证"
                                                            message:messageString delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 100;
            [alert show];
        } else {
            [MyEUtil showMessageOn:nil withMessage:@"与服务器通讯发生错误"];
            [[NSException exceptionWithName:@"错误" reason:@"返回码错误！" userInfo:Nil] raise];
        }
    }
    
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:AC_AUTO_VALIDATE_PERIOD_UPLOADER_NMAE])
        msg = @"时段指令验证通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}
#pragma mark - UIAlertView Delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 && buttonIndex == 1) {
        _periodNew.runMode = replaced_runMode;
        _periodNew.setpoint = replaced_setpoint;
        _periodNew.windLevel = replaced_windLevel;
        [self addOrEditPeriod];
    }
}
#pragma mark - MYETimePicker delegate 
-(void)MYETimePicker:(UIView *)picker didSelectString:(NSString *)title{
    if (picker.tag == 1) {
        _lblStart.text = title;
        _periodNew.stid = [MyEUtil hhidForTimeString:title];
    }else{
        _lblEnd.text = title;
        _periodNew.etid = [MyEUtil hhidForTimeString:title];
    }
}
#pragma mark - MYEPicker Delegate method
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSArray *)titles andRows:(NSArray *)rows{
    self.lblStatus.text = [NSString stringWithFormat:@"%@,%@,%@",titles[0],titles[1],titles[2]];
    _periodNew.runMode = [rows[0] intValue] + 1;
    _periodNew.setpoint = [rows[1] intValue] + 18;
    _periodNew.windLevel = [rows[2] intValue];
}
-(void)MYEPickerView:(UIView *)pickerView didSelectTitle:(NSString *)title andRow:(NSInteger)row{
    self.lblStatus.text = title;
    MyEAcInstruction *instruction = self.device.acInstructionSet.mainArray[row];
    _periodNew.runMode = instruction.runMode;
    _periodNew.setpoint = instruction.setpoint;
    _periodNew.windLevel = instruction.windLevel;
}
@end
