//
//  MyEAcPeriodViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/20/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAutoPeriodViewController.h"
#import "MyEAutoControlPeriod.h"
#import "MyEDevice.h"
#import "MyEAcInstruction.h"
#import "MyEAcInstructionSet.h"
#import "MyEAccountData.h"
#import "MyEAcUtil.h"
#import "MyEUtil.h"
#import "SBJson.h"

#define AC_AUTO_VALIDATE_PERIOD_UPLOADER_NMAE @"AcAutoControlPeriodValidateInstructionUploader"


@interface MyEAutoPeriodViewController ()

@end

@implementation MyEAutoPeriodViewController
@synthesize period = _period, isAddNew = _isAddNew;
@synthesize delegate = _delegate, accountData, device;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isAddNew = NO;
    }
    return self;
}
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.timePeriodBtn setTitle:[NSString stringWithFormat:@"%@       -        %@", [self.period startTimeString], [self.period endTimeString]] forState:UIControlStateNormal ];

    [self.instructionButton setTitle:[NSString stringWithFormat:@"%@,          %@,          %@",
                                       [MyEAcUtil getStringForRunMode:self.period.runMode],
                                       [MyEAcUtil getStringForSetpoint:self.period.setpoint],
                                       [MyEAcUtil getStringForWindLevel:self.period.windLevel]]
                             forState:UIControlStateNormal];
    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                [btn.layer setMasksToBounds:YES];
                [btn.layer setCornerRadius:4];
                [btn.layer setBorderWidth:1];
                [btn.layer setBorderColor:btn.tintColor.CGColor];
            }
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter
- (void)setPeriod:(MyEAutoControlPeriod *)period{
    if (_period != period) {
        _period = period;
        period_copy = [period copy];
    }
}

#pragma mark - IBAction methods
- (IBAction)timePeriodAction:(id)sender {
    // Show UIPickerView
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
        self.pickerViewContainer.frame = CGRectMake(0, 257, 320, 261);
    } else{
        self.pickerViewContainer.frame = CGRectMake(0, 169, 320, 261);
    }
    [UIView commitAnimations];
    
    buttonTag = 0;
    [self.pickerView reloadAllComponents];
    //特别注意这里的特色
//    [self.pickerView selectRow:self.period.stid inComponent:0 animated:YES];
//    [self.pickerView selectRow:self.period.etid - self.period.stid - 1 inComponent:1 animated:YES];
    [self.pickerView selectRow:self.period.stid inComponent:0 animated:YES];
    [self.pickerView selectRow:self.period.etid inComponent:1 animated:YES];
}
- (IBAction)instructionAction:(id)sender {
    // Show UIPickerView
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
        self.pickerViewContainer.frame = CGRectMake(0, 257, 320, 261);
    } else{
        self.pickerViewContainer.frame = CGRectMake(0, 169, 320, 261);
    }
    [UIView commitAnimations];
    
    buttonTag = 1;
    [self.pickerView reloadAllComponents];
    if(device.isSystemDefined){
        [self.pickerView selectRow:self.period.runMode - 1 inComponent:0 animated:YES];
        [self.pickerView selectRow:self.period.setpoint - 18 inComponent:1 animated:YES];
        [self.pickerView selectRow:self.period.windLevel inComponent:2 animated:YES];
    } else {
        NSInteger index = [self.device.acInstructionSet indexOfInstructionInOnListWithRunMode:self.period.runMode andSetpoint:self.period.setpoint andWindLevel:self.period.windLevel];
        [self.pickerView selectRow:index inComponent:0 animated:YES];
    }

}

- (IBAction)hidePicker:(id)sender {
    [self hidePickerView];
    
//    if (buttonTag == 0) {
//        NSInteger stid = [self.pickerView selectedRowInComponent:0];
//        NSInteger etid = [self.pickerView selectedRowInComponent:1] + self.period.stid + 1;
//    }else if (buttonTag == 1){
//        NSInteger runMode = [self.pickerView selectedRowInComponent:0];
//        NSInteger setpoint = [self.pickerView selectedRowInComponent:1];
//        NSInteger windLevel = [self.pickerView selectedRowInComponent:2];
//    }
}

