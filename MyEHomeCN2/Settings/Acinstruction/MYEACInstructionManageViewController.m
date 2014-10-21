//
//  MYEACInstructionManageViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/9/22.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEACInstructionManageViewController.h"

#import "MyEAcModel.h"
#import "MyEAcBrand.h"
#import "MyEAcBrandsAndModels.h"
#import "MBProgressHUD.h"
#import "MyEDataLoader.h"
#import "MyEAccountData.h"
#import "MyEUniversal.h"
#import "MyEUtil.h"
#import "MYEACBrandSelectViewController.h"
#import "MyEAcInstructionAutoCheckViewController.h"
#import "MyEAcInstructionListViewController.h"
#import "MyEAcAddNewBrandAndModuleViewController.h"

@interface MYEACInstructionManageViewController ()<MyEDataLoaderDelegate,UIAlertViewDelegate>{
    MBProgressHUD *HUD;
    MyEAcBrand *_currentBrand;
    MyEAcModel *_currentModel;
    NSArray *_models;
    
    BOOL _needRefresh;
    BOOL _isBrand;  //YES表示此时正在选择品牌
    
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

}

@property(nonatomic,strong) MyEAcBrandsAndModels *brandsAndModels;
@property (weak, nonatomic) IBOutlet UILabel *downloadLbl;

@property (weak, nonatomic) IBOutlet UILabel *brandLbl;
@property (weak, nonatomic) IBOutlet UILabel *modelLbl;
@property (weak, nonatomic) IBOutlet UIView *tableHeadView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *librarySelectSeg;

@property (weak, nonatomic) IBOutlet UIButton *autoCheckBtn;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;  //这个按钮的title是变化的，不同状态下不同title

@end

#define BRANDS_AND_MODELS @"brandsAndModels"
@implementation MYEACInstructionManageViewController

#pragma mark - life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"指令库管理";
    _index = -1;   //
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *string = [def objectForKey:BRANDS_AND_MODELS];
    if (string) {
        self.brandsAndModels = [[MyEAcBrandsAndModels alloc] initWithJSONString:string];
        if (!self.brandsAndModels) {
            [self downloadAcBrandsAndModules];
        }
        [self getData];
        [self refreshUI];
    }else
        [self downloadAcBrandsAndModules];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    if (IS_IOS6) {
        for (UISegmentedControl *s in self.tableView.tableHeaderView.subviews) {
            s.layer.borderColor = MainColor.CGColor;
            s.layer.borderWidth = 1.0f;
            s.layer.cornerRadius = 4.0f;
            s.layer.masksToBounds = YES;
        }
    }
    if (IS_IOS6) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = TableViewGroupBGColor;
        self.tableView.backgroundView = view;
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (_needRefresh) {
        _needRefresh = NO;
        if (_isBrand) {
            NSArray *array = self.brandsAndModels.selectedIndex == 0?self.brandsAndModels.sysAcBrands:self.brandsAndModels.userAcBrands;
            _currentBrand = array[_index];
            _currentModel = _currentBrand.models[0];
        }else
            _currentModel = _currentBrand.models[_index];
        [self refreshUI];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - private methods
-(void)getData{
    _currentBrand = [self.brandsAndModels findBrandByBrandId:_device.brandId];
    _currentModel = [self.brandsAndModels findModelByModelId:_device.modelId inBrand:_currentBrand];
}
-(void)refreshUI{
    if (self.brandsAndModels.userAcBrands.count) {
        self.tableView.tableHeaderView = self.tableHeadView;
    }else
        self.tableView.tableHeaderView = nil;
    [self.librarySelectSeg setSelectedSegmentIndex:self.brandsAndModels.selectedIndex];
    self.brandLbl.text = _currentBrand.brandName;
    self.modelLbl.text = _currentModel.modelName;

    [self.downloadLbl setText:_currentModel.study == 0?@"指令未学习,不允许下载":@"下载所选指令库"];
    
    if(self.brandsAndModels.selectedIndex == 0){
        self.autoCheckBtn.hidden = NO;
        if (self.brandsAndModels.userAcBrands.count < 1) {
            [self.changeBtn setTitle:@"找不到型号?点这里" forState:UIControlStateNormal];
        }else
            self.changeBtn.hidden = YES;
    }else{
        self.autoCheckBtn.hidden = YES;
        self.changeBtn.hidden = NO;
        [self.changeBtn setTitle:@"新增型号" forState:UIControlStateNormal];
    }
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
    cancelButton.frame = CGRectMake(60, screenHigh-20-44-44, 200, 40);
    [cancelButton setTitle:@"取消初始化" forState:UIControlStateNormal];
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
    HUD.detailsLabelText = @"正在初始化...";
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"此操作将终止空调初始化，你确定继续么？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 101;
    [alert show];
}

- (void)check{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"autoCheck"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.presentedFormSheetSize = CGSizeMake(290, 350); //指定弹出视图的高度和宽度
    
    //这里必须要知道以下这种方法的运行方法
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        navController.topViewController.title = @"空调型号自动匹配";
        MyEAcInstructionAutoCheckViewController *vc = (MyEAcInstructionAutoCheckViewController *)navController.topViewController;
        vc.brandsAndModules = self.brandsAndModels;
        vc.device = self.device;
//        vc.brandNameArray = self.brandNameArray;
//        vc.brandIdArray = self.brandIdArray;
//        vc.moduleIdArray = self.modelIdArray;
//        vc.moduleNameArray = self.modelNameArray;
//        //从当前选择的品牌和型号开始匹配
//        vc.brandLabel.text = brandBtn.titleLabel.text;
//        vc.modelLabel.text = modelBtn.titleLabel.text;
//        
//        //在这里对值进行初始化,以便接着前面面板点击的内容快速进行
//        vc.brandIdIndex = [brandNameArray indexOfObject:brandBtn.titleLabel.text];
//        vc.moduleIdIndex = [modelNameArray indexOfObject:modelBtn.titleLabel.text];
//        vc.startIndex = vc.moduleIdIndex;  //这里对startIndex进行赋值
        //        NSLog(@"%i %i",vc.brandIdIndex,vc.moduleIdIndex);
        
        //        vc.brandLabel.text = brandNameArray[0];
        //        vc.modelLabel.text = modelNameArray[0];
    };
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController){
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        MyEAcInstructionAutoCheckViewController *vc = (MyEAcInstructionAutoCheckViewController *)navController.topViewController;
//        self.brandNameArray = vc.brandNameArray;
//        self.brandIdArray = vc.brandIdArray;
//        self.modelNameArray = vc.moduleNameArray;
//        self.modelIdArray = vc.moduleIdArray;
//        [self.brandBtn setTitle:vc.brandLabel.text forState:UIControlStateNormal];
//        [self.modelBtn setTitle:vc.modelLabel.text forState:UIControlStateNormal];
    };
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:nil];
}
- (void)editInstruction{
    //其实这里对于MZFormSheetController有了更为深刻的了解
    MyEAcInstructionListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"instructionList"];
    vc.device = self.device;
    vc.moduleId = _currentModel.modelId;
    vc.brandId = _currentBrand.brandId;
    vc.jumpFromEditBtn = YES;
    vc.labelText = [NSString stringWithFormat:@"%@ - %@",_currentBrand.brandName,_currentModel.modelName];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - IBAction methods
