//
//  MDAlertController.m
//  MDAlertController
//
//  Created by xulinfeng on 2017/10/24.
//  Copyright © 2017年 Modool. All rights reserved.
//

#import <objc/runtime.h>

#import "MDAlertController.h"
#import "MDAlertController+Private.h"

#define HEXCOLOR(hex) [UIColor colorWithRed:((hex & 0xFF0000) >> 16)/255.0 green:((hex & 0xFF00) >> 8)/255.0 blue:(hex & 0xFF)/255.0 alpha:1.0]
#define HEXACOLOR(hex, a) [UIColor colorWithRed:((hex & 0xFF0000) >> 16)/255.0 green:((hex & 0xFF00) >> 8)/255.0 blue:(hex & 0xFF)/255.0 alpha:a]

const CGFloat MDAlertControllerPresentAnimationDuration = 0.15f;
const CGFloat MDAlertControllerDismissAnimationDuration = 0.15f;
const CGFloat MDAlertControllerRowHeight = 50.f;
const CGFloat MDAlertControllerDestructiveFooterViewHeight = 60.f;

@interface _MDAlertControllerAnimation : CAAnimationGroup <CAAnimationDelegate> {
@private
    void (^_completion)(void);
}

@end

@implementation _MDAlertControllerAnimation

+ (instancetype)aninmationWithAnimations:(NSArray<CAAnimation *> *)animations completion:(void (^)(void))completion {
    _MDAlertControllerAnimation *animation = [self animation];
    animation.delegate = animation;

    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.animations = [animations copy];
    animation->_completion = [completion copy];

    return animation;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    if (_completion) _completion();
}

@end

@implementation _MDAlertControllerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self _createSubviews];
        [self _initializeSubviews];
        [self _layoutSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self _layoutSubviews];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.titleLabel.textColor = self.tintColor;
}

#pragma mark - private

- (void)_createSubviews {
    _iconImageView = [[UIImageView alloc] init];
    _titleLabel = [[UILabel alloc] init];

    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.titleLabel];
}

- (void)_initializeSubviews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.titleLabel.textColor = self.tintColor;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
}

- (void)_layoutSubviews {
    CGRect bounds = self.contentView.bounds;
    CGSize imageSize = self.iconImageView.image.size;
    CGFloat imageY = (CGRectGetHeight(bounds) - imageSize.height) / 2.;
    
    self.iconImageView.frame = (CGRect){20, imageY, imageSize};
    
    CGSize fitSize = CGSizeMake(CGRectGetWidth(bounds) - (20 + imageSize.width + 16) * (self.titleAlignmentCenter + 1), CGRectGetHeight(bounds));
    CGSize titleSize = [self.titleLabel sizeThatFits:fitSize];
    CGFloat titleY = (CGRectGetHeight(bounds) - titleSize.height) / 2.;
    CGFloat titleX = self.titleAlignmentCenter ? (CGRectGetWidth(bounds) - titleSize.width) / 2. : ((imageSize.width ? 20 : 0) + imageSize.width + 16);
    
    self.titleLabel.frame = (CGRect){titleX, titleY, titleSize};
}

- (void)_updateContentView {
    self.iconImageView.image = self.action.image;
    self.titleLabel.text = self.action.title;
    
    self.titleLabel.font = self.action.font ?: (self.action.style == MDAlertActionStyleCancel ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14]);
    self.titleLabel.textColor = self.action.color ?: self.tintColor;
    
    self.contentView.backgroundColor = self.action.backgroundColor;
    
    self.userInteractionEnabled = self.action.enabled;
}

#pragma mark - accessor

- (void)setAction:(MDAlertAction *)action {
    if (_action != action) {
        _action = action;
        
        [self _updateContentView];
    }
}

- (void)setTitleAlignmentCenter:(BOOL)titleAlignmentCenter {
    _titleAlignmentCenter = titleAlignmentCenter;
    
    [self setNeedsLayout];
}

@end

@implementation _MDAlertControllerCheckCell

#pragma mark - private

- (void)_createSubviews {
    [super _createSubviews];
    _selectedImageView = [[UIImageView alloc] init];
    
    [self.contentView addSubview:self.selectedImageView];
}

- (void)_layoutSubviews {
    [super _layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGSize imageSize = self.iconImageView.image.size;
    CGFloat imageX = CGRectGetWidth(bounds) - imageSize.width - 12;
    CGFloat imageY = (CGRectGetHeight(bounds) - imageSize.height) / 2.;
    
    self.selectedImageView.frame = (CGRect){imageX, imageY, imageSize};
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
 
    self.selectedImageView.image = selected ? self.action.selectedImage : nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.selectedImageView.image = selected ? self.action.selectedImage : nil;
}

@end

@implementation _MDAlertControllerDestructiveFooterView

- (instancetype)initWithFrame:(CGRect)frame action:(MDAlertAction *)action {
    if (self = [super initWithFrame:frame]) {
        _action = action;
        _titleLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 5, frame.size.width, frame.size.height - 5}];
    
        self.backgroundColor = HEXCOLOR(0xE7E7E7);
        
        self.titleLabel.text = action.title;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = action.font ?: [UIFont systemFontOfSize:15];
        self.titleLabel.textColor = action.color ?: self.tintColor;
        self.titleLabel.backgroundColor = action.backgroundColor ?: [UIColor whiteColor];
        
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.titleLabel.textColor = self.tintColor;
}

