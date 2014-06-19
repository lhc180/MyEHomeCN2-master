//
//  MyEScenesViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/5/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEScenesViewController.h"

#define SCENES_DOWNLOADER_NMAE_SCENES @"ScenesDownloader_Scenes"
#define SCENES_DOWNLOADER_NMAE_ALL_INSTRUCTIONS     @"ScenesDownloader_All_Instruction"
#define SCENES_UPLOADER_NMAE @"ScenesUploader"

@interface MyEScenesViewController ()

@end

@implementation MyEScenesViewController
@synthesize accountData = _accountData, sceneList = _sceneList,instructionRecived,scenesArray;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life circle methods
-(void)doThisWhenNeedRefreshData{
    if (self.refreshControl.isRefreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中..."];
    }
    [self downloadSceneDataFromServer];
    [self downloadInstructionFromServer];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [rc addTarget:self
                            action:@selector(doThisWhenNeedRefreshData)
                  forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //从这里可以看出，其实所使用的原理都是相同的，但采用的方法却不相同
    //这里默认只刷新一次 // by YY
    if (self.accountData.needDownloadInstructionsForScene) {
        [self downloadInstructionFromServer];
        [self downloadSceneDataFromServer];
        self.accountData.needDownloadInstructionsForScene = NO;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(BOOL)checkIfCanAddScene{
    //读的是写好的值，修改的是新建的值
    NSMutableArray *dTArray = [NSMutableArray arrayWithArray:self.accountData.deviceTypes];
    
    for (int i=0; i<[self.accountData.deviceTypes count];i++) {   //终于算是找到了问题的根源了
        NSMutableArray *dArray = nil; //里面存放的是一个设备类型的所有设备ID
        NSMutableArray *isArray = nil; //里面存放的是一个设备ID对应的所有指令
        MyEDeviceType *dt = self.accountData.deviceTypes[i];
        if ([dt.devices count] == 0) {  //如果里面没有设备，那么就移除这个type
            [dTArray removeObject:dt];
        }else{
            dArray = [NSMutableArray arrayWithArray:dt.devices];
            for (int j=0;j<[dt.devices count];j++) {
                
                NSInteger deviceId = [dt.devices[j] integerValue];
                for (MyEDevice *d in self.accountData.devices) {
                    if (deviceId == d.deviceId) {
                        
                        if (d.type == 1 ) { // 如果是空调
                            if ([d.brand isEqualToString:@""]) {
                                [dArray removeObject:[NSNumber numberWithInteger:deviceId]];
                            }
                            for (int m=0;m<[instructionRecived.allInstructions count];m++) {
                                MyESceneDevice *sd = instructionRecived.allInstructions[m];
                                if (deviceId == sd.deviceId) {
                                    
                                    isArray = [NSMutableArray arrayWithArray:sd.instructions];
                                    for (MyESceneDeviceInstruction *sdi in sd.instructions) {
                                        if (sdi.status == 0) {
                                            [isArray removeObject:sdi];
                                        }
                                    }
                                }
                            }
                        }
                        else if (d.type == 6 || d.type == 7){
                            
                        }else {
                            for (int m=0;m<[instructionRecived.allInstructions count];m++) {
                                MyESceneDevice *sd = instructionRecived.allInstructions[m];
                                if (deviceId == sd.deviceId) {
                                    
                                    isArray = [NSMutableArray arrayWithArray:sd.instructions];  //这种写法相当于将这个数组初始化了一下
                                    for (MyESceneDeviceInstruction *sdi in sd.instructions) {
                                        if (sdi.status == 0) {
                                            [isArray removeObject:sdi];
                                        }
                                    }
                                    if ([isArray count] == 0) {
                                        [dArray removeObject:[NSNumber numberWithInteger:deviceId]];
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if ([dArray count] == 0) {
                [dTArray removeObject:dt];
            }
        }
    }
    if ([dTArray count] == 0) {
        return NO;
    } else {
        return YES;
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([scenesArray count] == 0) {
        [MyEUniversal dothisWhenTableViewIsEmptyWithMessage:@"当前没有有效场景，请点击右上角“+”进行添加" andFrame:CGRectMake(20,40,280,80) andVC:self];
    }else{
        if ([self.view.subviews containsObject:[self.view viewWithTag:999]]) {
            [[self.view viewWithTag:999] removeFromSuperview];
        }
    }
    return [scenesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SceneCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *detailLabel = (UILabel *)[cell.contentView viewWithTag:3];

    MyEScene *scene = [scenesArray objectAtIndex:indexPath.row];
    [titleLabel setText:scene.name];
    [detailLabel setText:[NSString stringWithFormat:@"设备数: %lu", (unsigned long)[scene.deviceControls count]]];
    return cell;
}

#pragma mark - tableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.instructionRecived == nil) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                    contentText:@"场景中设备指令下载失败,此时不能查看场景详情,现在下载么?"
                                                leftButtonTitle:@"取消"
                                               rightButtonTitle:@"确定"];
        alert.rightBlock = ^{
            [self downloadInstructionFromServer];
        };
        [alert show];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"scene" bundle:nil];
        MyESceneDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"sceneDetail"];
        MyEScene *scene = [scenesArray objectAtIndex:indexPath.row];
        vc.scene = scene;
        vc.accountData = self.accountData;
        vc.instructionRecived = self.instructionRecived;
        [self.navigationController pushViewController:vc animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    deleteSceneIndex = indexPath;
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                contentText:@"此操作将清空该场景的数据，您确定继续么？"
                                            leftButtonTitle:@"取消"
                                           rightButtonTitle:@"确定"];
    [alert show];
    alert.rightBlock = ^() {
        [self deleteSceneFromServerWithIndexPath:indexPath];
    };

}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
#pragma mark - URL Loading System methods
-(void) deleteSceneFromServerWithIndexPath:(NSIndexPath *)index{
    MyEScene *scene = self.scenesArray[index.row];
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&action=2&name=%@&id=%li&byOrder=%li&deviceControls=%@",URL_FOR_SCENES_EDIT,self.accountData.userId,scene.name,(long)scene.sceneId,(long)scene.byOrder,[scene JSONStringWithDictionary:scene]];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"deleteSceneUploader" userDataDictionary:nil];
    NSLog(@"deleteSceneUploader is %@",loader.name);
}
- (void) downloadInstructionFromServer{
    [self.refreshControl beginRefreshing];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&ver=2",URL_FOR_SCENES_DOWNLOAD_ALL_DEVICE_INSTRUCTION, self.accountData.userId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"downloadInstrction"  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
- (void) downloadSceneDataFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@",URL_FOR_SCENES_VIEW, self.accountData.userId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:SCENES_DOWNLOADER_NMAE_SCENES  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL delegate methods
// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:SCENES_DOWNLOADER_NMAE_SCENES]) {
        NSLog(@"Vacations JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"下载场景数据发生错误。"];
        } else{
            MyESceneList *sceneList = [[MyESceneList alloc] initWithJSONString:string];
            if(sceneList){
                self.sceneList = sceneList;
                scenesArray = [NSMutableArray array];
                [scenesArray addObjectsFromArray:self.sceneList.mainArray];
                [self.tableView reloadData];//重新加载数据,这一步骤是重要的，用来显示更新后的数据。
            }
        }
        [HUD hide:YES];
    }
    
    if([name isEqualToString:@"downloadInstrction"]) {
        NSLog(@"instruction JSON string is %@",string);
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            MyESceneInstructionRecived *sceneInstruction = [[MyESceneInstructionRecived alloc] initWithJSONString:string];
            self.instructionRecived = sceneInstruction;
            self.navigationItem.rightBarButtonItem.enabled = [self checkIfCanAddScene];
        } else {
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                        contentText:@"场景中设备指令下载失败，是否重试?"
                                                    leftButtonTitle:@"否"
                                                   rightButtonTitle:@"是"];
            alert.rightBlock = ^{
                [self downloadInstructionFromServer];
            };
            [alert show];
        }
        [HUD hide:YES];
    }
    if([name isEqualToString:@"deleteSceneUploader"]) {
        NSLog(@"deleteSceneUploader JSON string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            [scenesArray removeObjectAtIndex:deleteSceneIndex.row];
            [self.tableView deleteRowsAtIndexPaths:@[deleteSceneIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadData]; //这里必须要更新一下数据，否则会出现不同步
            [MyEUtil showMessageOn:nil withMessage:@"删除场景成功"];
        }
    }
    if([name isEqualToString:@"applySceneUploader"]) {
        [HUD hide:YES];
        NSLog(@"applySceneUploader JSON String from server is \n%@",string);
        
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }else if([MyEUtil getResultFromAjaxString:string] == 1){
            [MyEUtil showMessageOn:self.view.window withMessage:[NSString stringWithFormat:@"场景[ %@ ]应用成功",dict[@"name"]]];
            [self.navigationController popViewControllerAnimated:YES];
        }else if ([MyEUtil getResultFromAjaxString:string] == 2){
            [MyEUtil showMessageOn:self.navigationController.view withMessage:[NSString stringWithFormat:@"场景[ %@ ]应用成功",dict[@"name"]]];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"场景应用发送错误，请检查"];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg = @"与服务器通信时发生错误，请稍后重试.";
    
    [MyEUtil showMessageOn:nil withMessage:msg];
    [HUD hide:YES];
}

#pragma mark - IBAction methods
- (IBAction)addScene:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入场景名称"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    alert.tag = 100;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //要想设置textfield的属性，必须先获得这个对象才行
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.textAlignment = NSTextAlignmentCenter;
    [alert show];
}
- (IBAction)applyScene:(UIButton *)sender forEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:sender] anyObject];
    CGPoint location = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    MyEScene *scene = [scenesArray objectAtIndex:indexPath.row];
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.dimBackground = YES;//容易产生灰条
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSDictionary *dic = @{@"name": scene.name};
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&id=%li",URL_FOR_SCENES_APPLY,self.accountData.userId,(long)scene.sceneId];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"applySceneUploader" userDataDictionary:dic];
    NSLog(@"applySceneUploader is %@",loader.name);

}

#pragma mark - alertView delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSMutableArray *sceneNameArray = [NSMutableArray array];
        for (int i=0; i<[scenesArray count]; i++) {
            MyEScene *scene = scenesArray[i];
            [sceneNameArray addObject:scene.name];
        }
        //这里有个快速比较的方法，以后应该多用用
        if ([sceneNameArray containsObject:textField.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您输入的场景名称已存在，请重新输入"
                                                           delegate:self
                                                  cancelButtonTitle:@"知道了"
                                                  otherButtonTitles:nil, nil];
            alert.tag = 101;
            [alert show];
        }else{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"scene" bundle:nil];
            MyEscenesAddViewController *addSceneVC = (MyEscenesAddViewController *)[storyboard instantiateViewControllerWithIdentifier:@"sceneAdd"];
            addSceneVC.sceneName = textField.text;
            addSceneVC.instructionRecived = self.instructionRecived;
            addSceneVC.accountData = self.accountData;
            [self.navigationController pushViewController:addSceneVC animated:YES];
        }
    }else if(alertView.tag == 101){
        [self addScene:nil];
    }else{
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}
@end
