//
//  MYEACInitStepViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/9/29.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEACInitStepViewController.h"
#import "KAProgressLabel.h"
#import "MYEACBrandSelectViewController.h"

#import "MyEACManualControlNavController.h"
#import "MyEAcUserModelViewController.h"

@interface MYEACInitStepViewController (){
    MBProgressHUD *HUD;
    
    BOOL _needRefresh;
    BOOL _isBrand;
    
    //下载相关
    NSInteger requestTimes;
    NSInteger requestCircles;
    float progressLast;
    UIButton *cancelButton;
    KAProgressLabel *progressLabel;
    __block UIImageView *imageView;
    UITapGestureRecognizer *tapGestureToHideHUD;
    NSInteger acInitFailureTimes;
    NSTimer *timer;
    NSInteger _brandDownloadTimes;
    
    BOOL _isFinished;  //表示当屏幕关掉的时候已经下载完成
    
    NSTimer *_counter;
    NSInteger _counterTime;
}

@property (weak, nonatomic) IBOutlet UILabel *lblBrand;
@property (weak, nonatomic) IBOutlet UILabel *lblModel;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeCounter;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@end

@implementation MYEACInitStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    if (self.step == 1) {
        self.title = @"品牌选择";
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSDate *date = [def objectForKey:USERDEFAULT_FOR_AC_BRANDS_DATE];
        if (date) {
            if ([[NSDate date] timeIntervalSinceDate:date] > 24*60*60) {
                [self downloadAcBrandsAndModules];
            }else{
                _brandAndModels = [MyEUtil readObjectWithFileName:FILE_FOR_AC_BRANDS];
                if (_brandAndModels == nil) {
                    [self downloadAcBrandsAndModules];
                }
            }
        }else{
            [self downloadAcBrandsAndModules];
        }
    }else if (self.step == 2) {
        self.title = @"指令库下载";
        [self refreshUI];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }else{
        _counterTime = 5;
        self.title = @"开始控制";
        _counter = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
    }

    if (IS_IOS6) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = TableViewGroupBGColor;
        self.tableView.backgroundView = view;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (_needRefresh) {
        _needRefresh = NO;
        if (_isBrand) {
            _isBrand = NO;
            NSArray *array = self.brandAndModels.selectedIndex == 0?self.brandAndModels.sysAcBrands:self.brandAndModels.userAcBrands;
            if (_index > array.count) {
                _currentBrand = array[0];
            }else
                _currentBrand = array[_index == -1?0:_index];
            _currentModel = [_currentBrand firstUsefulModel];
        }else
            _currentModel = _currentBrand.models[_index == -1?0:_index];
        [self refreshUI];
    }

}
-(void)dealloc{
    if (self.step == 2) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - Private methods
-(void)pushVCWithStep:(NSInteger)step{
    MYEACInitStepViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:step == 2? @"download":@"control"];
    vc.brandAndModels = self.brandAndModels;
    vc.currentBrand = self.currentBrand;
    vc.currentModel = self.currentModel;
    vc.device = self .device;
    vc.step = step;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)refreshUI{
    _lblBrand.text = self.currentBrand.brandName;
    _lblModel.text = self.currentModel.modelName;
    [self.tableView setNeedsDisplay];
}
-(void)handleTimer{
    _counterTime --;
    self.lblTimeCounter.text = [NSString stringWithFormat:@"%i",_counterTime];
    if (_counterTime == 0) {
        [_counter invalidate];
        [self goToACControl];
    }
}
-(void)goToACControl{
    if (_counter.isValid) {
        [_counter invalidate];
    }
    NSString *str = IS_IPAD?@"standerdControlForIPad": @"standerdControl";
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"AcDevice" bundle:nil] instantiateViewControllerWithIdentifier:self.device.isSystemDefined?str:@"customControl"];
    [vc setValue:self.device forKey:@"device"];
    [vc setValue:@(YES) forKey:@"isPush"];
    [self.navigationController pushViewController:vc animated:YES];

}
-(void)didEnterBackground{
    if (!_isFinished) {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [cancelButton removeFromSuperview];
        [timer invalidate];
        [HUD hide:YES];
        self.device.brand = @"";
        self.device.brandId = 0;
        self.device.model = @"";
        self.device.modelId = 0;
    }
}
//这个不能删掉。是用来取消HUD的
-(void)defineTapGestureRecognizerOnWindow{
    tapGestureToHideHUD = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHUD)];
    tapGestureToHideHUD.cancelsTouchesInView = NO;
    [self.view.window addGestureRecognizer:tapGestureToHideHUD];
}
-(void)hideHUD{
    [HUD hide:YES];
    [self.view.window removeGestureRecognizer:tapGestureToHideHUD];
}
-(void)acInit{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    /*---------------初始化cancelBtn---------------*/
    cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = CGRectMake(screenwidth/2-100, screenHigh-20-44-44, 200, 40);
    [cancelButton setTitle:@"取消下载" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(areYouSureTocancelAcInit) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.userInteractionEnabled = YES;
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"deleteBtn"] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    cancelButton.backgroundColor = [UIColor redColor];
    //    cancelButton.tintColor = [UIColor whiteColor];
    
    //在这里对这些值进行初始化
    requestCircles = 0;
    requestTimes = 0;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    [self.view.window addSubview:HUD];
    HUD.detailsLabelText = @"正在下载...";
    HUD.dimBackground = YES; //增加背景灰度
    HUD.margin = 10;
    HUD.opacity = 0.6;
    HUD.cornerRadius = 4;
    HUD.square = YES;
    HUD.minSize = CGSizeMake(110.f, 110.f);
    
    [HUD show:YES];
    [self.view.window addSubview:cancelButton];
    //#warning    //这里使用的异步进程处理方式，以免阻塞主进程
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        /*----------这个是在下载进度的时候使用的，不过先在此处准备好--------------*/
        progressLabel = [[KAProgressLabel alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
        
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [label setText:[NSString stringWithFormat:@"%.0f%%", (progress*100)]];
            });
        };
        progressLabel.textAlignment = NSTextAlignmentCenter;
        progressLabel.textColor = [UIColor whiteColor];
        progressLabel.text = @"0%";
        progressLabel.font = [UIFont systemFontOfSize:20];
        progressLabel.borderWidth = 3;
        progressLabel.colorTable = @{
                                     NSStringFromProgressLabelColorTableKey(ProgressLabelTrackColor):[UIColor blackColor],
                                     NSStringFromProgressLabelColorTableKey(ProgressLabelProgressColor):[UIColor whiteColor]
                                     };
        //                dispatch_sync(dispatch_get_main_queue(), ^{
        //                    UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        //                    imageView = [[UIImageView alloc] initWithImage:image];
        //                });
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
    });
    [self doThisWhenAcInit];
}
-(void)areYouSureTocancelAcInit{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"此操作将终止空调指令库下载,你确定继续么？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 101;
    [alert show];
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (self.step == 1) {
            [self nextStep];
        }else if (self.step == 2){
            [self acInit];
        }else
            [self goToACControl];
    }
}
#pragma mark - IBAction methods
- (void)nextStep{
    if (self.currentBrand == nil || self.currentModel == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未选择型号或该型号的指令未学习" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (self.brandAndModels.selectedIndex == 1 && self.currentModel.study < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该型号的指令未学习" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self pushVCWithStep:2];
}

