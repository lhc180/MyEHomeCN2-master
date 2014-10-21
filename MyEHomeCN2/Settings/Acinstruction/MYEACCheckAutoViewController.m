//
//  MYEACCheckAutoViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/9.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEACCheckAutoViewController.h"
#import "MyEDataLoader.h"
#import "MyEAcModel.h"
#import "MZFormSheetController.h"
#import "MyEUtil.h"
#import "MyEUniversal.h"

@interface MYEACCheckAutoViewController ()<MyEDataLoaderDelegate,UIAlertViewDelegate>{
    BOOL _isFast;  //表示此时是快速检索阶段
    BOOL _isPause;  //程序进入暂停阶段
    MyEAcModel *_model; //表示当前正在匹配的型号
    
    NSInteger _failureTimes;  //记录匹配时失败的次数
    NSInteger _counter;  //精准匹配的个数
}
@property (weak, nonatomic) IBOutlet UILabel *lblModel;
@property (weak, nonatomic) IBOutlet UILabel *lblProcess;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actor;
@property (weak, nonatomic) IBOutlet UILabel *lblTips;
@property (weak, nonatomic) IBOutlet UIButton *btnStartAutoCheck;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation MYEACCheckAutoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _index = 0;
    [self refreshUI];
    [self changeTitleLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - private methods
-(void)changeTitleLabel{
    if (self.btnStartAutoCheck.selected) {
        self.lblTitle.text = @"当空调开机或发出'叮'的提示音时,请立即[停止]";
        self.lblTitle.textColor = [UIColor redColor];
    }else{
        self.lblTitle.text = @"请点击[开始]进行型号自动匹配";
        self.lblTitle.textColor = [UIColor darkGrayColor];
    }
}
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
    [self autoCheckInstructionWithModuleId:_model.modelId];
}
-(void)nextModel{
    if (_isPause) {
        return;
    }
    if (!self.btnStartAutoCheck.selected) {
        return;
    }
    if (_isFast) {
        _counter ++;
        if (_counter < 6) {
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
        }else{
            self.btnStartAutoCheck.selected = NO;
            _actor.hidden = YES;
            _lblTips.hidden = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"如果空调还是没有响应,请点击[开始]继续匹配" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }else{
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
    }
        [self refreshUI];
        [self autoCheckInstructionWithModuleId:_model.modelId];
}

#pragma mark - IBAction methods
- (IBAction)startAutoCheck:(UIButton *)sender {
    if (!sender.selected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.selected = YES;
            _actor.hidden = NO;
            [self changeTitleLabel];
        });
        _isFast = NO;  //这里要进行初始化
        [self autoCheckInstructionWithModuleId:_model.modelId];
    }else{
        _isFast = !_isFast;
        _isPause = YES;
        if (_isFast) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前空调是否有响应?(有响应是指空调是否打开、是否有提示音等状态变化)" delegate:self cancelButtonTitle:@"没有响应" otherButtonTitles:@"有响应", nil];
            alert.tag = 100;
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"当前您选择的空调型号为\n%@\n%@\n请问您确定选择该型号么?",_brand.brandName,_model.modelName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 101;
            [alert show];
        }
    }
}
- (IBAction)dismiss:(UIBarButtonItem *)sender {
    _cancelBtnClicked = YES;
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}
- (IBAction)cleanToZero:(UIButton *)sender {
    if (self.btnStartAutoCheck.selected) {
        return;
    }
    _index = 0;
    [self refreshUI];
    [self changeTitleLabel];
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
            [self performSelector:@selector(nextModel) withObject:nil afterDelay:_isFast?5:1];
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
}
#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    _isPause = NO;
    
    if (alertView.tag == 100) {   //是否进入精准匹配模式
        if (buttonIndex == 1) {   //进入精准匹配模式
            if (_index - 5 >= 0) {
                _index -= 5;
            }else
                _index = 0;
            _counter = 0;
            self.lblTips.hidden = NO;
            [self refreshUI];
            [self autoCheckInstructionWithModuleId:_model.modelId];
        }else{
            self.lblTips.hidden = YES;
            self.btnStartAutoCheck.selected = NO;
            _actor.hidden = YES;
            [self changeTitleLabel];
        }
    }
    if (alertView.tag == 101) {   //是否确认选择当前匹配的型号
        if (buttonIndex == 1) {   //确认选择当前型号
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
        }else{
            self.lblTips.hidden = YES;
            self.btnStartAutoCheck.selected = NO;
            _actor.hidden = YES;
            [self changeTitleLabel];
        }
    }
}
@end
