//
//  MYEACAutoCheckViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/9.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEACAutoCheckViewController.h"
#import "MyEAcModel.h"
#import "MZFormSheetController.h"

@interface MYEACAutoCheckViewController ()<MyEDataLoaderDelegate>{
    BOOL _isAutoCheck;  //表示现在是自动匹配
    NSInteger _index;   //表示当前匹配到的型号位置
    MyEAcModel *_model; //表示当前正在匹配的型号
    
    NSInteger _failureTimes;  //记录匹配时失败的次数
}

@property (weak, nonatomic) IBOutlet UILabel *lblModel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actor;
@property (weak, nonatomic) IBOutlet UILabel *lblProcess;
@property (weak, nonatomic) IBOutlet UIButton *btnStartAutoCheck;
@property (weak, nonatomic) IBOutlet UIView *viewManualCheck;

@end

@implementation MYEACAutoCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MyEUtil makeFlatButton:self.btnStartAutoCheck];
    for (UIButton *btn in self.viewManualCheck.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            if (btn.tag != 100) {
                [MyEUtil makeFlatButton:btn];
            }
        }
    }
    _index = 0;
    [self refreshUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - private methods
-(void)refreshUI{
    self.lblProcess.text = [NSString stringWithFormat:@"%i/%i",_index+1,_brand.models.count];
    _model = self.brand.models[_index];
    self.lblModel.text = _model.modelName;
}
-(void)lastModel{
    if (_index > 0) {
        _index --;
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前已经是第一个型号" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self refreshUI];
}
-(void)nextModel{
    if (_index < _brand.models.count - 1) {
        _index ++;
    }else{
        if (self.btnStartAutoCheck.selected) {
            self.btnStartAutoCheck.selected = NO;
            _actor.hidden = YES;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前已经是最后一个型号" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self refreshUI];
    if (_isAutoCheck) {
        [self autoCheckInstructionWithModuleId:_model.modelId];
    }
}
#pragma mark - IBAction methods
- (IBAction)autoCheck:(UIButton *)sender {
    _isAutoCheck = !sender.selected;
    sender.selected = !sender.selected;
    _actor.hidden = !_isAutoCheck;
    if (_isAutoCheck) {
        _index = 0;
        [self refreshUI];
        [self autoCheckInstructionWithModuleId:_model.modelId];
    }
}
- (IBAction)changeMode:(UIButton *)sender {
    if (sender.tag == 101) {  //表示此时是由自动匹配切换到手动匹配
        if (_isAutoCheck) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前正在自动匹配,无法切换到手动匹配模式" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    [self.view sendSubviewToBack:sender.superview];
}
- (IBAction)sendTestInstructionManually:(UIButton *)sender {
    _actor.hidden = NO;
    [self autoCheckInstructionWithModuleId:_model.modelId];
}
- (IBAction)changeModel:(UIButton *)sender {
    if (sender.tag == 101) {  //上一个型号
        [self lastModel];
    }else{
        [self nextModel];
    }
}
- (IBAction)dismiss:(UIBarButtonItem *)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

#pragma mark - URL private methods
-(void)autoCheckInstructionWithModuleId:(NSInteger)moduleId{
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&moduleId=%li",
                        GetRequst(URL_FOR_AC_AUTO_CHECK_MODULE),self.device.tId,(long)moduleId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"autoCheck" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if ([name isEqualToString:@"autoCheck"]) {
        NSLog(@"autoCheck string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            _failureTimes ++;
            if (_failureTimes < 5) {
                [self autoCheckInstructionWithModuleId:_model.modelId];
            }else{
                [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"自动匹配指令发送失败"];
            }
        }else if([MyEUtil getResultFromAjaxString:string] == 1){
            if (_isAutoCheck) {
                [self performSelector:@selector(nextModel) withObject:nil afterDelay:3];
            }else{
                _actor.hidden = YES;
            }

        }else if([MyEUtil getResultFromAjaxString:string] == -3){
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"与服务器连接失败,请稍后重试" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
    _actor.hidden = YES;
    _isAutoCheck = NO;
}
@end
