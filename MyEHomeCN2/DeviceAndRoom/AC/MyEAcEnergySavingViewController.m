//
//  MyEAcComfortViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/19/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcEnergySavingViewController.h"

#define AC_COMFORT_DOWNLOADER_NMAE @"AcComfortDownloader"
#define AC_COMFORT_UPLOADER_NMAE @"AcComfortUploader"
@interface MyEAcEnergySavingViewController ()

@end

@implementation MyEAcEnergySavingViewController
@synthesize accountData, device, comfort = _comfort,picker,pickerViewContainer;
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
    
    _timeArray = [NSMutableArray array];
    for (int i = 0; i < 48; i++) {
        [_timeArray addObject:[NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:i]]];
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

    
    [self downloadComfortDataFromServer];
    UIView *view1 = [self.view viewWithTag:200];
    UIView *view2 = [self.view viewWithTag:201];
    for (UIView *v in self.view.subviews) {
        if (v.tag == 200 || v.tag == 201) {
            v.layer.masksToBounds = YES;
            v.layer.borderWidth = 0.5;
            v.layer.borderColor = [UIColor lightGrayColor].CGColor;
            v.layer.cornerRadius = 4;
        }
    }
//    if (!IS_IOS6) {
        for (UIButton *btn in view1.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
            }
        }
        for (UIButton *btn in view2.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                btn.layer.masksToBounds = YES;
                btn.layer.borderWidth = 1;
                btn.layer.borderColor = btn.tintColor.CGColor;
                btn.layer.cornerRadius = 4;
            }
        }
//    }else{
//        for (UIButton *btn in view1.subviews) {
//            if ([btn isKindOfClass:[UIButton class]] && btn.tag != 100) {
//                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn-ios6"] forState:UIControlStateNormal];
//                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
//            }
//        }
//    }
    /*----------------------------------定义picker--------------------------------------------*/
    if (IS_IOS6) {
        pickerViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, screenHigh, screenwidth, 260)];
        picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, screenwidth, 216)];
    }else{
        pickerViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, screenHigh, screenwidth, 260)];
        picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, screenwidth, 216)];
    }
    
    UIToolbar *tool = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenwidth, 44)];
    tool.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(save)];
    UIBarButtonItem *one = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    tool.items = @[one,save];
    picker.delegate = self;
    picker.dataSource = self;
    picker.backgroundColor = [UIColor colorWithRed:215 green:236 blue:241 alpha:1];
    picker.showsSelectionIndicator = YES;
    [pickerViewContainer addSubview:tool];
    [pickerViewContainer addSubview:picker];
    [self.view bringSubviewToFront:pickerViewContainer];
    [self.view addSubview:pickerViewContainer];
    /*----------------------------------定义picker--------------------------------------------*/
    [self defineTapGestureRecognizer];
}
#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self ViewAnimation:pickerViewContainer willHidden:YES];
}
//使用block实现动画效果
- (void)ViewAnimation:(UIView*)view willHidden:(BOOL)hidden {
    [UIView animateWithDuration:0.3 animations:^{
        if (hidden) {
            view.frame = CGRectMake(0, screenHigh, screenwidth, 260);
        } else {
            [view setHidden:hidden];
            if (IS_IOS6) {
                view.frame = CGRectMake(0, screenHigh-44-20-260, screenwidth, 260);
            }else{
                view.frame = CGRectMake(0, screenHigh-44-10-260-44-10, screenwidth, 260);
            }
        }
    } completion:^(BOOL finished) {
        [view setHidden:hidden];
        //        [self.tool setHidden:!hidden];
    }];
}
-(void)save{
    [self ViewAnimation:pickerViewContainer willHidden:YES];
}
-(void)_refreshUI
{
    [self.comfortFlagSwitch setOn:self.comfort.comfortFlag animated:YES ];
    self.overView.hidden = self.comfort.comfortFlag;
    if (self.comfort.comfortRiseTime) {  //这里是要进行判断该值是否存在
        [self.riseTimeBtn setTitle:self.comfort.comfortRiseTime forState:UIControlStateNormal];
    }else
        [self.riseTimeBtn setTitle:@"0:00" forState:UIControlStateNormal];
    if (self.comfort.comfortSleepTime) {
       [self.sleepTimeBtn setTitle:self.comfort.comfortSleepTime forState:UIControlStateNormal];
    }else
        [self.sleepTimeBtn setTitle:@"0:00" forState:UIControlStateNormal];
}

