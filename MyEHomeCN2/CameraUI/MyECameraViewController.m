//
//  MyECameraViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/23/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraViewController.h"
#include "MyAudioSession.h"
#include "APICommon.h"
#import "PPPPDefine.h"
#import "obj_common.h"
#import "MyECameraDetailViewController.h"
@interface MyECameraViewController (){
    BOOL _isFullScreen;
    MBProgressHUD *HUD;
    CPPPPChannel *_cameraChannel;
    NSTimer *_timer;
}
@property (nonatomic, retain) NSCondition* m_PPPPChannelMgtCondition;
@end

@implementation MyECameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [_timer invalidate];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _stopCamera];
     });

////        _m_PPPPChannelMgt->StopAll();
////        _playView.image = nil;
//    });
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _m_PPPPChannelMgt = new CPPPPChannelManagement();
    _m_PPPPChannelMgt->pCameraViewController = self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    InitAudioSession();
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _startAll];
    });
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    for (UIButton *btn in self.actionView.subviews) {
        [btn setBackgroundImage:[[UIImage imageNamed:@"control-enable-normal"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:@"control-enable-highlight"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateSelected                                                                                                ];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:69/255 green:220/255 blue:200/255 alpha:1] forState:UIControlStateSelected];
    }
    [self refreshUIWithArray:@[@0,_camera.name]];
    _timer = [NSTimer scheduledTimerWithTimeInterval:10*60 target:self selector:@selector(popUpTop) userInfo:nil repeats:NO];
}
- (BOOL)prefersStatusBarHidden{
        return YES;//隐藏为YES，显示为NO
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Notification methods
- (void) didEnterBackground{
    [_m_PPPPChannelMgtCondition lock];
    if (_m_PPPPChannelMgt == NULL) {
        [_m_PPPPChannelMgtCondition unlock];
        return;
    }
    _m_PPPPChannelMgt->StopAll();
    [_m_PPPPChannelMgtCondition unlock];
}

- (void) willEnterForeground{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _startAll];
    });
}

#pragma mark - private methods
-(void)getCameraInfo{
    _m_PPPPChannelMgt->SetDateTimeDelegate((char*)[_camera.UID UTF8String], self);
    _m_PPPPChannelMgt->SetSDcardScheduleDelegate((char*)[_camera.UID UTF8String], self);
    _m_PPPPChannelMgt->SetWifiParamDelegate((char*)[_camera.UID UTF8String], self);
    
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_GET_PARAMS, NULL, 0);
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[self.camera.UID UTF8String], MSG_TYPE_GET_RECORD, NULL, 0);
}
-(void)hideHUD{
    [HUD hide:YES];
}
-(void)popUpTop{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)refreshUIWithArray:(NSArray *)array{
    UILabel *label = self.infoLabels[[array[0] intValue]];
    label.text = array[1];
}
#pragma mark - camera control methods
- (void)_startAll {
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.playView animated:YES];
    }
    [HUD show:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _initialize];
    });
    [self _connectCam];
}
- (void)_initialize{
    PPPP_Initialize((char*)[@"EBGBEMBMKGJMGAJPEIGIFKEGHBMCHMJHCKBMBHGFBJNOLCOLCIEBHFOCCHKKJIKPBNMHLHCPPFMFADDFIINOIABFMH" UTF8String]);
    st_PPPP_NetInfo NetInfo;
    PPPP_NetworkDetect(&NetInfo, 0);
}

