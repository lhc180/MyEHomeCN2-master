//
//  MyETvDefaultViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/29/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyETvDefaultViewController.h"
#import "MyEIrUserKeyViewController.h"


@interface MyETvDefaultViewController ()

@end

@implementation MyETvDefaultViewController
@synthesize device;
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
    
    _keyMap = [NSMutableArray array];
    NSDictionary *dict;
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:201], @"type",
            @"机顶盒开关", @"name",
            self.btnTopset, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:202], @"type",
            @"静音", @"name",
            self.btnMute, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:203], @"type",
            @"电视开关", @"name",
            self.btnTv, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:204], @"type",
            @"频道减", @"name",
            self.btnPrevChanel, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:205], @"type",
            @"减小音量", @"name",
            self.btnVolDown, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:206], @"type",
            @"OK", @"name",
            self.btnOk, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:207], @"type",
            @"增加音量", @"name",
            self.btnVolup, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:208], @"type",
            @"频道加", @"name",
            self.btnNextChanel, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:209], @"type",
            @"1", @"name",
            self.btn1, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:210], @"type",
            @"2", @"name",
            self.btn2, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:211], @"type",
            @"3", @"name",
            self.btn3, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:212], @"type",
            @"4", @"name",
            self.btn4, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:213], @"type",
            @"5", @"name",
            self.btn5, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:214], @"type",
            @"6", @"name",
            self.btn6, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:215], @"type",
            @"7", @"name",
            self.btn7, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:216], @"type",
            @"8", @"name",
            self.btn8, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:217], @"type",
            @"9", @"name",
            self.btn9, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:218], @"type",
            @"返回", @"name",
            self.btnReturn, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:219], @"type",
            @"0", @"name",
            self.btn0, @"button",
            nil];
    [_keyMap addObject:dict];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:220], @"type",
            @"TV/AV", @"name",
            self.btnTvAv, @"button",
            nil];
    [_keyMap addObject:dict];
    //修改刚开始时所有btn的背景
    //这个添加背景边框的方法适用于所有的控件
//    for (UIButton *btn in self.view.subviews) {
//        if ([btn isKindOfClass:[UIButton class]]) {
//            [btn.layer setMasksToBounds:YES];
//            [btn.layer setCornerRadius:4];
//            [btn.layer setBorderWidth:1];
//            [btn.layer setBorderColor:btn.tintColor.CGColor];
////            //利用颜色绘制图片
////            UIGraphicsBeginImageContext(btn.frame.size);
////            CGContextRef context = UIGraphicsGetCurrentContext();
////            
////            CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
////            CGContextFillRect(context, (CGRect){.size = btn.frame.size});
////            
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
    // Dispose of any resources that can be recreated.
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
