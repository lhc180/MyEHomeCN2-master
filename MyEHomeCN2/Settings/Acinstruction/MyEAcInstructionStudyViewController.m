//
//  MyEAcInstructionStudyViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-21.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcInstructionStudyViewController.h"
#import "MyEAcInstructionListViewController.h"

@interface MyEAcInstructionStudyViewController ()

@end

@implementation MyEAcInstructionStudyViewController
@synthesize powerBtn,modeBtn,windLevelBtn,setpointBtn,powerArray,modeArray,windLevelArray,setpointArray,jumpFromBarBtn,instruction,studyBtn,checkBtn;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life circle methods
//-(void)viewDidDisappear:(BOOL)animated{
//    MyEAcInstructionListViewController *vc = [self.navigationController childViewControllers][1];
//    vc.needToRefresh = YES;
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem.title = @"返回";
    powerArray = @[@"关",@"开"];
    modeArray = @[@"自动",@"制热",@"制冷",@"除湿",@"通风"];
    windLevelArray = @[@"自动",@"一级",@"二级",@"三级"];
    NSMutableArray *array = [NSMutableArray array];
    for (int i=18; i<31; i++) {
        [array addObject:[NSString stringWithFormat:@"%i℃",i]];
    }
    setpointArray = array;

//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [btn setFrame:CGRectMake(0, 0, 50, 30)];
//    if (!IS_IOS6) {
//        [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
//    }else{
//        [btn setBackgroundImage:[UIImage imageNamed:@"back-ios6"] forState:UIControlStateNormal];
//        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
//        btn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    }
//    [btn setTitle:@"返回" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

//    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                if (btn.tag == 100 || btn.tag == 101) {
                    btn.layer.masksToBounds = YES;
                    btn.layer.cornerRadius = 5;
                    btn.layer.borderColor = btn.tintColor.CGColor;
                    btn.layer.borderWidth = 1;
                }else{
                    [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
                }
            }
        }
//    }else{
//        for (UIButton *btn in self.view.subviews) {
//            if (btn.tag !=100 && btn.tag !=101) {
//                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
//                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn-ios6"] forState:UIControlStateNormal];
//            }
//        }
//    }
    
    if (jumpFromBarBtn) {
//#warning 这里新增一个随机数，从而使得每次新增指令时都会不一样
        /*---------------以下这几行代码是对-----------------*/
        [self getRandomNumber];
        for (MyEAcStudyInstruction *i in self.list.instructionList) {
            if (i.power == powerValue && i.mode == modeValue
                && i.windLevel == windValue && i.temperature == setpointValue) {
                [self getRandomNumber];
            }
        }
        /*---------------------------------*/
        //这里的instruction必须要初始化，否则我们无法访问到这个对象
        self.instruction = [[MyEAcStudyInstruction alloc] init];
        checkBtn.enabled = NO;
        [powerBtn setTitle:powerArray[powerValue] forState:UIControlStateNormal];
        [modeBtn setTitle:modeArray[modeValue] forState:UIControlStateNormal];
        [windLevelBtn setTitle:windLevelArray[windValue] forState:UIControlStateNormal];
        [setpointBtn setTitle:[NSString stringWithFormat:@"%i℃",[setpointArray[setpointValue] intValue]] forState:UIControlStateNormal];
    }else{
        if (instruction.status == 0) {
            checkBtn.enabled = NO;
            [studyBtn setTitle:@"学习" forState:UIControlStateNormal];
        }else{
            checkBtn.enabled = YES;
            [studyBtn setTitle:@"再学习" forState:UIControlStateNormal];
        }
        powerBtn.enabled = NO;
        modeBtn.enabled = NO;
        windLevelBtn.enabled = NO;
        setpointBtn.enabled = NO;
        [powerBtn setTitle:powerArray[instruction.power] forState:UIControlStateNormal];
        [modeBtn setTitle:modeArray[instruction.mode-1] forState:UIControlStateNormal];
        [windLevelBtn setTitle:windLevelArray[instruction.windLevel] forState:UIControlStateNormal];
        [setpointBtn setTitle:[NSString stringWithFormat:@"%li ℃",(long)instruction.temperature] forState:UIControlStateNormal];
    }
}

