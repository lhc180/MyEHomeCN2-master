//
//  MyEAcCustomInstructionViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-20.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcCustomInstructionViewController.h"

@interface MyEAcCustomInstructionViewController (){
    BOOL _isFinished;
}

@end

@implementation MyEAcCustomInstructionViewController
@synthesize brandIdArray,brandNameArray,modelIdArray,modelNameArray,brandBtn,modelBtn,downloadBtn,editInstructionBtn;

#pragma mark - life circle methods
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //这里是以view的形式加载的，所以这里要对4寸和3.5寸的屏幕做适配
    if (IS_IPHONE5) {
        self.view.frame = CGRectMake(0, 0, 320, 393);
    }else
        self.view.frame = CGRectMake(0, 0, 320, 305);

//    self.navigationController.topViewController.title = @"自学习库";
//    self.navigationController.navigationBar.topItem.title = @"自学习库";
//    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                if (btn.tag == 100 || btn.tag == 101) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
                }else if (btn.tag != 1000 && btn.tag != 1001){
                    btn.layer.masksToBounds = YES;
                    btn.layer.cornerRadius = 4;
                    btn.layer.borderColor = btn.tintColor.CGColor;
                    btn.layer.borderWidth = 1;
                }
            }
        }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

//    }else{
//        for (UIButton *btn in self.view.subviews) {
//            if (btn.tag == 100 || btn.tag == 101) {
//                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn-ios6"] forState:UIControlStateNormal];
//                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
//            }
//        }
//    }
}
-(void)refreshData:(BOOL)yes{
    if (yes) {
        yes = NO;
        [self downloadAcBrandsAndModules];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    //当界面是从instructionList界面跳转过来时就需要更新一下数据，以便于了解指令是否可以下载，当从其他界面跳转过来时不需要运行此方法
    if (self.jumpFromInstructionList) {
        self.jumpFromInstructionList = NO;//为了保险起见，随时将状态变量置为相反状态
        [self downloadAcBrandsAndModules];
    }else{
        [self findBrandArrayInData]; //寻找userBrand，以便于重建数组，完成最初的UI和数据
        //    NSLog(@"%@",[brandNameArray description]);
        if (![self.device.brand isEqualToString:@""] && !self.device.isSystemDefined) { //如果为自学习空调且初始化完成
            [brandBtn setTitle:self.device.brand forState:UIControlStateNormal];
            [modelBtn setTitle:self.device.model forState:UIControlStateNormal];
            _selectBrandIndex = (int)[self.brandNameArray indexOfObject:self.device.brand];
            [self findModelArrayWithBrandIndex:_selectBrandIndex];
            _selectModelIndex = (int)[self.modelNameArray indexOfObject:self.device.model];
            [self refreshDownloadBtnWith:_selectModelIndex];
            [downloadBtn setTitle:@"该品牌已下载" forState:UIControlStateNormal];
            //  downloadBtn.enabled = NO;
        }else{
            if ([self.brandNameArray count] == 0) {
                [brandBtn setTitle:@"空调品牌未添加" forState:UIControlStateNormal];
                [modelBtn setTitle:@"空调型号未添加" forState:UIControlStateNormal];
                //什么都没有的时候只有【新增品牌】btn可以点击
                self.deleteBrandAndModelBtn.enabled = NO;
                self.editInstructionBtn.enabled = NO;
                self.downloadBtn.enabled = NO;
            }else{
                _selectBrandIndex = 0;
                _selectModelIndex = 0;
                [self findModelArrayWithBrandIndex:_selectBrandIndex];
                [brandBtn setTitle:brandNameArray[_selectBrandIndex] forState:UIControlStateNormal];
                [modelBtn setTitle:modelNameArray[_selectModelIndex] forState:UIControlStateNormal];
                //更新button的可点击状态
                [self refreshDownloadBtnWith:_selectModelIndex];
            }
        }
    }
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
-(void)findBrandArrayInData{
    NSMutableArray *brands = [NSMutableArray array];
    NSMutableArray *brandIds= [NSMutableArray array];
    for (int i=0; i<[self.brandsAndModels.userAcBrands count]; i++) {
        MyEAcBrand *brand = self.brandsAndModels.userAcBrands[i];
        [brands addObject:brand.brandName];
        [brandIds addObject:[NSNumber numberWithInteger:brand.brandId]];
    }
    self.brandNameArray = brands;
    self.brandIdArray = brandIds;
}
-(void)findModelArrayWithBrandIndex:(NSInteger)index{
    NSMutableArray *models = [NSMutableArray array];
    NSMutableArray *modelIds = [NSMutableArray array];
    MyEAcBrand *brand = self.brandsAndModels.userAcBrands[index];
    for (int i=0; i<[self.brandsAndModels.userAcModels count]; i++) {
        MyEAcModel *modle = self.brandsAndModels.userAcModels[i];
        for (int j=0; j<[brand.models count]; j++) {
            if (modle.modelId == [brand.models[j] intValue]) {
                [models addObject:modle.modelName];
                [modelIds addObject:[NSNumber numberWithInteger:modle.modelId]];
            }
        }
    }
    self.modelNameArray = models;
    self.modelIdArray = modelIds;
}
-(void)defineTapGestureRecognizerOnWindow{
    tapGestureToHideHUD = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHUD)];
    tapGestureToHideHUD.cancelsTouchesInView = NO;
    [self.view.window addGestureRecognizer:tapGestureToHideHUD];
}