- (void)_connectCam{
    [_m_PPPPChannelMgtCondition lock];
    if (_m_PPPPChannelMgt == NULL) {
        [_m_PPPPChannelMgtCondition unlock];
        return;
    }
    _m_PPPPChannelMgt->StopAll();
    dispatch_async(dispatch_get_main_queue(),^{
        _playView.image = nil;
    });
    _m_PPPPChannelMgt->Start([self.camera.UID UTF8String], [self.camera.username UTF8String], [self.camera.password UTF8String]);
    [_m_PPPPChannelMgtCondition unlock];
}
- (void)_startVideo{
    if (_m_PPPPChannelMgt != NULL) {
        if (_m_PPPPChannelMgt->StartPPPPLivestream([self.camera.UID UTF8String], 10, self) == 0) {
            _m_PPPPChannelMgt->StopPPPPAudio([self.camera.UID UTF8String]);
            _m_PPPPChannelMgt->StopPPPPLivestream([self.camera.UID UTF8String]);
            
        }
        _m_PPPPChannelMgt->GetCGI([self.camera.UID UTF8String], CGI_IEGET_CAM_PARAMS);
    }
}
/*---------------------AUDIO---------------------------*/
- (void)_startAudio{
    dispatch_async(dispatch_get_main_queue(), ^{
        _m_PPPPChannelMgt->StopPPPPTalk([self.camera.UID UTF8String]);
    });
    _m_PPPPChannelMgt->StartPPPPAudio([self.camera.UID UTF8String]);
}
- (void)_stopAudio{
    _m_PPPPChannelMgt->StopPPPPAudio([self.camera.UID UTF8String]);
}
/*------------------------TALK-----------------------------*/
- (void)_startTalk{
    dispatch_async(dispatch_get_main_queue(), ^{
        _m_PPPPChannelMgt->StopPPPPAudio([self.camera.UID UTF8String]);
    });
    _m_PPPPChannelMgt->StartPPPPTalk([self.camera.UID UTF8String]);
}
- (void)_stopTalk{
    _m_PPPPChannelMgt->StopPPPPTalk([self.camera.UID UTF8String]);
}

- (void)_stopCamera{
    [_m_PPPPChannelMgtCondition lock];
    if (_m_PPPPChannelMgt == NULL) {
        [_m_PPPPChannelMgtCondition unlock];
        return;
    }
    _m_PPPPChannelMgt->StopAll();
    [_m_PPPPChannelMgtCondition lock];
    dispatch_async(dispatch_get_main_queue(),^{
        _playView.image = nil;
    });
}
-(BOOL)shouldAutorotate{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        self.view = _mainLandscapeView;
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft){
//        self.view = _mainLandscapeView;
        self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }else{
//        self.view = _mainPortraitView;
        self.view.transform = CGAffineTransformMakeRotation(0);
    }
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
#pragma mark - ImageNotifyProtocol methods
- (void) ImageNotify: (UIImage *)image timestamp: (NSInteger)timestamp DID:(NSString *)did{
    if ([self.playView.subviews count]) {
        [self performSelectorOnMainThread:@selector(hideHUD) withObject:nil waitUntilDone:YES];
    }
    [self performSelector:@selector(refreshImage:) withObject:image];
}
- (void) YUVNotify: (Byte*) yuv length:(int)length width: (int) width height:(int)height timestamp:(unsigned int)timestamp DID:(NSString *)did{
    UIImage* image = [APICommon YUV420ToImage:yuv width:width height:height];
    [self performSelector:@selector(refreshImage:) withObject:image];
}
- (void) H264Data: (Byte*) h264Frame length: (int) length type: (int) type timestamp: (NSInteger) timestamp{
    
}
#pragma mark - PPPPStatusDelegate methods
- (void) PPPPStatus: (NSString*) strDID statusType:(NSInteger) statusType status:(NSInteger) status{
    NSString* strPPPPStatus;
    switch (status) {
        case PPPP_STATUS_UNKNOWN:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusUnknown", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_CONNECTING:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnecting", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_INITIALING:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusInitialing", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_CONNECT_FAILED:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnectFailed", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_DISCONNECT:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusDisconnected", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_INVALID_ID:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusInvalidID", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_ON_LINE:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusOnline", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_DEVICE_NOT_ON_LINE:
            strPPPPStatus = NSLocalizedStringFromTable(@"CameraIsNotOnline", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_CONNECT_TIMEOUT:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnectTimeout", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_INVALID_USER_PWD:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusInvaliduserpwd", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        default:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusUnknown", @STR_LOCALIZED_FILE_NAME, nil);
            break;
    }
    NSLog(@"PPPPStatus  %@",strPPPPStatus);
    [self performSelectorOnMainThread:@selector(refreshUIWithArray:) withObject:@[@1,strPPPPStatus] waitUntilDone:YES];
    [self _startVideo];
    [self getCameraInfo];
}

//refreshImage
- (void) refreshImage:(UIImage* ) image{
    if (image != nil) {
        dispatch_async(dispatch_get_main_queue(),^{
            _playView.image = image;
        });
    }
}
#pragma mark - DateTimeProtocol

- (void) DateTimeProtocolResult:(int)now tz:(int)tz ntp_enable:(int)ntp_enable net_svr:(NSString*)ntp_svr{
    NSTimeInterval se=(long)now;
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:se];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-tz]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [self performSelectorOnMainThread:@selector(refreshUIWithArray:) withObject:@[@2,[formatter stringFromDate:date]] waitUntilDone:YES];
//    NSLog(@"Date Time %@",[formatter stringFromDate:date]);
}

