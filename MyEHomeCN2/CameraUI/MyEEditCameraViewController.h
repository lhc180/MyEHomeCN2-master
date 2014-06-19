//
//  MyEEditCameraViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/25/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyECamera.h"

@interface MyEEditCameraViewController : UIViewController<UITextFieldDelegate>
@property (nonatomic, retain) MyECamera *camera;
@property (nonatomic, retain) NSIndexPath *indexPath;
- (IBAction)confirm:(id)sender;

@end
