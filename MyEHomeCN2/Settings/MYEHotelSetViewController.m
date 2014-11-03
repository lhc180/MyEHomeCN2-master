//
//  MYEHotelSetViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/15.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEHotelSetViewController.h"
#import "MYECitySetViewController.h"

@interface MYEHotelSetViewController ()<MyEDataLoaderDelegate>{
    MYEHotelDetail *_hotelDetail;
    MYEHotelRoom *_hotelRoom;
    MYEHotelTerminal *_hotelTerminal;
    NSInteger _loaderAction,_type;
    MBProgressHUD *HUD;
    BOOL _needRefresh;
}

@property (weak, nonatomic) IBOutlet UILabel *lblHotelName;
@property (weak, nonatomic) IBOutlet UITextField *txtRoomName;
@property (weak, nonatomic) IBOutlet UILabel *lblTerminal;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
@property (weak, nonatomic) IBOutlet UITextField *txtPIN;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;

@end

@implementation MYEHotelSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"酒店管理";
    self.navigationItem.rightBarButtonItem = self.saveBtn;
    [self startDataLoaderWithAction:1];
    if (!IS_IOS6) {
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (_needRefresh) {
        _needRefresh = NO;
        [self changeData];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private method
-(void)changeData{
    if (_type == 0) {
        _hotelDetail = self.hotel.hotels[_index];
        self.lblHotelName.text = _hotelDetail.name;
        if (_hotelDetail.rooms.count == 0) {
            [self startDataLoaderWithAction:3];
        }else{
            _hotelRoom = _hotelDetail.rooms[0];
            self.txtRoomName.text = _hotelRoom.name;
        }
    }else if (_type == 1){
        _hotelRoom = _hotelDetail.rooms[_index];
        self.txtRoomName.text = _hotelRoom.name;
    }else if (_type == 2){
        _hotelTerminal = self.hotel.terminals[_index];
        self.lblTerminal.text = _hotelTerminal.tid;
    }else{
        self.lblCity.text = [MyEUtil getCityNameByCityId:_hotelDetail.cityId];
    }
}
-(void)refreshUI{
    self.lblHotelName.text = _hotelDetail.name;
    self.txtRoomName.text = _hotelRoom.name;
    self.lblTerminal.text = _hotelTerminal.tid;
    self.lblCity.text = [MyEUtil getCityNameByCityId:_hotelDetail.cityId];
    self.txtPIN.text = _hotel.pin;
}
#pragma mark - IBAction methods
- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    [self startDataLoaderWithAction:2];
}

#pragma mark - Table view delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 3) {
        _type = 3;
        _needRefresh = YES;
        MYECitySetViewController *vc = [[UIStoryboard storyboardWithName:@"settings" bundle:nil] instantiateViewControllerWithIdentifier:@"citySet"];
        MyEProvinceAndCity *p = [[MyEProvinceAndCity alloc] init];
        vc.allCities = p;
        vc.isProvince = YES;
        vc.hotelDetail = _hotelDetail;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - URL Methods
-(void)startDataLoaderWithAction:(NSInteger)action{
    _loaderAction = action;
    NSString *str = nil;
    if (action == 1) {
        str = [NSString stringWithFormat:@"%@?m_id=%@",GetRequst(URL_FOR_HOTEL_INFO),MainDelegate.accountData.mId];
    }else if(action == 2){
        str = [NSString stringWithFormat:@"%@?m_id=%@&pin=%@&entMemberGid=%@&cityCode=%@&roomName=%@&TId=%@",GetRequst(URL_FOR_HOTEL_SAVE),MainDelegate.accountData.mId,self.txtPIN.text,_hotelDetail.gid,_hotelDetail.cityId,self.txtRoomName.text,_hotelTerminal.tid];
    }else
        str = [NSString stringWithFormat:@"%@?entMemberGid=%@",GetRequst(URL_FOR_HOTEL_ROOM_LIST),_hotelDetail.gid];
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    [MyEDataLoader startLoadingWithURLString:str postData:nil delegate:self loaderName:nil userDataDictionary:nil];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = segue.destinationViewController;
    _type = [self.tableView indexPathForCell:sender].section;
    if (_type == 0) {
        self.index = [self.hotel.hotels indexOfObject:_hotelDetail];
    }else if (_type == 1){
        self.index = [_hotelDetail.rooms indexOfObject:_hotelRoom];
    }else
        self.index = [self.hotel.terminals indexOfObject:_hotelTerminal];
    [vc setValue:@(self.index) forKey:@"index"];
    [vc setValue:@(_type) forKey:@"type"];
    [vc setValue:self.hotel forKey:@"hotel"];
    [vc setValue:_hotelDetail forKey:@"detail"];
    _needRefresh = YES;
    
}
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    _type = [self.tableView indexPathForCell:sender].section;
    if (_type == 1) {
        if (_hotelDetail.rooms.count == 0) {
            return NO;
        }
    }
    return YES;
}
#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"%@",string);
    [HUD hide:YES];
    NSDictionary *dic = [string JSONValue];
    if ([dic[@"status"] intValue] == -3) {
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
        return;
    }
    if ([dic[@"status"] intValue] < 0) {
        [MyEUtil showMessageOn:nil withMessage:@"数据获取失败"];
        return;
    }
    if (_loaderAction == 1) {
        self.hotel = [[MYEHotel alloc] initWithJsonString:string];
        _hotelDetail = [self.hotel findHotelByGid:self.hotel.gid];
        if (_hotelDetail.rooms.count > 0) {
            _hotelRoom = _hotelDetail.rooms[0];
        }
        _hotelTerminal = self.hotel.terminals[0];
        [self refreshUI];
    }else if(_loaderAction == 2){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        _hotelDetail.rooms = [NSMutableArray arrayWithArray:[[MYEHotelRoom alloc] JsonString:string]];
        if (_hotelDetail.rooms.count > 0) {
            _hotelRoom = _hotelDetail.rooms[0];
        }
        self.txtRoomName.text = _hotelRoom.name;
        [self refreshUI];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [MyEUtil showMessageOn:nil withMessage:@"与服务器连接失败"];
}
@end
