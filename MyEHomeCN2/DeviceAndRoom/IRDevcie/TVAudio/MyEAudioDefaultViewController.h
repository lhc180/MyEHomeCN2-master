//
//  MyEAudioDefaultViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/4/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEIrDefaultViewController.h"

@interface MyEAudioDefaultViewController : MyEIrDefaultViewController
@property (weak, nonatomic) IBOutlet UIButton *btnPower;
@property (weak, nonatomic) IBOutlet UIButton *btnMute;
@property (weak, nonatomic) IBOutlet UIButton *btnVolUp;
@property (weak, nonatomic) IBOutlet UIButton *btnPrev;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnVolDown;
@property (weak, nonatomic) IBOutlet UIButton *btnCD;
@property (weak, nonatomic) IBOutlet UIButton *btnAV;

@end
