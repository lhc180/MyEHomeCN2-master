//
//  MYESettingsMediatorAddViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/24.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYESettingsMediatorAddViewController.h"
#import "MyEQRScanViewController.h"

@interface MYESettingsMediatorAddViewController ()<MyEDataLoaderDelegate,MyEQRScanViewControllerDelegate>{
    MBProgressHUD *HUD;
    MyEMediator *_mediatorNew;
}
@property (weak, nonatomic) IBOutlet WTReTextField *txtMid;
@property (weak, nonatomic) IBOutlet UITextField *txtPin;

@end

@implementation MYESettingsMediatorAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新增网关";
    self.txtMid.pattern = @"^([0-9a-fA-F]{2}(?:-)){7}[0-9a-fA-F]{2}$";
    if (!IS_IOS6) {
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    _mediatorNew = [[MyEMediator alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - private methods
-(void)bindMediatorToServer{
    [self.txtMid resignFirstResponder];
    if (self.txtMid.text.length < 23) {
        [MyEUtil showMessageOn:nil withMessage:@"MID格式错误"];
        return;
    }
    if (self.txtPin.text.length < 6) {
        [MyEUtil showMessageOn:nil withMessage:@"PIN码错误"];
        return;
    }
    _mediatorNew.mid = self.txtMid.text;
    _mediatorNew.pin = self.txtPin.text;
    
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&action=1&mId=%@&pin=%@",GetRequst(URL_FOR_SETTINGS_BIND_MEDIATOR),MainDelegate.accountData.userId,_mediatorNew.mid,_mediatorNew.pin];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsBindMedatorUploader" userDataDictionary:nil];
    NSLog(@"SettingsBindMedatorUploader is %@",loader.name);
}
#pragma mark - Table view delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self bindMediatorToServer];
        }else{
            UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"QRNav"];
            UIViewController *vc = nav.childViewControllers[0];
            [vc setValue:self forKey:@"delegate"];
            [vc setValue:@(NO) forKey:@"isAddCamera"];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
}
#pragma mark - MYEQRScanViewControl Delegate
-(void)passMID:(NSString *)mid andPIN:(NSString *)pin{
    self.txtMid.text = mid;
    self.txtPin.text = pin;
    [self bindMediatorToServer];
}
#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"%@",string);
    [HUD hide:YES];
    NSInteger i = [MyEUtil getResultFromAjaxString:string];
    if (i == -3 ) {
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
        return;
    }
    if (i == 1) {
        [MainDelegate.accountData.mediators addObject:_mediatorNew];
        [self.navigationController popViewControllerAnimated:YES];
    }else if (i == -2){
        [MyEUtil showMessageOn:nil withMessage:@"网关已注册"];
    }else if (i == -4){
        [MyEUtil showMessageOn:nil withMessage:@"当前用户已经绑定该网关"];
    }else{
        [MyEUtil showMessageOn:nil withMessage:@"网关绑定失败"];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [MyEUtil showMessageOn:nil withMessage:@"与服务器连接失败"];
}
@end
