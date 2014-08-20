//
//  MyEPickerViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-16.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyECitySettingViewController.h"

@interface MyECitySettingViewController ()
{
    NSString *_province_copy, *_city_copy;  //用以记录之前设置的城市，便于进行更改判断
    NSString *_province,*_city;
    NSMutableArray *_provinces,*_cities;
    NSString *_provinceIdRecived,*_cityIdRecived;
}

@end

@implementation MyECitySettingViewController

@synthesize picker,accountData;

#pragma mark
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!IS_IOS6) {
        picker.backgroundColor = [UIColor whiteColor];
        picker.layer.borderColor = [UIColor lightGrayColor].CGColor;
        picker.layer.borderWidth = 0.5;
    }
    //对于代理事件，可以在代码中写出来，也可以在VC中连线连出来
    picker.delegate = self;
    picker.dataSource = self;

    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self changeIdToName];
}

#pragma mark
#pragma mark - memory methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark
#pragma mark - private methods
-(void)checkIfHasChange{
    if ([_city isEqualToString:_city_copy] && [_province isEqualToString:_province_copy]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }else
        self.navigationItem.rightBarButtonItem.enabled = YES;
}
-(void)doThisWhenNeedPopUp{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)changeIdToName{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    _provinceIdRecived = [defs objectForKey:@"provinceId"];
    _cityIdRecived = [defs objectForKey:@"cityId"];
    
    _provinces = [NSMutableArray array];
    _cities = [NSMutableArray array];
    for (int i=0; i<[self.pAndC.provinceAndCity count]; i++) {
        MyEProvince *p = self.pAndC.provinceAndCity[i];
        [_provinces addObject:p.provinceName];
        if ([p.provinceId isEqualToString:_provinceIdRecived]) {
            _province = p.provinceName;
            for (MyECity *c in p.cities) {
                [_cities addObject:c.cityName];
                if ([c.cityId isEqualToString:_cityIdRecived]) {
                    _city = c.cityName;
                }
            }
        }
    }
    _province_copy = [_province copy];
    _city_copy = [_city copy];
    [self.picker selectRow:[_provinces indexOfObject:_province] inComponent:0 animated:YES];
    [self.picker selectRow:[_cities indexOfObject:_city] inComponent:1 animated:YES];
}

#pragma mark - IBAction Methods
- (IBAction)upload:(UIBarButtonItem *)sender {
    for (MyEProvince *p in self.pAndC.provinceAndCity) {
        if ([p.provinceName isEqualToString:_province]) {
            _provinceIdRecived = p.provinceId;
            for (MyECity *c in p.cities) {
                if ([c.cityName isEqualToString:_city]) {
                    _cityIdRecived = c.cityId;
                    break;  //找到之后就不在继续
                }
            }
            break;
        }
    }
    [self uploadModelToServerWithCurrentProvince:_provinceIdRecived andCity:_cityIdRecived];
}


#pragma mark
#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [_provinces count];
    }else
        return [_cities count];
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    if (component == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:0].width, [pickerView rowSizeForComponent:0].height)];
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textAlignment = NSTextAlignmentCenter;
        //这句代码添加之后，整个视图看上去好看多了，主要是label本身是白色的背景
        label.backgroundColor = [UIColor clearColor];
        label.text = _provinces[row];
        return label;
    }else{
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:1].width, [pickerView rowSizeForComponent:1].height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        //这句代码添加之后，整个视图看上去好看多了，主要是label本身是白色的背景
        label.backgroundColor = [UIColor clearColor];
        label.text = _cities[row];
        if ([label.text length] < 6) {
            label.font = [UIFont boldSystemFontOfSize:18];
        }else
            label.font = [UIFont boldSystemFontOfSize:13];
        return label;
    }
}

#pragma mark
#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        _province = _provinces[row];
        
        MyEProvince *p = self.pAndC.provinceAndCity[row];
        _cities = [NSMutableArray array];
        for (MyECity *c in p.cities) {
            [_cities addObject:c.cityName];
        }
        [self.picker reloadComponent:1];
        [self.picker selectRow:0 inComponent:1 animated:YES];
        _city = _cities[0];    //这里必须要更新city的值了，否则会出错，因为这个是时候用户没有点击城市列表
    }else
        _city = _cities[row];
    
    [self checkIfHasChange];  //用以判断此时的城市是否发生了变化
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (component == 0) {
        return 140;
    }
    return 180;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
#pragma mark
#pragma mark - downloadOrUpload data methods

- (void)uploadModelToServerWithCurrentProvince:(NSString *)nprovince andCity:(NSString *)ncity{

    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&provinceId=%@&cityId=%@",URL_FOR_SETTINGS_LOCATION, accountData.userId, nprovince, ncity];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsLocationUploader" userDataDictionary:nil];
    NSLog(@"SettingsUploader is %@",loader.name);
    
}

#pragma mark
#pragma mark - MyEDataLoader Delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    
    if([name isEqualToString:@"SettingsLocationUploader"]) {
        NSLog(@"Location upload with result: %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
            [defs setObject:_provinceIdRecived forKey:@"provinceId"];
            [defs setObject:_cityIdRecived forKey:@"cityId"];

            [MyEUtil showThingsSuccessOn:self.view WithMessage:@"设置成功" andTag:YES];
            [self performSelector:@selector(doThisWhenNeedPopUp) withObject:nil afterDelay:1.5];
            [self.delegate passProvince:_province andCity:_city];
        } else {
            [MyEUtil showMessageOn:nil withMessage:@"与服务器通讯发生异常，请重试"];
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
}

@end