-(MyEAcModel *)getCurrentSelectModelWith:(NSInteger)index{
    //    NSInteger modelId = [modelIdArray[[modelNameArray indexOfObject:modelBtn.titleLabel.text]] integerValue];
//#warning 一般都是这行出错，主要跟数组内容更新有关
    NSInteger modelId = [modelIdArray[index] integerValue];
    
    MyEAcModel *model = nil;
    for (int i = 0; i < [self.brandsAndModels.userAcModels count]; i++) {
        model = [self.brandsAndModels.userAcModels objectAtIndex:i];
        if(modelId == model.modelId)
            break;
    }
    return model;
}

//by YY
//根据空调型号是否已经学习了两个必要的指令, 来刷新  下载控制码  按钮的enable
-(void)refreshDownloadBtnWith:(NSInteger)index{
    if ([brandBtn.currentTitle isEqualToString:self.device.brand] && [modelBtn.currentTitle isEqualToString:self.device.model]) {
//        [self.downloadBtn setEnabled:NO];  //此处不能禁用，还可以让用户进行点击
        [downloadBtn setTitle:@"该品牌已下载" forState:UIControlStateNormal];
        return;
    }
    MyEAcModel *model = [self getCurrentSelectModelWith:index];
    [downloadBtn setTitle:@"下载所选控制码" forState:UIControlStateNormal];
    if(model && model.study > 0){
        self.downloadBtn.enabled = YES;
    } else
        self.downloadBtn.enabled = NO;
}
-(void)refreshModelArrayWithRow:(NSInteger)row{
    NSMutableArray *models = [NSMutableArray array];
    NSMutableArray *modelIds = [NSMutableArray array];
    MyEAcBrand *brand = self.brandsAndModels.userAcBrands[row];
    for (int i=0; i<[self.brandsAndModels.userAcModels count]; i++) {
        MyEAcModel *modle = self.brandsAndModels.userAcModels[i];
        for (int j=0; j<[brand.models count]; j++) {
            if (modle.modelId == [brand.models[j] intValue]) {
                [models addObject:modle.modelName];
                [modelIds addObject:[NSNumber numberWithInteger:modle.modelId]];
            }
        }
    }
    self.modelNameArray = models;
    self.modelIdArray = modelIds;
    _selectModelIndex = 0;
    [modelBtn setTitle:modelNameArray[_selectModelIndex] forState:UIControlStateNormal];
}

#pragma mark - IBAction methods
- (IBAction)brandBtnPress:(UIButton *)sender{
    if ([brandBtn.titleLabel.text isEqualToString:@"空调品牌未添加"]) {
        [MyEUtil showMessageOn:self.navigationController.view withMessage:@"请点击[新增品牌]按钮"];
        return;
    }
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择空调品牌" andDelegate:self andTag:1 andArray:brandNameArray andSelectRow:_selectBrandIndex andViewController:self];
}
- (IBAction)modelBtnPress:(UIButton *)sender{
    if ([modelBtn.titleLabel.text isEqualToString:@"空调型号未添加"]) {
        [MyEUtil showMessageOn:self.navigationController.view withMessage:@"请点击[新增品牌]按钮"];
        return;
    }
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择遥控器型号" andDelegate:self andTag:2 andArray:modelNameArray andSelectRow:_selectModelIndex andViewController:self];
}

