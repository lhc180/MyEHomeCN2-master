//
//  MyESubSwitchEditViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-14.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESubSwitchEditViewController.h"

@interface MyESubSwitchEditViewController (){
    MBProgressHUD *HUD;
    NSMutableArray *_mainSwitchList;
}

@end

@implementation MyESubSwitchEditViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    _mainSwitchList = [NSMutableArray array];
    self.lblName.text = self.subSwitch.name;
    self.lblTid.text = self.subSwitch.tid;
    self.imgSignal.image = [self.subSwitch getImage];
    self.lblMainTid.text = [self.subSwitch.mainTid isEqualToString:@""]?@"未绑定":self.subSwitch.mainTid;
    [self.tableView reloadData];
    self.navigationItem.title = self.subSwitch.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction methods
- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    if ([self.lblMainTid.text isEqualToString:@"未绑定"]) {
        [MyEUtil showMessageOn:nil withMessage:@"未指定主开关"];
        return;
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?mainTId=%@&subTId=%@",URL_FOR_SUBSWITCH_BIND,[self.lblMainTid.text isEqualToString:@"解绑"]?@"":self.lblMainTid.text,self.subSwitch.tid] postData:nil delegate:self loaderName:@"save" userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}

#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![_mainSwitchList count]) {
        return;
    }
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"选择主开关" andDelegate:self andTag:1 andArray:_mainSwitchList andSelectRow:[_mainSwitchList containsObject:self.lblMainTid.text]?[_mainSwitchList indexOfObject:self.lblMainTid.text]:0 andViewController:self];
}

#pragma mark - private methods
-(void)downloadInfoFromServer{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?tId=%@",URL_FOR_SUBSWITCH_INFO,self.subSwitch.tid] postData:nil delegate:self loaderName:@"download" userDataDictionary:nil];
    NSLog(@"loader is %@",loader.name);
}

#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"receive string is %@",string);
    if ([name isEqualToString:@"download"]) {
        NSDictionary *dic = [string JSONValue];
        if (dic[@"terminalSwitchList"]) {
            for (NSDictionary *d in dic[@"terminalSwitchList"]) {
                [_mainSwitchList addObject:d[@"TId"]];
            }
            [_mainSwitchList addObject:@"解绑"];
        }
    }
    if ([name isEqualToString:@"save"]) {
        int i = [MyEUtil getResultFromAjaxString:string];
        if (i == 1) {
            [MyEUtil showMessageOn:nil withMessage:@"关联成功"];
            self.subSwitch.mainTid = self.lblMainTid.text;
        }else if (i == 0){
            [MyEUtil showMessageOn:nil withMessage:@"传入的数据有误"];
        }else if (i == -1){
            [MyEUtil showMessageOn:nil withMessage:@"关联失败"];
        }else if (i == 2){
            [MyEUtil showMessageOn:nil withMessage:@"解绑成功"];
            self.subSwitch.mainTid = @"";
        }else
            [MyEUtil showMessageOn:nil withMessage:@"用户已断开"];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [MyEUtil showMessageOn:nil withMessage:@"与服务器连接失败"];
}
#pragma mark - IQActionSheet delegate methods
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles{
    self.lblMainTid.text = titles[0];
}
@end
