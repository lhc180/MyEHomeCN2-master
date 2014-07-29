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
#import "cmdhead.h"

#import "MyECameraLandscapeViewController.h"

#define deg2rad (M_PI/180.0)

@interface MyECameraViewController (){
    BOOL _isFullScreen;
    BOOL _isLandscape;
    MBProgressHUD *HUD;
    CPPPPChannel *_cameraChannel;
    NSTimer *_timer;
    NSTimer *_timerForSpeed,*_timerForDate;
    NSInteger _seconds,_timeZone,_speed,_secondsFromNow;
    MyECameraLandscapeViewController *_vc;
}
@property (nonatomic, retain) NSCondition* m_PPPPChannelMgtCondition;
@end

@implementation MyECameraViewController

#pragma mark - life circle methods
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [_timer invalidate];
    [_timerForDate invalidate];
    [_timerForSpeed invalidate];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    _m_PPPPChannelMgt->SetDateTimeDelegate((char*)[_camera.UID UTF8String], nil);
    _m_PPPPChannelMgt->SetSDcardScheduleDelegate((char*)[_camera.UID UTF8String], nil);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    _m_PPPPChannelMgtCondition = [[NSCondition alloc] init];
    _m_PPPPChannelMgt = new CPPPPChannelManagement();
    _m_PPPPChannelMgt->pCameraViewController = self;
    InitAudioSession();
    [self _startAll];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUserInterface) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self refreshUIWithArray:@[@0,_camera.name]];
    _timer = [NSTimer scheduledTimerWithTimeInterval:15*60 target:self selector:@selector(popUp:) userInfo:nil repeats:NO];
    
    //初始化各个方向的view
    _vc = [self.storyboard instantiateViewControllerWithIdentifier:@"landscape"];
    _vc.m_PPPPChannelMgt = _m_PPPPChannelMgt;
    _vc.camera = _camera;
    self.mainLandscapeView = _vc.view;
    self.mainPortraitView = self.view;
    UIImageView *image = (UIImageView *)[self.mainLandscapeView viewWithTag:100];
    [self addGestureOnImageView:image];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullScreenView:)];
    tap.numberOfTapsRequired = 2;
    [_playView addGestureRecognizer:tap];
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
    [self _stopCamera];
}

- (void) willEnterForeground{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _startAll];
    });
}

