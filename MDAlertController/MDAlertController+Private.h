//
//  MDAlertController+Private.h
//  MDAlertController
//
//  Created by xulinfeng on 2018/3/13.
//  Copyright © 2018年 Modool. All rights reserved.
//

#import "MDAlertController.h"

@interface _MDAlertControllerCell : UITableViewCell {
@protected
    UIImageView *_iconImageView;
    MDAlertAction *_action;
}
@property (nonatomic, strong, readonly) UILabel *titleLabel;

@end

@interface _MDAlertControllerCheckCell : _MDAlertControllerCell {
@protected
    UIImageView *_selectedImageView;
}

@end

@interface _MDAlertControllerDestructiveFooterView : UIControl {
@protected
    UIView *_separatorView;
    UILabel *_titleLabel;
}

@property (nonatomic, strong, readonly) MDAlertAction *action;

- (instancetype)initWithFrame:(CGRect)frame action:(MDAlertAction *)action;

@end

@interface _MDAlertControllerTitleLabel : UILabel
@end

@interface _MDAlertControllerMessageLabel : UILabel
@end

@protocol _MDAlertControllerTransitionView;
@protocol _MDAlertControllerContentViewDelegate <NSObject>

- (void)contentViewDidCancel:(UIView<_MDAlertControllerTransitionView> *)contentView;
- (void)contentView:(UIView<_MDAlertControllerTransitionView> *)contentView didSelectAction:(MDAlertAction *)action;

@end

@protocol _MDAlertControllerTransitionView <NSObject>

@property (nonatomic, weak) id<_MDAlertControllerContentViewDelegate> delegate;

@property (nonatomic, copy) NSArray<MDAlertAction *> *actions;

@property (nonatomic, strong) MDAlertAction *preferredAction;

@property (nonatomic, strong) MDAlertDismissAction *dismissAction;

@property (nonatomic, strong) UIView *customView;

@property (nonatomic, assign, getter=isWelt) BOOL welt;
@property (nonatomic, assign) MDAlertControllerAnimationOptions direction;
@property (nonatomic, assign) MDAlertControllerAnimationOptions curveOptions;

@property (nonatomic, assign) UIEdgeInsets separatorInset;
@property (nonatomic, strong) UIColor *separatorColor;

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

@interface _MDAlertControllerTransitionView : UIView <_MDAlertControllerTransitionView, CAAnimationDelegate, UITableViewDelegate, UITableViewDataSource> {
@protected
    __weak id<_MDAlertControllerContentViewDelegate> _delegate;

    NSArray<MDAlertAction *> *_actions;

    MDAlertAction *_preferredAction;
    MDAlertDismissAction *_dismissAction;

    UIView *_customView;
    UITableView *_tableView;
    UITapGestureRecognizer *_tapGestureRecognizer;

    BOOL _welt;
    MDAlertControllerAnimationOptions _direction;
    MDAlertControllerAnimationOptions _curveOptions;

    UIEdgeInsets _separatorInset;
    UIColor *_separatorColor;

    UIButton *_dismissButton;
    UIView *_wrapperView;
    UIView *_contentView;
    UIView *_backgroundView;
    UILabel *_titleLabel;
    UILabel *_messageLabel;

}

@property (nonatomic, copy) void (^animatedCompletion)(void);

@end

@interface _MDActionSheetTransitionView : _MDAlertControllerTransitionView

@end

@interface _MDAlertTransitionView : _MDAlertControllerTransitionView

@property (nonatomic, strong, readonly) UIView *buttonContentView;
@property (nonatomic, strong, readonly) UIView *lineView;

@property (nonatomic, strong, readonly) NSMutableArray<UIButton *> *buttons;
@property (nonatomic, strong, readonly) NSMutableArray<UIView *> *lines;

@end

@interface MDAlertAction ()

@property (nonatomic, copy, readonly) void (^handler)(MDAlertAction *action);

@end

@interface MDAlertController ()<_MDAlertControllerContentViewDelegate, UIViewControllerTransitioningDelegate> {
    NSMutableArray<MDAlertAction *> *_actions;
    NSMutableArray<MDAlertAction *> *_rowActions;
}

@property (nonatomic, strong, readonly) UIView<_MDAlertControllerTransitionView> *transitionView;;
@property (nonatomic, weak) MDAlertController *previousAlertController;

@property (nonatomic, weak, readonly) UIViewController *sourceViewController;

- (void)_layoutSubViews;
- (void)_updateView:(UIView *)view tintColor:(UIColor *)tintColor;
- (void)_reloadData;
- (void)_displayControllerAnimated:(BOOL)animated;
- (void)_displayControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)_dismissControllerAnimated:(BOOL)animated action:(MDAlertAction *)action;
- (void)_dismissControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)_dismissModalViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)_dismissEmbededViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)_dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)_display:(BOOL)displaying animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)_transitWithOptions:(MDAlertControllerAnimationOptions)options displaying:(BOOL)displaying completion:(void (^)(void))completion;
- (void)_transitWithAdditionalOptionsForDisplaying:(BOOL)displaying completion:(void (^)(void))completion;
- (void)_transitWithUIOptions:(UIViewAnimationOptions)options displaying:(BOOL)displaying completion:(void (^)(void))completion;

@end

