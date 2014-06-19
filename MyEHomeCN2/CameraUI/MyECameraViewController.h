//
//  MyECameraViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/23/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "PPPP_API.h"
#include "PPPPChannelManagement.h"
#import "ImageNotifyProtocol.h"
#import "SearchCameraResultProtocol.h"
#import "SearchDVS.h"
#import "ParamNotifyProtocol.h"
#import "MyECamera.h"

@interface MyECameraViewController : UIViewController
<ImageNotifyProtocol,ParamNotifyProtocol,DateTimeProtocol,SdcardScheduleProtocol,WifiParamsProtocol> {
    CSearchDVS* dvs;
    /*镜像参数*/
    int flip;
}
@property (nonatomic, retain) IBOutlet UIImageView* playView;
@property CPPPPChannelManagement* m_PPPPChannelMgt;
@property (nonatomic, weak) MyECamera *camera;
/*----------------info view---------------------*/
@property (weak, nonatomic) IBOutlet UIView *infoView;
/*-------------actionView--------------*/
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *infoLabels;

@end
