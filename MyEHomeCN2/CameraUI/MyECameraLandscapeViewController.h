//
//  MyECameraLandscapeViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPPPChannelManagement.h"
#import "MyECamera.h"
#import "ImageNotifyProtocol.h"
@interface MyECameraLandscapeViewController : UIViewController<ImageNotifyProtocol>
@property (nonatomic, weak) MyECamera *camera;
@property (nonatomic) CPPPPChannelManagement *m_PPPPChannelMgt;
@property (nonatomic, weak) MyECameraRecord *record;
@property (nonatomic, weak) MyECameraParam *cameraParam;
@property (nonatomic, assign) NSArray *recordArray;
@property (nonatomic, assign) NSInteger actionType;  //1表示正常播放，2表示回放录像
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *playbackView;
@property (weak, nonatomic) IBOutlet UIView *cameraControlView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *videoControlSeg;

@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *ContrastSetView;
@property (weak, nonatomic) IBOutlet UIView *brightnessSetView;

@end
