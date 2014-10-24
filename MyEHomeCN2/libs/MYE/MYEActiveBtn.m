//
//  MYEActiveBtn.m
//  newCollectionView
//
//  Created by 翟强 on 14-8-28.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEActiveBtn.h"

@interface MYEActiveBtn (){
    UIView *_bgView;
    UIActivityIndicatorView *_actor;
}

@end
@implementation MYEActiveBtn

- (id)initWithFrame:(CGRect)frame  //用代码实现的时候用这个
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _bgView = [[UIView alloc] initWithFrame:self.bounds];
        _bgView.backgroundColor = [UIColor whiteColor];
        _actor = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _actor.tintColor = [UIColor redColor];
        _actor.center = _bgView.center;
        [_actor startAnimating];
        [_bgView addSubview:_actor];
        _bgView.hidden = YES;
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
//        self.userInteractionEnabled = YES;
//        _bgView = [[UIView alloc] initWithFrame:self.bounds];
//        _bgView.backgroundColor = [UIColor whiteColor];
//        _actor = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//        _actor.color = [UIColor orangeColor];
//        [_actor startAnimating];
//        _actor.center = _bgView.center;
//        [_bgView addSubview:_actor];
//        [self addSubview:_bgView];
//        //        NSLog(@"%f %f %f %f",_bgView.frame.origin.x,_bgView.frame.origin.y,_bgView.frame.size.width,_bgView.frame.size.height);
        [self setImage:[UIImage imageNamed:@"switch-control-on"] forState:UIControlStateNormal];
    }
    return self;
}
-(void)show{
    _bgView.hidden = NO;
    self.userInteractionEnabled = NO; //这么做主要是为了当act运动时，不再接收用户点击操作
}
-(void)hide{
    _bgView.hidden = YES;
    self.userInteractionEnabled = YES;
}
-(BOOL)isLoading{
    return !_bgView.hidden;
}
-(void)setEnabled:(BOOL)enabled{
    if (!enabled) {
        [self setImage:[UIImage imageNamed:@"switch-control-disable"] forState:UIControlStateNormal];
        self.userInteractionEnabled = NO;
    }else
        self.userInteractionEnabled = YES;
}
-(void)setSelected:(BOOL)selected{
    if (selected) {
        [self setImage:[UIImage imageNamed:@"switch-control-off"] forState:UIControlStateNormal];
    }else
        [self setImage:[UIImage imageNamed:@"switch-control-on"] forState:UIControlStateNormal];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