@end

@implementation _MDAlertControllerTextLabel

- (CGSize)sizeThatFits:(CGSize)size {
    if (!self.text.length || !self.attributedText.length) return CGSizeZero;
    
    CGSize result = [super sizeThatFits:size];
    result.height += 16;
    
    return result;
}

- (CGSize)intrinsicContentSize {
    if (!self.text.length || !self.attributedText.length) return CGSizeZero;
    
    CGSize size = [super intrinsicContentSize];
    size.height += 16;
    
    return size;
}

@end

@interface _MDAlertDismissButton : UIButton
@end

@implementation _MDAlertDismissButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.layer.cornerRadius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / 2.;
}

@end

@interface _MDAlertControllerWrapperView : UIView
@end

@implementation _MDAlertControllerWrapperView

@end

@implementation _MDAlertControllerContentView
@synthesize delegate, actions = _actions;
@synthesize preferredAction = _preferredAction, dismissAction = _dismissAction;
@synthesize titleLabel = _titleLabel, messageLabel = _messageLabel;
@synthesize backgroundView = _backgroundView, wrapperView = _wrapperView, contentView = _contentView;
@synthesize customView = _customView, dismissButton = _dismissButton;

@dynamic tintColor;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _createSubviews];
        [self _initializeSubviews];
        [self _layoutSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self _layoutSubviews];
    [self _layoutDismissButton];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.titleLabel.textColor = self.tintColor;
    self.messageLabel.textColor = self.tintColor;
    
    self.tableView.separatorColor = self.tintColor;
    self.tableView.tableFooterView.tintColor = self.tintColor;
    
    [self.tableView reloadData];
}

#pragma mark - accessor

- (NSArray<MDAlertAction *> *)actions {
    if (!_actions) {
        _actions = @[];
    }
    return _actions;
}

#pragma mark - private

- (void)_createSubviews {
    _backgroundView = [[UIView  alloc] init];
    _wrapperView = [[_MDAlertControllerWrapperView  alloc] init];

    _contentView = [[UIView  alloc] init];
    _titleLabel = [[_MDAlertControllerTextLabel alloc] init];
    _messageLabel = [[_MDAlertControllerTextLabel alloc] init];
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBackgroundView:)];
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.wrapperView];

    [self.wrapperView addSubview:self.contentView];

    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.messageLabel];
    [self.contentView addSubview:self.tableView];
    
    [self.backgroundView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)_initializeSubviews {
    self.backgroundView.alpha = 0.f;
    self.backgroundView.layer.masksToBounds = YES;

    self.wrapperView.backgroundColor = [UIColor whiteColor];

    self.wrapperView.layer.masksToBounds = YES;
    
    self.titleLabel.textColor = self.tintColor;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    self.messageLabel.textColor = self.tintColor;
    self.messageLabel.font = [UIFont systemFontOfSize:14];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    
    self.tableView.bounces = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = self.tintColor;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 0;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    self.tableView.tableFooterView = [[UIView  alloc] init];
    
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.tableView registerClass:[_MDAlertControllerCell class] forCellReuseIdentifier:NSStringFromClass([_MDAlertControllerCell class])];
    [self.tableView registerClass:[_MDAlertControllerCheckCell class] forCellReuseIdentifier:NSStringFromClass([_MDAlertControllerCheckCell class])];
}

- (void)_layoutSubviews {
    self.backgroundView.frame = self.bounds;
}

- (void)_layoutDismissButton {
    CGSize contentSize = self.contentView.bounds.size;

    self.dismissButton.frame = [self _dismissButtonFrameWithContentSize:contentSize];
}

- (void)_respondSelectAction:(MDAlertAction *)action {
    if ([self.delegate respondsToSelector:@selector(contentView:didSelectAction:)]) {
        [self.delegate contentView:self didSelectAction:action];
    }
}

- (void)_loadCustomViewIfNeeds {
    if (!self.customView) return;

    [self.contentView addSubview:self.customView];
}

