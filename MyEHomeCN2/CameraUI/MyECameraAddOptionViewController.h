//
//  MyECameraAddOptionViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/27/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEEditCameraViewController.h"
#import "SearchCameraResultProtocol.h"
#import "SearchDVS.h"
#import "defineutility.h"
#import "MyECamera.h"
#import "MyEQRScanViewController.h"

@interface MyECameraAddOptionViewController : UIViewController<SearchCameraResultProtocol,MyEQRScanViewControllerDelegate>{
    CSearchDVS* dvs;
    MBProgressHUD *HUD;
}
@property (nonatomic, retain) NSTimer* searchTimer;
@property (nonatomic, strong) NSMutableArray *cameraList;
@property (nonatomic, strong) MyECamera *camera;
@end