- (IBAction)dismissVC:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - private methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ViewAnimation:(UIView*)view willHidden:(BOOL)hidden {
    [UIView animateWithDuration:0.3 animations:^{
        if (hidden) {
            view.frame = CGRectMake(0, screenHigh, screenwidth, 260);
            //            self.tabBarController.tabBar.hidden = NO;
        } else {
            [view setHidden:hidden];
            //            self.tabBarController.tabBar.hidden = YES;
            if (IS_IOS6) {
                view.frame = CGRectMake(0, screenHigh-44-20-260, screenwidth, 260);
            }else{
                view.frame = CGRectMake(0, screenHigh-44-10-260, screenwidth, 260);
            }
        }
    } completion:^(BOOL finished) {
        [view setHidden:hidden];
    }];
    
}
-(void)getRandomNumber{ //获取随机数
    powerValue = arc4random() % 2;//模式在“开、关”之间取值
    modeValue = arc4random() % 5;
    windValue = arc4random() % 4;
    setpointValue = arc4random() % 13;
}
-(void)changeStringToIntWithPowerName:(NSString *)powerName andRunModeName:(NSString *)modeName andWindLevelName:(NSString *)windLevelName andSetpointName:(NSString *)setpointName{
    NSLog(@"%@ %@ %@ %@",powerName,modeName,windLevelName,setpointName);
    instruction.power = [powerArray indexOfObject:powerName];
    instruction.mode = [modeArray indexOfObject:modeName]+1;
    instruction.windLevel = [windLevelArray indexOfObject:windLevelName];
    instruction.temperature = [[setpointName substringToIndex:2] intValue];
//    NSLog(@"%li|%li|%li|%li",(long)instruction.power,(long)instruction.mode,(long)instruction.windLevel,(long)instruction.temperature);
}
-(void)doThisWhenNeedHUD{
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.removeFromSuperViewOnHide = YES;
    HUD.dimBackground = YES;
    HUD.userInteractionEnabled = YES;
    HUD.delegate = self;
    //初始化label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,300,50)];
    //设置自动行数与字符换行
    [label setNumberOfLines:0];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    UIFont *font = [UIFont fontWithName:@"Arial" size:12];
    label.text = @"当智控星屏幕显示Lr--时，请按下遥控器按键进行学习。";
    //设置一个行高上限
    CGSize size = CGSizeMake(320,2000);
    //计算实际frame大小，并将label的frame变成实际大小
    CGSize labelsize = [label.text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    CGRect newFrame = label.frame;
    newFrame.size.height = labelsize.height;
    label.frame = newFrame;
    [label sizeToFit];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    HUD.customView = label;
    HUD.mode = MBProgressHUDModeCustomView;
}

#pragma mark - pickerView dataSource methods 

//定制picker的view，从而是的picker的文本可以居中显示
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:0].width, [pickerView rowSizeForComponent:0].height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:20];
    //这句代码添加之后，整个视图看上去好看多了，主要是label本身是白色的背景
    label.backgroundColor = [UIColor clearColor];
    switch (pickerTag) {
        case 1:
            label.text = powerArray[row];
            break;
        case 2:
            label.text = modeArray[row];
            break;
        case 3:
            label.text = windLevelArray[row];
            break;
        default:
            label.text = [NSString stringWithFormat:@"%i ℃",[setpointArray[row] intValue]];
            break;
    }
    return label;
}

