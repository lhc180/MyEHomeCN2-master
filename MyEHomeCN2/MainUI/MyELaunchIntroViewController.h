//
//  MyELaunchIntroViewController.h
//  MyE
//
//  Created by Ye Yuan on 3/17/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeView.h"

@interface MyELaunchIntroViewController : UIViewController<SwipeViewDataSource,SwipeViewDelegate>

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet SwipeView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *enterBtn;

@end
