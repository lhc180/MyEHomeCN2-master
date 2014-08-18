//
//  MyEAudioDefaultViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/4/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAudioDefaultViewController.h"
#import "MyEIrUserKeyViewController.h"


#define IR_KEY_SET_DOWNLOADER_NMAE @"IrKeySetDownloader"
#define IR_DEVICE_SEND_CONTROL_KEY_UPLOADER_NMAE @"IRDeviceSencControlKeyUploader"

@interface MyEAudioDefaultViewController ()

@end

@implementation MyEAudioDefaultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    super.isControlMode = YES;
	// Do any additional setup after loading the view.
    
    _keyMap = [NSMutableArray array];
    NSDictionary *dict;
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:401], @"type",
            @"电源开关", @"name",
            self.btnPower, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:402], @"type",
            @"静音", @"name",
            self.btnMute, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:403], @"type",
            @"增加音量", @"name",
            self.btnVolUp, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:404], @"type",
            @"上一首", @"name",
            self.btnPrev, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:405], @"type",
            @"开始/暂停", @"name",
            self.btnPlay, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:406], @"type",
            @"下一首", @"name",
            self.btnNext, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:407], @"type",
            @"减小音量", @"name",
            self.btnVolDown, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:408], @"type",
            @"CD", @"name",
            self.btnCD, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:409], @"type",
            @"AV", @"name",
            self.btnAV, @"button",
            nil];
    [_keyMap addObject:dict];
    //修改刚开始时所有btn的背景
//    for (UIButton *btn in self.view.subviews) {
//        if ([btn isKindOfClass:[UIButton class]]) {
//            [btn.layer setMasksToBounds:YES];
//            [btn.layer setCornerRadius:4];
//            [btn.layer setBorderWidth:1];
//            [btn.layer setBorderColor:btn.tintColor.CGColor];
////            //利用颜色绘制图片
////            UIGraphicsBeginImageContext(btn.frame.size);
////            CGContextRef context = UIGraphicsGetCurrentContext();
////            CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
////            CGContextFillRect(context, (CGRect){.size = btn.frame.size});
////            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
////            UIGraphicsEndImageContext();
////            [btn setBackgroundImage:image forState:UIControlStateHighlighted];
////            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//        }
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)changeMode:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"学习模式"]) {
        sender.title = @"控制模式";
        super.isControlMode = NO;
    }else{
        sender.title = @"学习模式";
        super.isControlMode = YES;
    }
}
@end
