//
//  MyEAcStandardInstructionViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-20.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcStandardInstructionViewController.h"

@interface MyEAcStandardInstructionViewController (){
    BOOL _isFinished;  //表示当屏幕关掉的时候已经下载完成
}

@end

@implementation MyEAcStandardInstructionViewController
@synthesize brandIdArray,brandNameArray,modelIdArray,modelNameArray,brandBtn,modelBtn;

#pragma mark - life circle methods

//以下的这行代码是导致tabbar上残留文字的罪魁祸首，这个以后要多加注意
//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:YES];
//    self.navigationController.topViewController.title = @"标准库";
//}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //这里是以view的形式加载的，所以这里要对4寸和3.5寸的屏幕做适配,以防不适应屏幕的变化
    if (IS_IPHONE5) {
        self.view.frame = CGRectMake(0, 0, 320, 393);
    }else
        self.view.frame = CGRectMake(0, 0, 320, 305);

    _brandDownloadTimes = 0;
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [btn setFrame:CGRectMake(0, 0, 50, 30)];
//    if (!IS_IOS6) {
//        [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
//    }else{
//        [btn setBackgroundImage:[UIImage imageNamed:@"back-ios6"] forState:UIControlStateNormal];
//        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
//        btn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    }
//    [btn setTitle:@"返回" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

    
//    self.navigationController.navigationBar.topItem.title = @"自学习库";
//    self.navigationController.topViewController.title = @"标准库";
//    vc.navigationController.navigationBar.topItem.title = @"标准库";
    [self downloadAcBrandsAndModules];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
//    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                if (btn.tag == 100 || btn.tag == 101) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
                }else{
                    if (!IS_IOS6) {
                        btn.layer.masksToBounds = YES;
                        btn.layer.cornerRadius = 4;
                        btn.layer.borderColor = btn.tintColor.CGColor;
                        btn.layer.borderWidth = 1;
                    }
                }
            }
        }
//    }else{
//        for (UIButton *btn in self.view.subviews) {
//            if (btn.tag == 100 || btn.tag == 101) {
//                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn-ios6"] forState:UIControlStateNormal];
//                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
//            }
//        }
//    }
}

#pragma mark - private methods
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
        //特别注意此处对于label内容更新的处理
        for (UILabel *l in self.view.superview.superview.subviews) {
            if ([l isKindOfClass:[UILabel class]] && l.tag == 100) {
                l.text = @"空调未初始化";
            }
        }
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

-(void)findModelArrayWithIndex:(NSInteger)index{
    NSMutableArray *modules = [NSMutableArray array];
    NSMutableArray *moduleIds = [NSMutableArray array];
    MyEAcBrand *brand = self.brandsAndModels.sysAcBrands[index];
    for (int i=0; i<[self.brandsAndModels.sysAcModels count]; i++) {
        MyEAcModel *module = self.brandsAndModels.sysAcModels[i];
        for (int j=0; j<[brand.models count]; j++) {
            if (module.modelId == [brand.models[j] intValue]) {
                [modules addObject:module.modelName];
                [moduleIds addObject:[NSNumber numberWithInteger:module.modelId]];
            }
        }
    }
    self.modelNameArray = modules;
    self.modelIdArray = moduleIds;
}
//之前还以为是这么传值的
//-(void)viewWillDisappear:(BOOL)animated{
//    MyEAcCustomInstructionViewController *custom = (MyEAcCustomInstructionViewController *)[self.tabBarController viewControllers][1];
//    NSLog(@"%@",self.brandsAndModules);
//    custom.brandsAndModules = self.brandsAndModules;
//    NSLog(@"%@",custom.brandsAndModules);
//}
#pragma mark - URL private methods

