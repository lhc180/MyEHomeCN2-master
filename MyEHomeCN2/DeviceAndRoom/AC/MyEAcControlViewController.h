//
//  MyEAcControlViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-12-18.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEAcControlViewController : UIViewController<MyEDataLoaderDelegate>
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, weak) MyEDevice *device;


@end
