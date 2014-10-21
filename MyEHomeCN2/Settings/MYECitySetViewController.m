//
//  MYECitySetViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/9/25.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYECitySetViewController.h"

#import "IIILocalizedIndex.h"


@interface MYECitySetViewController ()<MyEDataLoaderDelegate>{
    MyECity *_city;
    NSInteger _selectIndex;
}
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;

@property (strong, nonatomic) NSArray *keys;   //索引字母
@property (strong, nonatomic) NSDictionary *data;  //键是索引，值是数组

@end

@implementation MYECitySetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _isProvince?@"省份":@"城市或地区";
    if (!_isProvince) {
        self.navigationItem.rightBarButtonItem = self.saveBtn;
    }
    
    if (_isProvince) {
        self.data = [IIILocalizedIndex indexed:self.allCities.provinceAndCity];
    }else
        self.data = [IIILocalizedIndex indexed:self.province.cities];
    self.keys = [self.data.allKeys sortedArrayUsingSelector:@selector(compare:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - private methods
-(void)doThisWhenNeedPopUp{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - IBAction methods
- (IBAction)saveAction:(UIBarButtonItem *)sender {
//    _city = _province.cities[_selectIndex];
    if (self.hotelDetail != nil) {
        self.hotelDetail.cityId = _city.cityId;
        [self.navigationController popToViewController:self.navigationController.childViewControllers[[self.navigationController.childViewControllers indexOfObject:self] - 2] animated:YES];
        return;
    }
    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?gid=%@&provinceId=%@&cityId=%@",GetRequst(URL_FOR_SETTINGS_LOCATION),MainDelegate.accountData.userId,_province.provinceId, _city.cityId] postData:nil delegate:self loaderName:@"upload" userDataDictionary:nil];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.keys.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return _isProvince?self.allCities.provinceAndCity.count:_province.cities.count;
    NSString *key = [self.keys objectAtIndex:section];
    NSArray *arr = [self.data objectForKey:key];
    return arr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSArray *arr = [self.data objectForKey:[self.keys objectAtIndex:indexPath.section]];
    id item = arr[indexPath.row];
    cell.textLabel.text = [item valueForKey:_isProvince?@"provinceName":@"cityName"];
    if (_isProvince) {
//        MyEProvince *p = self.allCities.provinceAndCity[indexPath.row];
//        cell.textLabel.text = p.provinceName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
//        MyECity *c = _province.cities[indexPath.row];
//        cell.textLabel.text = c.cityName;
        cell.accessoryType = UITableViewCellAccessoryNone;
//        if (indexPath.row == _selectIndex) {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }
    }
    
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.keys objectAtIndex:section];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.keys;
}
#pragma mark - TableView Delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSArray *arr = [self.data objectForKey:[self.keys objectAtIndex:indexPath.section]];
    if (_isProvince) {
        MYECitySetViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"citySet"];
        vc.province = arr[indexPath.row];
//        vc.province = self.allCities.provinceAndCity[indexPath.row];
        vc.isProvince = NO;
        vc.allCities = self.allCities;
        vc.settings = self.settings;
        vc.comfort = self.comfort;
        vc.hotelDetail = self.hotelDetail;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        _city = arr[indexPath.row];
//        _selectIndex = indexPath.row;
//        [self.tableView reloadData];
    }
}
#pragma mark - MyEDataLoader Delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    
    if([name isEqualToString:@"upload"]) {
        NSLog(@"Location upload with result: %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            MainDelegate.accountData.provinceId = _province.provinceId;
            MainDelegate.accountData.cityId = _city.cityId;
            [MyEUtil showThingsSuccessOn:self.view WithMessage:@"设置成功" andTag:YES];
            [self performSelector:@selector(doThisWhenNeedPopUp) withObject:nil afterDelay:1.5];
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
