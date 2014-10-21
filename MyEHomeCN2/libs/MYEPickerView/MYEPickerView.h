//
//  MYEPickerView.h
//  textView
//
//  Created by 翟强 on 14-5-27.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MYEPickerViewDelegate <NSObject>
@optional
-(void)MYEPickerView:(UIView *)pickerView didSelectTitle:(NSString *)title andRow:(NSInteger)row;
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSArray *)titles andRows:(NSArray *)rows;
@end

@interface MYEPickerView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, strong) id <MYEPickerViewDelegate> delegate;

@property (nonatomic, strong) NSArray *selectedRows;
@property (nonatomic, assign) BOOL needLongView;

-(MYEPickerView *)initWithView:(UIView *)view andTag:(NSInteger)tag title:(NSString *)title dataSource:(NSArray *)data andSelectRow:(NSInteger)row;
-(void)show;

@end
