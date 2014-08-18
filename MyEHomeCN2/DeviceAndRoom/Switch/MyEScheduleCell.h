//
//  MyEScheduleCell.h
//  MyE
//
//  Created by 翟强 on 14-6-16.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEScheduleCell : UITableViewCell
@property (nonatomic, strong) NSString *time;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, strong) NSArray *weeks;
@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, assign) NSInteger maxChannel;  //这个表示允许显示的最大channel数
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *channelLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *weekLabels;

@end
