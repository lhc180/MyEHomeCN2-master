//
//  MyEAcInstructionAutoCheckViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-25.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcInstructionAutoCheckViewController.h"
#import "MyEAcBrand.h"
#import "MyEAcModel.h"
#import "MyEAcStandardInstructionViewController.h"
@interface MyEAcInstructionAutoCheckViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblProcess;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actor;

@end

@implementation MyEAcInstructionAutoCheckViewController
@synthesize brandLabel,modelLabel,brandNameArray,brandIdArray,moduleIdArray,moduleNameArray,startBtn,brandIdIndex,moduleIdIndex;

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    for (UIButton *btn in self.view.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 4;
            btn.layer.borderColor = btn.tintColor.CGColor;
            btn.layer.borderWidth = 1;
        }
    }
    //刚进入此界面时，【停止匹配】按钮必须不能点击
    self.stopBtn.enabled = NO;
    brandLabel.text = _brand.brandName;
    _model = _brand.models[0];
    moduleIdIndex = 0;
    [self refreshUI];
}
#pragma mark - private methods
-(void)refreshUI{
    self.lblProcess.text = [NSString stringWithFormat:@"%i/%i",moduleIdIndex+1,self.brand.models.count];
    modelLabel.text = _model.modelName;
}

-(void)doThisWhenInstructionSendSuccess{
    //#warning 这里修改了,当用户点击停止的时候，不再继续显示下一个品牌和型号
    if (autoCheckStop) {
        return;
    }
    failureTimes = 0; //一旦成功,就将失败次数清零
    
    if (moduleIdIndex == _brand.models.count - 1) {
        [self stopToCheck:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已经将该品牌的所有型号指令发送完毕,请查看整个过程中空调是否有响应" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    moduleIdIndex ++;
    
    _model = _brand.models[moduleIdIndex];
    [self refreshUI];
    [self autoCheckInstructionWithModuleId:_model.modelId];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction methods
- (IBAction)startToCheck:(UIButton *)sender {
    
    if (moduleIdIndex >= [_brand.models count] - 1) {
        moduleIdIndex = 0;
        _model = _brand.models[0];
    }
    autoCheckStop = NO;//在这里对autocheckstop进行初始化
    manualSendInstruction = NO;
    [startBtn setSelected:YES];//选中时候的title已经在storyboard中设置好了
    self.cancelBtn.enabled = NO;  //当匹配开始时禁止用户点击【返回】btn，以防此时退出时会发生错误
    self.lastBtn.enabled = NO;
    self.nextBtn.enabled = NO;
    self.sendBtn.enabled = NO;
    self.stopBtn.enabled = YES;
    startBtn.userInteractionEnabled = NO;//开始匹配之后就不允许用户点击这个btn了
    [UIApplication sharedApplication].idleTimerDisabled = YES;   //禁止屏幕休眠
    //这里使用的moduleIdArray是从上级面板继承过来的
    [self autoCheckInstructionWithModuleId:_model.modelId];
}

- (IBAction)stopToCheck:(UIButton *)sender {
    autoCheckStop = YES;
    startBtn.userInteractionEnabled = YES;
    self.cancelBtn.enabled = YES;  //停止时要让用户可以返回
    self.lastBtn.enabled = YES;
    self.nextBtn.enabled = YES;
    self.sendBtn.enabled = YES;
    [startBtn setSelected:NO];
    sender.enabled = NO;
    [UIApplication sharedApplication].idleTimerDisabled = NO;  //允许屏幕休眠
}

- (IBAction)lastModule:(UIButton *)sender {
    autoCheckStop = YES;
    if (moduleIdIndex == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前已经是第一个型号" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    moduleIdIndex--;
    _model = _brand.models[moduleIdIndex];
    [self refreshUI];
}
- (IBAction)nextModule:(UIButton *)sender {
    autoCheckStop = YES;
    if (moduleIdIndex == _brand.models.count - 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前已经是最后一个型号" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    moduleIdIndex++;
    _model = _brand.models[moduleIdIndex];
    [self refreshUI];
}
- (IBAction)sendInstructionByUser:(UIButton *)sender {
    manualSendInstruction = YES;
    [self autoCheckInstructionWithModuleId:_model.modelId];
}
- (IBAction)cancel:(UIButton *)sender {
    //    [timer invalidate];
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
            failureTimes ++;
            if (failureTimes < 5) {
                [self autoCheckInstructionWithModuleId:[moduleIdArray[moduleIdIndex] integerValue]];
            }else{
                [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"自动匹配指令发送失败"];
            }
        }else if([MyEUtil getResultFromAjaxString:string] == 1){
            if (manualSendInstruction) {
                manualSendInstruction = NO;
                [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"指令发送成功"];
            }else{
                if (!autoCheckStop) {
                    if (_roundTimes < 2) {
                        //之前使用的是sleep的方式,这会造成系统卡顿，现在采用了延迟加载的方法，使程序更加流畅
                        [self performSelector:@selector(doThisWhenInstructionSendSuccess) withObject:nil afterDelay:3];
                    }else{
                        [self.startBtn setSelected:NO];
                        self.startBtn.enabled = NO;
                        self.stopBtn.enabled = NO;
                        self.cancelBtn.enabled = YES;
                        autoCheckStop = YES;
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"该品牌的所有型号已匹配了 2 遍,如果空调仍没有反应,请点击[返回],切换到[自学习]进行指令学习" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }
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
    [MyEUtil showMessageOn:Nil withMessage:@"与服务器通讯失败"];
    [HUD hide:YES];
}

@end