- (IBAction)deleteBrandAndModel:(UIButton *)sender {
    if ([brandBtn.titleLabel.text isEqualToString:self.device.brand]) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                    contentText:@"该品牌的指令库目前正在使用中，不允许删除操作"
                                                leftButtonTitle:nil
                                               rightButtonTitle:@"确定"];
        [alert show];
        return;
    }
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                contentText:@"删除品牌会导致自学习的指令丢失，您确定删除么？"
                                            leftButtonTitle:@"取消"
                                           rightButtonTitle:@"确定"];
    [alert show];
    alert.rightBlock = ^() {
        [self deleteBrandAndModuleToServer];
    };
}
- (IBAction)editInstruction:(UIButton *)sender {
//其实这里对于MZFormSheetController有了更为深刻的了解
    MyEAcInstructionListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"instructionList"];
    vc.accountData = self.accountData;
    vc.device = self.device;
    vc.moduleId = [modelIdArray[[modelNameArray indexOfObject:modelBtn.titleLabel.text]] intValue];
    vc.brandId = [brandIdArray[[brandNameArray indexOfObject:brandBtn.titleLabel.text]] intValue];
    vc.jumpFromEditBtn = YES;
    vc.labelText = [NSString stringWithFormat:@"%@ - %@",brandBtn.titleLabel.text,modelBtn.titleLabel.text];
    vc.delegate = self; //这里这么做是为了刷新数据
//#warning 这个太牛逼了，这里介绍了怎么通过view来找到他的视图控制器
    MyEInstructionManageViewController *manager = (MyEInstructionManageViewController *)self.view.superview.superview.nextResponder;
    [manager.navigationController pushViewController:vc animated:YES];
}

- (IBAction)addBrandAndModel:(UIButton *)sender {
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addNew"];
//#warning 这里要对formsheet进行定制，主要是调整视图大小和页面控件的布局
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
//    formSheet.shouldCenterVerticallyWhenKeyboardAppears = YES;
    //    formSheet.shouldMoveToTopWhenKeyboardAppears = NO;
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        navController.topViewController.title = @"请输入新增的空调品牌和型号";
        MyEAcAddNewBrandAndModuleViewController *modalVc = (MyEAcAddNewBrandAndModuleViewController *)navController.topViewController;
        modalVc.accountData = self.accountData;
        modalVc.brandsAndModules = self.brandsAndModels;
        modalVc.device = self.device;
        modalVc.jumpFromAddBtn = 1;
        modalVc.modelNameArray = self.modelNameArray; //这两个数组主要用来进行重复性判断
        modalVc.brandNameArray = self.brandNameArray;
        modalVc.titleLabel.hidden = YES;
    };
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
    
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController) {
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        MyEAcAddNewBrandAndModuleViewController *modalVc = (MyEAcAddNewBrandAndModuleViewController *)navController.topViewController;
        if (!modalVc.cancelBtnPressed) {
            [brandBtn setTitle:modalVc.brandName.text forState:UIControlStateNormal];
            [modelBtn setTitle:modalVc.moduleName.text forState:UIControlStateNormal];
            self.deleteBrandAndModelBtn.enabled = YES;
            self.editInstructionBtn.enabled = YES;
            self.downloadBtn.enabled = YES;
            //新增品牌成功之后要跳转到指令学习的面板
            MyEAcInstructionListViewController *list = [self.storyboard instantiateViewControllerWithIdentifier:@"instructionList"];
            list.delegate = self; //这里这么做是为了能够成功刷新数据
            list.device = self.device;
            list.moduleId = modalVc.newModuleId;
            list.labelText = [NSString stringWithFormat:@"%@ - %@",modalVc.brandName.text,modalVc.moduleName.text];
            MyEInstructionManageViewController *vc = (MyEInstructionManageViewController *)[self.view.superview.superview nextResponder];
            [vc.navigationController pushViewController:list animated:YES];
        }
    };
}
- (IBAction)downloadInstruction:(UIButton *)sender {
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示" contentText:@"现在开始下载所选型号控制码，如果之前已下载则会覆盖，确定开始么？" leftButtonTitle:@"取消" rightButtonTitle:@"确定"];
    [alert show];
    alert.rightBlock = ^{
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

        requestCircles = 0;
        requestTimes = 0;
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:HUD];
        HUD.detailsLabelText = @"正在初始化...";
        HUD.square = YES;
        HUD.margin = 10;
        HUD.opacity = 0.6;
        HUD.cornerRadius = 4;
        HUD.minSize = CGSizeMake(110.f, 110.f);
        //添加背景模板
        HUD.dimBackground = YES;
        [HUD show:YES];
        
        [self.view.window addSubview:cancelButton];
        [self doThisWhenAcInit];
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
    };
}
#pragma mark - URL private methods

