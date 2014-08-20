//
//  MyELaunchIntroViewController.m
//  MyE
//
//  Created by Ye Yuan on 3/17/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import "MyELaunchIntroViewController.h"

#define DEMO_PAGE_NUM 4
@interface MyELaunchIntroViewController ()

@end

@implementation MyELaunchIntroViewController
@synthesize scrollView,pageControl;

#pragma mark - life Circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    scrollView.alignment = SwipeViewAlignmentCenter;
    scrollView.pagingEnabled = YES;
    scrollView.wrapEnabled = NO;
    scrollView.itemsPerPage = 1;
    scrollView.truncateFinalPage = YES;
    
    //configure page control
    pageControl.numberOfPages = scrollView.numberOfPages;
    pageControl.defersCurrentPageDisplay = YES;
}
#pragma mark - scroll dataSource
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return 4;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIImageView *img = [[UIImageView alloc] initWithFrame:self.view.frame];
    if (IS_IPHONE5) {
        switch (index) {
            case 0:
                [img setImage:[UIImage imageNamed:@"demo1-568h@2x"]];
                break;
            case 1:
                [img setImage:[UIImage imageNamed:@"demo2-568h@2x"]];
                break;
            case 2:
                [img setImage:[UIImage imageNamed:@"demo3-568h@2x"]];
                break;
            default:
                [img setImage:[UIImage imageNamed:@"demo4-568h@2x"]];
                break;
        }
    }else{
        switch (index) {
            case 0:
                [img setImage:[UIImage imageNamed:@"demo1"]];
                break;
            case 1:
                [img setImage:[UIImage imageNamed:@"demo2"]];
                break;
            case 2:
                [img setImage:[UIImage imageNamed:@"demo3"]];
                break;
            default:
                [img setImage:[UIImage imageNamed:@"demo4"]];
                break;
        }
    }
    return img;
}

#pragma mark - scroll delegate
- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    //update page control page
    pageControl.currentPage = swipeView.currentPage;
    //这里算是取巧了。真正的做法应该是动态创建btn，这样就显得btn是从画面外滚动进来的，使得界面更为好看。说到底还是对于scrollView的理解还是不够
    if (pageControl.currentPage == 3) {
        self.enterBtn.hidden = NO;
    }else{
        self.enterBtn.hidden = YES;
    }
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"Selected item at index %li", (long)index);
}
#pragma mark - IBAction methods
- (IBAction)showLoginVC:(UIButton *)sender {
    MyELoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [MainDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    MainDelegate.window.rootViewController = vc;
}

- (IBAction)pageControlTapped
{
    //update swipe view page
    [scrollView scrollToPage:pageControl.currentPage duration:0.4];
}
@end
