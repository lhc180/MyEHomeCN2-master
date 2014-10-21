//
//  MYETimePicker.m
//  pickerss
//
//  Created by zhaiqiang on 14/9/25.
//  Copyright (c) 2014年 zhaiqiang. All rights reserved.
//

#import "MYETimePicker.h"

@interface MYETimePicker ()<UIPickerViewDataSource,UIPickerViewDelegate>{
    UIView *_contentView; //内容视图
    UIView *_topView;  //顶部view
    UIPickerView *_pickerView;
    UIView *_showView;
    NSInteger _interval;  //时间间隔,用来表示间隔时30分钟还是10分钟
    NSArray *_hours,*_minutes;
}
@end

#define margin 20
#define viewWidth 25
@implementation MYETimePicker

-(MYETimePicker *)initWithView:(UIView *)view andTag:(NSInteger)tag title:(NSString *)title interval:(NSInteger)interval andDelegate:(id<MYETimePickerDelegate>)delegate{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        _showView = view;
        _interval = interval;
        _delegate = delegate;
        //定制背景view
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor clearColor];  //这里背景要设定颜色，选定透明色
        self.tag = tag;
        //topView 主要接收点击事件，并且半透明，可以看到遮盖的背景
        _topView = [[UIView alloc] initWithFrame:self.bounds];
        _topView.backgroundColor = [UIColor colorWithWhite:0.667 alpha:0.5];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_topView addGestureRecognizer:tap];
        [self addSubview:_topView];
        
        //content View
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHigh,screenwidth,260)];
        _contentView.backgroundColor = [UIColor whiteColor];
        
        //ToolBar
        UIToolbar *tool = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenwidth, 44)];
        tool.barStyle = UIBarStyleBlackOpaque;
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(hide)];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(pickerDoneClicked)];
        [tool setItems:[NSArray arrayWithObjects:cancelButton,flexSpace,doneBtn, nil] animated:YES];
        [_contentView addSubview:tool];
        
        //titleLabel
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.center = CGPointMake(screenwidth/2, CGRectGetMidY(tool.frame));
        [tool addSubview:titleLabel];
        

        //pickerView
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tool.frame) , screenwidth, 216)];
//        [_pickerView sizeToFit];   //这里不能再用sizeToFit，否则picker是系统默认的大小
        [_pickerView setShowsSelectionIndicator:NO];
        [_pickerView setDelegate:self];
        [_pickerView setDataSource:self];
        _pickerView.backgroundColor = [UIColor whiteColor]; //加了这句代码之后两边就没有view的背景色了，这样显得好看些
        [_contentView addSubview:_pickerView];
        
        [_contentView sizeToFit];
        [self addSubview:_contentView];
        
        // dot
        UILabel *dotLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dotLabel.text = @":";
        dotLabel.backgroundColor = [UIColor clearColor];
        dotLabel.textAlignment = NSTextAlignmentCenter;
        dotLabel.font = [UIFont boldSystemFontOfSize:20];
        [dotLabel sizeToFit];
        dotLabel.center = CGPointMake(screenwidth/2, 108);
        [_pickerView addSubview:dotLabel];

        _hours = self.hours;
        _minutes = self.minutes;
    }
    return self;
}
#pragma mark - get data
-(NSArray *)hours{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 24; i ++) {
        if (i < 10) {
            [array addObject:[NSString stringWithFormat:@"0%i",i]];
        }else
            [array addObject:[NSString stringWithFormat:@"%i",i]];
    }
    return array;
}

-(NSArray *)minutes{
    return _interval == 10?@[@"00",@"10",@"20",@"30",@"40",@"50"]:@[@"00",@"30"];
}

#pragma mark - animate actions
-(void)show{
    [_showView.window addSubview:self];
    [_pickerView reloadAllComponents];
    NSArray *array = [_time componentsSeparatedByString:@":"];
    [_pickerView selectRow:[array[0] intValue]<_hours.count?[array[0] intValue]:0 inComponent:0 animated:YES];
    [_pickerView selectRow:[array[1] intValue]/_interval<_minutes.count? [array[1] intValue]/_interval:0 inComponent:1 animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect newFrame = _contentView.frame;
        newFrame.origin.y -= newFrame.size.height;
        _contentView.frame = newFrame;
    }];
    
    for (UIView *v in _pickerView.subviews) {
        if (v.frame.size.height == 0.5) {
            [v removeFromSuperview];
        }
        if (IS_IOS6) {   //这个是用来定制ios系统下picker的外观的
            if (v.frame.size.height == 216) {
                v.backgroundColor = [UIColor clearColor];
            }
            if (v.frame.size.width == 148) {  //一共有四个view，分别为 _UIPickerWheelView 和 _UIOnePartImageView
                [v removeFromSuperview];
            }
            if (v.class == NSClassFromString(@"_UIPickerViewTopFrame")) {   // 这里需要多加注意
                [v removeFromSuperview];
            }
        }
    }
    for (int i = 0; i < 2; i ++) {
        UIView *top = [[UIView alloc] init];
        UIView *bottom = [[UIView alloc] init];
        top.backgroundColor = MainColor;
        bottom.backgroundColor = MainColor;
        if (i == 0) {
            top.frame = CGRectMake(screenwidth/2-margin-viewWidth-2, 86, viewWidth, 1);
            bottom.frame = CGRectMake(screenwidth/2-margin-viewWidth-2, 130, viewWidth, 1);
        }else{
            top.frame = CGRectMake(screenwidth/2+margin, 86, viewWidth, 1);
            bottom.frame = CGRectMake(screenwidth/2+margin, 130, viewWidth, 1);
        }
        [_pickerView addSubview:top];
        [_pickerView addSubview:bottom];
    }

//    for (int i = 0; i < 4; i ++) {
//        UIView *view = [[UIView alloc] init];
//        view.backgroundColor = MainColor;
//        if (i < 2) {
//            view.frame = CGRectMake(117 + i*20*3 + i*3, 90.5, 20, 1);  //90.5是查看细节获取到的
//        }else
//            view.frame = CGRectMake(117 + (i - 2)*20*3 + (i-2)*3, 125, 20, 1); //125也是查看细节获取到的
//        [_pickerView addSubview:view];
//    }
}
-(void)hide{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect newFrame = _contentView.frame;
        newFrame.origin.y += newFrame.size.height;
        _contentView.frame = newFrame;
    }completion:^(BOOL finish){
        [self removeFromSuperview];
    }];
}

#pragma mark - action
-(void)pickerDoneClicked{
    NSInteger i = [_pickerView selectedRowInComponent:0];
    NSInteger j = [_pickerView selectedRowInComponent:1];
    
    if ([self.delegate respondsToSelector:@selector(MYETimePicker:didSelectString:)]) {
        [self.delegate MYETimePicker:self didSelectString:[NSString stringWithFormat:@"%@:%@",_hours[i],_minutes[j]]];
    }
    [self hide];
}

#pragma mark - UIPickerView dataSource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return component == 0?_hours.count:_minutes.count;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(margin, 0, [pickerView rowSizeForComponent:0].width-margin*2, [pickerView rowSizeForComponent:0].height)];
    label.textAlignment = component == 0?NSTextAlignmentRight: NSTextAlignmentLeft;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.text = component==0?_hours[row]:_minutes[row];
    return label;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 44;
}
@end