-(void)deleteBrandAndModuleToServer{
    NSString *urlStr = [NSString stringWithFormat:@"%@?gId=%@&action=2&brandId=%i&moduleId=%i&tId=%@",
                        URL_FOR_AC_BRAND_MODEL_EDIT,
                        self.accountData.userId,
                        [brandIdArray[[brandNameArray indexOfObject:brandBtn.titleLabel.text]] intValue],
                        [modelIdArray[[modelNameArray indexOfObject:modelBtn.titleLabel.text]] intValue],
                        self.device.tId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"deleteBrandAndModule" userDataDictionary:nil];
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
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%li&action=0&brandId=%li&moduleId=%@&tId=%@",
                        URL_FOR_AC_INIT,
                        (long)self.device.deviceId,
                        (long)[brandIdArray[[brandNameArray indexOfObject:brandBtn.titleLabel.text]] intValue],
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
    [timer invalidate];
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%li&action=2&brandId=%i&moduleId=%@&tId=%@",URL_FOR_AC_INIT, (long)self.device.deviceId,[brandIdArray[[brandNameArray indexOfObject:brandBtn.titleLabel.text]] intValue],modelIdArray[[modelNameArray indexOfObject:modelBtn.titleLabel.text]],self.device.tId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"cancelAcInit" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
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
#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:@"downloadAcBrandsAndModules"]) {
        [HUD hide:YES];
        NSLog(@"downloadAcBrandsAndModules JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
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
//            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"下载空调品牌和型号时发生错误"];
        }else{
            MyEAcBrandsAndModels *ac = [[MyEAcBrandsAndModels alloc] initWithJSONString:string];
            self.brandsAndModels.userAcBrands = ac.userAcBrands;
            self.brandsAndModels.userAcModels = ac.userAcModels;
            [self findBrandArrayInData];
//            NSMutableArray *models = [NSMutableArray array];
//            NSMutableArray *modelIds = [NSMutableArray array];
            //判断是否为空这个优先级最高
            if ([self.brandNameArray count] == 0) {
                [brandBtn setTitle:@"空调品牌未添加" forState:UIControlStateNormal];
                [modelBtn setTitle:@"空调型号未添加" forState:UIControlStateNormal];
                self.editInstructionBtn.enabled = NO;
                self.downloadBtn.enabled = NO;
                self.deleteBrandAndModelBtn.enabled = NO;
                self.editInstructionBtn.enabled = NO;
            }else{
                self.editInstructionBtn.enabled = YES;
                self.downloadBtn.enabled = YES;
                self.deleteBrandAndModelBtn.enabled = YES;
                self.editInstructionBtn.enabled = YES;
                if (deleteToDownload) {
                    //及时更新deleteToDownload的状态，以防出错
                    deleteToDownload = NO;
                    _selectBrandIndex = 0;
                    _selectModelIndex = 0;
                    [self findModelArrayWithBrandIndex:_selectBrandIndex];
                    [brandBtn setTitle:brandNameArray[_selectBrandIndex] forState:UIControlStateNormal];
                    [modelBtn setTitle:modelNameArray[_selectModelIndex] forState:UIControlStateNormal];
                    [self refreshDownloadBtnWith:_selectModelIndex];
                }else{
                    _selectBrandIndex = (int)[brandNameArray indexOfObject:brandBtn.titleLabel.text];
                    [self findModelArrayWithBrandIndex:_selectBrandIndex];
                    _selectModelIndex = (int)[modelNameArray indexOfObject:modelBtn.currentTitle];
                    //这里是个有意思的地方，要特别注意此处的0，因为新增的品牌都会排在第一个，所以此处选择0
                    [self refreshDownloadBtnWith:0];
                }
            }
/////            [picker reloadAllComponents];
        }
//        [self refreshDownloadBtn];//by YY
//        [self performSelector:@selector(refreshDownloadBtn) withObject:nil afterDelay:3];
    }
    if ([name isEqualToString:@"deleteBrandAndModule"]) {
        NSLog(@"%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"删除空调品牌和型号失败"];
        }else{
//#warning 这个还需要完善           //如果删除的是已经在用的品牌和型号，则要清空本地数据
            if ([self.device.brand isEqualToString:brandBtn.titleLabel.text] &&
                [self.device.model isEqualToString:modelBtn.titleLabel.text]) {
                self.device.brand = @"";
                self.device.model = @"";
                self.device.brandId = 0;
                self.device.modelId = 0;
            }
            deleteToDownload = YES;
            [self downloadAcBrandsAndModules];
        }
    }
    if ([name isEqualToString:@"checkAcInitProgress"]) {
        NSLog(@"%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [HUD hide:YES];
            [timer invalidate];
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [HUD hide:YES];
            [timer invalidate];
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
                    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkAcInitProgress) userInfo:nil repeats:NO];
                }else{
                    [timer invalidate];
                    [cancelButton removeFromSuperview];
                    HUD.detailsLabelText = @"空调初始化失败";
                    [self defineTapGestureRecognizerOnWindow];
//                    [HUD hide:YES afterDelay:2];
                }
            }else{
                if (progress < 100) {
                    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkAcInitProgress) userInfo:nil repeats:NO];
                }else{
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
                    self.device.isSystemDefined = NO;
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
            [HUD hide:YES];
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            [cancelButton removeFromSuperview];
            return;
        }

        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            acInitFailureTimes ++;
            if (acInitFailureTimes < 5) {
                [self doThisWhenAcInit];
            }else{
                HUD.detailsLabelText = @"空调初始化失败";
                [HUD hide:YES afterDelay:2];
                [cancelButton removeFromSuperview];
                
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
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [timer invalidate];
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            HUD.detailsLabelText = @"初始化取消失败";
            [timer invalidate];
            [HUD hide:YES afterDelay:2];
            [cancelButton removeFromSuperview];
        }else{
            HUD.customView = imageView;
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.detailsLabelText = @"初始化取消成功";
            [timer invalidate];
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
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:@"checkAcInitProgress"])
        msg = @"通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    [MyEUtil showMessageOn:self.navigationController.view withMessage:msg];
}

