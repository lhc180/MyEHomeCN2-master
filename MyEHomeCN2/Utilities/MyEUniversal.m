//
//  MyEUniversal.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-2-14.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyEUniversal.h"
#import "IQActionSheetPickerView.h"
#import "DXAlertView.h"

@implementation MyEUniversal

+(void)doThisWhenNeedPickerWithTitle:(NSString *)title andDelegate:(id<UIActionSheetDelegate>)delegate andTag:(NSInteger)tag andArray:(NSArray*)array andSelectRow:(NSInteger)row andViewController:(UIViewController *)vc{
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:nil delegate:delegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    [picker setTag:tag];
    [picker setTitlesForComponenets:@[array]];
    /*--------这里定制titleLbel来显示当前picker的title---------*/
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 44)];
    titleLable.text = title;
    titleLable.textColor = [UIColor whiteColor];
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    [picker.actionToolbar addSubview:titleLable];
    /*------------------------------------------------------*/
    [picker.pickerView selectRow:row inComponent:0 animated:YES];
    [picker showInView:vc.view];
}
+(void)doThisWhenNeedPickerWithTitle:(NSString *)title andDelegate:(id<UIActionSheetDelegate>)delegate andTag:(NSInteger)tag andArray:(NSArray*)array andSelectRows:(NSArray *)row andViewController:(UIViewController *)vc{
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:nil delegate:delegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    [picker setTag:tag];
    [picker setTitlesForComponenets:array];
    /*--------这里定制titleLbel来显示当前picker的title---------*/
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 44)];
    titleLable.text = title;
    titleLable.textColor = [UIColor whiteColor];
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    [picker.actionToolbar addSubview:titleLable];
    /*------------------------------------------------------*/
    if ([array count] >1) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 8, 40)];
        label.center = CGPointMake(picker.pickerView.center.x, picker.pickerView.center.y-44);
        label.text = @":";
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textAlignment = NSTextAlignmentCenter;
        //    NSLog(@"%f%f%f%f",label.frame.origin.x,label.frame.origin.y,label.frame.size.width,label.frame.size.height);
        //    NSLog(@"%f%f%f%f",picker.pickerView.frame.origin.x,picker.pickerView.frame.origin.y,picker.pickerView.frame.size.width,picker.pickerView.frame.size.height);
        [picker.pickerView addSubview:label];
    }
    [picker.pickerView selectRow:[row[0] intValue] inComponent:0 animated:YES];
    
    if ([row count] > 1) {
        [picker.pickerView selectRow:[row[1] intValue] inComponent:1 animated:YES];
    }
    
    [picker showInView:vc.view];
}

+(void)doThisWhenUserLogOutWithVC:(UIViewController*)vc{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示" contentText:@"检测到此次会话超时，需要重新登录" leftButtonTitle:nil rightButtonTitle:@"确定"];
    alert.rightBlock = ^{
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MyELoginViewController *login = [story instantiateViewControllerWithIdentifier:IS_IPAD?@"loginForIPad":@"LoginViewController"];
        //这里
        [vc presentViewController:login animated:YES completion:nil];
    };
    [alert show];
}
+(void)doThisToCloseKeyboardWithVC:(UIViewController *)vc{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(hideKeyboard:)];
    tapGesture.cancelsTouchesInView = NO;
    if ([vc isKindOfClass:[UITableViewController class]]) {
    }else
        [vc.view addGestureRecognizer:tapGesture];
}
-(void)hideKeyboard:(UITapGestureRecognizer *)recognizer{
    for (UITextField *t in recognizer.view.subviews) {
        if ([t isKindOfClass:[UITextField class]]) {
            [t endEditing:YES];
        }
    }
}
+(void)dothisWhenTableViewIsEmptyWithMessage:(NSString *)message andFrame:(CGRect)frame andVC:(UIViewController *)vc{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.tag = 999;
    label.text = message;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont systemFontOfSize:13];
    label.numberOfLines = 0;
    //这里要针对UITableViewController和普通VC进行区别待遇
    if ([vc isKindOfClass:[UITableViewController class]]) {
        UITableViewController *table = (UITableViewController *)vc;
        if (![table.tableView.subviews containsObject:(UILabel *)[table.tableView viewWithTag:999]]) {
            [table.tableView addSubview:label];
        }
    }else{
        label.center = vc.view.center;
        if (![vc.view.subviews containsObject:(UILabel *)[vc.view viewWithTag:999]]) {
            [vc.view addSubview:label];
        }
    }
}
+(void)doThisWhenNeedTellUserToSaveWhenExitWithLeftBtnAction:(void (^)(void))lAction andRightBtnAction:(void (^)(void))rAction{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                contentText:@"检测到您所做的修改尚未保存，现在需要保存吗?"
                                            leftButtonTitle:@"取消"
                                           rightButtonTitle:@"保存并返回"];
    alert.rightBlock = rAction;
    alert.leftBlock = lAction;
    [alert show];
}
+(void)showPopListWithTitle:(NSString *)title data:(NSArray *)data andVC:(UIViewController *)vc;{
    
}
@end
