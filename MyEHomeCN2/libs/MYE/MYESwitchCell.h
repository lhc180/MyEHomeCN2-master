//
//  MYESwitchCell.h
//  newCollectionView
//
//  Created by 翟强 on 14-8-28.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYEActiveBtn.h"

@interface MYESwitchCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet MYEActiveBtn *switchBtn;

@property (nonatomic, setter = isDisable:) BOOL disable;  //这个用于表示该路开关的禁用状态
@property (nonatomic, setter = isLightOn:) BOOL lightOn;
@property (nonatomic, setter = isTimeOn:) BOOL timeOn;

@property (nonatomic, strong) NSString *timeSet;
@property (nonatomic, strong) NSString *timeDelay;
@end
