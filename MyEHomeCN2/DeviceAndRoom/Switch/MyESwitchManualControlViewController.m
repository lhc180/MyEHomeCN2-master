//
//  MyESwitchManualControlViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-24.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchManualControlViewController.h"

@implementation MyESwitchManualControlViewController

-(void)viewDidLoad{
//    [(UICollectionView *)self.view.subviews[0] setDelaysContentTouches:NO];
    self.collectionView.delaysContentTouches = NO;
    [self downloadInfo];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(downloadInfo) userInfo:nil repeats:YES];
//    _UIArray = [NSMutableArray array];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self downloadInfo];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    if (_timer.isValid) {
        [_timer invalidate];
    }
}
#pragma mark - private methods
-(void)downloadInfo{
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li",URL_FOR_SWITCH_FIND_SWITCH_CHANNERL,(long)self.device.deviceId] andName:@"dowmloadChannelInfo" andDictionary:nil];
}
-(void)doThisWhenNeedDownLoadOrUploadInfoWithURLString:(NSString *)url andName:(NSString *)name andDictionary:(NSDictionary *)dic{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    NSLog(@"%@ string is %@",name,url);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:dic];
    NSLog(@"%@ is %@",name,loader.name);
}
-(void)setDelayTimeWithStatus:(MyESwitchChannelStatus *)status{
    //#warning 这里是精简至极的MZFormSheetController用法
    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"timeDelay"];
    MyEDelayTimeSetViewController *vc = nav.childViewControllers[0];
    MZFormSheetController *formsheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(260, 294) viewController:nav];
//    vc.delegate = self;
    vc.index = _selectedIndex;
    vc.status = status;
    vc.control = self.control;
    vc.device = self.device;
    formsheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController){
        if (vc.selectedBtnIndex == 100) {  //说明是从确定按钮过来的
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:_selectedIndex];
            UIButton *btn = (UIButton *)[cell viewWithTag:102];
            UILabel *delayTimeLabel = (UILabel *)[cell viewWithTag:103];
            UILabel *remainTimeLabel = (UILabel *)[cell viewWithTag:104];
            delayTimeLabel.text = [NSString stringWithFormat:@"时长:%i分钟",status.delayMinute];
            remainTimeLabel.text = [NSString stringWithFormat:@"剩余:%i分钟",status.delayMinute];
            delayTimeLabel.hidden = NO;
            remainTimeLabel.hidden = NO;
            btn.selected = NO;
            UINavigationController *nav = self.tabBarController.childViewControllers[1];
            MyESwitchAutoViewController *vc = nav.childViewControllers[0];
            vc.needRefresh = YES;

            if (status.switchStatus == 1) {
//                status.timerValue = status.delayMinute*60+60;
//                status.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCount:) userInfo:_UIArray[_selectedIndex.row] repeats:YES];
            }else
                remainTimeLabel.text = [NSString stringWithFormat:@"剩余:0分钟"];
//            [self.collectionView reloadData];  //这里不能够刷新数据，否则容易造成数据上的错误
        }
    };
    
    [formsheet presentAnimated:YES completionHandler:nil];
}
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//-(void)timeCount:(NSTimer *)timer{
//    UIButton *switchBtn = (UIButton *)timer.userInfo[0];
//    UILabel *remainTimeLabel = (UILabel *)timer.userInfo[1];
//    MyESwitchChannelStatus *status = self.control.SCList[[_UIArray indexOfObject:timer.userInfo]];
//    if (status.timerValue <= 0) {
//        [timer invalidate];
//        status.switchStatus = 0;
//        switchBtn.selected = YES;
//        remainTimeLabel.text = @"剩余:0分钟";
//    }else{
//        status.timerValue --;
//        remainTimeLabel.text = [NSString stringWithFormat:@"剩余:%i分钟",(int)status.timerValue/60];
//    }
//}
#pragma mark - collectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.control.SCList count];  //这里就是按照有多少通道就新建多少item，没有将数据写死，有助于以后的修改
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    MyESwitchChannelStatus *status = self.control.SCList[indexPath.row];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    UIButton *switchBtn = (UIButton *)[cell viewWithTag:101];
    UIButton *timeBtn = (UIButton *)[cell viewWithTag:102];
    UILabel *delayTimeLabel = (UILabel *)[cell viewWithTag:103];
    UILabel *remainTimeLabel = (UILabel *)[cell viewWithTag:104];
    if (status.disable) {
        titleLabel.textColor = [UIColor lightGrayColor];
        switchBtn.enabled = NO;
        timeBtn.enabled = NO;
    }