- (IBAction)selectMode:(UISegmentedControl *)sender {
    self.brandsAndModels.selectedIndex = sender.selectedSegmentIndex;
    [self getData];
    [self refreshUI];
    [self.tableView reloadData];
}
- (IBAction)autoCheck:(UIButton *)sender {
    [self check];
}
- (IBAction)addModel:(UIButton *)sender {
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addNew"];
    //#warning 这里要对formsheet进行定制，主要是调整视图大小和页面控件的布局
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsMoveToTop;
    formSheet.presentedFormSheetSize = CGSizeMake(284, 209); //指定弹出视图的高度和宽度
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        navController.topViewController.title = @"请输入新增的空调品牌和型号";
        MyEAcAddNewBrandAndModuleViewController *modalVc = (MyEAcAddNewBrandAndModuleViewController *)navController.topViewController;
        modalVc.brandsAndModules = self.brandsAndModels;
        modalVc.device = self.device;
    };
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:nil];
    
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController) {
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        MyEAcAddNewBrandAndModuleViewController *modalVc = (MyEAcAddNewBrandAndModuleViewController *)navController.topViewController;
        
        if (!modalVc.cancelBtnPressed) {
            _currentBrand = modalVc.brandNew;
            _currentModel = modalVc.modelNew;
            [self refreshUI];
            [self editInstruction];
        }
    };
}

#pragma mark - UITableView dataSource methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1 && self.brandsAndModels.selectedIndex == 0) {
        return 1;
    }
    return 2;
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        MYEACBrandSelectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"brand"];
        vc.brandAndModels = self.brandsAndModels;
        if (indexPath.row == 0) {   //选择品牌
            NSArray *array = self.brandsAndModels.selectedIndex == 0? self.brandsAndModels.sysAcBrands: self.brandsAndModels.userAcBrands;
            _index = [array indexOfObject:_currentBrand];
        }else
            _index = [_currentBrand.models indexOfObject:_currentModel];
        vc.index = _index;
        vc.brand = _currentBrand;
        _needRefresh = YES;
        _isBrand = indexPath.row == 0;
        vc.isBrand = indexPath.row == 0;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (_currentModel.study == 0) {
                return;
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:[NSString stringWithFormat:@"您现在选择下载的指令库为:\n%@-%@\n如果之前已下载则会覆盖,确定开始么?",_currentBrand.brandName,_currentModel.modelName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开始下载", nil];
            alert.tag = 100;
            [alert show];
        }else{
            [self editInstruction];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

-(void)acInitWithAction:(NSInteger)action{   //0:开始下载  1:查询进度  2:取消下载
    
    if (action == 1) {
        requestTimes ++;
        if (requestTimes == 12) {
            requestCircles ++;
            requestTimes = 0;
        }
    }
    if (action == 2) {
        [timer invalidate]; //取消初始化的时候就把timer注销掉
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.detailsLabelText = @"正在取消初始化";
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%li&action=%i&brandId=%i&moduleId=%i&tId=%@",
                        GetRequst(URL_FOR_AC_INIT),
                        (long)self.device.deviceId,
                        action,
                        _currentBrand.brandId,
                        _currentModel.modelId,
                        self.device.tId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"acInit" userDataDictionary:nil];
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
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def setObject:string forKey:BRANDS_AND_MODELS];
            self.brandsAndModels = [[MyEAcBrandsAndModels alloc] initWithJSONString:string];
            [self getData];
            [self refreshUI];
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
                    HUD.detailsLabelText = @"空调初始化失败";
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
                    HUD.detailsLabelText = @"空调初始化完成";
                    [self defineTapGestureRecognizerOnWindow];
                    //                    [HUD hide:YES afterDelay:2];
                    self.device.brand = _currentBrand.brandName;
                    self.device.model = _currentModel.modelName;
                    self.device.brandId = _currentBrand.brandId;
                    self.device.modelId = _currentModel.modelId;
                    self.device.isSystemDefined = self.brandsAndModels.selectedIndex == 0;
                    self.device.status.powerSwitch = 0;
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