- (IBAction)cancelTimer:(UIButton *)sender {
    [_counter invalidate];
    self.coverView.hidden = NO;
}

#pragma mark - UINavigation methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MYEACBrandSelectViewController *vc = segue.destinationViewController;
    vc.brandAndModels = self.brandAndModels;
    vc.brand = self.currentBrand;
    vc.isACInit = YES;
    vc.device = self.device;
    _needRefresh = YES;
    if ([segue.identifier isEqualToString:@"brand"]) {
        vc.isBrand = YES;
        _isBrand = YES;
    }
    if (_isBrand) {   //选择品牌
        NSArray *array = self.brandAndModels.selectedIndex == 0? self.brandAndModels.sysAcBrands: self.brandAndModels.userAcBrands;
        if ([array containsObject:_currentBrand]) {
            _index = [array indexOfObject:_currentBrand];
        }else
            _index = -1;
    }else{
        if ([_currentBrand.models containsObject:_currentModel]) {
            _index = [_currentBrand.models indexOfObject:_currentModel];
        }else
            _index = -1;
    }

    vc.index = self.index;
}
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([identifier isEqualToString:@"model"]) {
        if (_currentBrand == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先选择品牌" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
    return YES;
}
#pragma mark - URL Methods
-(void)downloadAcBrandsAndModules{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@",GetRequst(URL_FOR_IR_LIST_AC_MODELS), MainDelegate.accountData.userId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"downloadAcBrandsAndModules" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

-(void)doThisWhenAcInit{
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%li&action=0&brandId=%i&moduleId=%i&tId=%@",
                        GetRequst(URL_FOR_AC_INIT),
                        (long)self.device.deviceId,
                        _currentBrand.brandId,
                        _currentModel.modelId,
                        self.device.tId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"acInit" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
-(void)checkAcInitProgress{
    
    requestTimes ++;
    if (requestTimes == 12) {
        requestCircles ++;
        requestTimes = 0;
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%li&action=1&brandId=%i&moduleId=%i&tId=%@",
                        GetRequst(URL_FOR_AC_INIT),
                        (long)self.device.deviceId,
                        _currentBrand.brandId,
                        _currentModel.modelId,
                        self.device.tId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"checkAcInitProgress" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
-(void)cancelAcInit{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    //    //写这个是为了取消初始化点击后，后台不在进行请求
    //    requestCircles = 4;
    [timer invalidate]; //取消初始化的时候就把timer注销掉
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.detailsLabelText = @"正在取消初始化";
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%li&action=2&brandId=%i&moduleId=%i&tId=%@",GetRequst(URL_FOR_AC_INIT), (long)self.device.deviceId,_currentBrand.brandId,_currentModel.modelId,self.device.tId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"cancelAcInit" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    NSInteger i = [MyEUtil getResultFromAjaxString:string];
    
    if (i == -3) {
        [timer invalidate];
        [HUD hide:YES];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [cancelButton removeFromSuperview];
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
        return;
    }
    if ([name isEqualToString:@"downloadAcBrandsAndModules"]) {
        if (i == 1) {
//            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//            [def setObject:string forKey:BRANDS_AND_MODELS];
            self.brandAndModels = [[MyEAcBrandsAndModels alloc] initWithJSONString:string];
            if (self.brandAndModels != nil) {
                [MyEUtil saveObject:self.brandAndModels withFileName:FILE_FOR_AC_BRANDS];
                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                [def setObject:[NSDate date] forKey:USERDEFAULT_FOR_AC_BRANDS_DATE];
            }
        } else {
            [MyEUtil showMessageOn:nil withMessage:@"指令库下载失败"];
        }
        [HUD hide:YES];
    }
    if ([name isEqualToString:@"checkAcInitProgress"]) {
        if (i != 1) {
            [HUD hide:YES];
            [timer invalidate];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            HUD.detailsLabelText = @"进度查询失败!";
        }else{
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dic = [parser objectWithString:string];
            float progress = [dic[@"progress"] floatValue];
            
            if (progress == 0) {
                HUD.detailsLabelText = @"正在查询进度...";
            }else{
                HUD.customView = progressLabel;
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.detailsLabelText = @"";
                [progressLabel setProgress:progress/100];
            }
            if (progressLast == progress) {
                NSLog(@"requestTimes is %li requestCircles is %li",(long)requestTimes,(long)requestCircles);
                if (requestCircles < 3 && requestTimes < 12) {
                    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkAcInitProgress) userInfo:nil repeats:NO];
                }else{
                    [timer invalidate];
                    [cancelButton removeFromSuperview];
                    //#warning 这里添加一个下载失败的笑脸图案
                    HUD.detailsLabelText = @"指令库下载失败";
                    [UIApplication sharedApplication].idleTimerDisabled = NO;
                    [self defineTapGestureRecognizerOnWindow];
                }
            }else{
                if (progress < 100) {
                    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkAcInitProgress) userInfo:nil repeats:NO];
                }else{
                    [UIApplication sharedApplication].idleTimerDisabled = NO;
                    _isFinished = YES;
                    [timer invalidate];
                    [cancelButton removeFromSuperview];
                    HUD.customView = imageView;
                    HUD.mode = MBProgressHUDModeCustomView;
                    HUD.detailsLabelText = @"指令库下载完成";
                    [HUD hide:YES afterDelay:2];
                    self.device.brand = _currentBrand.brandName;
                    self.device.model = _currentModel.modelName;
                    self.device.brandId = _currentBrand.brandId;
                    self.device.modelId = _currentModel.modelId;
                    self.device.isSystemDefined = self.brandAndModels.selectedIndex == 0;
                    self.device.status.powerSwitch = 0;
                    [self performSelector:@selector(pushVCWithStep:) withObject:@(3) afterDelay:2];
                }
            }
            //记录上次的progress
            progressLast = progress;
        }
    }
    
    if ([name isEqualToString:@"acInit"]) {
        if (i != 1) {
            //如果失败就继续请求，直到请求超过4次，就提示失败
            acInitFailureTimes ++;
            if (acInitFailureTimes < 5) {
                [self doThisWhenAcInit];
            }else{
                HUD.detailsLabelText = @"空调初始化失败";
                //                [MyEUtil showMessageOn:self.navigationController.view withMessage:@"空调初始化失败"];
                [cancelButton removeFromSuperview];
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                [HUD hide:YES afterDelay:2];
            }
        }else{
            HUD.detailsLabelText = @"查询初始化进度";
            requestTimes = 0;
            progressLast = 0;
            [self checkAcInitProgress];
        }
    }
    
    if ([name isEqualToString:@"cancelAcInit"]) {
        if (i != 1) {
            HUD.detailsLabelText = @"初始化取消失败";
            [HUD hide:YES afterDelay:2];
            [cancelButton removeFromSuperview];
        }else{
            HUD.customView = imageView;
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.detailsLabelText = @"初始化取消成功";
            [HUD hide:YES afterDelay:2];
            [cancelButton removeFromSuperview];
            self.device.brand = @"";
            self.device.brandId = 0;
            self.device.model = @"";
            self.device.modelId = 0;
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [cancelButton removeFromSuperview];
    [HUD hide:YES];
    [MyEUtil showMessageOn:nil withMessage:@"与服务器通信发生错误,请稍候重试"];
}

#pragma mark - UIAlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        [self acInit];
    }
    if (alertView.tag == 101 && buttonIndex == 1) {
        [self cancelAcInit];
    }
}

@end
