//
//  MyESwitchScheduleSettingViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchScheduleSettingViewController.h"
#import "MyESwitchAutoViewController.h"
@interface MyESwitchScheduleSettingViewController ()

@end

@implementation MyESwitchScheduleSettingViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSString *string = IS_IOS6?@"detailBtn-ios6":@"detailBtn";
    for (UIButton *btn in self.view.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
        }
    }

//    if (!IS_IOS6) {
//        for (UIButton *btn in self.view.subviews) {
//            if ([btn isKindOfClass:[UIButton class]]) {
//                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
//                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
//            }
//        }
//    }else{
//        for (UIButton *btn in self.view.subviews) {
//            if ([btn isKindOfClass:[UIButton class]]) {
//                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn-ios6"] forState:UIControlStateNormal];
//                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
//            }
//        }
//    }
    if (IS_IOS6) {
        self.channelSeg.layer.borderColor = MainColor.CGColor;
        self.channelSeg.layer.borderWidth = 1.0f;
        self.channelSeg.layer.cornerRadius = 4.0f;
        self.channelSeg.layer.masksToBounds = YES;
    }
    if (IS_IOS6) {
        self.weekSeg.layer.borderColor = MainColor.CGColor;
        self.weekSeg.layer.borderWidth = 1.0f;
        self.weekSeg.layer.cornerRadius = 4.0f;
        self.weekSeg.layer.masksToBounds = YES;
    }

    self.channelSeg.mydelegate = self;
    self.weekSeg.mydelegate = self;
    NSMutableArray *array1 = [NSMutableArray array];
    NSMutableArray *array2 = [NSMutableArray array];
    for (int i = 0; i < 24; i++) {
        if (i < 10) {
            [array1 addObject:[NSString stringWithFormat:@"0%i",i]];
        }else
            [array1 addObject:[NSString stringWithFormat:@"%i",i]];
    }
    for (int i = 0; i< 6; i++) {
        if (i == 0) {
            [array2 addObject:@"00"];
        }else
            [array2 addObject:[NSString stringWithFormat:@"%i",i*10]];
    }
    _headTimeArray = array1;
    _tailTimeArray = array2;

    if (self.control.numChannel == 1) {
        [self.channelSeg removeSegmentAtIndex:1 animated:YES];
        [self.channelSeg removeSegmentAtIndex:2 animated:YES];
    }else if(self.control.numChannel == 2){
        [self.channelSeg removeSegmentAtIndex:2 animated:YES];
    }
    for (int idx = 0; idx < self.control.channelDisabledStatus.count; idx++) {
        NSInteger i = [self.control.channelDisabledStatus[idx] intValue];
        if (i == 1) {
            [self.channelSeg setEnabled:NO forSegmentAtIndex:idx];
        }
    }
    _scheduleNew = [_schedule copy];
    [self.startBtn setTitle:_schedule.onTime forState:UIControlStateNormal];
    [self.endBtn setTitle:_schedule.offTime forState:UIControlStateNormal];
    [self refreshSegment];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