#pragma mark - pickerView delegate methods
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles{
    switch (pickerView.tag) {
        case 1:
            [powerBtn setTitle:titles[0] forState:UIControlStateNormal];
            break;
        case 2:[modeBtn setTitle:titles[0] forState:UIControlStateNormal];break;
        case 3:[windLevelBtn setTitle:titles[0] forState:UIControlStateNormal];break;
        default:
            [setpointBtn setTitle:titles[0] forState:UIControlStateNormal];
            break;
    }
}
#pragma mark - IBAction methods
- (IBAction)power:(UIButton *)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择空调状态" andDelegate:self andTag:1 andArray:powerArray andSelectRow:[powerArray indexOfObject:powerBtn.currentTitle] andViewController:self];
}

- (IBAction)mode:(UIButton *)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择空调模式" andDelegate:self andTag:2 andArray:modeArray andSelectRow:[modeArray indexOfObject:modeBtn.titleLabel.text] andViewController:self];
}

- (IBAction)windLevel:(UIButton *)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择风量大小" andDelegate:self andTag:3 andArray:windLevelArray andSelectRow:[windLevelArray indexOfObject:windLevelBtn.titleLabel.text] andViewController:self];
}

- (IBAction)setpoint:(UIButton *)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择温度大小" andDelegate:self andTag:4 andArray:setpointArray andSelectRow:[setpointArray indexOfObject:setpointBtn.currentTitle] andViewController:self];
}

