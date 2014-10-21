//
//  MyEScheduleCell.m
//  MyE
//
//  Created by 翟强 on 14-6-16.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEScheduleCell.h"

@implementation MyEScheduleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
-(void)setTime:(NSString *)time{
    UILabel *label = (UILabel *)[self.contentView viewWithTag:200];
    label.text = time;
}
-(void)setIsOn:(BOOL)isOn{
    UISwitch *onSwitch = (UISwitch *)[self.contentView viewWithTag:201];
    [onSwitch setOn:isOn animated:YES];
}
-(void)setMaxChannel:(NSInteger)maxChannel{
    for (UILabel *lbl in self.channelLabels) {
        if (lbl.tag - 500 <= maxChannel) {
            lbl.hidden = NO;
        }else
            lbl.hidden = YES;
    }
}
-(void)setWeeks:(NSArray *)weeks{
    for (UILabel *lbl in self.weekLabels) {
        if ([weeks containsObject:@(lbl.tag - 400)]) {
            lbl.textColor = NavBarColor;
        }else
            lbl.textColor = [UIColor lightGrayColor];
    }
}
-(void)setChannels:(NSArray *)channels{
    for (UILabel *lbl in self.channelLabels) {
        if ([channels containsObject:@(lbl.tag - 500)]) {
            lbl.textColor = NavBarColor;
        }else
            lbl.textColor = [UIColor lightGrayColor];
    }
}
@end
