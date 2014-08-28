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

@end

@implementation MyEAcInstructionAutoCheckViewController
@synthesize brandLabel,modelLabel,brandNameArray,brandIdArray,moduleIdArray,moduleNameArray,startBtn,brandIdIndex,moduleIdIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                btn.layer.masksToBounds = YES;
                btn.layer.cornerRadius = 4;
                btn.layer.borderColor = btn.tintColor.CGColor;
                btn.layer.borderWidth = 1;
            }
        }
    }
    //刚进入此界面时，【停止匹配】按钮必须不能点击
    self.stopBtn.enabled = NO;
}
#pragma mark - private methods
-(void)findModuleNameAndIdArrayByIndex:(NSInteger)index{
    NSMutableArray *modules = [NSMutableArray array];
    NSMutableArray *moduleIds = [NSMutableArray array];
    MyEAcBrand *brand = self.brandsAndModules.sysAcBrands[index];
    for (int i=0; i<[self.brandsAndModules.sysAcModels count]; i++) {
        MyEAcModel *module = self.brandsAndModules.sysAcModels[i];
        for (int j=0; j<[brand.models count]; j++) {
            if (module.modelId == [brand.models[j] intValue]) {
                [modules addObject:module.modelName];
                [moduleIds addObject:[NSNumber numberWithInteger:module.modelId]];
            }
        }
    }
    self.moduleNameArray = modules;
    self.moduleIdArray = moduleIds;
    NSLog(@"%@%@",moduleNameArray,moduleIdArray);
}
-(void)doThisWhenInstructionSendSuccess{
//#warning 这里修改了,当用户点击停止的时候，不再继续显示下一个品牌和型号
    if (autoCheckStop) {
        return;
    }
    failureTimes = 0; //一旦成功,就将失败次数清零
    if (moduleIdIndex >= [moduleIdArray count] - 1) {
        moduleIdIndex = 0;
    }else
        moduleIdIndex ++;
    if (moduleIdIndex == self.startIndex) {
        _roundTimes++;
    }
    
    brandLabel.text = brandNameArray[brandIdIndex];
    modelLabel.text = moduleNameArray[moduleIdIndex];
    [self autoCheckInstructionWithModuleId:[moduleIdArray[moduleIdIndex] integerValue]];
//    if (!autoCheckStop) {
//        if (moduleIdIndex == [moduleIdArray count]-1) {
//            brandIdIndex++;
//            moduleIdIndex = 0;
//            [self findModuleNameAndIdArrayByIndex:brandIdIndex];
//            brandLabel.text = brandNameArray[brandIdIndex];
//            modelLabel.text = moduleNameArray[moduleIdIndex];
//            [self autoCheckInstructionWithModuleId:[moduleIdArray[moduleIdIndex] integerValue]];
//        }else{
//            moduleIdIndex++;
//            brandLabel.text = brandNameArray[brandIdIndex];
//            modelLabel.text = moduleNameArray[moduleIdIndex];
//            [self autoCheckInstructionWithModuleId:[moduleIdArray[moduleIdIndex] integerValue]];
//        }
//    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction methods
- (IBAction)startToCheck:(UIButton *)sender {
//    //这里注意要这么初始化index
//    brandIdIndex = [brandNameArray indexOfObject:self.brandLabel.text];
//    moduleIdIndex = [moduleNameArray indexOfObject:self.modelLabel.text];
//    
//    NSLog(@"%i %i",brandIdIndex,moduleIdIndex);

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
    [self autoCheckInstructionWithModuleId:[moduleIdArray[moduleIdIndex] intValue]];
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
    if (moduleIdIndex < 0 || moduleIdIndex > [moduleIdArray count]-1) {
        return;
    }
    if (moduleIdIndex == 0) {
        moduleIdIndex = [moduleIdArray count] - 1;
    } else {
        moduleIdIndex--;
    }
    brandLabel.text = brandNameArray[brandIdIndex];
    modelLabel.text = moduleNameArray[moduleIdIndex];
//    if (brandIdIndex == 0 && moduleIdIndex == 0) {
//        return;
//    }
//    if (moduleIdIndex == 0) {
//        brandIdIndex--;
//        [self findModuleNameAndIdArrayByIndex:brandIdIndex];
//        moduleIdIndex = [moduleNameArray count]-1;
//    }else{
//        moduleIdIndex--;
//    }
//    brandLabel.text = brandNameArray[brandIdIndex];
//    modelLabel.text = moduleNameArray[moduleIdIndex];
//    manualSendInstruction = YES;
}
- (IBAction)nextModule:(UIButton *)sender {
    autoCheckStop = YES;
    if (moduleIdIndex < 0 || moduleIdIndex > [moduleIdArray count]-1) {
        return;
    }
    if (moduleIdIndex >= [moduleIdArray count] - 1) {
        moduleIdIndex = 0;
    } else {
        moduleIdIndex++;
    }
    brandLabel.text = brandNameArray[brandIdIndex];
    modelLabel.text = moduleNameArray[moduleIdIndex];

//    if (brandIdIndex == [brandNameArray count] && moduleIdIndex == [moduleNameArray count]) {
//        return;
//    }
//    if (moduleIdIndex == [moduleNameArray count]-1) {
//        brandIdIndex ++;
//        [self findModuleNameAndIdArrayByIndex:brandIdIndex];
//        moduleIdIndex = 0;
//    }else{
//        moduleIdIndex++;
//    }
//    brandLabel.text = brandNameArray[brandIdIndex];
//    modelLabel.text = moduleNameArray[moduleIdIndex];
//    manualSendInstruction = YES;
}
- (IBAction)sendInstructionByUser:(UIButton *)sender {
    manualSendInstruction = YES;
    [self autoCheckInstructionWithModuleId:[moduleIdArray[moduleIdIndex] intValue]];
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
//-(void)autoCheckInstructionWithModuleId{
//    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&moduleId=%i",
//                        URL_FOR_AC_AUTO_CHECK_MODULE,self.device.tId,[timer.userInfo intValue]];
//    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"autoCheck" userDataDictionary:nil];
//    NSLog(@"%@",downloader.name);
//}
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
                        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示" contentText:@"该品牌的所有型号已匹配了 2 遍,如果空调仍没有反应,请点击[返回],切换到[自学习]进行指令学习" leftButtonTitle:nil rightButtonTitle:@"知道了"];
                        [alert show];
                    }
                }
                
