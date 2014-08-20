//
//  MyEMainTabBarController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/2/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEMainTabBarController.h"
#import "MyELoginViewController.h"

@interface MyEMainTabBarController ()

@end

@implementation MyEMainTabBarController
@synthesize selectedTabIndex = _selectedTabIndex;
@synthesize accountData = _accountData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.selectedIndex = self.selectedTabIndex;
    
    // @see：iOS 7 offers 68 more vertical pixels for the main view of an application because the status/navigation bar is now semi-transparent and exists “above” the main view content.
    //http://www.brianjcoleman.com/ios7-weve-got-a-problem/
    //https://developer.apple.com/library/ios/documentation/userexperience/conceptual/TransitionGuide/AppearanceCustomization.html
    //http://hugeinc.com/ideas/perspectives/porting-apps-ios-7-punch-list
//    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
//        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //这个用于限制当网关不在线的时候，此时只能进设置面板，不能进入其他面板
    if (self.accountData.mStatus == 0 || self.accountData.terminals.count == 0) {
        self.selectedIndex = 4;
        [self setTabbarButtonEnable:NO];
    } else
        [self setTabbarButtonEnable:YES];
}
#pragma mark - private methods
//by YY
-(void)setTabbarButtonEnable:(BOOL)enable{
    NSInteger count = [[self childViewControllers] count];
    for (int i=0; i < count-1; i++) {
        UINavigationController *nav = [self childViewControllers][i];
        nav.tabBarItem.enabled = enable;
    }
}

#pragma mark - UITabBarDelegate Methods

//- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
//{
//    //    NSLog(@"%@, index = %i", item.title, item.tag);
//    //    id vc = [self.viewControllers objectAtIndex:self.selectedIndex];
//    //    if ([vc isKindOfClass:[MyEVacationMasterViewController class]]) {
//    //        NSLog(@"1 MyEVacationMasterViewController is selected");
//    //    }
//    //    if ([self.selectedViewController isKindOfClass:[MyEVacationMasterViewController class]]) {
//    //        NSLog(@"2 MyEVacationMasterViewController is selected");
//    //    }
//    switch (item.tag) {
//        case MYE_TAB_DEVICE_TYPE:
//            item.title = @"设备";            //            self.title = @"设备";
//            self.selectedTabIndex = MYE_TAB_DEVICE_TYPE;
//            break;
//        case MYE_TAB_ROOM:
//            item.title = @"房间";
//            //           self.title = @"房间";
//            self.selectedTabIndex = MYE_TAB_ROOM;
//            break;
//        case MYE_TAB_SCENE:
//            item.title = @"场景";
//            //            self.title = @"场景";
//            self.selectedTabIndex = MYE_TAB_SCENE;
//            break;
//        case MYE_TAB_SETTINGS:
//            item.title = @"设置";
//            //            self.title = @"设置";
//            self.selectedTabIndex = MYE_TAB_SETTINGS;
//            break;
//        default:
//            break;
//    }
////    self.title = self.accountData.userName;
//}
@end