#pragma mark - private methods
-(void)addGestureOnImageView:(UIImageView *)image{
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [image addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [image addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [image addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [image addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endShowFullScreenView)];
    tap.numberOfTapsRequired = 2;
    [image addGestureRecognizer:tap];
}
-(void)changeUserInterface{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationUnknown:
            NSLog(@"Unknown");
            break;
        case UIDeviceOrientationFaceUp:
            NSLog(@"Device oriented flat, face up");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"Device oriented flat, face down");
            break;
        case UIDeviceOrientationLandscapeLeft:
            if (_isLandscape) {
                return ;
            }
            _isLandscape = YES;
//            self.view=self.mainLandscapeView;
            [self.view addSubview:self.mainLandscapeView];
//            self.view.transform=CGAffineTransformMakeRotation(deg2rad*(90));
//            self.view.bounds=CGRectMake(0.0, 0.0, screenHigh, screenwidth);
            NSLog(@"Device oriented horizontally, home button on the right");
            break;
        case UIDeviceOrientationLandscapeRight:
            if (_isLandscape) {
                return ;
            }
            _isLandscape = YES;
//            self.view=self.mainLandscapeView;
            [self.view addSubview:self.mainLandscapeView];
//            self.view.transform=CGAffineTransformMakeRotation(deg2rad*(-90));
//            self.view.bounds=CGRectMake(0.0, 0.0, screenHigh, screenwidth);
            NSLog(@"Device oriented horizontally, home button on the left");
            break;
        case UIDeviceOrientationPortrait:
            _isLandscape = NO;
//            self.view=self.mainPortraitView;
            [self.mainLandscapeView removeFromSuperview];
//            self.view.transform=CGAffineTransformMakeRotation(deg2rad*(0));
//            self.view.bounds=CGRectMake(0.0, 0.0, screenwidth, screenHigh);
            NSLog(@"Device oriented vertically, home button on the bottom");
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"Device oriented vertically, home button on the top");
            break;
        default:
            NSLog(@"cannot distinguish");
            break;
    }
}
-(void)getCameraInfo{
    //设置代理
    _m_PPPPChannelMgt->SetDateTimeDelegate((char*)[_camera.UID UTF8String], self);
    _m_PPPPChannelMgt->SetSDcardScheduleDelegate((char*)[_camera.UID UTF8String], self);
    
    //获取具体的值
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_GET_PARAMS, NULL, 0);
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[self.camera.UID UTF8String], MSG_TYPE_GET_RECORD, NULL, 0);
}
-(void)hideHUD{
    [HUD hide:YES];
}
-(void)popUpTop{
    [self _stopCamera];
    [self dismissViewControllerAnimated:YES completion:nil];
    //    [self.navigationController popViewControllerAnimated:YES];
}
-(void)refreshUIWithArray:(NSArray *)array{
    UILabel *label = self.infoLabels[[array[0] intValue]];
    label.text = array[1];
}
-(void)startTimerToGetStatus{
    _timerForSpeed = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getSpeed) userInfo:nil repeats:YES];
    _timerForDate = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getTime) userInfo:nil repeats:YES];
}
-(void)getTime{
    if (_seconds > 0) {
        NSTimeInterval se=(long)_seconds;
        NSDate *date=[NSDate dateWithTimeIntervalSince1970:se];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-_timeZone]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _seconds ++;
        _secondsFromNow ++;
//        NSLog(@"Date Time %@",[formatter stringFromDate:date]);
        [self refreshUIWithArray:@[@(2),[formatter stringFromDate:date]]];
        [self refreshUIWithArray:@[@(5),[NSString stringWithFormat:@"%i 分钟",_secondsFromNow/60]]];
    }
}
-(void)getSpeed{
//    NSLog(@"%i Kb/s",_speed/1024/3);
    [self refreshUIWithArray:@[@(4),[NSString stringWithFormat:@"%i KB/s",_speed/1024/3]]];
    _speed = 0;
}

#pragma mark UIScreenEdgePanGesture methods
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionDown) {
        _m_PPPPChannelMgt->PTZ_Control([self.camera.UID UTF8String], CMD_PTZ_UP);
        NSLog(@"swipe down");
    }
    if(recognizer.direction==UISwipeGestureRecognizerDirectionUp) {
        _m_PPPPChannelMgt->PTZ_Control([self.camera.UID UTF8String], CMD_PTZ_DOWN);
        NSLog(@"swipe up");
    }
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        _m_PPPPChannelMgt->PTZ_Control([self.camera.UID UTF8String], CMD_PTZ_RIGHT);
        NSLog(@"swipe left");
    }
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        _m_PPPPChannelMgt->PTZ_Control([self.camera.UID UTF8String], CMD_PTZ_LEFT);
        NSLog(@"swipe right");
    }
}
#pragma mark - camera control methods
- (void)_startAll {
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.playView animated:YES];
    }
    [HUD show:YES];
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
    [self performSelector:@selector(startPPPP:) withObject:_camera.UID];
    [_m_PPPPChannelMgtCondition unlock];
}
-(void)startPPPP:(NSString *)cameraUID{
    _m_PPPPChannelMgt->Start([cameraUID UTF8String], [self.camera.username UTF8String], [self.camera.password UTF8String]);
}
- (void)_startVideo{
    if (_m_PPPPChannelMgt != NULL) {
        if (_m_PPPPChannelMgt->StartPPPPLivestream([self.camera.UID UTF8String], 10, self) == 0) {
            _m_PPPPChannelMgt->StopPPPPAudio([self.camera.UID UTF8String]);
            _m_PPPPChannelMgt->StopPPPPLivestream([self.camera.UID UTF8String]);
        }
    }
    //设置代理
    _m_PPPPChannelMgt->SetDateTimeDelegate((char*)[_camera.UID UTF8String], self);
    _m_PPPPChannelMgt->SetSDcardScheduleDelegate((char*)[_camera.UID UTF8String], self);
    
    //获取具体的值
    _m_PPPPChannelMgt->GetCGI([_camera.UID UTF8String], CGI_IEGET_CAM_PARAMS);
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_GET_PARAMS, NULL, 0);
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[self.camera.UID UTF8String], MSG_TYPE_GET_RECORD, NULL, 0);
    [self performSelectorOnMainThread:@selector(startTimerToGetStatus) withObject:nil waitUntilDone:YES];
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
    _m_PPPPChannelMgt->StopPPPPAudio([self.camera.UID UTF8String]);
    _m_PPPPChannelMgt->StopPPPPTalk([self.camera.UID UTF8String]);
    _m_PPPPChannelMgt->StopPPPPLivestream([self.camera.UID UTF8String]);

    _m_PPPPChannelMgt->StopAll();
    [_m_PPPPChannelMgtCondition unlock];
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
#pragma mark - ImageNotifyProtocol methods
- (void) ImageNotify: (UIImage *)image timestamp: (NSInteger)timestamp DID:(NSString *)did{
    if ([self.playView.subviews count]) {
        [self performSelectorOnMainThread:@selector(hideHUD) withObject:nil waitUntilDone:YES];
    }
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    _speed += data.length;
    [self performSelector:@selector(refreshImage:) withObject:image];
}
//- (void) YUVNotify: (Byte*) yuv length:(int)length width: (int) width height:(int)height timestamp:(unsigned int)timestamp DID:(NSString *)did{
////    UIImage* image = [APICommon YUV420ToImage:yuv width:width height:height];
//    [self performSelector:@selector(refreshImage:) withObject:[APICommon YUV420ToImage:yuv width:width height:height]];
//}
//- (void) H264Data: (Byte*) h264Frame length: (int) length type: (int) type timestamp: (NSInteger) timestamp{
//
//}
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
            [self _startVideo];
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
}

