//
//  MyEAcAddNewBrandAndModuleViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-21.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcAddNewBrandAndModuleViewController.h"

@interface MyEAcAddNewBrandAndModuleViewController ()

@end

@implementation MyEAcAddNewBrandAndModuleViewController

#pragma mark - life circle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    _brandNew = [[MyEAcBrand alloc] init];
    _modelNew = [[MyEAcModel alloc] init];
    [self defineTapGestureRecognizer];
    self.brandName.delegate = self;
    self.moduleName.delegate = self;
    
    for (UIButton *btn in self.view.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [MyEUtil makeFlatButton:btn];
        }
    }
}

#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods
- (IBAction)save:(UIButton *)sender {
    [self.view endEditing:YES];
    _brandNew.brandName = self.brandName.text;
    _modelNew.modelName = self.moduleName.text;
    if ([_brandNew.brandName length]==0||[_modelNew.modelName length] == 0) {
        [MyEUtil showMessageOn:nil withMessage:@"输入错误"];
        return;
    }
    for (MyEAcModel *m in _brandNew.models) {
        if ([m.modelName isEqualToString:_modelNew.modelName]) {
            [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"型号已存在！"];
            return;
        }
    }
    self.cancelBtnPressed = NO;
    [self addNewBrandAndModuleToServer];
}
- (IBAction)cancel:(UIButton *)sender {
    self.cancelBtnPressed = YES;
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

#pragma mark - URL private methods
-(void) submitEditToServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr;
    MyEDataLoader *uploader;
    urlStr= [NSString stringWithFormat:@"%@?gId=%@&action=1&brandId=%i&moduleId=%i&tId=%@&brandName=%@&moduleName=%@",
             GetRequst(URL_FOR_AC_BRAND_MODEL_EDIT),
             MainDelegate.accountData.userId,
             _brandNew.brandId,
             _modelNew.modelId,
             self.device.tId,
             _brandNew.brandName,
             _modelNew.modelName];
    uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"editBrandAndModule"  userDataDictionary:nil];
    NSLog(@"%@",uploader.name);
    
}
- (void)addNewBrandAndModuleToServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr;
    MyEDataLoader *uploader;
    urlStr= [NSString stringWithFormat:@"%@?gId=%@&action=0&brandId=0&moduleId=0&tId=%@&brandName=%@&moduleName=%@",
             GetRequst(URL_FOR_AC_BRAND_MODEL_EDIT),
             MainDelegate.accountData.userId,
             self.device.tId,
             _brandNew.brandName,
             _modelNew.modelName];
    uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"addNewBrandAndModule"  userDataDictionary:nil];
    NSLog(@"%@",uploader.name);
}

#pragma mark - URL delegate methods

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:@"addNewBrandAndModule"]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"添加新的空调品牌和型号发生错误！"];
        } else{
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dic = [parser objectWithString:string];
            _brandNew.brandId = [dic[@"brandId"] intValue];
            _modelNew.modelId = [dic[@"moduleId"] intValue];
            BOOL hasOne = NO;
            for (MyEAcBrand *b in self.brandsAndModules.userAcBrands) {
                if (b.brandId == _brandNew.brandId) {
                    hasOne = YES;
                    [b.models addObject:_modelNew];
                    break;
                }
            }
            if (!hasOne) {
                [_brandNew.models addObject:_modelNew];
                [self.brandsAndModules.userAcBrands addObject:_brandNew];
            }
            [MyEUtil saveObject:self.brandsAndModules withFileName:FILE_FOR_AC_BRANDS];
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
        }
    }
    if([name isEqualToString:@"editBrandAndModule"]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"编辑空调品牌和型号发生错误！"];
        } else{
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            }];
        }
    }
    
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [MyEUtil showMessageOn:nil withMessage:@"通讯错误，请稍候再试"];
    [HUD hide:YES];
}
#pragma mark - textField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([self.brandName.text length]!=0||[self.moduleName.text length]!=0) {
        self.saveBtn.enabled = YES;
    }
}
@end
