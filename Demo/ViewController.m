//
//  ViewController.m
//  Demo
//
//  Created by xulinfeng on 2018/3/21.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <MDAlertController/MDAlertController.h>

#import "ViewController.h"

@interface ViewController2 : UIViewController

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(100, 100, 100, 100);
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didClickBack:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:button];
}

- (IBAction)didClickBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didClickAlert:(id)sender{
////    MDAlertController *alertController = [[[MDAlertController alertNamed:@"name" message:@"message"] actionNamed:@"确认"] actionNamed:@"取消" style:MDAlertActionStyleDestructive];
//    MDAlertController *alertController = [[[MDAlertController alertNamed:nil message:nil] actionNamed:@"确定"] actionNamed:@"取消" style:MDAlertActionStyleDestructive];
////    MDAlertController *alertController = [[MDAlertController alertNamed:nil message:nil] actionNamed:@"确定"];
////    MDAlertController *alertController = [[MDAlertController alertNamed:nil message:nil] actionNamed:@"取消" style:MDAlertActionStyleDestructive];
////    MDAlertController *alertController = [MDAlertController alertNamed:nil message:nil];
//
//    alertController.transitionStyle = MDAlertControllerTransitionStyleMoveIn | MDAlertControllerTransitionFromLeft;
//    alertController.transitionDuration = .5f;
//
//    alertController.tintColor = [UIColor redColor];
////    alertController.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
//
//    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];;
//    customView.backgroundColor = [UIColor redColor];
//    alertController.customView = customView;
//
////    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
////    animation.fromValue = @(0);
////    animation.toValue = @(2 * M_PI);
////    animation.repeatCount = 3;
////    animation.duration = 0.25;
//
////    alertController.dismissingAnimation = animation;
//
//    [self presentViewController:alertController animated:YES completion:nil];
//
////    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        ViewController2 *viewController2 = [[ViewController2 alloc] init];
////        [alertController presentViewController:viewController2 animated:YES completion:nil];
////    });
}

- (IBAction)didClickActionSheet:(id)sender{
//    MDAlertController *alertController = [[[MDAlertController actionSheetNamed:@"name" message:@"message"] actionNamed:@"确定"] actionNamed:@"取消" style:MDAlertActionStyleDestructive];
    MDAlertController *alertController = [[[MDAlertController actionSheetNamed:nil message:nil] actionNamed:@"确定"] actionNamed:@"取消" style:MDAlertActionStyleDestructive];
//    MDAlertController *alertController = [MDAlertController actionSheetNamed:nil message:nil];

    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];;
    customView.backgroundColor = [UIColor redColor];
    alertController.customView = customView;

    [self presentViewController:alertController animated:YES completion:nil];
}

@end
