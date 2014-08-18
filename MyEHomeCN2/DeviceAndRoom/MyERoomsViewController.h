//
//  MyERoomsViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/3/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyERoomsViewController : UITableViewController<MyEDataLoaderDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
}
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic) BOOL needRefresh;

@end
