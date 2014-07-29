//
//  MyECameraTableViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/27/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEEditCameraViewController.h"
#import "defineutility.h"
#import "PPPPChannelManagement.h"

@interface MyECameraTableViewController : UITableViewController <SnapshotProtocol,MyEDataLoaderDelegate>

@property (nonatomic, retain) NSMutableArray *cameraList;
@property (nonatomic) BOOL needRefresh;

@end