//    [_UIArray addObject:@[switchBtn,remainTimeLabel]];
    titleLabel.text = [NSString stringWithFormat:@"通道%li",(long)indexPath.row+1];
    if (status.switchStatus == 1) {
        switchBtn.selected = NO;
        if (status.delayStatus == 1) {
            timeBtn.selected = NO;
            delayTimeLabel.hidden = NO;
            remainTimeLabel.hidden = NO;
            delayTimeLabel.text = [NSString stringWithFormat:@"时长:%li分钟",(long)status.delayMinute];
            remainTimeLabel.text = [NSString stringWithFormat:@"剩余:%li分钟",(long)status.remainMinute];
//            status.timerValue = status.remainMinute*60;
//            status.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCount:) userInfo:_UIArray[indexPath.row] repeats:YES];
        }else{
            timeBtn.selected = YES;
            delayTimeLabel.hidden = YES;
            remainTimeLabel.hidden = YES;
        }
    }else{
        switchBtn.selected = YES;
        if (status.delayStatus == 1) {
            timeBtn.selected = NO;
            delayTimeLabel.hidden = NO;
            remainTimeLabel.hidden = NO;
            delayTimeLabel.text = [NSString stringWithFormat:@"时长:%li分钟",(long)status.delayMinute];
            remainTimeLabel.text = [NSString stringWithFormat:@"剩余:0分钟"];
        }else{
            timeBtn.selected = YES;
            delayTimeLabel.hidden = YES;
            remainTimeLabel.hidden = YES;
        }
    }
    return cell;
}
#pragma mark - IBActionMethods
- (IBAction)switchControl:(UIButton *)sender {
    UICollectionViewCell *cell = (UICollectionViewCell *)sender.superview.superview;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];   //这里有两个方法来指定当前的collectionView
//    NSIndexPath *indexPath = [(UICollectionView *)self.view.subviews[0] indexPathForCell:cell];
    MyESwitchChannelStatus *status = self.control.SCList[indexPath.row];
    _selectedIndex = indexPath;
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?id=%li&switchStatus=%li&action=2",URL_FOR_SWITCH_CONTROL,(long)status.channelId,1-(long)status.switchStatus] andName:@"controlSwitch" andDictionary:@{@"button": sender,@"status":status}];
}
- (IBAction)timeControl:(UIButton *)sender {
    UICollectionViewCell *cell = (UICollectionViewCell *)sender.superview.superview;
//    NSIndexPath *indexPath = [(UICollectionView *)self.view.subviews[0] indexPathForCell:cell];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    MyESwitchChannelStatus *status = self.control.SCList[indexPath.row];
    if (!sender.selected) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示" contentText:@"确认关闭该通道的延时设置么?" leftButtonTitle:@"取消" rightButtonTitle:@"确定"];
        alert.rightBlock = ^{
            UILabel *delayTimeLabel = (UILabel *)[cell viewWithTag:103];
            UILabel *remainTimeLabel = (UILabel *)[cell viewWithTag:104];
            delayTimeLabel.hidden = YES;
            remainTimeLabel.hidden = YES;
            sender.selected = YES;
            status.delayStatus = 0;
            [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?allChannel=%@",URL_FOR_SWITCH_TIME_DELAY_SAVE,[[MyESwitchChannelStatus alloc] jsonStringWithStatus:status]] andName:@"powerOffDelayTime" andDictionary:nil];
        };
        [alert show];
        return;
    }
    _selectedIndex = indexPath;
    [self setDelayTimeWithStatus:status];
}
- (IBAction)refreshData:(UIBarButtonItem *)sender {
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li",URL_FOR_SWITCH_FIND_SWITCH_CHANNERL,(long)self.device.deviceId] andName:@"dowmloadChannelInfo" andDictionary:nil];
}

#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if ([name isEqualToString:@"dowmloadChannelInfo"]) {
        NSLog(@"dowmloadChannelInfo string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            MyESwitchManualControl *control = [[MyESwitchManualControl alloc] initWithString:string];
            self.control = control;
            //这里这么做是为了能够将数据保持一致,这里也不是必需这么写的
            NSMutableArray *array = [NSMutableArray array];
            for(MyESwitchChannelStatus *status in control.SCList){
                [array addObject:@(status.switchStatus)];
            }
            self.device.status.switchStatus = [NSMutableString stringWithString:[array componentsJoinedByString:@""]];
            [self.collectionView reloadData];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:nil withMessage:@"下载数据时发生错误"];
        }
    }
    if ([name isEqualToString:@"controlSwitch"]) {
        NSLog(@"controlSwitch string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            UIButton *btn = (UIButton *)dict[@"button"];
            btn.selected = !btn.selected;
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:_selectedIndex];
            UILabel *label = (UILabel *)[cell viewWithTag:104];
            MyESwitchChannelStatus *status = (MyESwitchChannelStatus *)dict[@"status"];
            status.switchStatus = 1 - status.switchStatus;
            if (status.switchStatus == 1) {
                if (status.delayStatus == 1) {
                    label.text = [NSString stringWithFormat:@"剩余:%i分钟",status.delayMinute];
//                    status.timerValue = status.delayMinute*60+60;
//                    status.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCount:) userInfo:_UIArray[_selectedIndex.row] repeats:YES];
                }
            }else{
//                [status.timer invalidate];
                label.text = [NSString stringWithFormat:@"剩余:0分钟"];
            }
            //下面这三句代码主要是为了更改switch在device列表中的状态，这样做的好处就是不需要刷新数据，就可以实时更改开关的状态了
            NSInteger i = [self.control.SCList indexOfObject:status];
            [self.device.status.switchStatus replaceCharactersInRange:NSMakeRange(i, 1)withString:[NSString stringWithFormat:@"%i",status.switchStatus]];

        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:@"开关控制失败"];
        }
    }
    if ([name isEqualToString:@"powerOffDelayTime"]) {
        NSLog(@"powerOffDelayTime string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == 0) {
            [MyEUtil showMessageOn:nil withMessage:@"传入的数据有问题"];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:@"与服务器通讯失败"];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [MyEUtil showMessageOn:nil withMessage:@"与服务器通讯失败"];
}
@end
