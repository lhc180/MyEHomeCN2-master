//
//  MyECameraAddOptionViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/27/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraAddOptionViewController.h"
#import "MyECameraAddNewViewController.h"
#import "MyECameraTableViewController.h"
#import "PPPP_API.h"
@interface MyECameraAddOptionViewController ()
{
    NSMutableArray *_wlanSearchDevices,*_wlanUsefullDevices;  //局域网扫描到的设备
    BOOL _hasAdd; //表示该设备已经添加
    NSInteger count;
    NSTimer *_timer;
}
@end

@implementation MyECameraAddOptionViewController

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
    self.camera = [[MyECamera alloc] init];
    for (UIButton *btn in self.view.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            
            [btn setBackgroundImage:[[UIImage imageNamed:@"control-enable-normal"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
            [btn setBackgroundImage:[[UIImage imageNamed:@"control-enable-highlight"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:69/255 green:220/255 blue:200/255 alpha:1] forState:UIControlStateHighlighted];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
-(void)presentVCToAddDeviceWithTag:(NSInteger)tag{
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addNew"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.preferredContentSize = CGSizeMake(280, 233);
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
        UINavigationController *nav = (UINavigationController *)presentedFSViewController;
        MyECameraAddNewViewController *vc = nav.childViewControllers[0];
        vc.jumpFromWhere = tag;
        vc.cameraList = self.cameraList;
        vc.camera = _camera;
        NSLog(@"%@",vc.camera);
        [vc viewDidLoad];
    };
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:nil];
    
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController) {
        UINavigationController *nav = (UINavigationController *)presentedFSViewController;
        MyECameraAddNewViewController *vc = nav.childViewControllers[0];
        if (!vc.cancelBtnClicked) {
            MyECameraTableViewController *vc = self.navigationController.childViewControllers[0];
            vc.needRefresh = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
}
- (void)Initialize{
    PPPP_Initialize((char*)[@"EBGBEMBMKGJMGAJPEIGIFKEGHBMCHMJHCKBMBHGFBJNOLCOLCIEBHFOCCHKKJIKPBNMHLHCPPFMFADDFIINOIABFMH" UTF8String]);
    st_PPPP_NetInfo NetInfo;
    PPPP_NetworkDetect(&NetInfo, 0);
}

- (void)handleTimer:(NSTimer *)timer{
    [self stopSearch];
    NSLog(@"%@",_wlanSearchDevices);
    _wlanUsefullDevices = _wlanSearchDevices;
    BOOL hasNew = NO;
    if ([_wlanSearchDevices count]) {
        if ([self.cameraList count]) {
            BOOL hasOne = NO;
            for (MyECamera *c in _wlanSearchDevices) {
                for (MyECamera *c1 in self.cameraList) {
                    if ([c.UID isEqualToString:c1.UID]) {
                        hasOne = YES;
                    }
//                    if (![c.UID isEqualToString:c1.UID]) {  //只有所有都不一样的时候才能够新增设备
//                        hasNew = YES;
//                        _camera = c;
//                        break;
//                    }
                }
                if (hasOne) {
                    [_wlanUsefullDevices removeObject:c];
                }
            }
            if ([_wlanUsefullDevices count]) {
                hasNew = YES;
            }
        }else{
            hasNew = YES;
//            _camera = _wlanSearchDevices[0];
        }
    }
    [HUD hide:YES];
    if (hasNew) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"局域网检测到[%i]个设备,已成功完成添加",[_wlanSearchDevices count]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
        [alert show];
//        [self presentVCToAddDeviceWithTag:1];
    }else{
        [MyEUtil showThingsSuccessOn:self.view WithMessage:@"未找到新设备" andTag:NO];
    }

}
- (void) stopSearch
{
    if (dvs != NULL) {
        SAFE_DELETE(dvs);
    }
}
#pragma mark - IBAction methods
- (IBAction) startSearch
{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    HUD.dimBackground = YES;
    HUD.labelText = @"正在搜索...";
    
    _wlanSearchDevices = [NSMutableArray arrayWithCapacity:20];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self Initialize];
        });
        
        [self stopSearch];
        
        dvs = new CSearchDVS();
        dvs->searchResultDelegate = self;
        dvs->Open();
        
        //create the start timer
        _searchTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:NO];
    });
}
- (IBAction)scanQr:(UIButton *)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"settings" bundle:nil];
    UINavigationController *nav = [story instantiateInitialViewController];
    MyEQRScanViewController *vc = [nav childViewControllers][0];
    vc.delegate = self;
    vc.isAddCamera = YES;
    [self presentViewController:nav animated:YES completion:nil];
}
- (IBAction)manualAddCamera:(UIButton *)sender {
    [self presentVCToAddDeviceWithTag:3];
}

#pragma mark -
#pragma mark SearchCameraResultProtocol

- (void) SearchCameraResult:(NSString *)mac Name:(NSString *)name Addr:(NSString *)addr Port:(NSString *)port DID:(NSString*)did{
    NSLog(@"name is %@ UID is %@ MAC is %@ add is %@",name, did,mac,addr);
    MyECamera *camera = [[MyECamera alloc] init];
    camera.name = name;
    camera.UID = did;
    if (![_wlanSearchDevices count]) {
        [_wlanSearchDevices addObject:camera];
    }else{
        for (MyECamera *c in _wlanSearchDevices) {
            if (![camera.UID isEqualToString:c.UID]) {
                [_wlanSearchDevices addObject:camera];
            }
        }
    }
}
#pragma mark - QRScan delegate methods
-(void)passCameraUID:(NSString *)UID{
    self.camera.UID = UID;
    [self presentVCToAddDeviceWithTag:2];
}

#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.cameraList addObjectsFromArray:_wlanUsefullDevices];
}
@end
