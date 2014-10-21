//
//  MyEAcInstructionListCell.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-23.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcInstructionListCell.h"

@implementation MyEAcInstructionListCell
@synthesize order,power,mode,windLevel,temperature,status,orderLabel,powerLabel,modeLabel,windLevelLabel,temperatureLabel,studyLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - setter methods 
-(void)setOrder:(NSInteger)o{
    orderLabel.text = [NSString stringWithFormat:@"%li",(long)o];
}
-(void)setPower:(NSInteger)p{
    switch (p) {
        case 0:
            powerLabel.text = @"关";
            break;
        default:
            powerLabel.text = @"开";
            break;
    }
}
-(void)setMode:(NSInteger)m{
    switch (m) {
        case 1:
            modeLabel.text = @"自动";
            break;
        case 2:
            modeLabel.text = @"制热";
            break;
        case 3:
            modeLabel.text = @"制冷";
            break;
        case 4:
            modeLabel.text = @"除湿";
            break;
        default:
            modeLabel.text = @"送风";
            break;
    }
}
-(void)setWindLevel:(NSInteger)w{
    switch (w) {
        case 0:
            windLevelLabel.text = @"自动";
            break;
        case 1:
            windLevelLabel.text = @"一级";
            break;
        case 2:
            windLevelLabel.text = @"二级";
            break;
        default:
            windLevelLabel.text = @"三级";
            break;
    }
}
-(void)setTemperature:(NSInteger)t{
    temperatureLabel.text = [NSString stringWithFormat:@"%li℃",(long)t];
}
-(void)setStatus:(NSInteger)s{
    if (s == 1 || s == 2) {
        studyLabel.text = @"已学习";
    } else {
        studyLabel.text = @"未学习";
    }
}
@end
