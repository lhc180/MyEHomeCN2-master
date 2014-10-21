//
//  MYEPickerView.m
//  textView
//
//  Created by 翟强 on 14-5-27.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEPickerView.h"

#define SIZEDetail(frame) NSLog(@"x:%.0f y:%.0f width:%0.f height:%.0f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height)

#define viewWidth 80

@interface MYEPickerView (){
    UIView *_showView;
    UIView *_contentView; //内容视图，其实就是包含了picker和toolbar的视图
    UIPickerView *_pickerView;
    NSInteger _selectRow;
    NSArray *_data;
    CGFloat _margin; //每个挡板距离两端的距离
    UIView *_topView;
    CGFloat _viewWidth;
}

@end

@implementation MYEPickerView


-(MYEPickerView *)initWithView:(UIView *)view andTag:(NSInteger)tag title:(NSString *)title dataSource:(NSArray *)data andSelectRow:(NSInteger)row{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        //传值，以便进行全局使用
        _showView = view;
        _data = data;
        _selectRow = row;
        //定制背景view
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor clearColor];  //这里背景要设定颜色，选定透明色
        self.tag = tag;
        _topView = [[UIView alloc] initWithFrame:self.bounds];
        _topView.backgroundColor = [UIColor colorWithWhite:0.7f alpha:0.5];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_topView addGestureRecognizer:tap];  //当点击背景的时候可以隐藏界面
        [self addSubview:_topView];
        //content View
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHigh, screenwidth,260)];
        _contentView.backgroundColor = [UIColor whiteColor];
        
        //ToolBar
        UIToolbar *tool = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenwidth, 44)];
        tool.barStyle = UIBarStyleBlackOpaque;
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(hide)];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(done:)];
        [tool setItems:[NSArray arrayWithObjects:cancelButton,flexSpace,doneBtn, nil] animated:YES];
        
        //titleLabel
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.center = CGPointMake(screenwidth/2, CGRectGetMidY(tool.frame));
        [tool addSubview:titleLabel];
        
        [_contentView addSubview:tool];
        
        //pickerView
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tool.frame) , screenwidth, 216)];
        //        [_pickerView sizeToFit];
        [_pickerView setShowsSelectionIndicator:NO];
        [_pickerView setDelegate:self];
        [_pickerView setDataSource:self];
        //        _pickerView.backgroundColor = [UIColor whiteColor]; //加了这句代码之后两边就没有view的背景色了，这样显得好看些
        [_contentView addSubview:_pickerView];
        
        [_contentView sizeToFit];
        [self addSubview:_contentView];
        //        SIZEDetail(_pickerView.frame);
        //        SIZEDetail(_contentView.frame);
        }
    return self;
}

#pragma mark - animate methods
-(void)show{
    [_showView.window addSubview:self];
    [_pickerView reloadAllComponents];
    if ([_data[0] isKindOfClass:[NSArray class]]) {
        for (int i=0 ; i < _selectedRows.count; i ++) {
            [_pickerView selectRow:[_selectedRows[i] intValue] inComponent:i animated:YES];
        }
    }else
        [_pickerView selectRow:_selectRow inComponent:0 animated:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect newFrame = _contentView.frame;
        newFrame.origin.y -= newFrame.size.height;
        _contentView.frame = newFrame;
    }];
    _viewWidth = viewWidth;
    if (self.needLongView) {
        _viewWidth = 120;
    }
    _margin = (screenwidth - _viewWidth)/2;
    if (_selectedRows.count > 0) {
        _margin = (screenwidth - _viewWidth * _selectedRows.count)/(_selectedRows.count*2);
    }
    for (UIView *v in _pickerView.subviews) {
        if (v.frame.size.height == 0.5) {
            [v removeFromSuperview];
        }
        if (IS_IOS6) {   //这个是用来定制ios系统下picker的外观的
//            if (v.frame.size.width == 148) {  //一共有四个view，分别为 _UIPickerWheelView 和 _UIOnePartImageView
//                [v removeFromSuperview];
//            }
            if (v.class == NSClassFromString(@"_UIPickerViewTopFrame")) {   // 这里需要多加注意
                [v removeFromSuperview];
            }
            if (v.class == NSClassFromString(@"_UIOnePartImageView")) {   // 这里需要多加注意
                [v removeFromSuperview];
            }
            if (v.frame.size.height == 216) {
                v.backgroundColor = [UIColor whiteColor];
            }
            if (v.class == NSClassFromString(@"_UIPickerWheelView")) {   // 这里需要多加注意
                [v removeFromSuperview];
            }
        }
    }
    for (int i = 0 ; i < (_selectedRows == nil?2:_selectedRows.count); i ++) {
        UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _viewWidth, 1)];
        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _viewWidth, 1)];
        top.backgroundColor = MainColor;
        bottom.backgroundColor = MainColor;
        top.center = CGPointMake(_margin*(2*i+1) + (i*2+1)*_viewWidth/2, 86);
        bottom.center = CGPointMake(_margin*(2*i+1) + (i*2+1)*_viewWidth/2, 130);
        [_pickerView addSubview:top];
        [_pickerView addSubview:bottom];
    }
    //    for (int i = 0; i < 2; i ++) {
    //        UIView *view = [[UIView alloc] init];
    //        view.backgroundColor = MainColor;
    //        if (i == 0) {
    //            view.frame = CGRectMake(120, 90.5, 80, 1);  //90.5是查看细节获取到的
    //        }else
    //            view.frame = CGRectMake(120, 125, 80, 1); //125也是查看细节获取到的
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
-(void)done:(UIBarButtonItem *)item{
    NSInteger i = [_pickerView selectedRowInComponent:0];
    NSInteger j = 0,k = 0;
    if ([_data[0] isKindOfClass:[NSArray class]]) {
        j = [_pickerView selectedRowInComponent:1];
        if (_selectedRows.count == 3) {
            k = [_pickerView selectedRowInComponent:2];
            [self.delegate MYEPickerView:self didSelectTitles:@[_data[0][i],_data[1][j],_data[2][k]] andRows:@[@(i),@(j),@(k)]];
            [self hide];
            return;
        }
        if ([self.delegate respondsToSelector:@selector(MYEPickerView:didSelectTitles:andRows:)]) {
            [self.delegate MYEPickerView:self didSelectTitles:@[_data[0][i],_data[1][j]] andRows:@[@(i),@(j)]];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(MYEPickerView:didSelectTitle:andRow:)]) {
            [self.delegate MYEPickerView:self didSelectTitle:_data[i] andRow:i];
        }
    }
    [self hide];
}
#pragma mark - UIPickerView dataSource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if ([_data[0] isKindOfClass:[NSArray class]]) {
        return _data.count;
    }
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([_data[0] isKindOfClass:[NSArray class]]) {
        NSArray *array = _data[component];
        return array.count;
    }
    return _data.count;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:0].width, [pickerView rowSizeForComponent:0].height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    
    if ([_data[0] isKindOfClass:[NSArray class]]) {
        NSArray *array = _data[component];
        label.text = array[row];
    }else
        label.text = _data[row];
    
    NSInteger i = label.text.length;
    if (i > 80) {
        label.font = [UIFont systemFontOfSize:11];
    }else if(i > 25){
        label.font = [UIFont systemFontOfSize:13];
    }else
        label.font = [UIFont boldSystemFontOfSize:20];
    return label;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 44;
}
#pragma mark - UIPickerView delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
}
@end