- (void)_loadDismissButtonIfNeeds {
    if (!self.dismissAction || self.dismissButton) return;

    _dismissButton = [[_MDAlertDismissButton alloc] init];
    self.dismissButton.titleLabel.font = self.dismissAction.font;
    self.dismissButton.backgroundColor = self.dismissAction.backgroundColor;
    self.dismissButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

    if (self.dismissAction.image) {
        [self.dismissButton setImage:self.dismissAction.image forState:UIControlStateNormal];
    }
    if (self.dismissAction.title) {
        [self.dismissButton setTitle:self.dismissAction.title forState:UIControlStateNormal];
    }
    if (self.dismissAction.color) {
        [self.dismissButton setTitleColor:self.dismissAction.color forState:UIControlStateNormal];
    }
    [self.dismissButton addTarget:self action:@selector(didClickDismissButton:) forControlEvents:UIControlEventTouchUpInside];

    [self.wrapperView addSubview:self.dismissButton];
}

- (CGSize)_dismissButtonSize {
    if (!self.dismissButton) return CGSizeZero;

    CGSize size = self.dismissAction.size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        [self.dismissButton sizeToFit];
        size = self.dismissButton.frame.size;
    }
    return size;
}

- (CGRect)_dismissButtonFrameWithContentSize:(CGSize)contentSize {
    if (!_dismissButton) return CGRectZero;

    CGSize size = [self _dismissButtonSize];
    CGPoint center = CGPointMake(contentSize.width / 2., contentSize.height / 2.);

    MDAlertActionPosition position = _dismissAction.position;
    if (position & MDAlertActionPositionLeft && !(position & MDAlertActionPositionRight)) {
        center.x = 0;
    } else if (position & MDAlertActionPositionRight && !(position & MDAlertActionPositionLeft)) {
        center.x = contentSize.width;
    }

    if (position & MDAlertActionPositionTop && !(position & MDAlertActionPositionBottom)) {
        center.y = 0;
    } else if (position & MDAlertActionPositionBottom && !(position & MDAlertActionPositionTop)) {
        center.y = contentSize.height;
    }
    CGRect frame = (CGRect){center.x - size.width / 2., center.y - size.height / 2., size};

    return frame;
}

- (void)_cancel {
    if ([self.delegate respondsToSelector:@selector(contentViewDidCancel:)]) {
        [self.delegate contentViewDidCancel:self];
    }
}

- (CABasicAnimation *)_defaultAnimationWithKeyPath:(NSString *)keyPath displaying:(BOOL)displaying {
    CGFloat duration = displaying ? MDAlertControllerPresentAnimationDuration : MDAlertControllerDismissAnimationDuration;
    NSString *functionName = displaying ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn;

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];

    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:functionName];

    return animation;
}

- (CATransition *)_defaultTransitionForDisplaying:(BOOL)displaying {
    NSString *functionName = displaying ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn;

    CATransition *animation = [CATransition animation];

    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;

    animation.startProgress = displaying ? 0.f : 1.f;
    animation.endProgress = displaying ? 1.f : 0.f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:functionName];

    return animation;
}

- (CABasicAnimation *)_opacityAnimationForDisplaying:(BOOL)displaying {
    CABasicAnimation *animation = [self _defaultAnimationWithKeyPath:@"opacity" displaying:displaying];
    animation.fromValue = @(displaying ? 0.f : 1.f);
    animation.toValue = @(displaying ? 1.f : 0.f);

    return animation;
}

- (NSString *)_directionTypeWithDirection:(MDAlertControllerTransitionStyle)direction negation:(BOOL)negation {
    NSString *subtype = nil;
    if (direction & MDAlertControllerTransitionFromLeft) {
        subtype = negation ? kCATransitionFromRight : kCATransitionFromLeft;
    }
    if (direction & MDAlertControllerTransitionFromRight) {
        NSAssert(subtype == nil, @"Unsupport multiple direction %ld", direction);
        subtype = negation ? kCATransitionFromLeft : kCATransitionFromRight;
    }
    if (direction & MDAlertControllerTransitionFromTop) {
        NSAssert(subtype == nil, @"Unsupport multiple direction %ld", direction);
        subtype = negation ? kCATransitionFromBottom : kCATransitionFromTop;
    }
    if (direction & MDAlertControllerTransitionFromBottom) {
        NSAssert(subtype == nil, @"Unsupport multiple direction %ld", direction);
        subtype = negation ? kCATransitionFromTop : kCATransitionFromBottom;
    }
    return subtype;
}

- (NSString *)_transitionTypeWithDisplaying:(BOOL)displaying style:(MDAlertControllerTransitionStyle)style {
    switch (style) {
        case MDAlertControllerTransitionStyleFade: return kCATransitionFade;
        case MDAlertControllerTransitionStylePush: return kCATransitionPush;
        case MDAlertControllerTransitionStyleMoveIn: return kCATransitionMoveIn;
        case MDAlertControllerTransitionStyleReveal: return kCATransitionReveal;

        case MDAlertControllerTransitionStyleCube: return @"cube";
        case MDAlertControllerTransitionStyleFlip: return @"oglFlip";
        case MDAlertControllerTransitionStylePageCurl: return @"pageCurl";
        case MDAlertControllerTransitionStylePageUnCurl: return @"pageUnCurl";
        case MDAlertControllerTransitionStyleSuckEffect: return @"suckEffect";
        case MDAlertControllerTransitionStyleRippleEffect: return @"rippleEffect";
        case MDAlertControllerTransitionStyleCameraIrisHollowOpen: return @"cameraIrisHollowOpen";
        case MDAlertControllerTransitionStyleCameraIrisHollowClose: return @"cameraIrisHollowClose";
        default: return nil;
    }
}

