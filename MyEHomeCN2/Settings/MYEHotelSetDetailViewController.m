//
//  MYEHotelSetDetailViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/15.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEHotelSetDetailViewController.h"

@interface MYEHotelSetDetailViewController ()

@end

@implementation MYEHotelSetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.type == 0) {
        return self.hotel.hotels.count;
    }
    if (self.type == 1) {
        return self.detail.rooms.count;
    }
    if (self.type == 2) {
        return self.hotel.terminals.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (self.type == 0) {
        MYEHotelDetail *detail = self.hotel.hotels[indexPath.row];
        cell.textLabel.text = detail.name;
    }
    if (self.type == 1) {
        MYEHotelRoom *room = _detail.rooms[indexPath.row];
        cell.textLabel.text = room.name;
    }
    if (self.type == 2) {
        MYEHotelTerminal *terminal = self.hotel.terminals[indexPath.row];
        cell.textLabel.text = terminal.tid;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row == _index) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIViewController *vc = self.navigationController.childViewControllers[[self.navigationController.childViewControllers indexOfObject:self] - 1];
    _index = indexPath.row;
    [vc setValue:@(_index) forKey:@"index"];
    [self.navigationController popViewControllerAnimated:YES];
//    [self.tableView reloadData];
}
@end