#pragma mark - SdcardScheduleProtocol
-(void)sdcardScheduleParams:(NSString *)did Tota:(int)total/*SD卡总容量*/  RemainCap:(int)remain/*SD卡剩余容量*/ SD_status:(int)status/*1:停止录像 2:正在录像 0:未检测到卡*/ Cover:(int) cover_enable/*0:不自动覆盖1:自动覆盖 */ TimeLength:(int)timeLength/*录像时长*/ FixedTimeRecord:(int)ftr_enable/*0:未开启实时录像 1:开启实时录像*/ RecordSize:(int)recordSize/*录像总容量*/ record_schedule_sun_0:(int) record_schedule_sun_0 record_schedule_sun_1:(int) record_schedule_sun_1 record_schedule_sun_2:(int) record_schedule_sun_2 record_schedule_mon_0:(int) record_schedule_mon_0 record_schedule_mon_1:(int) record_schedule_mon_1 record_schedule_mon_2:(int) record_schedule_mon_2 record_schedule_tue_0:(int) record_schedule_tue_0 record_schedule_tue_1:(int) record_schedule_tue_1 record_schedule_tue_2:(int) record_schedule_tue_2 record_schedule_wed_0:(int) record_schedule_wed_0 record_schedule_wed_1:(int) record_schedule_wed_1 record_schedule_wed_2:(int) record_schedule_wed_2 record_schedule_thu_0:(int) record_schedule_thu_0 record_schedule_thu_1:(int) record_schedule_thu_1 record_schedule_thu_2:(int) record_schedule_thu_2 record_schedule_fri_0:(int) record_schedule_fri_0 record_schedule_fri_1:(int) record_schedule_fri_1 record_schedule_fri_2:(int) record_schedule_fri_2 record_schedule_sat_0:(int) record_schedule_sat_0 record_schedule_sat_1:(int) record_schedule_sat_1 record_schedule_sat_2:(int) record_schedule_sat_2{
    [self performSelectorOnMainThread:@selector(refreshUIWithArray:) withObject:@[@3,total==0?@"没有插卡或者需要格式化":[NSString stringWithFormat:@"%iM/%iM",remain,total]] waitUntilDone:YES];
//    NSLog(@"Camera %@ SD Status total %d ....",did, total);
}

