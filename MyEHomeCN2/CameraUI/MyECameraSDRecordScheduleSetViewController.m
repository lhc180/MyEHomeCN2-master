//
//  MyECameraSDRecordScheduleSetViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-25.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraSDRecordScheduleSetViewController.h"

@interface MyECameraSDRecordScheduleSetViewController (){
    NSMutableString *_scheduleStr;
    NSInteger _selectWeek; //0表示星期天,1表示星期一
    NSArray *_weeks;
}

@end

@implementation MyECameraSDRecordScheduleSetViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    _selectWeek = 0;
    _weeks = [_schedule weekArray];
    _weekLbl.text = _weeks[_selectWeek];
    [self getMainScheduleStr];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    dispatch_async(dispatch_get_main_queue(), ^{  //之所以这么做是因为当前页面是肯定不会保存的，所以退出页面时要自动保存
        [self changeStringToInt];
    });
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
-(void)getMainScheduleStr{  //获取数据，用于更新UI
    NSArray *array = @[@"sun",@"mon",@"tue",@"wed",@"thu",@"fri",@"sat"];
    _scheduleStr = [NSMutableString string];
    for (int i=0; i< 3; i++) {
        NSInteger index = [[_schedule valueForKey:[NSString stringWithFormat:@"%@_%i",array[_selectWeek],i]] intValue];
        [_scheduleStr appendString:[_schedule stringFromInt:index]];
    }
    NSLog(@"%@",_scheduleStr);
    [self.tableView reloadData];
}
-(void)changeStringToInt{  //保存所做更改
    NSArray *array = @[@"sun",@"mon",@"tue",@"wed",@"thu",@"fri",@"sat"];
    NSLog(@"%@",_scheduleStr);
    for (int i = 0; i < 3; i++) {
        NSString *str = [_scheduleStr substringWithRange:NSMakeRange(i*32, 32)];
        NSLog(@"%@",str);
        NSInteger value = [_schedule intFromString:str];
        NSLog(@"%i",value);
        [_schedule setValue:@(value) forKey:[NSString stringWithFormat:@"%@_%i",array[_selectWeek],i]];
    }
}
#pragma mark - IBAction methods
-(IBAction)lastWeekSelect:(UIButton *)sender{
    [self changeStringToInt];
    if (_selectWeek == 0) {
        _selectWeek = 6;
    }else
        _selectWeek --;   //上下两个方法一个在前一个在后，顺序不能颠倒
    _weekLbl.text = _weeks[_selectWeek];
    [self getMainScheduleStr];
}
-(IBAction)nextWeekSelect:(UIButton *)sender{
    [self changeStringToInt];
    if (_selectWeek == 6) {
        _selectWeek = 0;
    }else
        _selectWeek ++;
    _weekLbl.text = _weeks[_selectWeek];
    [self getMainScheduleStr];
}
-(IBAction)selectAll:(UIBarButtonItem *)sender{
    NSInteger value = 0;
    if ([sender.title isEqualToString:@"全选"]) {
        sender.title = @"反选";
        value = -1;
    }else
        sender.title = @"全选";
    NSArray *array = @[@"sun",@"mon",@"tue",@"wed",@"thu",@"fri",@"sat"];
    for (int i =0; i<7; i++) {
        for (int j = 0; j < 3; j++) {
            [_schedule setValue:@(value) forKey:[NSString stringWithFormat:@"%@_%i",array[i],j]];
        }
    }
    [self getMainScheduleStr];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 24;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [NSString stringWithFormat:@"%i:00~%i:00",indexPath.row,indexPath.row+1];
    NSString *str = [_scheduleStr substringWithRange:NSMakeRange(indexPath.row*4, 4)];
    if (str.intValue > 0) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *str = [_scheduleStr substringWithRange:NSMakeRange(indexPath.row*4, 4)];
    if (str.intValue > 0) {
        str = [@"0000" mutableCopy];
    }else
        str = [@"1111" mutableCopy];
    [_scheduleStr replaceCharactersInRange:NSMakeRange(indexPath.row*4, 4) withString:str];
    [tableView reloadData];
}
@end
