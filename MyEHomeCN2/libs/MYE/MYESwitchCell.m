//
//  MYESwitchCell.m
//  newCollectionView
//
//  Created by 翟强 on 14-8-28.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYESwitchCell.h"
@interface MYESwitchCell(){
    __weak IBOutlet UILabel *timeSetLbl;
    __weak IBOutlet UILabel *timeDelayLbl;
    __weak IBOutlet UIActivityIndicatorView *actor;
}

@end
@implementation MYESwitchCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
#pragma mark - private methods
-(void)hideOrShowObjectsWith:(BOOL)yes{
    _switchBtn.enabled = yes;
    _timeBtn.enabled = yes;
    timeSetLbl.text = @"";
    timeDelayLbl.text = @"";
}
-(void)isDisable:(BOOL)disable{
    [self hideOrShowObjectsWith:!disable];
    _disable = disable;
}
-(void)isLightOn:(BOOL)lightOn{
    if (_disable) {
        return;
    }
    _switchBtn.selected = !lightOn;
    _lightOn = lightOn;
}
-(void)isTimeOn:(BOOL)timeOn{
    if (_disable) {
        return;
    }
    _timeBtn.selected = !timeOn;
    _timeOn = timeOn;
}
-(void)setTimeDelay:(NSString *)timeDelay{
    if (_disable) {  //禁用时啥也不显示
        return;
    }
//    NSLog(@"%@",self.timeSet);
//    NSLog(@"%@",self.timeDelay);
//    NSLog(@"light:%@  time:%@",self.lightOn?@"YES":@"NO",self.timeOn?@"YES":@"NO");
    if (_lightOn && _timeOn) {   //只有当灯开，且延时开的时候，剩余时间才显示
        if (![timeDelay isEqualToString:_timeDelay]) {
            timeDelayLbl.text = timeDelay;
        }
    }
}
-(void)setTimeSet:(NSString *)timeSet{
    if (_disable) {
        return;
    }
    if (_timeOn) {
        if (![timeSet isEqualToString:_timeSet]) {
            timeSetLbl.text = timeSet;
        }
    }
}
-(void)viewShowOrHide:(BOOL)flag{
    self.switchBtn.hidden = !flag;
    actor.hidden = flag;
}
-(void)show{
    [actor startAnimating];
    [self viewShowOrHide:NO];
}
-(void)hide{
    [self viewShowOrHide:YES];
}
@end