//                sleep(3);//这里暂停3s进行等待，一是看空调有没有响应，二是看用户有没有按停止
//                failureTimes = 0; //一旦成功
//                if (!autoCheckStop) {
//                    if (moduleIdIndex == [moduleIdArray count]-1) {
//                        brandIdIndex++;
//                        moduleIdIndex = 0;
//                        [self findModuleNameAndIdArrayByIndex:brandIdIndex];
//                        brandLabel.text = brandNameArray[brandIdIndex];
//                        modelLabel.text = moduleNameArray[moduleIdIndex];
//                        [self autoCheckInstructionWithModuleId:[moduleIdArray[moduleIdIndex] integerValue]];
//                    }else{
//                        NSLog(@"%i",moduleIdIndex);
//                        moduleIdIndex++;
//                        NSLog(@"%i",moduleIdIndex);
//                        brandLabel.text = brandNameArray[brandIdIndex];
//                        modelLabel.text = moduleNameArray[moduleIdIndex];
//                        [self autoCheckInstructionWithModuleId:[moduleIdArray[moduleIdIndex] integerValue]];
//                    }
//                }
            }
        }else if([MyEUtil getResultFromAjaxString:string] == -3){
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
 //           [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"用户已注销登录"];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [MyEUtil showMessageOn:Nil withMessage:@"与服务器通讯失败"];
    [HUD hide:YES];
}

@end
