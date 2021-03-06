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

@property (strong, nonatomic) UIViewController *presented;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.presented = nil;
}

- (MDAlertController *)alertController {
    MDAlertControllerStyle style = arc4random() % 2;
    MDAlertController *alertController = [MDAlertController alertControllerWithTitle:@"title" message:@"message" preferredStyle:style];
    MDAlertAction *action = [MDAlertAction actionWithTitle:@"哈哈哈" style:MDAlertActionStyleDefault handler:nil];
//    action.titleAlignment = NSTextAlignmentCenter;
    [alertController addAction:action];

    action = [MDAlertAction actionWithTitle:@"确定" style:MDAlertActionStyleDefault handler:nil];
    [alertController addAction:action];

    action = [MDAlertAction actionWithTitle:@"取消" style:MDAlertActionStyleDestructive handler:nil];
    [alertController addAction:action];

    alertController.backgroundTouchabled = YES;

    BOOL valid = arc4random() % 2;
    if (valid) {
        MDAlertControllerAnimationOptions direction = (arc4random() % 4 + 1) << 28;
        alertController.transitionOptions = MDAlertControllerAnimationOptionCurveEaseIn | MDAlertControllerAnimationOptionTransitionMoveIn | direction;
    } else {
        MDAlertControllerAnimationOptions options = (arc4random() % 8) << 20;
        alertController.transitionOptions = MDAlertControllerAnimationOptionCurveEaseIn | options;
    }

    alertController.transitionDuration = arc4random() % 100 / 100. * 0.5 + .15f;
    alertController.welt = arc4random() % 2;
    alertController.overridable = arc4random() % 2;
    alertController.backgroundOptions = MDAlertControllerBackgroundOptionExclusive;

    alertController.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    alertController.contentView.backgroundColor = [UIColor clearColor];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    label.text = @"哈哈哈";
    label.userInteractionEnabled = YES;
    label.textColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255. green:arc4random() % 255 / 255. blue:arc4random() % 255 / 255. alpha:1];
    label.numberOfLines = 10000;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickCustomView:)];
    [label addGestureRecognizer:tap];

    alertController.customView = label;

    alertController.cancelation = ^(MDAlertController *alertController) {
        
    };

    return alertController;
}

- (void)presentAlert:(UIViewController *)viewController {
    MDAlertController *alertController = [self alertController];

    [viewController presentViewController:alertController animated:YES completion:nil];
    self.presented = alertController;
}

- (void)embeded {
    MDAlertController *alertController = [self alertController];

    [self embedAlertController:alertController animated:YES completion:nil];
}

- (IBAction)didClickAlert:(id)sender{
    [self presentAlert:self];
//    [self embeded];
}

- (IBAction)didClickCustomView:(UITapGestureRecognizer *)sender{
//    UILabel *label = (UILabel *)[sender view];
//
//    label.text = @"fnsfnoneofiosnfoesnfisfiesnfsnefoenfisenfosiefnsiefnesifnsofenfsofnsfnoneofiosnfoesnfisfiesnfsnefoenfisenfosiefnsiefnesifnsofenfsofnsfnoneofiosnfoesnfisfiesnfsnefoenfisenfosiefnsiefnesifnsofenfsofnsfnoneofiosnfoesnfisfiesnfsnefoenfisenfosiefnsiefnesifnsofenfsofnsfnoneofiosnfoesnfisfiesnfsnefoenfisenfosiefnsiefnesifnsofenfsofnsfnoneofiosnfoesnfisfiesnfsnefoenfisenfosiefnsiefnesifnsofenfsofnsfnoneofiosnfoesnfisfiesnfsnefoenfisenfosiefnsiefnesifnsofenfsofnsfnoneofiosnfoesnfisfiesnfsnefoenfisenfosiefnsiefnesifnsofenfsofnsfnoneofiosnfoesnfisfiesnfsnefoenfisenfosiefnsiefnesifnsofenfsofnsfnoneofiosnfoesnfisfiesnfsnefoenfisenfosiefnsiefnesifnsofenfsofnsfnoneofiosnfoesnfisfiesnfsnefoenfisenfosiefnsiefnesifnsofenfsofnsfnoneofiosnfoesnfisfiesnfsnefoenfisenfosiefnsiefnesifnsofenfso";
//
//    [label sizeToFit];
//    sender.frame = CGRectMake(0, 0, 100, 100);

    UIViewController *top = [self.navigationController topViewController];
    UIViewController *visible = [self.navigationController visibleViewController];

    UIViewController *presented = self.presented ?: self;
    [self presentAlert:presented];
//    [self embeded];

}

- (IBAction)didClickActionSheet:(id)sender{
//    MDAlertController *alertController = [[[MDAlertController actionSheetNamed:@"name" message:@"message"] actionNamed:@"确定"] actionNamed:@"取消" style:MDAlertActionStyleDestructive];
    MDAlertController *alertController = [[[MDAlertController actionSheetNamed:nil message:nil] actionNamed:@"确定"] actionNamed:@"取消" style:MDAlertActionStyleDestructive];
//    MDAlertController *alertController = [MDAlertController actionSheetNamed:nil message:nil];

    alertController.transitionOptions = MDAlertControllerAnimationOptionCurveEaseIn | MDAlertControllerAnimationOptionTransitionMoveIn | MDAlertControllerAnimationOptionDirectionFromBottom;
    alertController.transitionDuration = .15f;

    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];;
    customView.backgroundColor = [UIColor redColor];
    alertController.customView = customView;

    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