-(void)doThisWhenNeedDownLoadOrUploadInfoWithURLString:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    NSLog(@"%@ string is %@",name,url);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@ is %@",name,loader.name);
}
-(void)uploadInfoToServer{
    _scheduleNew.runFlag = 1;   //保存的时候进程的启用状态肯定为1，不能为0
    // 估计这里会有问题，因为数组没有转变为字符串(特别注意这里是怎么样转化为字符串的)
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li&scheduleId=%li&onTime=%@&offTime=%@&channels=%@&weeks=%@&runFlag=%i&action=%li",
                                                           URL_FOR_SWITCH_SCHEDULE_SAVE,
                                                           (long)self.device.deviceId,
                                                           (long)_scheduleNew.scheduleId,
                                                           _scheduleNew.onTime,
                                                           _scheduleNew.offTime,
                                                           [_scheduleNew.channels componentsJoinedByString:@","],
                                                           [_scheduleNew.weeks componentsJoinedByString:@","],
                                                           _scheduleNew.runFlag,
                                                           (long)self.actionType] andName:@"scheduleEdit"];
}
-(NSMutableArray *)changeIndexSetToArrayWithIndexSet:(NSIndexSet *)indexSet{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = [indexSet firstIndex];i != NSNotFound; i = [indexSet indexGreaterThanIndex: i])  {
        [array addObject:[NSNumber numberWithInteger:i+1]];
    }
    return array;
}
-(BOOL)isValid{  //用于判断时段和星期是否符合要求
    NSInteger onTime = [MyEUtil hhidForTimeString:_scheduleNew.onTime];
    NSInteger offTime = [MyEUtil hhidForTimeString:_scheduleNew.offTime];
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.control.SSList];
    if (self.actionType == 2) {  //只有编辑的时候才这么做
        [array removeObject:self.schedule];
    }
    for (MyESwitchSchedule *s in array) {
        NSInteger onTime1 = [MyEUtil hhidForTimeString:s.onTime];
        NSInteger offTime1 = [MyEUtil hhidForTimeString:s.offTime];
        if(onTime >= offTime1 || offTime <= onTime1){
            continue;
        }else{
            for (NSNumber *i in _scheduleNew.weeks) {
                if ([s.weeks containsObject:i]) {
                    for (NSNumber *i in _scheduleNew.channels){
                        if([s.channels containsObject:i]){
                            return NO;
                        }
                    }
                }
            }
        }
    }
    return YES;
}
-(BOOL)isTimeUsefull{
    NSMutableString *startString = [NSMutableString stringWithString:self.startBtn.currentTitle];
    NSMutableString *endString = [NSMutableString stringWithString:self.endBtn.currentTitle];
    NSInteger startTime = [[startString stringByReplacingCharactersInRange:NSMakeRange(2, 1) withString:@"0"] intValue];
    NSInteger endTime = [[endString stringByReplacingCharactersInRange:NSMakeRange(2, 1) withString:@"0"] intValue];
    if (startTime >= endTime) {
        return NO;
    }
    return YES;
}
//-(void)changeBtnTitleWithIndex:(NSInteger)tag{
//    NSInteger onTime = [MyEUtil hhidForTimeString:self.startBtn.currentTitle];
//    NSInteger offTime = [MyEUtil hhidForTimeString:self.endBtn.currentTitle];
//    if ((offTime - onTime) <= 0) {
//        if (tag == 1) {
//            [self.endBtn setTitle:[MyEUtil timeStringForHhid:onTime+1] forState:UIControlStateNormal];
//        }else
//            [self.startBtn setTitle:[MyEUtil timeStringForHhid:offTime-1] forState:UIControlStateNormal];
//    }
//    if (self.actionType == 2) {
//        [self changeBarBtnEnable];
//    }
//}
-(void)refreshSegment{
    NSMutableIndexSet *channelIndex = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *weekIndex = [NSMutableIndexSet indexSet];
    for (NSNumber *i in _schedule.channels) {
        [channelIndex addIndex:[i intValue]-1];
    }
    for (NSNumber *i in _schedule.weeks) {
        [weekIndex addIndex:[i intValue]-1];
    }
    [self.channelSeg setSelectedSegmentIndexes:channelIndex];
    [self.weekSeg setSelectedSegmentIndexes:weekIndex];
}
-(NSArray *)changeStringToInt:(NSString *)title{
    NSArray *array = [NSArray array];
    if (title.length !=5) {
//        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告" contentText:@"time is off" leftButtonTitle:nil rightButtonTitle:@"OK"];
//        [alert show];
        array = @[@1,@1];
    }else{
        NSInteger i = [_headTimeArray indexOfObject:[title substringToIndex:2]];
        NSInteger j = [_tailTimeArray indexOfObject:[title substringFromIndex:3]];
        array = @[@(i),@(j)];
    }
    return array;
}