#pragma mark - navigation methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"instructionList"]) {
        MyEAcInstructionListViewController *vc = segue.destinationViewController;
        vc.accountData = self.accountData;
        vc.device = self.device;
        vc.moduleId = [modelIdArray[[modelNameArray indexOfObject:modelBtn.titleLabel.text]] intValue];
        vc.brandId = [brandIdArray[[brandNameArray indexOfObject:brandBtn.titleLabel.text]] intValue];
        vc.jumpFromEditBtn = YES;
        //从这里可以看出，这么做的好处就是可以少写几个参数，但是功能却没落下
//        vc.brandAndModuleLabel.text = [NSString stringWithFormat:@"%@ - %@",brandBtn.titleLabel.text,moduleBtn.titleLabel.text];
        //从这里可以看出，此处只能传值，不能赋值
        //这里将两个值合并为一个值，减少了传值的参数过多的问题
        vc.brandAndModuleLabel.text = [NSString stringWithFormat:@"%@ - %@",brandBtn.titleLabel.text,modelBtn.titleLabel.text];
    }
}
-(void)hideHUD{
    [HUD hide:YES];
    HUD = nil;
    [self.view.window removeGestureRecognizer:tapGestureToHideHUD];
}
-(void)passValue:(MyEAcBrandsAndModels *)brand{
    //本以为传值成功之后要重新进行构造，想不到竟然啥也不需要做了
    self.brandsAndModels = brand;
}
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles{
    if (pickerView.tag == 1) {
        [brandBtn setTitle:titles[0] forState:UIControlStateNormal];
        _selectBrandIndex = (int)[brandNameArray indexOfObject:brandBtn.currentTitle];
        [self refreshModelArrayWithRow:_selectBrandIndex];
    }else{
        [modelBtn setTitle:titles[0] forState:UIControlStateNormal];
        _selectModelIndex = (int)[modelNameArray indexOfObject:modelBtn.currentTitle];
    }
    [self refreshDownloadBtnWith:_selectModelIndex];
}
@end