-(void)checkAcInitProgress{
    
    requestTimes ++;
    if (requestTimes == 12) {
        requestCircles ++;
        requestTimes = 0;
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%li&action=1&brandId=%i&moduleId=%@&tId=%@",
                        URL_FOR_AC_INIT,
                        (long)self.device.deviceId,
                        [brandIdArray[[brandNameArray indexOfObject:brandBtn.titleLabel.text]] intValue],
                        modelIdArray[[modelNameArray indexOfObject:modelBtn.titleLabel.text]],
                        self.device.tId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"checkAcInitProgress" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

-(void)downloadAcBrandsAndModules{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@",URL_FOR_IR_LIST_AC_MODELS, self.accountData.userId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"downloadAcBrandsAndModules" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
-(void)doThisWhenAcInit{
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%li&action=0&brandId=%i&moduleId=%@&tId=%@",
                        URL_FOR_AC_INIT,
                        (long)self.device.deviceId,
                        [brandIdArray[[brandNameArray indexOfObject:brandBtn.titleLabel.text]] intValue],
                        modelIdArray[[modelNameArray indexOfObject:modelBtn.titleLabel.text]],
                        self.device.tId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"acInit" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
-(void)areYouSureTocancelAcInit{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                contentText:@"此操作将终止空调初始化，你确定继续么？"
                                            leftButtonTitle:@"取消"
                                           rightButtonTitle:@"确定"];
    [alert show];
    alert.rightBlock = ^() {
        [self cancelAcInit];
    };
}
-(void)cancelAcInit{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    //写这个是为了取消初始化点击后，后台不在进行请求
//    requestCircles = 4;
    [timer invalidate]; //取消初始化的时候就把timer注销掉
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.detailsLabelText = @"正在取消初始化";
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%li&action=2&brandId=%i&moduleId=%@&tId=%@",URL_FOR_AC_INIT, (long)self.device.deviceId,[brandIdArray[[brandNameArray indexOfObject:brandBtn.titleLabel.text]] intValue],modelIdArray[[modelNameArray indexOfObject:modelBtn.titleLabel.text]],self.device.tId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"cancelAcInit" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL Methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if ([name isEqualToString:@"checkAcInitProgress"]) {
        NSLog(@"%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [HUD hide:YES];
            [timer invalidate];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [HUD hide:YES];
            [timer invalidate];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            HUD.detailsLabelText = @"进度查询失败!";
//            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"初始化进度查询失败"];
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
                    self.device.brand = brandBtn.titleLabel.text;
                    self.device.model = modelBtn.titleLabel.text;
                    self.device.brandId = [brandIdArray[[brandNameArray indexOfObject:brandBtn.titleLabel.text]] integerValue];
                    self.device.modelId = [modelIdArray[[modelNameArray indexOfObject:modelBtn.titleLabel.text]] integerValue];
                    self.device.isSystemDefined = YES;
                    self.device.status.powerSwitch = 0;
                    //特别注意此处对于label内容更新的处理
                    for (UILabel *l in self.view.superview.superview.subviews) {
                        if ([l isKindOfClass:[UILabel class]] && l.tag == 100) {
                            l.text = [NSString stringWithFormat:@"%@   %@",brandBtn.titleLabel.text,modelBtn.titleLabel.text];;
                        }
                    }
                }
            }
            //记录上次的progress
            progressLast = progress;
        }
    }
    if ([name isEqualToString:@"acInit"]) {
        NSLog(@"%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            [HUD hide:YES];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            [cancelButton removeFromSuperview];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
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
        NSLog(@"%@",string);
        [timer invalidate];
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [HUD hide:YES];
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
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
            //特别注意此处对于label内容更新的处理
            for (UILabel *l in self.view.superview.superview.subviews) {
                if ([l isKindOfClass:[UILabel class]] && l.tag == 100) {
                    l.text = @"空调未初始化";
                }
            }
        }
    }

    if([name isEqualToString:@"downloadAcBrandsAndModules"]) {
        [HUD hide:YES];
//        NSLog(@"downloadAcBrandsAndModules JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            //这里针对下载错误要做特殊处理，如果下载失败则不能继续进行操作
            _brandDownloadTimes++;
            MyEInstructionManageViewController *vc = (MyEInstructionManageViewController *)self.view.superview.superview.nextResponder;
            if (_brandDownloadTimes < 3) {
                DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示" contentText:@"未能成功下载空调品牌数据，是否再次请求下载？" leftButtonTitle:@"取消" rightButtonTitle:@"下载"];
                [alert show];
                alert.leftBlock = ^{
                    [vc.navigationController popViewControllerAnimated:YES];
                };
                alert.rightBlock = ^{
                    [self downloadAcBrandsAndModules];
                };
            }else{
                _brandDownloadTimes = 0;
                DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示" contentText:@"空调指令库下载失败，此时您不能继续进行操作，请返回上级" leftButtonTitle:nil rightButtonTitle:@"知道了"];
                [alert show];
                alert.rightBlock = ^{
                    [vc.navigationController popViewControllerAnimated:YES];
                };
            }
        }else{
            MyEAcBrandsAndModels *ac = [[MyEAcBrandsAndModels alloc] initWithJSONString:string];
            self.brandsAndModels = ac;
//            MyEAcBrand *brand = self.brandsAndModules.sysAcBrands[0];
//            NSLog(@"%@",brand.brandName);
            //这里需要注意的时tab之间传值时，不能在viewwillapper里面传值，这时候值的传递有问题，应该在接收到值的时候传值
//            UINavigationController *nav = [self.tabBarController viewControllers][1];
            
//            UINavigationController *nav = [self.tabBarController viewControllers][1];
//            MyEAcCustomInstructionViewController *custom = (MyEAcCustomInstructionViewController *)[nav viewControllers][0];
//            custom.brandsAndModels = self.brandsAndModels;
//            custom.device = self.device;
            //向同一级别的customInstructionVC传值
            [self.delegate passValue:self.brandsAndModels];
            
            NSMutableArray *brands = [NSMutableArray array];
            NSMutableArray *brandIds = [NSMutableArray array];
            for (int i=0; i<[self.brandsAndModels.sysAcBrands count]; i++) {
                MyEAcBrand *brand = self.brandsAndModels.sysAcBrands[i];
                [brands addObject:brand.brandName];
                [brandIds addObject:[NSNumber numberWithInteger:brand.brandId]];
            }
            self.brandNameArray = brands;
            self.brandIdArray = brandIds;
            
            if (![self.device.brand isEqualToString:@""] && self.device.isSystemDefined) {
                [brandBtn setTitle:self.device.brand forState:UIControlStateNormal];
                [modelBtn setTitle:self.device.model forState:UIControlStateNormal];
                [self findModelArrayWithIndex:[self.brandNameArray indexOfObject:self.device.brand]];
            }else{
                [self findModelArrayWithIndex:0];
                [brandBtn setTitle:brandNameArray[0] forState:UIControlStateNormal];
                [modelBtn setTitle:modelNameArray[0] forState:UIControlStateNormal];
            }
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg = @"与服务器通信时发生错误，请稍后重试.";
    
    [MyEUtil showMessageOn:nil withMessage:msg];
    [HUD hide:YES];
}


#pragma mark - picker dataSource
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (pickerTag) {
        case 1:
            return [brandNameArray count];
            break;
        default:
            return [modelNameArray count];
            break;
    }
}
//定制picker的view，从而是的picker的文本可以居中显示
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:0].width, [pickerView rowSizeForComponent:0].height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:20];
    //这句代码添加之后，整个视图看上去好看多了，主要是label本身是白色的背景
    label.backgroundColor = [UIColor clearColor];
    switch (pickerTag) {
        case 1:
            label.text = brandNameArray[row];
            break;
        default:
            label.text = modelNameArray[row];
            break;
    }
    return label;
}

