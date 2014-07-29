//
//  MyECameraLandscapeViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraLandscapeViewController.h"

@interface MyECameraLandscapeViewController (){
    UIImageView *_playImage;
    NSInteger _dataLength;
    BOOL _isShowing;
}

@end
#define deg2rad (M_PI/180.0)

@implementation MyECameraLandscapeViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    _playImage = (UIImageView *)[self.view viewWithTag:100];
    if (self.actionType == 2) {
        [self setPlaybackViewHide:NO];
        [self performSelector:@selector(changeView) withObject:nil afterDelay:0.1];
        [self startRecordFromBegin:YES];
    }
    [self performSelector:@selector(changeView) withObject:nil afterDelay:0.1];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideOrShowView)];
    _isShowing = YES;
    [_playImage addGestureRecognizer:tap];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //resolution: 0  bright: 12  contrast: 100  mode: 1 flip: 0
    NSLog(@"%@",_cameraParam);
    if (self.actionType != 2) {
        UILabel *contrastLbl = (UILabel *)[_ContrastSetView viewWithTag:100];
        UILabel *brightnessLbl = (UILabel *)[_brightnessSetView viewWithTag:100];
        UISlider *contrastSlider = (UISlider *)[_ContrastSetView viewWithTag:101];
        UISlider *brightnessSlider = (UISlider *)[_brightnessSetView viewWithTag:101];
        contrastLbl.text = [NSString stringWithFormat:@"%i",_cameraParam.contrast];
        brightnessLbl.text = [NSString stringWithFormat:@"%i",_cameraParam.bright];
        contrastSlider.value = _cameraParam.contrast;
        brightnessSlider.value = _cameraParam.bright;
        contrastSlider.transform=CGAffineTransformMakeRotation(deg2rad*(90));
        brightnessSlider.transform=CGAffineTransformMakeRotation(deg2rad*(90));
        self.videoBtn.selected = _cameraParam.saturation==0?YES:NO;
    }
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
#pragma mark - private methods
-(void)hideOrShowView{
    if (_isShowing) {
        _isShowing = NO;
        if (_actionType == 2) {
            [self setPlaybackViewHide:YES];
        }else
            [self setVideoControlViewHide:YES];
    }else{
        _isShowing = YES;
        if (_actionType == 2) {
            [self setPlaybackViewHide:NO];
        }else
            [self setVideoControlViewHide:NO];
    }
}
-(void)setPlaybackViewHide:(BOOL)flag{
    _topView.hidden = flag;
    _playbackView.hidden = flag;
}
-(void)setVideoControlViewHide:(BOOL)flag{
    _cameraControlView.hidden = flag;
}
-(void)changeView{
    self.view.transform=CGAffineTransformMakeRotation(deg2rad*(90));
    self.view.bounds=CGRectMake(0.0, 0.0, screenHigh, screenwidth);
}
-(void)updateSliderValue{
    [self.progressSlider setValue:(float)_dataLength/_record.fileSize animated:YES];
}
- (void) refreshImage:(UIImage*)image{
    if (image != nil) {
        dispatch_async(dispatch_get_main_queue(),^{
            _playImage.image = nil;
            _playImage.image = image;
        });
    }
    NSData *data = UIImageJPEGRepresentation(image, 1);
    _dataLength += data.length;
    [self performSelectorOnMainThread:@selector(updateSliderValue) withObject:nil waitUntilDone:YES];
}
#pragma mark - Camera methods
-(void)startRecordFromBegin:(BOOL)flag{
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",[_record getDate],[_record getTime]];
    _m_PPPPChannelMgt->SetPlaybackDelegate((char *)[_camera.UID UTF8String], self);
    _m_PPPPChannelMgt->PPPPStartPlayback((char *)[_camera.UID UTF8String], (char *)[_record.name UTF8String], flag?0:(int)_record.fileSize*_progressSlider.value);
    if (flag) {
        self.progressSlider.value = 0;
        _dataLength = 0;
    }else
        _dataLength = _record.fileSize*_progressSlider.value;
}
-(void)stopRecord{
    _m_PPPPChannelMgt->SetPlaybackDelegate((char *)[_camera.UID UTF8String], nil);
    _m_PPPPChannelMgt->PPPPStopPlayback((char *)[_camera.UID UTF8String]);
}
-(void)cameraControlWithParam:(NSInteger)param andValue:(NSInteger)value{
    _m_PPPPChannelMgt->CameraControl([_camera.UID UTF8String], param, value);
}
#pragma mark - IBAction methods
//camera control
- (IBAction)changeVideoQulity:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([sender.currentTitle isEqualToString:@"标清"]) {
        _cameraParam.saturation = 0;
        [self cameraControlWithParam:0 andValue:0];  //转成高清
    }else
        _cameraParam.saturation = 1;
        [self cameraControlWithParam:0 andValue:1];
}
- (IBAction)contrastSet:(UISlider *)sender {
    UILabel *label = (UILabel *)[_ContrastSetView viewWithTag:100];
    label.text = [NSString stringWithFormat:@"%i",(int)sender.value];
    [self cameraControlWithParam:2 andValue:(int)sender.value];
    _ContrastSetView.hidden = YES;
}
- (IBAction)brightnessSet:(UISlider *)sender {
    UILabel *label = (UILabel *)[_brightnessSetView viewWithTag:100];
    label.text = [NSString stringWithFormat:@"%i",(int)sender.value];
    [self cameraControlWithParam:1 andValue:(int)sender.value];
    _brightnessSetView.hidden = YES;
}

- (IBAction)changeContrast:(UIButton *)sender {
    _ContrastSetView.hidden = !_ContrastSetView.hidden;
}
- (IBAction)changeBrightness:(UIButton *)sender {
    _brightnessSetView.hidden = !_brightnessSetView.hidden;
}
- (IBAction)snapshot:(UIButton *)sender {
    UIGraphicsBeginImageContext(_playImage.bounds.size);
    [_playImage.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(temp, nil, nil, nil);
    [MyEUtil showMessageOn:nil withMessage:@"截图已保存到照片库"];
}

- (IBAction)changeProgress:(UISlider *)sender {
    [self startRecordFromBegin:NO];
}
- (IBAction)lastRecord:(UIButton *)sender {
    if ([_recordArray containsObject:_record]) {
        NSInteger i = [_recordArray indexOfObject:_record];
        if (i == _recordArray.count-1) {
            [MyEUtil showMessageOn:nil withMessage:@"没有更早的录像"];
        }else{
            NSLog(@"%@",_record);
//            [self stopRecord];
            _record = _recordArray[i+1];
            NSLog(@"%@",_record);
            [self startRecordFromBegin:YES];
        }
    }
}
- (IBAction)nextRecord:(UIButton *)sender {
    if ([_recordArray containsObject:_record]) {
        NSInteger i = [_recordArray indexOfObject:_record];
        if (i == 0) {
            [MyEUtil showMessageOn:nil withMessage:@"没有最新录像"];
        }else{
//            [self stopRecord];
            _record = _recordArray[i-1];
            [self startRecordFromBegin:YES];
        }
    }
}
- (IBAction)startOrStopRecord:(UIButton *)sender {
    if (sender.selected) {
        [self startRecordFromBegin:NO];
    }else{
        [self stopRecord];
    }
    sender.selected = !sender.selected;
}
-(IBAction)dismissVC:(UIButton *)sender{
    [self stopRecord];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - image notify delegate
- (void) ImageNotify: (UIImage *)image timestamp: (NSInteger)timestamp DID:(NSString *)did{
    [self performSelector:@selector(refreshImage:) withObject:image];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