//-(void)changeImage:(UIImage *)image{
//    if (image != nil) {
//        if ([self.view isEqual:self.mainLandscapeView]) {
//            UIImageView *imageV = (UIImageView *)[self.mainLandscapeView viewWithTag:100];
//            imageV.image = image;
//        }else{
//            _playView.image = image;
//        }
//    }
//}
//refreshImage
- (void) refreshImage:(UIImage*)image{
    if (image != nil) {
        dispatch_async(dispatch_get_main_queue(),^{
//            if ([self.view isEqual:self.mainLandscapeView]) {
            if ([self.view.subviews containsObject:self.mainLandscapeView]) {
                UIImageView *imageV = (UIImageView *)[self.mainLandscapeView viewWithTag:100];
                imageV.image = nil;
                imageV.image = image;
            }else{
                _playView.image = nil;
                _playView.image = image;
            }
        });
    }
}
#pragma mark - DateTimeProtocol

- (void) DateTimeProtocolResult:(int)now tz:(int)tz ntp_enable:(int)ntp_enable net_svr:(NSString*)ntp_svr{
    _seconds = now;
    _timeZone = tz;
//    NSTimeInterval se=(long)now;
//    NSDate *date=[NSDate dateWithTimeIntervalSince1970:se];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-tz]];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    [self performSelectorOnMainThread:@selector(refreshUIWithArray:) withObject:@[@2,[formatter stringFromDate:date]] waitUntilDone:YES];
}

