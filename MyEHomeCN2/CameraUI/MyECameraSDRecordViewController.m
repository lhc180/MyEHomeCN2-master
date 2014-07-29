//
//  MyECameraSDRecordViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-22.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraSDRecordViewController.h"
#import "MyECameraSDRecordDetailViewController.h"
@interface MyECameraSDRecordViewController (){
    NSMutableArray *_allRecords,*_data;
    NSTimer *_timer;
    MBProgressHUD *HUD;
}

@end

@implementation MyECameraSDRecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    _allRecords = [NSMutableArray array];
    _data = [NSMutableArray array];
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    _m_PPPPChannelMgt->SetSDCardSearchDelegate((char*)[_camera.UID UTF8String], self);
    _m_PPPPChannelMgt->PPPPGetSDCardRecordFileList((char*)[_camera.UID UTF8String], 0, 0);
    _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(getMainData) userInfo:nil repeats:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods
-(void)getMainData{
    [HUD hide:YES];
    NSMutableArray *array = [NSMutableArray array];
    for (MyECameraRecord *r in _allRecords) {
        NSString *headString = [r.name substringToIndex:8];
//        NSLog(@"%@",headString);
        if (![array containsObject:headString]) {
            [array addObject:headString];
        }
    }
    for (NSString *s in array) {
        NSMutableArray *value = [NSMutableArray array];
        for (MyECameraRecord *r in _allRecords) {
            if ([r.name hasPrefix:s]) {
                [value addObject:r];
            }
        }
        [_data addObject:@{s: value}];
    }
//    NSLog(@"%@",_data);
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dic = _data[indexPath.row];
    NSString *str = dic.allKeys[0];
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@-%@",[str substringWithRange:NSMakeRange(0, 4)],[str substringWithRange:NSMakeRange(4, 2)],[str substringWithRange:NSMakeRange(6, 2)]];
    NSArray *array = dic[str];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i",array.count];
    return cell;
}
#pragma mark - SDCard delegate
-(void)SDCardRecordFileSearchResult:(NSString *)strFileName fileSize:(NSInteger)fileSize bEnd:(BOOL)bEnd{
    NSLog(@"fileName: %@ filesize: %i end:%@",strFileName,fileSize,bEnd?@"YES":@"NO");
    MyECameraRecord *record = [[MyECameraRecord alloc] init];
    record.name = strFileName;
    record.fileSize = fileSize;
    record.bEnd = bEnd;
    [_allRecords addObject:record];
}

#pragma mark - UINavigation methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MyECameraSDRecordDetailViewController *vc = segue.destinationViewController;
    NSDictionary *dic = _data[[self.tableView indexPathForCell:sender].row];
    vc.dic = dic;
    vc.camera = _camera;
    vc.m_PPPPChannelMgt = _m_PPPPChannelMgt;
}
@end