#pragma mark - picker delegate methods
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    switch (pickerView.tag)
    {
        case 1:
            [brandBtn setTitle:titles[0] forState:UIControlStateNormal];
            [self refreshModuleArrayWithRow:[brandNameArray indexOfObject:brandBtn.currentTitle]];
            break;
        case 2:
            [modelBtn setTitle:titles[0] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (pickerTag) {
        case 1:
            [brandBtn setTitle:brandNameArray[row] forState:UIControlStateNormal];
            [self refreshModuleArrayWithRow:row];
            break;
        default:
            [modelBtn setTitle:modelNameArray[row] forState:UIControlStateNormal];
            break;
    }
}

-(void)refreshModuleArrayWithRow:(NSInteger)row{
    
    NSMutableArray *modules = [NSMutableArray array];
    NSMutableArray *moduleIds = [NSMutableArray array];
    MyEAcBrand *brand = self.brandsAndModels.sysAcBrands[row];
    for (int i=0; i<[self.brandsAndModels.sysAcModels count]; i++) {
        MyEAcModel *module = self.brandsAndModels.sysAcModels[i];
        for (int j=0; j<[brand.models count]; j++) {
            if (module.modelId == [brand.models[j] intValue]) {
                [modules addObject:module.modelName];
                [moduleIds addObject:[NSNumber numberWithInteger:module.modelId]];
            }
        }
    }
    self.modelNameArray = modules;
    self.modelIdArray = moduleIds;
    [modelBtn setTitle:modelNameArray[0] forState:UIControlStateNormal];
}

#pragma mark - IBAction methods

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)brandBtnPress:(UIButton *)sender{
    [self.tabBarController.tabBar setHidden:YES];
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择空调品牌" andDelegate:self andTag:1 andArray:brandNameArray andSelectRow:[brandNameArray indexOfObject:brandBtn.titleLabel.text] andViewController:self];
//    pickerTag = 1;
//    [self ViewAnimation:pickerContainer willHidden:NO];
//    [picker reloadAllComponents];
//    [picker selectRow:[brandNameArray indexOfObject:brandBtn.titleLabel.text] inComponent:0 animated:YES];
}
- (IBAction)modelBtnPress:(UIButton *)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择遥控器型号" andDelegate:self andTag:2 andArray:modelNameArray andSelectRow:[modelNameArray indexOfObject:modelBtn.titleLabel.text] andViewController:self];
//    pickerTag = 2;
//    [self ViewAnimation:pickerContainer willHidden:NO];
//    [picker reloadAllComponents];
//    [picker selectRow:[modelNameArray indexOfObject:modelBtn.titleLabel.text] inComponent:0 animated:YES];
}