#pragma mark - SdcardScheduleProtocol
-(void)sdcardScheduleParams:(NSString *)did Tota:(int)total/*SD卡总容量*/  RemainCap:(int)remain/*SD卡剩余容量*/ SD_status:(int)status/*1:停止录像 2:正在录像 0:未检测到卡*/ Cover:(int) cover_enable/*0:不自动覆盖1:自动覆盖 */ TimeLength:(int)timeLength/*录像时长*/ FixedTimeRecord:(int)ftr_enable/*0:未开启实时录像 1:开启实时录像*/ RecordSize:(int)recordSize/*录像总容量*/ record_schedule_sun_0:(int) record_schedule_sun_0 record_schedule_sun_1:(int) record_schedule_sun_1 record_schedule_sun_2:(int) record_schedule_sun_2 record_schedule_mon_0:(int) record_schedule_mon_0 record_schedule_mon_1:(int) record_schedule_mon_1 record_schedule_mon_2:(int) record_schedule_mon_2 record_schedule_tue_0:(int) record_schedule_tue_0 record_schedule_tue_1:(int) record_schedule_tue_1 record_schedule_tue_2:(int) record_schedule_tue_2 record_schedule_wed_0:(int) record_schedule_wed_0 record_schedule_wed_1:(int) record_schedule_wed_1 record_schedule_wed_2:(int) record_schedule_wed_2 record_schedule_thu_0:(int) record_schedule_thu_0 record_schedule_thu_1:(int) record_schedule_thu_1 record_schedule_thu_2:(int) record_schedule_thu_2 record_schedule_fri_0:(int) record_schedule_fri_0 record_schedule_fri_1:(int) record_schedule_fri_1 record_schedule_fri_2:(int) record_schedule_fri_2 record_schedule_sat_0:(int) record_schedule_sat_0 record_schedule_sat_1:(int) record_schedule_sat_1 record_schedule_sat_2:(int) record_schedule_sat_2{
    [self performSelectorOnMainThread:@selector(refreshUIWithArray:) withObject:@[@3,total==0?@"没有插卡或者需要格式化":[NSString stringWithFormat:@"%iM/%iM",remain,total]] waitUntilDone:YES];
    //    NSLog(@"Camera %@ SD Status total %d ....",did, total);
}

#pragma mark - ParamNotifyProtocol
- (void) ParamNotify: (int) paramType params:(void*) params{
    if (paramType == CGI_IEGET_CAM_PARAMS) {
        PSTRU_CAMERA_PARAM param = (PSTRU_CAMERA_PARAM) params;
        _cameraParam = [[MyECameraParam alloc] init];
        _cameraParam.resolution = param->resolution;
        _cameraParam.bright = param->bright;
        _cameraParam.contrast = param->contrast;
        _cameraParam.mode = param->mode;
        _cameraParam.flip = param->flip;
        _vc.cameraParam = _cameraParam;
        NSLog(@"%@",_cameraParam);
    }
}
#pragma mark - IBAction Methods
-(void)endShowFullScreenView{
    if (_isLandscape) {
        _isLandscape = NO;
//        self.view=self.mainPortraitView;
        [self.mainLandscapeView removeFromSuperview];
//        self.view.transform=CGAffineTransformMakeRotation(deg2rad*(0));
//        self.view.bounds=CGRectMake(0.0, 0.0, screenwidth, screenHigh);
    }
}
- (IBAction)showFullScreenView:(UIButton *)sender {
    _isLandscape = !_isLandscape;
    if (_isLandscape) {
//        self.view=self.mainLandscapeView;
        [self.view addSubview:self.mainLandscapeView];
//        self.view.transform=CGAffineTransformMakeRotation(deg2rad*(90));
//        self.view.bounds=CGRectMake(0.0, 0.0, screenHigh, screenwidth);
    }else{
        [self.mainLandscapeView removeFromSuperview];
//        self.view=self.mainPortraitView;
//        self.view.transform=CGAffineTransformMakeRotation(deg2rad*(0));
//        self.view.bounds=CGRectMake(0.0, 0.0, screenwidth, screenHigh);
    }
}
- (IBAction)popUp:(UIButton *)sender {
    [self _stopCamera];
    [self dismissViewControllerAnimated:YES completion:nil];
    //    [self performSelector:@selector(popUpTop) withObject:nil afterDelay:0.5];
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
    //之前的功能是截取摄像头的图片保存，现在的功能是截取当前看到的图片保存
    //    _m_PPPPChannelMgt->SetSnapshotDelegate((char*)[_camera.UID UTF8String], self);
    //    _m_PPPPChannelMgt->Snapshot([_camera.UID UTF8String]);
}
- (IBAction)openLight:(UIButton *)sender {
    sender.selected = !sender.selected;
    _m_PPPPChannelMgt->CameraControl([self.camera.UID UTF8String], 14, sender.selected);
}

- (IBAction)talkToCamera:(UIButton *)sender {
    if (self.listenBtn.selected) {
        self.listenBtn.selected = NO;
        [self _stopAudio];
    }
    if (sender.selected) {
        [self _stopTalk];
    }else
        [self _startTalk];
    sender.selected = !sender.selected;
}
- (IBAction)listenFromCamera:(UIButton *)sender {
    if (self.talkBtn.selected) {
        self.talkBtn.selected = NO;
        [self _stopTalk];
    }
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
