//
//  MyEUniversal.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-2-14.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyELoginViewController.h"

@interface MyEUniversal : NSObject<UIAlertViewDelegate>


+(void)doThisWhenNeedPickerWithTitle:(NSString *)title andDelegate:(id<UIActionSheetDelegate>)delegate andTag:(NSInteger)tag andArray:(NSArray*)array andSelectRow:(NSInteger)row andViewController:(UIViewController *)vc;
+(void)doThisWhenNeedPickerWithTitle:(NSString *)title andDelegate:(id<UIActionSheetDelegate>)delegate andTag:(NSInteger)tag andArray:(NSArray*)array andSelectRows:(NSArray *)row andViewController:(UIViewController *)vc;

+(void)doThisWhenUserLogOutWithVC:(UIViewController*)vc;

+(void)doThisToCloseKeyboardWithVC:(UIViewController*)vc;

+(void)dothisWhenTableViewIsEmptyWithMessage:(NSString *)message andFrame:(CGRect)frame andVC:(UIViewController *)vc;
+(void)doThisWhenNeedTellUserToSaveWhenExitWithLeftBtnAction:(void (^)(void))lAction andRightBtnAction:(void (^)(void))rAction;
@end
