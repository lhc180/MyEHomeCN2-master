//
//  MyECameraLandscapeViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraLandscapeViewController.h"
#import "MBProgressHUD.h"
@interface MyECameraLandscapeViewController (){
    UIImageView *_playImage;
    NSInteger _dataLength;
    BOOL _isShowing;
    MBProgressHUD *HUD;
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
    }else{
        [self setVideoControlViewHide:NO];
        [self addGestureOnControlView];
    }
    [self performSelector:@selector(changeView) withObject:nil afterDelay:0.1];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideOrShowView)];
    _isShowing = YES;
    [self.view addGestureRecognizer:tap];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToSuperView:)];
    tap2.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap2];
    if (IS_IOS6) {
        self.videoControlSeg.layer.borderColor = MainColor.CGColor;
        self.videoControlSeg.layer.borderWidth = 1.0f;
        self.videoControlSeg.layer.cornerRadius = 4.0f;
        self.videoControlSeg.layer.masksToBounds = YES;
    }
//    [_resetBtn setBackgroundImage:[[UIImage imageNamed:@"control-enable-normal"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
//    [_resetBtn setBackgroundImage:[[UIImage imageNamed:@"control-enable-highlight"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
//    [_resetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_resetBtn setTitleColor:[UIColor colorWithRed:69/255 green:220/255 blue:200/255 alpha:1] forState:UIControlStateHighlighted];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
//    NSLog(@"%@",_playImage.gestureRecognizers);
//    //resolution: 0  bright: 12  contrast: 100  mode: 1 flip: 0
//    NSLog(@"%@",_cameraParam);
//    if (self.actionType != 2) {
//        UILabel *contrastLbl = (UILabel *)[_ContrastSetView viewWithTag:100];
//        UILabel *brightnessLbl = (UILabel *)[_brightnessSetView viewWithTag:100];
//        UISlider *contrastSlider = (UISlider *)[_ContrastSetView viewWithTag:101];
//        UISlider *brightnessSlider = (UISlider *)[_brightnessSetView viewWithTag:101];
//        contrastLbl.text = [NSString stringWithFormat:@"%i",_cameraParam.contrast];
//        brightnessLbl.text = [NSString stringWithFormat:@"%i",_cameraParam.bright];
//        contrastSlider.value = _cameraParam.contrast;
//        brightnessSlider.value = _cameraParam.bright;
//        contrastSlider.transform=CGAffineTransformMakeRotation(deg2rad*(90));
//        brightnessSlider.transform=CGAffineTransformMakeRotation(deg2rad*(90));
//        self.videoBtn.selected = _cameraParam.saturation==0?YES:NO;
//    }
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
    [self performSelectorOnMainThread:@selector(updateSliderValue) withObject:nil waitUntilDone:NO];
}
-(void)addGestureOnControlView{
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeOnBrightViewFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [_brightnessSetView addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeOnBrightViewFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [_brightnessSetView addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeOnContrastViewFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [_ContrastSetView addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeOnContrastViewFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [_ContrastSetView addGestureRecognizer:recognizer];
}
-(void)handleSwipeOnBrightViewFrom:(UISwipeGestureRecognizer *)recognizer{
    if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        _cameraParam.bright += 5;
        if (_cameraParam.bright > 255) {
            _cameraParam.bright = 255;
        }
    }else if(recognizer.direction == UISwipeGestureRecognizerDirectionDown){
        _cameraParam.bright -= 5;
        if (_cameraParam.bright < 1) {
            _cameraParam.bright = 1;
        }
    }
    [self cameraControlWithParam:1 andValue:_cameraParam.bright];
    [self showHUDWithString:[NSString stringWithFormat:@"亮度: %i",_cameraParam.bright]];
}
-(void)handleSwipeOnContrastViewFrom:(UISwipeGestureRecognizer *)recognizer{
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        _cameraParam.contrast += 5;
        if (_cameraParam.contrast > 255) {
            _cameraParam.contrast = 255;
        }
    }else if(recognizer.direction == UISwipeGestureRecognizerDirectionDown){
        _cameraParam.contrast -= 5;
        if (_cameraParam.contrast < 1) {
            _cameraParam.contrast = 1;
        }
    }
    [self cameraControlWithParam:2 andValue:_cameraParam.contrast];
    [self showHUDWithString:[NSString stringWithFormat:@"对比度: %i",_cameraParam.contrast]];
}
-(void)showHUD{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.opacity = 0.5;
        HUD.userInteractionEnabled = YES;
    }else
        [HUD show:YES];
}
-(void)showHUDWithString:(NSString *)string{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.opacity = 0.5;
        HUD.userInteractionEnabled = YES;
    }else
        [HUD show:YES];
    HUD.labelText = string;
    [HUD hide:YES afterDelay:1];
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
- (IBAction)videoQulityChange:(UISegmentedControl *)sender {
    NSInteger i = sender.selectedSegmentIndex;
    if (i == 0) {
        _cameraParam.saturation = 1;
        [self cameraControlWithParam:0 andValue:1];
        [sender setSelectedSegmentIndex:0];
    }else{
        _cameraParam.saturation = 0;
        [self cameraControlWithParam:0 andValue:0];  //转成高清
        [sender setSelectedSegmentIndex:1];
    }
}
- (IBAction)snapshot:(UIButton *)sender {
    UIGraphicsBeginImageContext(_playImage.bounds.size);
    [_playImage.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(temp, nil, nil, nil);
//    [MyEUtil showMessageOn:nil withMessage:@"截图已保存到照片库"];
}
- (IBAction)resetToTheDefault:(UIButton *)sender {
    [self cameraControlWithParam:1 andValue:62];
    [self cameraControlWithParam:2 andValue:123];
}
- (IBAction)backToSuperView:(UIButton *)sender {
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
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
