//
//  MDAlertController+Private.h
//  MDAlertController
//
//  Created by xulinfeng on 2018/3/13.
//  Copyright © 2018年 Modool. All rights reserved.
//

#import "MDAlertController.h"

@interface _MDAlertControllerCell : UITableViewCell

@property (nonatomic, strong, readonly) UIImageView *iconImageView;

@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, strong, readonly) MDAlertAction *action;

@end

@interface _MDAlertControllerCheckCell : _MDAlertControllerCell

@property (nonatomic, strong, readonly) UIImageView *selectedImageView;

@end

@interface _MDAlertControllerDestructiveFooterView : UIControl

@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, strong, readonly) MDAlertAction *action;

- (instancetype)initWithFrame:(CGRect)frame action:(MDAlertAction *)action;

@end

@interface _MDAlertControllerTextLabel : UILabel
@end

@protocol _MDAlertControllerContentView;
@protocol _MDAlertControllerContentViewDelegate <NSObject>

- (void)contentViewDidCancel:(UIView<_MDAlertControllerContentView> *)contentView;
- (void)contentView:(UIView<_MDAlertControllerContentView> *)contentView didSelectAction:(MDAlertAction *)action;

@end

@protocol _MDAlertControllerContentView <NSObject>

@property (nonatomic, weak) id<_MDAlertControllerContentViewDelegate> delegate;

@property (nonatomic, copy) NSArray<MDAlertAction *> *actions;

@property (nonatomic, strong) MDAlertAction *preferredAction;

@property (nonatomic, strong) MDAlertDismissAction *dismissAction;

@property (nonatomic, strong) UIView *customView;

@property (nonatomic, assign, getter=isWelt) BOOL welt;
@property (nonatomic, assign) MDAlertControllerAnimationOptions direction;
@property (nonatomic, assign) MDAlertControllerAnimationOptions curveOptions;

@property (nonatomic, assign) UIEdgeInsets separatorInset;

@property (nonatomic, strong, readonly) UIButton *dismissButton;
@property (nonatomic, strong, readonly) UIView *wrapperView;
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *messageLabel;

@property (nonatomic, strong, readonly) UIColor *tintColor;

- (MDAlertControllerAnimationOptions)systemOptionsWithOptions:(MDAlertControllerAnimationOptions)options displaying:(BOOL)displaying;
- (CABasicAnimation *)alphaAnimationForDisplaying:(BOOL)displaying;
- (CABasicAnimation *)positionAnimationForDisplaying:(BOOL)displaying;

- (void)reload;
- (void)displaying:(BOOL)displaying;

- (void)display:(BOOL)displaying animated:(BOOL)animated duration:(CGFloat)duration completion:(void (^)(void))completion;
- (void)display:(BOOL)displaying duration:(CGFloat)duration animations:(NSArray<CAAnimation *> *)animations completion:(void (^)(void))completion;

@end

@interface _MDAlertControllerContentView : UIView <_MDAlertControllerContentView, CAAnimationDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, copy) void (^animatedCompletion)(void);

@end

@interface _MDActionSheetContentView : _MDAlertControllerContentView

@end

@interface _MDAlertContentView : _MDAlertControllerContentView

@property (nonatomic, strong, readonly) UIView *buttonContentView;
@property (nonatomic, strong, readonly) UIView *lineView;

@property (nonatomic, strong, readonly) NSMutableArray<UIButton *> *buttons;
@property (nonatomic, strong, readonly) NSMutableArray<UIView *> *lines;

@end

@interface MDAlertAction ()

@property (nonatomic, copy, readonly) void (^handler)(MDAlertAction *action);

@end

@interface MDAlertController ()<_MDAlertControllerContentViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, copy, readonly) NSArray<MDAlertAction *> *rowActions;

@property (nonatomic, strong, readonly) UIView<_MDAlertControllerContentView> *contentView;

@property (nonatomic, strong) MDAlertController *previousAlertController;
@property (nonatomic, assign) BOOL animating;

@end

