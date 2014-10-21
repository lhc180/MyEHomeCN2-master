//
//  MyESwitchElecInfoViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchElecInfoViewController.h"
#import "EColumnDataModel.h"
#import "EColumnChartLabel.h"
#import "EFloatBox.h"
#import "EColor.h"
#include <stdlib.h>

@interface MyESwitchElecInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTips;

@end

@implementation MyESwitchElecInfoViewController
@synthesize device;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self downloadElecInfoFromServer];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (IS_IOS6) {
        self.dateSegment.layer.borderColor = MainColor.CGColor;
        self.dateSegment.layer.borderWidth = 1.0f;
        self.dateSegment.layer.cornerRadius = 4.0f;
        self.dateSegment.layer.masksToBounds = YES;
    }
    if (IS_IPAD) {
        self.lblTips.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)changeDate:(id)sender {
    [self downloadElecInfoFromServer];
}

#pragma mark - private methods
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)defineGestureWith:(EColumnChart *)eco{
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [eco addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [eco addGestureRecognizer:recognizer];
}
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        if (self.eColumnChart == nil) return;
        [self.eColumnChart moveRight];
    }
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        if (self.eColumnChart == nil) return;
        [self.eColumnChart moveLeft];
    }
    
}
-(void)doThisToChangeChart{
    [_eColumnChart removeFromSuperview];
    _eColumnChart = nil;
    if (IS_IPAD) {
        _eColumnChart = [[EColumnChart alloc] initWithFrame:CGRectMake(100, 99, screenwidth - 125, screenHigh - 99 - 20 - 44 -20-44-20-20)];
    }else
        _eColumnChart = [[EColumnChart alloc] initWithFrame:CGRectMake(40, 99, screenwidth - 50, screenHigh - 99 - 20 - 44 -20-44-20)];
//    _eColumnChart = [[EColumnChart alloc] initWithFrame:CGRectMake(40, 140, 270, 200)];
    [_eColumnChart setColumnsIndexStartFromLeft:YES];
    [_eColumnChart setDataSource:self];
    [_eColumnChart setShowHighAndLowColumnWithColor:YES];
    [self.view addSubview:_eColumnChart];
    [self defineGestureWith:_eColumnChart];
}
-(void)downloadElecInfoFromServer{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    [HUD show:YES];
    NSString *str = [NSString stringWithFormat:@"%@?deviceId=%li&action=%i",GetRequst(URL_FOR_SWITCH_ELECT_STATUS),(long)self.device.deviceId,self.dateSegment.selectedSegmentIndex+1];
    NSLog(@"download elec string is %@",str);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:str postData:nil delegate:self loaderName:@"downloadElecInfo" userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}
#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"downloadElecInfo string is %@",string);
    if ([MyEUtil getResultFromAjaxString:string] == 1) {
        MyESwitchElec *elct = [[MyESwitchElec alloc] initWithString:string];
        
        NSMutableArray *temp = [NSMutableArray array];
        NSString *str;
        for (int i = 0; i < [elct.powerRecordList count]; i++)
        {
            MyESwitchElecStatus *status = elct.powerRecordList[i];
            switch (self.dateSegment.selectedSegmentIndex+1) {
                case 1:
                    str = status.date;
                    break;
                case 2:
                    str = status.week;
                    break;
                default:
                    str = status.month;
                    break;
            }
            EColumnDataModel *eColumnDataModel = [[EColumnDataModel alloc] initWithLabel:str value:status.totalPower/1000 index:i unit:@"kWh"];
            [temp addObject:eColumnDataModel];
        }
        _data = [NSArray arrayWithArray:temp];
//        for (EColumnDataModel *dataModel in _data)
//        {
//            NSLog(@"%@   %f   %i   %@",dataModel.label,dataModel.value,dataModel.index,dataModel.unit);
//        }
        [self doThisToChangeChart];
        //这里说明了小数点后保留几位有效数字
//        self.currentLabel.text = [NSString stringWithFormat:@"%0.2f瓦",elct.currentPower*220];
//        self.totalLabel.text = [NSString stringWithFormat:@"%0.2f度",elct.totalPower/1000];
    }
    if ([MyEUtil getResultFromAjaxString:string] == -3) {
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
    }
    if ([MyEUtil getResultFromAjaxString:string] != 1) {
        [MyEUtil showMessageOn:nil withMessage:@"下载数据发生错误"];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [MyEUtil showMessageOn:nil withMessage:@"与服务器连接失败"];
}
#pragma -mark- EColumnChartDataSource

- (NSInteger)numberOfColumnsInEColumnChart:(EColumnChart *)eColumnChart
{
    return [_data count];
}

- (NSInteger)numberOfColumnsPresentedEveryTime:(EColumnChart *)eColumnChart
{
    return IS_IPAD?12:6;
}

- (EColumnDataModel *)highestValueEColumnChart:(EColumnChart *)eColumnChart
{
    EColumnDataModel *maxDataModel = nil;
    float maxValue = -FLT_MIN;
    for (EColumnDataModel *dataModel in _data)
    {
        if (dataModel.value > maxValue)
        {
            maxValue = dataModel.value;
            maxDataModel = dataModel;
        }
    }
    return maxDataModel;
}

- (EColumnDataModel *)eColumnChart:(EColumnChart *)eColumnChart valueForIndex:(NSInteger)index
{
    if (index >= [_data count] || index < 0) return nil;
    return [_data objectAtIndex:index];
}

@end