- (IBAction)saveAndReturnAction:(id)sender {
    [self validateTimeFrame]; //按照方法名称，这里的意思是验证时间段的正确性。但是方法内部写的确实代理传值
    if(self.device.type == 1 && self.device.isSystemDefined){ // 如果是系统定义的空调，需要指令验证和补全
        if (self.period.runMode != period_copy.runMode ||
            self.period.setpoint != period_copy.setpoint ||  //对于标准空调必须要
            self.period.windLevel != period_copy.windLevel) { //只要有一个不相等，那么就向服务器保存数据
            [self validatePeriodInstructionFromServer];
        }else{
            if ([_delegate respondsToSelector:@selector(didFinishEditPeriod:isAddNew:)])
                [_delegate didFinishEditPeriod:self.period isAddNew:self.isAddNew];
            self.period = Nil;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{ //如果是插座或者自学习的空调就直接返回
        if ([_delegate respondsToSelector:@selector(didFinishEditPeriod:isAddNew:)])
            [_delegate didFinishEditPeriod:self.period isAddNew:self.isAddNew];
        self.period = Nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIPickerViewDelegate Protocol and UIPickerViewDataSource Method
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if (buttonTag == 0) {
        if (component == 0) {
            return 48;
        } else {
            return 49;
        }
//        if (component == 0) {
//            return self.period.etid;
//        } else{  //if (component == 1)
//            return 48 - self.period.stid ;
//        }
    }else {//if(buttonTag == 1)
        if (self.device.isSystemDefined){
            if (component == 0) {
                if(self.device.instructionMode == 1)
                    return 5;
                else
                    return 4;
            } else if (component == 1) {
                return 13;
            } else {// if (component == 2)
                return 4;
            }
        }else{
            return [self.device.acInstructionSet countOfInstructionInOnList];
        }
    }

}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(buttonTag == 0) {
        return 2;
    } else {// if(buttonTag == 1)
        if (self.device.isSystemDefined){
            return 3;
        } else {
            return 1;
        }
    }
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:0].width, [pickerView rowSizeForComponent:0].height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:20];
    //这句代码添加之后，整个视图看上去好看多了，主要是label本身是白色的背景
    label.backgroundColor = [UIColor clearColor];
    if (buttonTag == 0) {
        label.text = [NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:row]];
//        if(component == 0){
//            label.text = [NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:row]];
//        } else{ //if(component == 1)
//            label.text = [NSString stringWithFormat: @"%@ ",  [MyEUtil timeStringForHhid:self.period.stid + row + 1]];
//        }
        
    }else{ // if(buttonTag == 1)
        if (self.device.isSystemDefined){
            if(component == 0){
                label.text = [NSString stringWithFormat: @"%@", [MyEAcUtil getStringForRunMode:row + 1]];
            } else if (component == 1){
                label.text = [NSString stringWithFormat: @"%@", [MyEAcUtil getStringForSetpoint:row + 18]];
            } else{
                label.text = [NSString stringWithFormat: @"%@", [MyEAcUtil getStringForWindLevel:row]];
            }
        } else {
            MyEAcInstruction *instruction = [self.device.acInstructionSet instructionInOnListAtIndex:row];
            label.text = [NSString stringWithFormat:@"%@,          %@,          %@",
                    [MyEAcUtil getStringForRunMode:instruction.runMode],
                    [MyEAcUtil getStringForSetpoint:instruction.setpoint],
                    [MyEAcUtil getStringForWindLevel:instruction.windLevel]];
        }
    }
    return label;
}
//-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    if (buttonTag == 0) {
//        if(component == 0){
//            return [NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:row]];
//        } else{ //if(component == 1)
//            return [NSString stringWithFormat: @"%@ ",  [MyEUtil timeStringForHhid:self.period.stid + row + 1]];
//        }
//        
//    }else{ // if(buttonTag == 1)
//        if (self.device.isSystemDefined){
//            if(component == 0){
//                return [NSString stringWithFormat: @"%@", [MyEAcUtil getStringForRunMode:row + 1]];
//            } else if (component == 1){
//                return [NSString stringWithFormat: @"%@", [MyEAcUtil getStringForSetpoint:row + 18]];
//            } else{
//                return [NSString stringWithFormat: @"%@", [MyEAcUtil getStringForWindLevel:row]];
//            }
//        } else {
//            MyEAcInstruction *instruction = [self.device.acInstructionSet instructionInOnListAtIndex:row];
//            return [NSString stringWithFormat:@"%@,          %@,          %@",
//                    [MyEAcUtil getStringForRunMode:instruction.runMode],
//                    [MyEAcUtil getStringForSetpoint:instruction.setpoint],
//                    [MyEAcUtil getStringForWindLevel:instruction.windLevel]];
//        }
//    }
//}

