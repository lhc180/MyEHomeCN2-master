//
//  MyEAboutViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-1-24.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAboutViewController.h"

@interface MyEAboutViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end

@implementation MyEAboutViewController


#pragma mark - lifeCircle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.versionLabel.text = [NSString stringWithFormat:@"MyE家居 %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    self.image.layer.cornerRadius = 5;
    self.image.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
