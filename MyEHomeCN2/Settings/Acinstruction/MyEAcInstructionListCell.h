//
//  MyEAcInstructionListCell.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-23.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEAcInstructionListCell : UITableViewCell

@property(nonatomic) NSInteger order;
@property(nonatomic) NSInteger power;
@property(nonatomic) NSInteger mode;
@property(nonatomic) NSInteger windLevel;
@property(nonatomic) NSInteger temperature;
@property(nonatomic) NSInteger status;

@property (strong, nonatomic) IBOutlet UILabel *orderLabel;
@property (strong, nonatomic) IBOutlet UILabel *powerLabel;
@property (strong, nonatomic) IBOutlet UILabel *modeLabel;
@property (strong, nonatomic) IBOutlet UILabel *windLevelLabel;
@property (strong, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *studyLabel;


@end
