//
//  MyECameraAddNewViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-4-30.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraAddNewViewController.h"
#import "MyECameraEnterUserInfoViewController.h"
@interface MyECameraAddNewViewController ()

@end

@implementation MyECameraAddNewViewController

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
    if (self.jumpFromWhere == 1) {
        self.lblTitle.text = @"检测到当前WIFI环境下存在以下设备";
        self.txtName.text = self.camera.name;
        self.txtUID.text = self.camera.UID;
    }else if (self.jumpFromWhere == 2){
        self.lblTitle.text = @"通过二维码扫描到以下设备";
        self.txtUID.text = self.camera.UID;
    }else{
        self.lblTitle.text = @"请手动输入以下信息";
        self.txtUID.text = self.camera.UID;
    }
    for (UIButton *btn in self.view.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            if (btn.tag == 101) {
                [btn setBackgroundImage:[[UIImage imageNamed:@"control-enable-normal"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:@"control-enable-highlight"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithRed:69/255 green:220/255 blue:200/255 alpha:1] forState:UIControlStateHighlighted];
            }else{
                [btn setBackgroundImage:[[UIImage imageNamed:@"control-disable-normal"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:@"control-disable-highlight"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithRed:69/255 green:220/255 blue:200/255 alpha:1] forState:UIControlStateHighlighted];
            }
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
#pragma mark - IBAction methods
- (IBAction)dissmissVC:(UIButton *)sender {
    self.cancelBtnClicked = YES;
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MyECameraEnterUserInfoViewController *vc = segue.destinationViewController;
    self.camera.name = self.txtName.text;
    vc.camera = self.camera;
    vc.cameraList = self.cameraList;
}


@end
