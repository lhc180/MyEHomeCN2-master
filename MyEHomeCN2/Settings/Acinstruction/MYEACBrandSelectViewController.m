//
//  MYEACBrandSelectViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/9/22.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEACBrandSelectViewController.h"
#import "MYEACInstructionManageViewController.h"
#import "MYEACInitStepViewController.h"
#import "MyEAcInstructionAutoCheckViewController.h"
#import "MyEAcAddNewBrandAndModuleViewController.h"
#import "MYEACAutoCheckViewController.h"
#import "MyEAcInstructionListViewController.h"
#import "MYEACCheckAutoViewController.h"

@interface MYEACBrandSelectViewController ()<UIAlertViewDelegate,MyEDataLoaderDelegate>{
    NSIndexPath *_deleteIndex;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *barAutoCheck;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barFlex;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barAddBrand;
@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectSeg;

@end

@implementation MYEACBrandSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.isBrand ? @"品牌":@"型号";
    self.tableView.tableFooterView = [[UIView alloc] init];
    if (_isACInit) {
        if (_isBrand) {
            [self setToolbarItems:@[self.barFlex,self.barAddBrand] animated:YES];
        }else{
            if (self.brandAndModels.selectedIndex == 1) {
                [self setToolbarItems:@[self.barFlex,self.barAddBrand] animated:YES];
            }else
                [self setToolbarItems:@[self.barAutoCheck,self.barFlex,self.barAddBrand] animated:YES];
        }
    }
    if (IS_IOS6) {
        self.selectSeg.layer.borderColor = MainColor.CGColor;
        self.selectSeg.layer.borderWidth = 1.0f;
        self.selectSeg.layer.cornerRadius = 4.0f;
        self.selectSeg.layer.masksToBounds = YES;
    }

//    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
//    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
//    [rc addTarget:self
//           action:@selector(downloadAcBrandsAndModules)
// forControlEvents:UIControlEventValueChanged];
//    self.refreshControl = rc;

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (_isBrand) {
        if (self.brandAndModels.userAcBrands.count > 0) {
            self.tableView.tableHeaderView = self.tableHeaderView;
            [self.selectSeg setSelectedSegmentIndex:self.brandAndModels.selectedIndex];
        }
    }
    if (_isACInit) {
        [self.navigationController setToolbarHidden:NO animated:NO];
    }
    [self.tableView reloadData];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if (_isACInit) {
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
-(void)goToStudy{
    MyEAcInstructionListViewController *vc = [[UIStoryboard storyboardWithName:@"AcInstruction" bundle:nil] instantiateViewControllerWithIdentifier:@"instructionList"];
    vc.brandId = self.brand.brandId;
    vc.model = _model;
    vc.labelText = [NSString stringWithFormat:@"%@ - %@",self.brand.brandName,_model.modelName];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - IBAction methods
- (IBAction)autoCheck:(UIBarButtonItem *)sender {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"AcInstruction" bundle:nil] instantiateViewControllerWithIdentifier:@"check"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.presentedFormSheetSize = CGSizeMake(290, 340); //指定弹出视图的高度和宽度
    
    //这里必须要知道以下这种方法的运行方法
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        navController.topViewController.title = @"空调型号自动匹配";
        MYEACCheckAutoViewController *vc = (MYEACCheckAutoViewController *)navController.topViewController;
        vc.brand = self.brand;
        vc.device = self.device;
        [vc viewDidLoad];
    };
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController){
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        MYEACCheckAutoViewController *vc = (MYEACCheckAutoViewController *)navController.topViewController;
        if (!vc.cancelBtnClicked) {
            UIViewController *viewc = self.navigationController.childViewControllers[[self.navigationController.childViewControllers indexOfObject:self] - 1];
            [viewc setValue:@(vc.index) forKey:@"index"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:nil];

}
- (IBAction)addNewBrand:(UIBarButtonItem *)sender {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"AcInstruction" bundle:nil] instantiateViewControllerWithIdentifier:@"addNew"];
    //#warning 这里要对formsheet进行定制，主要是调整视图大小和页面控件的布局
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsMoveToTop;
    formSheet.presentedFormSheetSize = CGSizeMake(260, 209); //指定弹出视图的高度和宽度
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        navController.topViewController.title = @"新增空调品牌和型号";
        MyEAcAddNewBrandAndModuleViewController *modalVc = (MyEAcAddNewBrandAndModuleViewController *)navController.topViewController;
        modalVc.brandsAndModules = self.brandAndModels;
        modalVc.device = self.device;
    };
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:nil];
    
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController) {
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        MyEAcAddNewBrandAndModuleViewController *modalVc = (MyEAcAddNewBrandAndModuleViewController *)navController.topViewController;
        if (!modalVc.cancelBtnPressed) {
            MyEAcInstructionListViewController *vc = [[UIStoryboard storyboardWithName:@"AcInstruction" bundle:nil] instantiateViewControllerWithIdentifier:@"instructionList"];
            vc.brandId = modalVc.brandNew.brandId;
            vc.moduleId = modalVc.modelNew.modelId;
            vc.labelText = [NSString stringWithFormat:@"%@ - %@",modalVc.brandNew.brandName,modalVc.modelNew.modelName];
            [self.navigationController pushViewController:vc animated:YES];
        }
    };
}
- (IBAction)changeMode:(UISegmentedControl *)sender {
    self.brandAndModels.selectedIndex = sender.selectedSegmentIndex;
    self.index = -1;
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isBrand) {
        return self.brandAndModels.selectedIndex == 0?self.brandAndModels.sysAcBrands.count:self.brandAndModels.userAcBrands.count;
    }
    return self.brand.models.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (_isBrand) {
        MyEAcBrand *brand = self.brandAndModels.selectedIndex == 0?self.brandAndModels.sysAcBrands[indexPath.row]:self.brandAndModels.userAcBrands[indexPath.row];
        cell.textLabel.text = brand.brandName;
    }else{
        MyEAcModel *model = self.brand.models[indexPath.row];
        cell.textLabel.text = model.modelName;
        if (self.brandAndModels.selectedIndex == 1) {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
    }
    cell.textLabel.numberOfLines = 0;
//    #通用1/RN02J/BG|RN02H|R51FA-M|RN51K|R51DA|R51D(2)|K51D|RN511/BG
    if (cell.textLabel.text.length > 30) {
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }else
        cell.textLabel.font = [UIFont systemFontOfSize:17];
    if (_isACInit) {
        if (indexPath.row == _index) {
            cell.imageView.image = [UIImage imageNamed:@"checkMark"];
        }else
            cell.imageView.image = [MyEUtil imageWithColor:[UIColor clearColor] size:CGSizeMake(22, 22)];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor whiteColor];
    if (self.brandAndModels.selectedIndex == 1) {
        BOOL flag = NO;
        if (_isBrand) {
            MyEAcBrand *brand = self.brandAndModels.userAcBrands[indexPath.row];
            flag = !brand.hasOneModelStudy;
        }else{
            MyEAcModel *model = self.brand.models[indexPath.row];
            flag = model.study < 1;
        }
        if (flag) {
            cell.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        }
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    _model = self.brand.models[indexPath.row];
    [self goToStudy];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.brandAndModels.selectedIndex == 1) {   //表示此时选择的是自学习的空调
        if (_isBrand) {
            self.brand = self.brandAndModels.userAcBrands[indexPath.row];
            if (![_brand hasOneModelStudy]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"品牌: %@\n所有型号指令都还没有学习,此时不能使用.现在是否去学习?",_brand.brandName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去学习", nil];
                alert.tag = 100;
                [alert show];
                return;
            }
        }else{
            _model = self.brand.models[indexPath.row];
            if (_isACInit) {
                if (_model.study < 1) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"型号: %@\n基本指令还没有学习,此时不能使用.现在是否去学习?",_model.modelName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去学习", nil];
                    alert.tag = 101;
                    [alert show];
                    return;
                }
            }else{
                [self goToStudy];
                return;
            }
        }
    }
    _index = indexPath.row;
    UIViewController *vc = self.navigationController.childViewControllers[[self.navigationController.childViewControllers indexOfObject:self] - 1];
    [vc setValue:@(_index) forKey:@"index"];