/*
 - (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
 {
 return Nil;
 }
 
 
 - (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
 {
 UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
 
 }
 */


 //本来没选中一个值后，在下面函数里面就直接更新对应的Textfiled，但这里导致没选中一个值后，运行完下面函数后，self.pickerViewContainer就被自动隐藏了，不知原因，所以先不用这个办法，而是把更新Textfield的代码放到隐藏self.pickerViewContainer的action函数 hidePicker: 里面了。
 - (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
 {
     if (buttonTag == 0) {  //这里是两种不同的实现方法
         if (component == 0) {
             self.period.stid = row;
             if ((self.period.etid - self.period.stid) < 1) {
                 self.period.etid = row+1;
                 [self.pickerView selectRow:row+1 inComponent:1 animated:YES];
                 [self.pickerView reloadComponent:1];
              }
         } else {
             self.period.etid = row;
             if ((self.period.etid - self.period.stid) < 1) {
                 self.period.stid = row-1;
                 [self.pickerView reloadComponent:0];
                 [self.pickerView selectRow:row-1 inComponent:0 animated:YES];
             }
         }
//         if(component == 0){
//             self.period.stid = row;
//             [pickerView reloadComponent:1];
//             [self.pickerView selectRow:self.period.etid - self.period.stid - 1 inComponent:1 animated:NO];
//         } else{ //if(component == 1)
//             self.period.etid = row + self.period.stid + 1;
//             [pickerView reloadComponent:0];
//             
//         }
         [self.timePeriodBtn setTitle:[NSString stringWithFormat:@"%@       -        %@", [self.period startTimeString], [self.period endTimeString]] forState:UIControlStateNormal ];
     }else{
         if (self.device.isSystemDefined){
             if(component == 0){
                 self.period.runMode = row + 1;
             } else if (component == 1){
                 self.period.setpoint = row + 18;
             } else{
                 self.period.windLevel = row;
             }
             [self.instructionButton setTitle:[NSString stringWithFormat:@"%@,          %@,          %@",
                                               [MyEAcUtil getStringForRunMode:self.period.runMode],
                                               [MyEAcUtil getStringForSetpoint:self.period.setpoint],
                                               [MyEAcUtil getStringForWindLevel:self.period.windLevel]]
                                     forState:UIControlStateNormal];
         }else{
             MyEAcInstruction *instruction = [self.device.acInstructionSet instructionInOnListAtIndex:row];
             self.period.runMode = instruction.runMode;
             self.period.setpoint = instruction.setpoint;
             self.period.windLevel = instruction.windLevel;
             [self.instructionButton setTitle:[NSString stringWithFormat:@"%@,          %@,          %@",
                                               [MyEAcUtil getStringForRunMode:instruction.runMode],
                                               [MyEAcUtil getStringForSetpoint:instruction.setpoint],
                                               [MyEAcUtil getStringForWindLevel:instruction.windLevel]]
                                     forState:UIControlStateNormal];
         }
     }
 
 }

#pragma mark - private method
- (void)hidePickerView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
        self.pickerViewContainer.frame = CGRectMake(0, 568, 320, 261);
    } else
        self.pickerViewContainer.frame = CGRectMake(0, 480, 320, 261);
    [UIView commitAnimations];
}
- (BOOL) validateTimeFrame {
    if ([_delegate respondsToSelector:@selector(isTimeFrameValidForPeriod:)])
        return [_delegate isTimeFrameValidForPeriod:self.period];
    return YES;
}

#pragma mar UIAlertView Delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        NSLog(@"ok");
        self.period.runMode = replaced_runMode;
        self.period.setpoint = replaced_setpoint;
        self.period.windLevel = replaced_windLevel;
        if ([_delegate respondsToSelector:@selector(didFinishEditPeriod:isAddNew:)])
            [_delegate didFinishEditPeriod:self.period isAddNew:self.isAddNew];
        self.period = Nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (buttonIndex == 1){
        NSLog(@"cancel");
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark URL Loading System methods
- (void) validatePeriodInstructionFromServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.detailsLabelText = @"正在验证指令...";
        HUD.delegate = self;
    } else
        [HUD show:YES];
   
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&tId=%@&runMode=%ld&setpoint=%ld&windLevel=%ld",
                        GetRequst(URL_FOR_AC_PERIOD_VALIDATE_INSTRUCTION),
                        self.accountData.userId,
                        self.device.tId,
                        (long)self.period.runMode,
                        (long)self.period.setpoint,
                        (long)self.period.windLevel];
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
            if ([_delegate respondsToSelector:@selector(didFinishEditPeriod:isAddNew:)])
                [_delegate didFinishEditPeriod:self.period isAddNew:self.isAddNew];
            [self.navigationController popViewControllerAnimated:YES];
        } else  if ([MyEUtil getResultFromAjaxString:string] == 2){// invalid instruction, give a suggested one
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            // 把JSON转为字典
            NSDictionary *result_dict = [parser objectWithString:string];
            replaced_runMode = [[result_dict objectForKey:@"runMode"] intValue];
            replaced_setpoint =[[result_dict objectForKey:@"setpoint"] intValue];
            replaced_windLevel =[[result_dict objectForKey:@"windLevel"] intValue];
            
            NSString *messageString = [NSString stringWithFormat:
                                       @"所选择的指令不存在，系统为您选择一个相近的指令：(%@,%@,%@)，您确定用这个指令吗？",
                                       [MyEAcUtil getStringForRunMode:replaced_runMode],
                                       [MyEAcUtil getStringForSetpoint:replaced_setpoint],
                                       [MyEAcUtil getStringForWindLevel:replaced_windLevel]];
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"指令验证"
                                                        contentText:messageString
                                                    leftButtonTitle:@"取消"
                                                   rightButtonTitle:@"确定"];
            [alert show];
            alert.rightBlock=^{
                self.period.runMode = replaced_runMode;
                self.period.setpoint = replaced_setpoint;
                self.period.windLevel = replaced_windLevel;
                if ([_delegate respondsToSelector:@selector(didFinishEditPeriod:isAddNew:)])
                    [_delegate didFinishEditPeriod:self.period isAddNew:self.isAddNew];
                self.period = Nil;
                [self.navigationController popViewControllerAnimated:YES];

            };
        } else {
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
@end
