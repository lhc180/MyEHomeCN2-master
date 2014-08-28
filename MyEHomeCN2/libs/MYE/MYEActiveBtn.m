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
}

@end
@implementation MYEActiveBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _bgView = [[UIView alloc] initWithFrame:self.bounds];
        _bgView.backgroundColor = [UIColor whiteColor];
       UIActivityIndicatorView *actor = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        actor.tintColor = [UIColor redColor];
        actor.center = _bgView.center;
        [actor startAnimating];
        [_bgView addSubview:actor];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.userInteractionEnabled = YES;
        _bgView = [[UIView alloc] initWithFrame:self.bounds];
        _bgView.backgroundColor = [UIColor whiteColor];
        UIActivityIndicatorView *actor = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        actor.color = [UIColor orangeColor];
        [actor startAnimating];
        [_bgView addSubview:actor];
        actor.center = _bgView.center;

        NSLog(@"%f %f %f %f",_bgView.frame.origin.x,_bgView.frame.origin.y,_bgView.frame.size.width,_bgView.frame.size.height);
        [self setImage:[UIImage imageNamed:@"switch-on"] forState:UIControlStateNormal];
    }
    return self;
}
-(void)show{
    if (![self.subviews containsObject:_bgView]) {
        [self addSubview:_bgView];
        self.userInteractionEnabled = NO; //这么做主要是为了当act运动时，不再接收用户点击操作
    }
}
-(void)hide{
    if ([self.subviews containsObject:_bgView]) {
        [_bgView removeFromSuperview];
        self.userInteractionEnabled = YES;
    }
}
-(BOOL)isLoading{
    return [self.subviews containsObject:_bgView];
}
-(void)setEnabled:(BOOL)enabled{
    if (!enabled) {
        [self setImage:[UIImage imageNamed:@"switch-disable"] forState:UIControlStateNormal];
        self.userInteractionEnabled = NO;
    }else
        self.userInteractionEnabled = YES;
}
-(void)setSelected:(BOOL)selected{
    if (selected) {
        [self setImage:[UIImage imageNamed:@"switch-off"] forState:UIControlStateNormal];
    }else
        [self setImage:[UIImage imageNamed:@"switch-on"] forState:UIControlStateNormal];
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