- (CAAnimation *)_transitionForDisplaying:(BOOL)displaying style:(MDAlertControllerTransitionStyle)style direction:(MDAlertControllerTransitionStyle)direction {
    CATransition *transition = [self _defaultTransitionForDisplaying:displaying];
    NSString *type = [self _transitionTypeWithDisplaying:displaying style:style];
    NSAssert(type, @"Must specify an style");

    NSString *subtype = [self _directionTypeWithDirection:direction negation:NO];
    NSAssert(subtype, @"Must specify an direction");

    transition.type = type;
    transition.subtype = subtype;

    return transition;
}

- (void)_addAnimations:(NSArray<CAAnimation *> *)animations backgroundAnimation:(CAAnimation *)backgroundAnimation {
    for (CAAnimation *animation in animations) {
        NSString *key = [NSString stringWithFormat:@"wrapper.view.animation.%ld", (NSUInteger)animation];
        [self.wrapperView.layer addAnimation:animation forKey:key];
    }
    [self.backgroundView.layer addAnimation:backgroundAnimation forKey:@"background.view.animation.opacity.key"];
}

- (void)_display:(BOOL)displaying duration:(CGFloat)duration animations:(NSArray<CAAnimation *> *)animations completion:(void (^)(void))completion {
    if (animations.count) {
        CAAnimation *backgroundAnimation = [self _opacityAnimationForDisplaying:displaying];
        backgroundAnimation.duration = duration;
        backgroundAnimation.delegate = self;

        self.userInteractionEnabled = NO;
        self.animatedCompletion = completion;
        [self _addAnimations:animations backgroundAnimation:backgroundAnimation];
    } else {
        if (completion) completion();
    }
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    self.userInteractionEnabled = YES;
    if (self.animatedCompletion) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), self.animatedCompletion);
    }
}

#pragma mark - public

- (void)reload {
    [self _loadCustomViewIfNeeds];
    [self _loadDismissButtonIfNeeds];
}

- (void)display:(BOOL)displaying animated:(BOOL)animated duration:(CGFloat)duration completion:(void (^)(void))completion {
    [self display:displaying duration:duration animations:nil completion:completion];
}

- (void)display:(BOOL)displaying duration:(CGFloat)duration animations:(NSArray<CAAnimation *> *)animations completion:(void (^)(void))completion {
    [self _display:displaying duration:duration animations:animations completion:completion];
}

- (CAAnimation *)animationForDisplaying:(BOOL)displaying transitionStyle:(MDAlertControllerTransitionStyle)transitionStyle {
    MDAlertControllerTransitionStyle style = transitionStyle & 0xFF;
    MDAlertControllerTransitionStyle addition = transitionStyle & 0xFFFFFF00;
    MDAlertControllerTransitionStyle direction = addition & 0xF00;

    return [self _transitionForDisplaying:displaying style:style direction:direction];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.actions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MDAlertControllerRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MDAlertAction *action = self.actions[[indexPath row]];
    Class cellClass = action.selectedImage ? [_MDAlertControllerCheckCell class] : [_MDAlertControllerCell class];
    
    _MDAlertControllerCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass)];
    cell.action = action;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MDAlertAction *action = self.actions[[indexPath row]];
    
    [self _respondSelectAction:action];
}

#pragma mark - actions

- (IBAction)didTapBackgroundView:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self _cancel];
}

- (IBAction)didClickDestructFooterView:(_MDAlertControllerDestructiveFooterView *)footerView {
    [self _respondSelectAction:[footerView action]];
}

- (IBAction)didClickDismissButton:(UIButton *)sender {
    [self _respondSelectAction:self.dismissAction];
}

@end

@implementation _MDActionSheetContentView

#pragma mark - private

- (CGRect)_dismissButtonFrameWithContentSize:(CGSize)contentSize {
    CGRect frame = [super _dismissButtonFrameWithContentSize:contentSize];

    frame.origin.x = MAX(frame.origin.x, 0);
    frame.origin.x = MIN(frame.origin.x, CGRectGetWidth(self.wrapperView.bounds) - CGRectGetWidth(frame) / 2.);

    frame.origin.y = MIN(frame.origin.y, CGRectGetHeight(self.wrapperView.bounds) - CGRectGetHeight(frame) / 2.);
    return frame;
}

