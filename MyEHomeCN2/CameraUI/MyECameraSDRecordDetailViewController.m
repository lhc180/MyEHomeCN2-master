//
//  MyECameraSDRecordDetailViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-22.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraSDRecordDetailViewController.h"
#import "MyECameraLandscapeViewController.h"
@interface MyECameraSDRecordDetailViewController (){
    NSArray *_data;
    MyECameraSDRecordDetailViewController *_vc;
    UIImageView *_playImage;
    BOOL _willAppear;
}

@end
#define deg2rad (M_PI/180.0)

@implementation MyECameraSDRecordDetailViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = _dic.allKeys[0];
    _data = _dic[_dic.allKeys[0]];
    _willAppear = YES;
}
//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:YES];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
//    
//    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
//        // iOS 7
//        [self prefersStatusBarHidden];
//        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
//    }
//}
//- (BOOL)prefersStatusBarHidden{
//    if (_willAppear) {
//        return NO;
//    }else
//        return YES;//隐藏为YES，显示为NO
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MyECameraRecord *record = _data[indexPath.row];
    cell.detailTextLabel.text = [record getTime];
    return cell;
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyECameraRecord *record = _data[indexPath.row];
    MyECameraLandscapeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"landscape"];
    vc.camera = _camera;
    vc.record = record;
    vc.m_PPPPChannelMgt = _m_PPPPChannelMgt;
    vc.actionType = 2;
    vc.recordArray = _data;
    vc.modalPresentationStyle = UIModalPresentationNone;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
}
@end