- (IBAction)study:(UIButton *)sender {
    [self changeStringToIntWithPowerName:powerBtn.titleLabel.text andRunModeName:modeBtn.titleLabel.text andWindLevelName:windLevelBtn.titleLabel.text andSetpointName:setpointBtn.titleLabel.text];
    if (jumpFromBarBtn) {
//        instruction.instructionId = 0;   //这里不需要写值为0，因为int类型变量初始化时默认会将值变为0
        if (!_isAdd) {
            for (MyEAcStudyInstruction *i in self.list.instructionList) {
                if (i.power == instruction.power &&
                    i.mode == instruction.mode &&
                    i.windLevel == instruction.windLevel &&
                    i.temperature == instruction.temperature) {
                    [MyEUtil showMessageOn:nil withMessage:@"指令已存在"];
                    return;
                }
            }
        }
    }
//    if (jumpFromBarBtn) {
//        [self editInstructionToServerWithAction:1 AndId:0];
//    }else{
//        //这里这么操作也没有影响
//        [self editInstructionToServerWithAction:2 AndId:instruction.instructionId];
//    }
    [self studyInstructionToServer];
}
- (IBAction)check:(UIButton *)sender {
    NSString * urlStr= [NSString stringWithFormat:@"%@?studyId=%li",
                        URL_FOR_AC_INSTRUCTION_VALIDATE,
                        (long)instruction.instructionId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self loaderName:@"instructionValidate"
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL private Methods
-(void)editInstructionToServerWithAction:(NSInteger)action AndId:(NSInteger)instructionId{
    NSString * urlStr= [NSString stringWithFormat:@"%@?moduleId=%li&id=%li&action=%li&tId=%@&switch_=%li&runMode=%li&windLevel=%li&setpoint=%li",
                        URL_FOR_AC_INSTRUCTION_EDIT,
                        (long)self.moduleId,
                        (long)instructionId,
                        (long)action,
                        self.device.tId,
                        (long)instruction.power,
                        (long)instruction.mode,
                        (long)instruction.windLevel,
                        (long)instruction.temperature];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self loaderName:@"editInstruction"
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);

}
-(void)studyInstructionToServer{
    [self doThisWhenNeedHUD];
    NSString * urlStr= [NSString stringWithFormat:@"%@?gid=%@&id=%li&moduleId=%li&tId=%@&switch_=%li&runMode=%li&windLevel=%li&setpoint=%li",
                        URL_FOR_AC_INSTRUCTION_STUDY2,
                        self.accountData.userId,
                        (long)instruction.instructionId,
                        (long)self.moduleId,
                        self.device.tId,
                        (long)self.instruction.power,
                        (long)self.instruction.mode,
                        (long)self.instruction.windLevel,
                        (long)self.instruction.temperature];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self loaderName:@"studyInstruction"
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
-(void)queryStudayProgress
{
    studyQueryTimes ++;
    
    NSString * urlStr= [NSString stringWithFormat:@"%@?&tId=%@&studyId=%li&moduleId=%li",
                        URL_FOR_AC_INSTRUCTION_STUDY_FEEDBACK,
                        self.device.tId,
                        (long)instruction.instructionId,
                        (long)self.moduleId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self
                                 loaderName:@"queryStudayProgress"
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
    
}
-(void) sendInstructionStudyTimeout
{
//    if(HUD == nil) {
//        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        HUD.delegate = self;
//    } else
//        [HUD show:YES];
    NSString * urlStr= [NSString stringWithFormat:@"%@?tId=%@&studyId=%li",
                        URL_FOR_IR_DEVICE_SEND_STUDY_TIMEOUT,
                        self.device.tId,(long)instruction.instructionId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self
                                 loaderName:@"studyTimeOut"
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if ([name isEqualToString:@"editInstruction"]) {
        NSLog(@"editInstruction string is %@",string);
        [HUD hide:YES];
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] == 2) {
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"空调指令已存在，请重新添加"];
        }else if([MyEUtil getResultFromAjaxString:string] == -1){
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"空调指令编辑出错"];
        }else{
            //此时指令添加或者编辑成功
            if (jumpFromBarBtn) {
                [self.list.instructionList addObject:instruction];
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                NSDictionary *dic = [parser objectWithString:string];
                instruction.instructionId = [dic[@"terminalStudyId"] intValue];
                [self studyInstructionToServer];
            }else{
                [self studyInstructionToServer];
            }
        }
    }
    if([name isEqualToString:@"studyInstruction"]) {
        
        NSLog(@"downloadAcInstructionList JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [HUD hide:YES];
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] == -2) {
            [HUD hide:YES];
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"空调指令已存在，请重新添加"];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [HUD hide:YES];
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"空调指令学习时发生错误"];
        }else{
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dic = [parser objectWithString:string];
            instruction.instructionId = [dic[@"terminalStudyId"] intValue];
            studyQueryTimes = 0;
            [self queryStudayProgress];
        }
    }
    if ([name isEqualToString:@"queryStudayProgress"]) {
        NSLog(@"queryStudayProgress string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [HUD hide:YES];
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            instruction.status = 1;
            if (!_isAdd) {
                if (self.jumpFromBarBtn) {  //注意这里，当指令成功学习之后,前面的数组里面就会新增该指令
                    [self.list.instructionList addObject:instruction];
                }
            }
            _isAdd = YES;
            [HUD hide:YES];
            self.checkBtn.enabled = YES;
//  #warning 这里建议修改studyBtn的背景色，以区分学习和未学习。这里必须要以背景图片的形式处理，因为
            [self.studyBtn setTitle:@"再学习" forState:UIControlStateNormal]; //这里要更新button的title，从而让用户更为直观的明确
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"空调指令学习成功"];
        }else{
            if (studyQueryTimes < 7) {
                //这里的timer是不重复的，运行之后就自动停下来了。这种处理问题的思路跟直接一个全局timer是不同的，这里这种思路考虑的出发点就是此处有一个特征值，也就是studyQueryTimes用来处理事件变化次数
                NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(queryStudayProgress) userInfo:nil repeats:NO];
                NSLog(@"%@",timer);
            }else{
                [self sendInstructionStudyTimeout];
                [HUD hide:YES];
                [MyEUtil showMessageOn:self.navigationController.view withMessage:@"学习超时，请重试"];
            }
        }
    }
    if ([name isEqualToString:@"studyTimeOut"]) {
        NSLog(@"studyTimeOut string is %@",string);
        instruction.status = 0;
    }
    if ([name isEqualToString:@"instructionValidate"]) {
        NSLog(@"instructionValidate string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"校验指令发送失败"];
        }else{
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"校验指令发送成功"];
        }
    }
}

@end