#pragma mark - IBAction methods
- (IBAction)startBtnPressed:(UIButton *)sender{
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择开始时间" andDelegate:self andTag:1 andArray:@[_headTimeArray,_tailTimeArray] andSelectRows:[self changeStringToInt:sender.currentTitle] andViewController:self];
}
- (IBAction)endBtnPressed:(UIButton *)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择结束时间" andDelegate:self andTag:2 andArray:@[_headTimeArray,_tailTimeArray] andSelectRows:[self changeStringToInt:sender.currentTitle] andViewController:self];
}
- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    if (![self isTimeUsefull]) {
        [MyEUtil showMessageOn:nil withMessage:@"开始时间必须小于结束时间"];
        return;
    }
    _scheduleNew.onTime = self.startBtn.currentTitle;
    _scheduleNew.offTime = self.endBtn.currentTitle;
    _scheduleNew.channels = [self changeIndexSetToArrayWithIndexSet:self.channelSeg.selectedSegmentIndexes];
    _scheduleNew.weeks = [self changeIndexSetToArrayWithIndexSet:self.weekSeg.selectedSegmentIndexes];
    if ([_scheduleNew.channels count] == 0) {
        [MyEUtil showMessageOn:nil withMessage:@"没有选择开关路数"];
        return;
    }
    if ([_scheduleNew.weeks count] == 0) {
        [MyEUtil showMessageOn:nil withMessage:@"没有指定星期"];
        return;
    }
    if (![self isValid]) {
        [MyEUtil showMessageOn:nil withMessage:@"时段重叠,已存在相似时段"];
        return;
    }
    if (self.actionType == 1) {
        _scheduleNew.scheduleId = 0;
    }
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li&channels=%@&action=2",URL_FOR_SWITCH_TIME_DELAY,(long)self.device.deviceId,[_scheduleNew.channels componentsJoinedByString:@","]] andName:@"check"];
}

#pragma mark - MultiSelectSegmentedControlDelegate methods
-(void)multiSelect:(MultiSelectSegmentedControl*) multiSelecSegmendedControl didChangeValue:(BOOL) value atIndex: (NSUInteger) index{

    NSIndexSet *anIndexSet;
    if (multiSelecSegmendedControl == self.channelSeg) {
        anIndexSet = self.channelSeg.selectedSegmentIndexes;
    }else
        anIndexSet = self.weekSeg.selectedSegmentIndexes;
    
    if ([anIndexSet count] == 0) {
        [MyEUtil showMessageOn:self.view withMessage:multiSelecSegmendedControl == self.channelSeg?@"必须指定开关路数":@"必须指定星期"];
    }
}
#pragma mark - IQActionSheetPickerView delegate methods
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles{
    //这里本来应该添加内容，当一个btn的title选定时，另外一个btn的title自动增加，出于程序简单的目的，这里就不做了，只是在用户点击保存的时候进行了判断，
    if (pickerView.tag == 1) {
        [self.startBtn setTitle:[titles componentsJoinedByString:@":"] forState:UIControlStateNormal];
    }else{
        [self.endBtn setTitle:[titles componentsJoinedByString:@":"] forState:UIControlStateNormal];
    }
}
#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if ([name isEqualToString:@"check"]) {
        NSLog(@"check string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 2) {
            [self uploadInfoToServer];
        }
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前开关路数已经开启了延时控制,确定保存此定时设置吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 100;
            [alert show];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:@"获取数据失败"];
        }
    }
    if ([name isEqualToString:@"scheduleEdit"]) {
        NSLog(@"scheduleEdit string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            if (self.actionType == 1) {
                MyESwitchSchedule *schedule = [[MyESwitchSchedule alloc] initWithString:string];
                _scheduleNew.scheduleId = schedule.scheduleId;
                [self.control.SSList addObject:_scheduleNew];
            }else{
                if ([self.control.SSList containsObject:_schedule]) {
                    NSInteger i = [self.control.SSList indexOfObject:_schedule];
                    [self.control.SSList removeObject:_schedule];
                    [self.control.SSList insertObject:_scheduleNew atIndex:i];
                }
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -506) {
            [MyEUtil showMessageOn:nil withMessage:@"时段已存在,请修改后重试"];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:[NSString stringWithFormat:self.actionType == 1?@"新增时段时发生错误":@"编辑时段时发生错误"]];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [MyEUtil showMessageOn:nil withMessage:@"与服务器通讯失败"];
}

#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        //这里也要进行手动控制面板的刷新
        UINavigationController *nav = self.tabBarController.childViewControllers[0];
        MyESwitchManualControlViewController *vc = nav.childViewControllers[0];
        vc.needRefresh = YES;
        [self uploadInfoToServer];
    }
}
@end
