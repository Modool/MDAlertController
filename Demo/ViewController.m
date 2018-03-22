//
//  ViewController.m
//  Demo
//
//  Created by xulinfeng on 2018/3/21.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <MDAlertController/MDAlertController.h>

#import "ViewController.h"

@interface ViewController ()

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
    MDAlertController *alertController = [[[MDAlertController alertNamed:@"name" message:@"message"] actionNamed:@"确认"] actionNamed:@"取消" style:MDAlertActionStyleDestructive];
    alertController.tintColor = [UIColor redColor];
    alertController.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(0);
    animation.toValue = @(2 * M_PI);
    animation.repeatCount = 3;
    animation.duration = 0.25;
    
    alertController.dismissingAnimation = animation;
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)didClickActionSheet:(id)sender{
    MDAlertController *alertController = [[[MDAlertController actionSheetNamed:@"name" message:@"message"] actionNamed:@"确定"] actionNamed:@"取消" style:MDAlertActionStyleDestructive];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