- (void)_layoutSubviews {
    [super _layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);

    CGSize customViewSize = self.customView.frame.size;
    CGFloat contentWidth = width;

    CGFloat expectTableHeight = (self.preferredAction ? MDAlertControllerDestructiveFooterViewHeight : 0) + (self.actions.count * MDAlertControllerRowHeight);
    CGFloat titleHeight = [self.titleLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)].height;
    CGFloat messageHeight = [self.messageLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)].height;
    CGFloat tableViewHeight = MIN(height - customViewSize.height - titleHeight - messageHeight, expectTableHeight);;

    CGFloat contentHeight = customViewSize.height + titleHeight + messageHeight + tableViewHeight;
    CGFloat contentY = height - contentHeight;
    CGSize contentSize = CGSizeMake(contentWidth, contentHeight);

    self.wrapperView.frame = (CGRect){0, contentY, contentSize};

    self.contentView.frame = (CGRect){0, 0, contentSize};

    CGFloat offsetY = 0;
    self.titleLabel.frame = (CGRect){0, offsetY, contentWidth, titleHeight};

    offsetY += titleHeight;
    self.messageLabel.frame = (CGRect){0, offsetY, contentWidth, messageHeight};

    offsetY += messageHeight;
    self.customView.frame = (CGRect){(contentWidth - customViewSize.width) / 2., offsetY, customViewSize};

    offsetY += customViewSize.height;
    self.tableView.frame = (CGRect){0, offsetY, contentWidth, tableViewHeight};
}

- (CAAnimation *)_positionAnimationForDisplaying:(BOOL)displaying {
    CABasicAnimation *animation = [self _defaultAnimationWithKeyPath:@"position.y" displaying:displaying];

    CGRect contentFrame = self.wrapperView.frame;
    animation.fromValue = @(CGRectGetHeight(self.bounds) + CGRectGetHeight(contentFrame) / 2. * (displaying ? 1 : -1));
    animation.toValue = @(CGRectGetHeight(self.bounds) - CGRectGetHeight(contentFrame) / 2. * (displaying ? 1 : -1));

    return animation;
}

#pragma mark - public

- (void)reload {
    [super reload];
    
    [self _layoutSubviews];
    
    _MDAlertControllerDestructiveFooterView *footerView = nil;
    if (self.preferredAction) {
        footerView = [[_MDAlertControllerDestructiveFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), MDAlertControllerDestructiveFooterViewHeight) action:self.preferredAction];
        
        [footerView addTarget:self action:@selector(didClickDestructFooterView:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.tableView.tableFooterView = footerView;
    
    [self.tableView reloadData];
    
    [self.actions enumerateObjectsUsingBlock:^(MDAlertAction *action, NSUInteger index, BOOL *stop) {
        if (!action.selected) return;

        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }];
}

- (void)display:(BOOL)displaying animated:(BOOL)animated duration:(CGFloat)duration completion:(void (^)(void))completion {
    CAAnimation *animation = nil;
    if (animated) {
        animation = [self _positionAnimationForDisplaying:displaying];
        animation.duration = duration;
    }
    [self display:displaying duration:duration animations:@[animation] completion:completion];
}

@end

@implementation _MDAlertContentView

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.lineView.backgroundColor = self.tintColor;
    
    [self.lines setValue:self.tintColor forKey:@"backgroundColor"];
    
    for (UIButton *button in self.buttons) {
        [button setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
}

#pragma mark - private

- (void)_createSubviews {
    [super _createSubviews];
    
    _buttons = [NSMutableArray array];
    _lines = [NSMutableArray array];

    _buttonContentView = [[UIView  alloc] init];
    _lineView = [[UIView  alloc] init];
    
    [self.contentView addSubview:self.buttonContentView];
    [self.contentView addSubview:[self lineView]];
}

- (void)_initializeSubviews {
    [super _initializeSubviews];
    
    self.wrapperView.layer.cornerRadius = 10.f;
    
    self.lineView.backgroundColor = self.tintColor;
}

- (void)_layoutSubviews {
    [super _layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);

    CGSize customViewSize = self.customView.frame.size;

    CGFloat contentWidth = self.customView ? customViewSize.width :  width * .75f;
    contentWidth = MIN(width, contentWidth);

    CGFloat titleHeight = [self.titleLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)].height;
    CGFloat messageHeight = [self.messageLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)].height;

    CGFloat headerHeight = titleHeight + messageHeight + customViewSize.height;

    BOOL buttonEnabled = self.actions.count > 0;
    BOOL needsButtonContent = buttonEnabled && self.actions.count <= 2;
    CGFloat actionContentHeight = (needsButtonContent ? 1 : self.actions.count) * MDAlertControllerRowHeight;
    actionContentHeight = MIN(actionContentHeight, height - headerHeight);

    CGFloat contentHeight = headerHeight + actionContentHeight;

    CGFloat contentX = (width - contentWidth) / 2.f;
    CGFloat contentY = (height - contentHeight) / 2.f;

    self.wrapperView.frame = (CGRect){contentX, contentY, contentWidth, contentHeight};

    self.contentView.frame = (CGRect){0, 0, contentWidth, contentHeight};

    CGFloat offsetY = 0;
    self.titleLabel.frame = (CGRect){0, offsetY, contentWidth, titleHeight};

    offsetY += titleHeight;
    self.messageLabel.frame = (CGRect){0, offsetY, contentWidth, messageHeight};

    offsetY += messageHeight;
    CGFloat lineHeight = offsetY > 0 ? .5f : 0.f;
    self.lineView.frame = (CGRect){0, offsetY, contentWidth, lineHeight};

    offsetY += lineHeight;
    self.customView.frame = (CGRect){0, offsetY, customViewSize};

    offsetY += customViewSize.height;
    UIView *actionContentView = needsButtonContent ? self.buttonContentView : self.tableView;
    actionContentView.frame = (CGRect){0, offsetY, contentWidth, actionContentHeight};

    if (needsButtonContent) {
        [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger index, BOOL *stop) {
            [self _layoutButton:button atIndex:index];
        }];
        [self.lines enumerateObjectsUsingBlock:^(UIView *line, NSUInteger index, BOOL *stop) {
            [self _layoutLine:line atIndex:index];
        }];
    }
}

