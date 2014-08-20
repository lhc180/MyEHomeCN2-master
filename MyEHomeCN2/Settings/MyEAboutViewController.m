//
//  MyEAboutViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-1-24.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAboutViewController.h"

@interface MyEAboutViewController ()

@end

@implementation MyEAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - lifeCircle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.versionLabel.text = [NSString stringWithFormat:@"MyE家居 %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
