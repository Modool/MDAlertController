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

@property (nonatomic, strong) MDAlertAction *action;

@property (nonatomic, assign) BOOL titleAlignmentCenter;

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

@protocol MDAlertControllerContentView;
@protocol MDAlertControllerContentViewDelegate <NSObject>

- (void)contentViewDidCancel:(UIView<MDAlertControllerContentView> *)contentView;
- (void)contentView:(UIView<MDAlertControllerContentView> *)contentView didSelectAction:(MDAlertAction *)action;

@end

@protocol MDAlertControllerContentView <NSObject>

@property (nonatomic, weak) id<MDAlertControllerContentViewDelegate> delegate;

@property (nonatomic, copy) NSArray<MDAlertAction *> *actions;

@property (nonatomic, strong) MDAlertAction *preferredAction;

@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *messageLabel;

@property (nonatomic, strong) UIColor *tintColor;

- (void)reload;

- (void)displayAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)displayWithAnimation:(CAAnimation *)animation completion:(void (^)(void))completion;

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissWithAnimation:(CAAnimation *)animation completion:(void (^)(void))completion;

#pragma mark - private

- (void)_layoutSubviews;

@end

@interface MDAlertControllerContentView : UIView <MDAlertControllerContentView, CAAnimationDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, copy) void (^animatedCompletion)(void);

@end

@interface MDActionSheetContentView : MDAlertControllerContentView

@end

@interface MDAlertContentView : MDAlertControllerContentView

@property (nonatomic, strong) UIView *buttonContentView;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;
@property (nonatomic, strong) NSMutableArray<UIView *> *lines;

@end

@interface MDAlertAction ()

@property (nonatomic, assign) MDAlertActionStyle style;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) void (^handler)(MDAlertAction *action);

@end

@interface MDAlertController ()<MDAlertControllerContentViewDelegate> {
    dispatch_once_t _onceToken;
    NSString *_alertTitle;
}

@property (nonatomic, copy) NSArray<MDAlertAction *> *actions;

@property (nonatomic, copy) NSArray<MDAlertAction *> *rowActions;

@property (nonatomic, assign) MDAlertControllerStyle preferredStyle;

@property (nonatomic, strong) UIView<MDAlertControllerContentView> *contentView;

@end