- (void)_reloadButtonContentView {
    [[self.actions copy] enumerateObjectsUsingBlock:^(MDAlertAction *action, NSUInteger index, BOOL *stop) {
        UIButton *button = [self _buttonWithAction:action atIndex:index];
        UIView *line = index == (self.actions.count - 1) ? nil : [[UIView  alloc] init];
        line.backgroundColor = self.tintColor;
        
        [self.buttons addObject:button];
        [self.buttonContentView addSubview:button];
        [self _layoutButton:button atIndex:index];
        
        if (line) {
            [self.lines addObject:line];
            [self.buttonContentView addSubview:line];
            [self _layoutLine:line atIndex:index];
        }
    }];
}

- (void)_layoutButton:(UIButton *)button atIndex:(NSUInteger)index {
    CGRect bounds = [self.buttonContentView bounds];
    CGFloat width = CGRectGetWidth(bounds) / self.actions.count;
    
    button.frame = (CGRect){index * width, 0, width, bounds.size.height};
}

- (void)_layoutLine:(UIView *)line atIndex:(NSUInteger)index{
    CGRect bounds = self.buttonContentView.bounds;
    CGFloat width = bounds.size.width / self.actions.count;
    
    line.frame = (CGRect){(index + 1) * width, 0, .5f, bounds.size.height};
}

- (UIButton *)_buttonWithAction:(MDAlertAction *)action atIndex:(NSUInteger)index {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    button.enabled = action.enabled;
    button.selected = action.selected;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.backgroundColor = action.backgroundColor;
    
    UIFont *titleFont = action.font ?: (action == self.preferredAction ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14]);
    button.titleLabel.font = titleFont;
    
    [button setTitle:action.title forState:UIControlStateNormal];
    [button setImage:action.image forState:UIControlStateNormal];
    [button setImage:action.selectedImage forState:UIControlStateSelected];
    
    UIColor *titleColor = action.color ?: (action == self.preferredAction ? HEXCOLOR(0x505050) : HEXCOLOR(0x212121));
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)_reloadTableView {
    [self.tableView reloadData];
    
    [self.actions enumerateObjectsUsingBlock:^(MDAlertAction *action, NSUInteger index, BOOL *stop) {
        if (!action.selected) return;
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }];
}

- (CAAnimation *)_scaleAnimationForDisplaying:(BOOL)displaying {
    CABasicAnimation *animation = [self _defaultAnimationWithKeyPath:@"transform.scale" displaying:displaying];

    animation.fromValue = @(displaying ? 0.5f : 1.f);
    animation.toValue = @(displaying ? 1.f : 0.5f);

    return animation;
}

#pragma mark - public

- (void)reload {
    [super reload];

    [self _layoutSubviews];
    
    for (UIView *view in [self.buttonContentView subviews]) [view removeFromSuperview];
    
    [self.buttons removeAllObjects];
    [self.lines removeAllObjects];
    
    self.buttonContentView.hidden = self.actions.count > 2;
    self.lineView.hidden = self.actions.count > 2;
    self.tableView.hidden = self.actions.count <= 2;
    
    if (self.actions.count <= 2) {
        [self _reloadButtonContentView];
    } else {
        [self _reloadTableView];
    }
}

- (void)display:(BOOL)displaying animated:(BOOL)animated duration:(CGFloat)duration completion:(void (^)(void))completion {
    NSArray<CAAnimation *> *animations = nil;
    if (animated) {
        CAAnimation *scaleAnimation = [self _scaleAnimationForDisplaying:displaying];
        scaleAnimation.duration = duration;

        CAAnimation *opacityAnimation = [self _opacityAnimationForDisplaying:displaying];
        opacityAnimation.duration = duration;

        animations = @[scaleAnimation, opacityAnimation];
    }
    [self display:displaying duration:duration animations:animations completion:completion];
}

