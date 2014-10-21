//
//  MyEAcInstructionListViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-21.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcInstructionListViewController.h"
#import "MyEAcInstructionStudyViewController.h"
#import "MyEAcCustomInstructionViewController.h"


@interface MyEAcInstructionListViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addBtn;

@end

@implementation MyEAcInstructionListViewController

@synthesize brandAndModuleLabel,tableviewArray,labelText;


#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"指令列表";
    self.navigationItem.rightBarButtonItem = self.addBtn;
    self.brandAndModuleLabel.text = self.labelText;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    //这个是最新的定制cell的方式
    [self downloadAcInstructionList];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    MyEAcStudyInstruction *instruction0 = self.list.instructionList[0];
    MyEAcStudyInstruction *instruction1 = self.list.instructionList[1];
    if (instruction0.status > 0 && instruction1.status > 0) {
        self.model.study = 1;
    }
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - URL private methods
-(void)deleteInstructionFromServerWithIndexPath:(NSIndexPath *)index{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    MyEAcStudyInstruction *instruction = self.list.instructionList[index.row - 1];
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%li",GetRequst(URL_FOR_AC_INSTRUCTION_DELETE),(long)instruction.instructionId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"deleteInstruction" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);

}
-(void)downloadAcInstructionList{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&moduleId=%li",GetRequst(URL_FOR_USER_AC_INSTRUCTION_SET_VIEW),self.device.tId,(long)self.model.modelId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"downloadAcInstructionList" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:@"downloadAcInstructionList"]) {
        [HUD hide:YES];
        NSLog(@"downloadAcInstructionList JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"下载空调指令列表时发生错误"];
        }else{
            MyEAcStudyInstructionList *list = [[MyEAcStudyInstructionList alloc] initWithJSONString:string];
            self.list = list;
            [self.tableView reloadData];
        }
    }
    if ([name isEqualToString:@"deleteInstruction"]) {
        NSLog(@"deleteInstruction string is %@",string);
        [HUD hide:YES];
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"删除指令时发生错误"];
        }else{
            [self.list.instructionList removeObjectAtIndex:deleteInstructionIndex.row-1];
            [self.tableView deleteRowsAtIndexPaths:@[deleteInstructionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - tableview dataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.list.instructionList count]+1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    MyEAcInstructionListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.orderLabel.text = @"序号";
        cell.powerLabel.text = @"开关";
        cell.modeLabel.text = @"模式";
        cell.windLevelLabel.text = @"风力";
        cell.temperatureLabel.text = @"温度";
        cell.studyLabel.text = @"状态";
    }else{
        MyEAcStudyInstruction *instruction = self.list.instructionList[indexPath.row - 1];
        cell.order = indexPath.row;
        cell.power = instruction.power;
        cell.mode = instruction.mode;
        cell.windLevel = instruction.windLevel;
        cell.temperature = instruction.temperature;
        cell.status = instruction.status;
    }
    return cell;
    
}
#pragma mark - tableView delegate methods
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //这里可以判断是否进行编辑，不管是插入，删除还是排序
    if (indexPath.row > 2) {
        return YES;
    }else
        return NO;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return nil;
    }
    return indexPath;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    }else{
        MyEAcStudyInstruction *instruction = self.list.instructionList[indexPath.row - 1];
        switch (instruction.status) {
            case 0:
                cell.backgroundColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:0.5];
                break;
            case 1:
                cell.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:0.5];
                break;
            default:
                cell.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.4 alpha:0.5];
                break;
        }
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    deleteInstructionIndex = indexPath;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您正在删除这条指令,确定要删除么?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    alert.tag = 100;
    [alert show];
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
#pragma mark - navigation methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"edit"]) {
        MyEAcStudyInstruction *instruction = self.list.instructionList[[self.tableView indexPathForCell:sender].row - 1];
        MyEAcInstructionStudyViewController *vc = segue.destinationViewController;
        vc.instruction = instruction;
        vc.device = self.device;
        vc.brandId = self.brandId;
        vc.moduleId = self.moduleId;
        vc.jumpFromBarBtn = NO;
        vc.list = self.list;
        vc.index = [self.tableView indexPathForCell:sender];
    }
//    if ([segue.identifier isEqualToString:@"add"]) {
//        MyEAcInstructionStudyViewController *vc = segue.destinationViewController;
//        vc.jumpFromBarBtn = YES;
//        vc.device = self.device;
//        vc.moduleId = self.moduleId;
//        vc.list = self.list;
////        int i = 100;
////        [NSValue valueWithBytes:&i objCType:@encode(int)];
//    }
}

#pragma mark - IBAction methods
- (IBAction)dismissVC:(UIBarButtonItem *)sender {
//#warning 这里可能还有些问题，现在的逻辑是只要返回上一级VC都会刷新数据。为了简化逻辑，有必要新增单独返回用户品牌的接口
    [self.delegate refreshData:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)addNewInstruction:(UIBarButtonItem *)sender {
    MyEAcStudyInstruction *instruction1 = self.list.instructionList[0];
    MyEAcStudyInstruction *instruction2 = self.list.instructionList[1];
    if (instruction1.status == 0 || instruction2.status == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"当前列表的指令未学习,只有指令学习成功之后才可以添加新的指令" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        MyEAcInstructionStudyViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@""];
        vc.jumpFromBarBtn = YES;
        vc.device = self.device;
        vc.moduleId = self.moduleId;
        vc.list = self.list;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        [self deleteInstructionFromServerWithIndexPath:deleteInstructionIndex];
    }
}
@end