-(void)setBtnTitle{
    NSString *provinceName,*cityName;
    MyEProvinceAndCity *provinceAndCity = [[MyEProvinceAndCity alloc] init];
    for (MyEProvince *p in provinceAndCity.provinceAndCity) {
        NSLog(@"%@",p.provinceName);
        if ([p.provinceId isEqualToString:self.comfort.provinceId]) {
            provinceName = p.provinceName;
            for (MyECity *c in p.cities) {
                if ([c.cityId isEqualToString:self.comfort.cityId]) {
                    cityName = c.cityName;
                    break;
                }
            }
            break;   //break的必要性，这个可以加快程序的运行
        }
    }
    //这里特别值得注意，btn在enable未被选中的前提下，不允许修改btn的title
    UIView *view = (UIView *)[self.view viewWithTag:201];
    UIButton *btn = (UIButton *)[view viewWithTag:100];
    [btn setTitle:[NSString stringWithFormat:@"%@ %@",provinceName,cityName] forState:UIControlStateNormal];
}
- (void)decideIfComfortChanged
{
    if (self.comfort != Nil && _comfort_copy != Nil) {
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *original = [writer stringWithObject:[self.comfort JSONDictionary]];
        NSString *copy = [writer stringWithObject:[_comfort_copy JSONDictionary]];
        if ([original isEqualToString:copy]) {
            self.saveBtn.enabled = NO;
        }else
            self.saveBtn.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - setter methods
-(void)setComfort:(MyEAcComfort *)comfort
{
    if(_comfort != comfort){
        _comfort = comfort;
        _comfort_copy = [comfort copy];
        [self _refreshUI];
    }
}
#pragma mark - URL private methods
- (void)downloadComfortDataFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&id=%ld",
                        URL_FOR_AC_COMFORT_VIEW,
                        self.device.tId,
                        (long)self.device.deviceId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil delegate:self
                                 loaderName:AC_COMFORT_DOWNLOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:AC_COMFORT_DOWNLOADER_NMAE]) {
        NSLog(@"ac comfort string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"下载空调舒适度时发生错误！"];
        } else  {
            MyEAcComfort *comfort = [[MyEAcComfort alloc] initWithJSONString:string];
            if(comfort){
                self.comfort = comfort;
            }
            [self setBtnTitle];
        }
        [self decideIfComfortChanged];
    }
    if([name isEqualToString:AC_COMFORT_UPLOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"下载空调舒适度时发生错误！"];
            self.comfort = [_comfort_copy copy];// revert the value
        } else  {
            _comfort_copy = [self.comfort copy];// clone the backup data
            if (_saveToExit) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        [self decideIfComfortChanged];
    }
    
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:AC_COMFORT_DOWNLOADER_NMAE])
        msg = @"获取空调舒适度通信错误，请稍后重试.";
    else if([name isEqualToString:AC_COMFORT_UPLOADER_NMAE])
        msg = @"上传空调舒适度通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}

#pragma mark - IBAction methods
- (IBAction)comfortSwitchChanged:(UISwitch *)sender {
    self.overView.hidden = sender.isOn;
    self.comfort.comfortFlag = self.comfortFlagSwitch.on;
    [self decideIfComfortChanged];
}
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)riseTimeAction:(UIButton *)sender {
    // Show UIPickerView
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3];
//    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
//    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
//        self.pickerViewContainer.frame = CGRectMake(0, 257, 320, 261);
//    } else{
//        self.pickerViewContainer.frame = CGRectMake(0, 169, 320, 261);
//    }
//    [UIView commitAnimations];
    [self ViewAnimation:pickerViewContainer willHidden:NO];
    buttonTag = 0;
    [self.picker selectRow:[_timeArray containsObject:sender.currentTitle]?[_timeArray indexOfObject:sender.currentTitle]:0 inComponent:0 animated:YES];
}
- (IBAction)sleepTimeAction:(UIButton *)sender {
//    // Show UIPickerView
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3];
//    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
//    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
//        self.pickerViewContainer.frame = CGRectMake(0, 257, 320, 261);
//    } else{
//        self.pickerViewContainer.frame = CGRectMake(0, 120, 320, 261);
//    }
//    [UIView commitAnimations];
    [self ViewAnimation:pickerViewContainer willHidden:NO];
    buttonTag = 1;
    [self.picker selectRow:[_timeArray containsObject:sender.currentTitle]?[_timeArray indexOfObject:sender.currentTitle]:0 inComponent:0 animated:YES];
}

- (IBAction)saveComfortAction:(UIBarButtonItem *)sender {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&id=%ld&comfortFlag=%ld&comfortRiseTime=%@&comfortSleepTime=%@",
                        URL_FOR_AC_COMFORT_SAVE,
                        self.device.tId,
                        (long)self.device.deviceId,
                        (long)(self.comfort.comfortFlag?1:0),
                        self.comfort.comfortRiseTime,
                        self.comfort.comfortSleepTime];
    MyEDataLoader *uploader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil delegate:self
                                 loaderName:AC_COMFORT_UPLOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",uploader.name);
}

//    [self.mainContainer setFrame:CGRectMake(self.mainContainer.frame.origin.x, 0, self.mainContainer.frame.size.width, self.mainContainer.frame.size.height)];


#pragma mark -
#pragma mark UIPickerViewDelegate Protocol and UIPickerViewDataSource Method
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 48;
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:0].width, [pickerView rowSizeForComponent:0].height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:20];
    
    //这句代码添加之后，整个视图看上去好看多了，主要是label本身是白色的背景
    label.backgroundColor = [UIColor clearColor];
    label.text = _timeArray[row];
  //  label.text = [NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:row]];
    return label;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (buttonTag == 0) {
        self.comfort.comfortRiseTime = [NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:row]];
    }else {
        self.comfort.comfortSleepTime = [NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:row]];
    }
    [self _refreshUI];
    [self decideIfComfortChanged];
}
-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    if (self.navigationItem.rightBarButtonItem.enabled) {
        [MyEUniversal doThisWhenNeedTellUserToSaveWhenExitWithLeftBtnAction:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        } andRightBtnAction:^{
            _saveToExit = YES;
            [self saveComfortAction:nil];
        }];
    }else
        [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}
@end