//    if (_isACInit) {
//        
//    }else{
//        MYEACInstructionManageViewController *instruction = (MYEACInstructionManageViewController *)vc;
//        vc.index = _index;
//    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.brandAndModels.selectedIndex == 0 || self.isBrand) {
        return NO;
    }
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _deleteIndex = indexPath;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除该型号么?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 102;
        [alert show];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        MYEACBrandSelectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"brand"];
        vc.brand = self.brand;
        vc.device = self.device;
        vc.brandAndModels = self.brandAndModels;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (alertView.tag == 101 && buttonIndex == 1) {
        [self goToStudy];
    }
    if (alertView.tag == 102 && buttonIndex == 1) {
        [self deleteBrandAndModuleToServer];
    }
}

#pragma mark - URL methods
-(void)downloadAcBrandsAndModules{
    if (self.refreshControl.isRefreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中..."];
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@",GetRequst(URL_FOR_IR_LIST_AC_MODELS), MainDelegate.accountData.userId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"downloadAcBrandsAndModules" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
-(void)deleteBrandAndModuleToServer{
    MyEAcModel *model = self.brand.models[_deleteIndex.row];
    NSString *urlStr = [NSString stringWithFormat:@"%@?gId=%@&action=2&brandId=%i&moduleId=%i&tId=%@",
                        GetRequst(URL_FOR_AC_BRAND_MODEL_EDIT),
                        MainDelegate.accountData.userId,
                        self.brand.brandId,model.modelId,
                        self.device.tId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"deleteBrandAndModule" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    NSInteger i = [MyEUtil getResultFromAjaxString:string];
    
    if (i == -3) {
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
        return;
    }
    if ([name isEqualToString:@"deleteBrandAndModule"]) {
        if (i == 1) {
            [self.brand.models removeObjectAtIndex:_deleteIndex.row];
            if (self.brand.models.count == 0) {
                NSMutableArray *array = self.brandAndModels.selectedIndex == 0?self.brandAndModels.sysAcBrands:self.brandAndModels.userAcBrands;
                if ([array containsObject:self.brand]) {
                    [array removeObject:self.brand];
                }
            }
            [self.tableView deleteRowsAtIndexPaths:@[_deleteIndex] withRowAnimation:UITableViewRowAnimationFade];
            [MyEUtil saveObject:self.brandAndModels withFileName:FILE_FOR_AC_BRANDS];
        }else
            [MyEUtil showMessageOn:nil withMessage:@"删除失败"];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [MyEUtil showMessageOn:nil withMessage:@"与服务器连接失败"];
}
@end