- (IBAction)check:(UIButton *)sender {
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"autoCheck"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
//    formSheet.shouldCenterVerticallyWhenKeyboardAppears = YES;
    formSheet.presentedFormSheetSize = CGSizeMake(290, 350); //指定弹出视图的高度和宽度
    //    formSheet.shouldMoveToTopWhenKeyboardAppears = NO;
    
    //这里必须要知道以下这种方法的运行方法
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        navController.topViewController.title = @"空调型号自动匹配";
        MyEAcInstructionAutoCheckViewController *vc = (MyEAcInstructionAutoCheckViewController *)navController.topViewController;
        vc.brandsAndModules = self.brandsAndModels;
        vc.device = self.device;
        vc.brandNameArray = self.brandNameArray;
        vc.brandIdArray = self.brandIdArray;
        vc.moduleIdArray = self.modelIdArray;
        vc.moduleNameArray = self.modelNameArray;
        //从当前选择的品牌和型号开始匹配
        vc.brandLabel.text = brandBtn.titleLabel.text;
        vc.modelLabel.text = modelBtn.titleLabel.text;
        
        //在这里对值进行初始化,以便接着前面面板点击的内容快速进行
        vc.brandIdIndex = [brandNameArray indexOfObject:brandBtn.titleLabel.text];
        vc.moduleIdIndex = [modelNameArray indexOfObject:modelBtn.titleLabel.text];
        vc.startIndex = vc.moduleIdIndex;  //这里对startIndex进行赋值
//        NSLog(@"%i %i",vc.brandIdIndex,vc.moduleIdIndex);

//        vc.brandLabel.text = brandNameArray[0];
//        vc.modelLabel.text = modelNameArray[0];
    };
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController){
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        MyEAcInstructionAutoCheckViewController *vc = (MyEAcInstructionAutoCheckViewController *)navController.topViewController;
        self.brandNameArray = vc.brandNameArray;
        self.brandIdArray = vc.brandIdArray;
        self.modelNameArray = vc.moduleNameArray;
        self.modelIdArray = vc.moduleIdArray;
        [self.brandBtn setTitle:vc.brandLabel.text forState:UIControlStateNormal];
        [self.modelBtn setTitle:vc.modelLabel.text forState:UIControlStateNormal];
    };

    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:nil];
}
- (IBAction)AcInit:(UIButton *)sender {
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示" contentText:@"现在开始下载所选型号控制码，如果之前已下载则会覆盖，确定开始么？" leftButtonTitle:@"取消" rightButtonTitle:@"确定"];
    [alert show];
    alert.rightBlock = ^{
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
    };
}
@end