#pragma mark - Wifi Param Protocol
- (void) WifiParams: (NSString*)strDID enable:(NSInteger)enable ssid:(NSString*)strSSID channel:(NSInteger)channel mode:(NSInteger)mode authtype:(NSInteger)authtype encryp:(NSInteger)encryp keyformat:(NSInteger)keyformat defkey:(NSInteger)defkey strKey1:(NSString*)strKey1 strKey2:(NSString*)strKey2 strKey3:(NSString*)strKey3 strKey4:(NSString*)strKey4 key1_bits:(NSInteger)key1_bits key2_bits:(NSInteger)key2_bits key3_bits:(NSInteger)key3_bits key4_bits:(NSInteger)key4_bits wpa_psk:(NSString*)wpa_psk{
//    NSLog(@"Camera WifiParams.....strDID: %@, enable:%d, ssid:%@, channel:%d, mode:%d, authtype:%d, encryp:%d, keyformat:%d, defkey:%d, strKey1:%@, strKey2:%@, strKey3:%@, strKey4:%@, key1_bits:%d, key2_bits:%d, key3_bits:%d, key4_bits:%d, wap_psk:%@", strDID, enable, strSSID, channel, mode, authtype, encryp, keyformat, defkey, strKey1, strKey2, strKey3, strKey4, key1_bits, key2_bits, key3_bits, key4_bits, wpa_psk);
    [self performSelectorOnMainThread:@selector(refreshUIWithArray:) withObject:@[@4,strSSID] waitUntilDone:YES];
}
#pragma mark - ParamNotifyProtocol
- (void) ParamNotify: (int) paramType params:(void*) params{
    if (paramType == CGI_IEGET_CAM_PARAMS) {
        PSTRU_CAMERA_PARAM param = (PSTRU_CAMERA_PARAM) params;
        flip = param->flip;
    }
}
#pragma mark - IBAction Methods
- (IBAction)showFullScreenView:(UIButton *)sender {
//    self.playView.frame = CGRectMake(0, 0, 320, 480);
//    self.playView.transform = CGAffineTransformMakeRotation(M_PI_2);
//    self.playView.frame = CGRectMake(0, 0, 320, 480);
//    NSLog(@"%f %f%f %f",self.playView.frame.origin.x,self.playView.frame.origin.y, self.playView.frame.size.width,self.playView.frame.size.height);
}
- (IBAction)popUp:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)changeView:(UISegmentedControl *)sender {
    self.infoView.hidden = !self.infoView.hidden;
    self.actionView.hidden = !self.actionView.hidden;
}
/*--------------------------action view methods---------------------*/
#pragma mark - IBAction camera control methods
- (IBAction)snapImage:(UIButton *)sender {
    UIGraphicsBeginImageContext(_playView.bounds.size);
    [_playView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(temp, nil, nil, nil);
    [MyEUtil showMessageOn:nil withMessage:@"截图已保存到照片库"];
//    _m_PPPPChannelMgt->SetSnapshotDelegate((char*)[_camera.UID UTF8String], self);
//    _m_PPPPChannelMgt->Snapshot([_camera.UID UTF8String]);
}
- (IBAction)openLight:(UIButton *)sender {
    _m_PPPPChannelMgt->CameraControl([self.camera.UID UTF8String], 14, sender.selected);
    sender.selected = !sender.selected;
}

- (IBAction)talkToCamera:(UIButton *)sender {
    if (sender.selected) {
        [self _stopTalk];
    }else
        [self _startTalk];
    sender.selected = !sender.selected;
}
- (IBAction)listenFromCamera:(UIButton *)sender {
    if (sender.selected) {
        [self _stopAudio];
    }else
        [self _startAudio];
    sender.selected = !sender.selected;
}
- (IBAction)moveLeftToRight:(UIButton *)sender {
    if (sender.selected) {
        _m_PPPPChannelMgt->PTZ_Control([self.camera.UID UTF8String], CMD_PTZ_CENTER);
    }else
        _m_PPPPChannelMgt->PTZ_Control([self.camera.UID UTF8String], CMD_PTZ_LEFT_RIGHT);
    sender.selected = !sender.selected;
}
- (IBAction)moveUpDown:(UIButton *)sender {
    if (sender.selected) {
        _m_PPPPChannelMgt->PTZ_Control([self.camera.UID UTF8String], CMD_PTZ_CENTER);
    }else
        _m_PPPPChannelMgt->PTZ_Control([self.camera.UID UTF8String], CMD_PTZ_UP_DOWN);
    sender.selected = !sender.selected;
}

-(void)SnapshotNotify:(NSString *)strDID data:(char *)data length:(int)length{
    UIGraphicsBeginImageContext(_playView.bounds.size);
    [_playView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(temp, nil, nil, nil);
}

@end