#pragma mark - actions

- (IBAction)didClickButton:(UIButton *)sender {
    NSUInteger index = [self.buttons indexOfObject:sender];
    MDAlertAction *action = self.actions[index];
    
    [self _respondSelectAction:action];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MDAlertAction *action = self.actions[[indexPath row]];
    _MDAlertControllerCell *cell = (id)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.titleAlignmentCenter = YES;
    cell.titleLabel.font = action == self.preferredAction ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14];
    
    return cell;
}

@end

@implementation MDAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler {
    return [self actionWithTitle:title image:nil style:style handler:handler];
}

+ (instancetype)actionWithTitle:(NSString *)title image:(UIImage *)image style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler {
    return [[self alloc] initWithTitle:title image:image style:style handler:handler];
}

+ (instancetype)cancelActionWithTitle:(NSString *)title {
    return [self cancelActionWithTitle:title image:nil];
}

+ (instancetype)cancelActionWithTitle:(NSString *)title image:(UIImage *)image {
    return [[self alloc] initWithTitle:title image:image style:MDAlertActionStyleCancel handler:nil];
}

+ (instancetype)destructiveActionWithTitle:(NSString *)title {
    return [self destructiveActionWithTitle:title image:nil];
}

+ (instancetype)destructiveActionWithTitle:(NSString *)title image:(UIImage *)image {
    return [[self alloc] initWithTitle:title image:image style:MDAlertActionStyleDestructive handler:nil];
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler {
    if (self = [super init]) {
        _enabled = YES;

        _title = [title copy];
        _image = image;
        _style = style;
        _handler = [handler copy];
    }
    return self;
}

@end

@implementation MDAlertDismissAction
@dynamic selectedImage, enabled, selected;

+ (instancetype)actionWithTitle:(NSString *)title position:(MDAlertActionPosition)position handler:(void (^)(MDAlertAction *action))handler {
    MDAlertDismissAction *action = [super actionWithTitle:title image:nil style:MDAlertActionStyleCancel handler:handler];
    action->_position = position;

    return action;
}

+ (instancetype)actionWithImage:(UIImage *)image position:(MDAlertActionPosition)position handler:(void (^)(MDAlertAction *action))handler {
    MDAlertDismissAction *action = [super actionWithTitle:nil image:image style:MDAlertActionStyleCancel handler:handler];
    action->_position = position;

    return action;
}

@end

@interface _MDAlertControllerAnimationController : NSObject <UIViewControllerAnimatedTransitioning>
@end

@implementation _MDAlertControllerAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.01f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    UIViewController *viewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    viewController.view.frame = [transitionContext finalFrameForViewController:viewController];
    [containerView addSubview:viewController.view];

    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
}

@end

@implementation MDAlertController
@synthesize contentView = _contentView, actions = _actions, rowActions = _rowActions;
@dynamic title;

