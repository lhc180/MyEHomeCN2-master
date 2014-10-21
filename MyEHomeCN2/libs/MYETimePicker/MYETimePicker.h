//
//  MYETimePicker.h
//  pickerss
//
//  Created by zhaiqiang on 14/9/25.
//  Copyright (c) 2014年 zhaiqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MYETimePickerDelegate <NSObject>

-(void)MYETimePicker:(UIView *)picker didSelectString:(NSString *)title;

@end

@interface MYETimePicker : UIView

@property (nonatomic, weak) id <MYETimePickerDelegate> delegate;

@property (nonatomic, strong) NSString *time;

-(MYETimePicker *)initWithView:(UIView *)view andTag:(NSInteger)tag title:(NSString *)title interval:(NSInteger)interval andDelegate:(id <MYETimePickerDelegate>) delegate;

-(void)show;

@end