- (instancetype)init {
    return [self initWithTitle:nil message:nil preferredStyle:MDAlertControllerStyleActionSheet];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithTitle:nil message:nil preferredStyle:MDAlertControllerStyleAlert];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithTitle:nil message:nil preferredStyle:MDAlertControllerStyleAlert];
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(MDAlertControllerStyle)preferredStyle {
    return [[self alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(MDAlertControllerStyle)preferredStyle {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _preferredStyle = preferredStyle;
        _transitionDuration = 0.25;

        self.title = title;
        self.message = message;
        self.backgroundColor = HEXACOLOR(0x000000, 0.5);
        self.backgroundTouchabled = preferredStyle == MDAlertControllerStyleActionSheet;

        self.transitioningDelegate = self;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;

        self.definesPresentationContext = YES;
        self.providesPresentationContextTransitionStyle = YES;
    }
    return self;
}

- (void)loadView {
    [super loadView];

    [self.view addSubview:self.contentView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self _reloadData];
    [self _layoutSubViews];
    [self _updateView:self.view tintColor:self.tintColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self _layoutSubViews];
    [self _displayAnimated:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self _layoutSubViews];
}

#pragma mark - accessor

- (UIView<_MDAlertControllerContentView> *)contentView {
    if (!_contentView) {
        BOOL actionSheet = self.preferredStyle == MDAlertControllerStyleActionSheet;

        _contentView = actionSheet ? [[_MDActionSheetContentView alloc] init] : [[_MDAlertContentView alloc] init];
        _contentView.delegate = self;
    }
    return _contentView;
}

- (NSArray<MDAlertAction *> *)actions {
    if (!_actions) {
        _actions = @[];
    }
    return _actions;
}

- (NSArray<MDAlertAction *> *)rowActions {
    if (!_rowActions) {
        _rowActions = @[];
    }
    return _rowActions;
}

- (void)setPreferredAction:(MDAlertAction *)preferredAction {
    if (_preferredAction != preferredAction) {
        NSMutableArray *actions = [self.actions mutableCopy];
        [actions removeObject:_preferredAction];
        
        _actions = [actions copy];
        
        if (preferredAction) {
            _actions = [_actions arrayByAddingObject:preferredAction];
        }
        _preferredAction = preferredAction;
        
        if ([self isViewLoaded]) {
            [self _reloadData];
        }
    }
}

- (void)setDismissAction:(MDAlertDismissAction *)dismissAction {
    self.contentView.dismissAction = dismissAction;
}

- (MDAlertDismissAction *)dismissAction {
    return self.contentView.dismissAction;
}

- (void)setCustomView:(UIView *)customView {
    self.contentView.customView = customView;
}

- (UIView *)customView {
    return self.contentView.customView;
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
        
    if ([self isViewLoaded]) {
        self.contentView.titleLabel.text = title;
    }
}

- (void)setMessage:(NSString *)message {
    if (_message != message) {
        _message = [message copy];
        
        if ([self isViewLoaded]) {
            self.contentView.messageLabel.text = message;
        }
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    if (_tintColor != tintColor) {
        _tintColor = tintColor;

        if ([self isViewLoaded]) {
            [self _updateView:self.view tintColor:tintColor];
        }
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = backgroundColor;
        
        self.contentView.backgroundView.backgroundColor = backgroundColor;
    }
}

#pragma mark - private

- (void)_layoutSubViews {
    self.contentView.frame = self.view.bounds;
}

- (void)_updateView:(UIView *)view tintColor:(UIColor *)tintColor {
    view.tintColor = tintColor;
    
    for (UIView *subview in view.subviews) {
        [self _updateView:subview tintColor:tintColor];
    }
}

- (void)_reloadData {
    self.contentView.frame = self.view.bounds;
    self.contentView.titleLabel.text = self.title;
    self.contentView.messageLabel.text = self.message;

    self.contentView.backgroundView.backgroundColor = self.backgroundColor;
    self.contentView.backgroundView.userInteractionEnabled = self.backgroundTouchabled;
    
    self.contentView.preferredAction = self.preferredAction;
    self.contentView.actions = self.preferredStyle == MDAlertControllerStyleActionSheet ? self.rowActions : self.actions;

    [self.contentView reload];
}

- (void)_displayAnimated:(BOOL)animated {
    if (!self.beingPresented) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self _display:YES animated:animated completion:nil];
    });
}

- (void)_dismissAnimated:(BOOL)animated action:(MDAlertAction *)action {
    __weak MDAlertAction *weakAction = action;
    void (^completion)(void) = ^{
        __strong MDAlertAction *action = weakAction;
        if ([action handler]) action.handler(action);
    };
    [self _dismissAnimated:animated completion:completion];
}

- (void)_dismissAnimated:(BOOL)animated completion:(void (^)(void))completion {
    void (^_completion)(void) = ^{
        [super dismissViewControllerAnimated:NO completion:completion];
    };
    [self _display:NO animated:animated completion:_completion];
}

- (void)_display:(BOOL)displaying animated:(BOOL)animated completion:(void (^)(void))completion {
    NSMutableArray<CAAnimation *> *animations = [NSMutableArray array];
    CAAnimation *animation = displaying ? self.presentingAnimation : self.dismissingAnimation;

    if (animation) [animations addObject:animation];
    if (animated && !animation && self.transitionStyle != MDAlertControllerTransitionStyleDefault) {
        CAAnimation *transition = [[self contentView] animationForDisplaying:displaying transitionStyle:self.transitionStyle];
        transition.duration = self.transitionDuration;
        if (transition) [animations addObject:transition];
    }
    if (animated && animations.count) {
        [self.contentView display:displaying duration:self.transitionDuration animations:animations completion:completion];
    } else {
        [self.contentView display:displaying animated:animated duration:self.transitionDuration completion:completion];
    }
}

#pragma mark - public

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self _dismissAnimated:animated completion:completion];
}

- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    [super presentViewController:viewController animated:animated completion:completion];
}

- (void)addAction:(MDAlertAction *)action {
    NSParameterAssert(action);
    NSParameterAssert(![self.actions containsObject:action]);
    NSParameterAssert(action.style != MDAlertActionStyleDestructive || !self.preferredAction);
    
    if (action.style != MDAlertActionStyleDestructive) {
        _rowActions = [self.rowActions arrayByAddingObject:action];
        _actions = [self.actions arrayByAddingObject:action];
    } else {
        self.preferredAction = action;
    }
}

#pragma mark - _MDAlertControllerContentViewDelegate

- (void)contentViewDidCancel:(UIView<_MDAlertControllerContentView> *)contentView {
    [self _dismissAnimated:YES action:nil];
}

- (void)contentView:(UIView<_MDAlertControllerContentView> *)contentView didSelectAction:(MDAlertAction *)action {
    [self _dismissAnimated:YES action:action];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[_MDAlertControllerAnimationController alloc] init];
}

@end
