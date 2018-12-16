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

#define HEXCOLOR(hex)    [UIColor colorWithRed:((hex & 0xFF0000) >> 16)/255.0 green:((hex & 0xFF00) >> 8)/255.0 blue:(hex & 0xFF)/255.0 alpha:1.0]
#define HEXACOLOR(hex, a)  [UIColor colorWithRed:((hex & 0xFF0000) >> 16)/255.0 green:((hex & 0xFF00) >> 8)/255.0 blue:(hex & 0xFF)/255.0 alpha:a]

#define MDALERT_CONTENT_BACKGROUND_COLOR    HEXCOLOR(0xF9F9F9)

const CGFloat MDAlertControllerPresentAnimationDuration = 0.15f;
const CGFloat MDAlertControllerDismissAnimationDuration = 0.15f;
const CGFloat MDAlertControllerRowHeight = 44.f;
const CGFloat MDAlertControllerDestructiveFooterViewHeight = 60.f;

const CGFloat MDAlertControllerTitleTopOffset = 19.f;
const CGFloat MDAlertControllerActionContentTopOffset = 20.5f;

NSString *const MDAlertControllerWrapperAnimationKey = @"wrapper.view.animation.key";
NSString *const MDAlertControllerBackgroundAnimationKey = @"background.view.animation.opacity.key";

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

    self.titleLabel.textColor = self.action.color ?: self.tintColor;
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

    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];

    self.titleLabel.textColor = self.tintColor;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
}

- (void)_layoutSubviews {
    CGRect bounds = self.contentView.bounds;
    CGSize imageSize = self.iconImageView.image.size;

    CGFloat imageY = (CGRectGetHeight(bounds) - imageSize.height) / 2.;
    self.iconImageView.frame = CGRectMake(20, imageY, imageSize.width, imageSize.height);

    CGFloat titleX = 16 + (imageSize.width > 0 ? 20 : 0) + imageSize.width;
    self.titleLabel.frame = CGRectMake(titleX, 0, CGRectGetWidth(bounds) - titleX * 2, CGRectGetHeight(bounds));
}

- (void)_updateContentView {
    self.iconImageView.image = self.action.image;
    self.titleLabel.text = self.action.title;

    self.titleLabel.font = self.action.font ?: (self.action.style == MDAlertActionStyleCancel ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14]);
    self.titleLabel.textColor = self.action.color ?: self.tintColor;
    self.titleLabel.textAlignment = self.action.alignment;

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

    self.selectedImageView.frame = CGRectMake(imageX, imageY, imageSize.width, imageSize.height);
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
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 5)];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, frame.size.width, frame.size.height - 5)];

        self.backgroundColor = [UIColor clearColor];
        self.separatorView.backgroundColor = HEXCOLOR(0xE7E7E7);;

        self.titleLabel.text = action.title;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = action.font ?: [UIFont systemFontOfSize:15];
        self.titleLabel.textColor = action.color ?: self.tintColor;
        self.titleLabel.backgroundColor = action.backgroundColor;

        [self addSubview:self.separatorView];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect bounds = self.bounds;
    self.separatorView.frame = CGRectMake(0, 0, bounds.size.width, 5);
    self.titleLabel.frame = CGRectMake(0, 5, bounds.size.width, bounds.size.height - 5);
}

- (void)tintColorDidChange {
    [super tintColorDidChange];

    self.titleLabel.textColor = self.action.color ?: self.tintColor;
}

@end

@implementation _MDAlertControllerTitleLabel

- (CGSize)sizeThatFits:(CGSize)size {
    if (!self.text.length || !self.attributedText.length) return CGSizeZero;

    CGSize result = [super sizeThatFits:size];
    result.height += 4;

    return result;
}

- (CGSize)intrinsicContentSize {
    if (!self.text.length || !self.attributedText.length) return CGSizeZero;

    CGSize size = [super intrinsicContentSize];
    size.height += 4;

    return size;
}

@end


@implementation _MDAlertControllerMessageLabel

- (CGSize)sizeThatFits:(CGSize)size {
    if (!self.text.length || !self.attributedText.length) return CGSizeZero;

    CGSize result = [super sizeThatFits:size];
    result.height += 2;

    return result;
}

- (CGSize)intrinsicContentSize {
    if (!self.text.length || !self.attributedText.length) return CGSizeZero;

    CGSize size = [super intrinsicContentSize];
    size.height += 2;

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

@implementation _MDAlertControllerTransitionView
@synthesize delegate, actions = _actions;
@synthesize preferredAction = _preferredAction, dismissAction = _dismissAction;
@synthesize titleLabel = _titleLabel, messageLabel = _messageLabel;
@synthesize backgroundView = _backgroundView, wrapperView = _wrapperView, contentView = _contentView;
@synthesize customView = _customView, dismissButton = _dismissButton;
@synthesize welt = _welt, direction = _direction, curveOptions = _curveOptions;
@synthesize separatorInset = _separatorInset, separatorColor = _separatorColor;

@dynamic tintColor;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _createSubviews];
        [self _initializeSubviews];
        [self _layoutSubviews];
    }
    return self;
}

- (void)dealloc {
    [self _removeObserver];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self _layoutSubviews];
    [self _layoutDismissButton];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];

    [self _updateTintColor];

    [self.tableView reloadData];
}

#pragma mark - accessor

- (NSArray<MDAlertAction *> *)actions {
    if (!_actions) {
        _actions = @[];
    }
    return _actions;
}

- (void)setCustomView:(UIView *)customView {
    if (_customView != customView) {
        [self _removeObserver];
        _customView = customView;
        [self _addObserver];
    }
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    if (_separatorColor != separatorColor) {
        _separatorColor = separatorColor;

        [self _updateSeparatorColor];
    }
}

#pragma mark - private

- (void)_createSubviews {
    _backgroundView = [[UIView  alloc] init];
    _wrapperView = [[_MDAlertControllerWrapperView  alloc] init];

    _contentView = [[UIView  alloc] init];
    _titleLabel = [[_MDAlertControllerTitleLabel alloc] init];
    _messageLabel = [[_MDAlertControllerMessageLabel alloc] init];
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
    self.hidden = YES;
    self.separatorColor = HEXCOLOR(0xBFBFBF);
    
    self.backgroundView.layer.masksToBounds = YES;

    self.wrapperView.layer.masksToBounds = YES;
    self.wrapperView.backgroundColor = [UIColor whiteColor];

    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = HEXCOLOR(0x000000);
    self.titleLabel.font = [UIFont systemFontOfSize:17];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;

    self.messageLabel.numberOfLines = 0;
    self.messageLabel.textColor = HEXCOLOR(0x000000);
    self.messageLabel.font = [UIFont systemFontOfSize:13];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;

    self.tableView.bounces = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.backgroundColor = [UIColor clearColor];

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

- (void)_updateTintColor {
    [self _updateSeparatorColor];

    self.titleLabel.textColor = self.titleLabel.textColor ?: self.tintColor;
    self.messageLabel.textColor = self.messageLabel.textColor ?: self.tintColor;

    self.tableView.tableFooterView.tintColor = self.tintColor;
}

- (void)_updateSeparatorColor {
    self.tableView.separatorColor = self.separatorColor ?: self.tintColor;
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
    CGRect frame = CGRectMake(center.x - size.width / 2., center.y - size.height / 2., size.width, size.height);

    return frame;
}

- (void)_cancel {
    if ([self.delegate respondsToSelector:@selector(contentViewDidCancel:)]) {
        [self.delegate contentViewDidCancel:self];
    }
}

- (CABasicAnimation *)_defaultAnimationWithKeyPath:(NSString *)keyPath displaying:(BOOL)displaying {
    MDAlertControllerAnimationOptions curveOptions = [self _systemOptionsWithOptions:self.curveOptions displaying:displaying];

    CGFloat duration = displaying ? MDAlertControllerPresentAnimationDuration : MDAlertControllerDismissAnimationDuration;
    NSString *functionName = [self _fuctionNameWithCurveOptions:curveOptions];

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];

    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:functionName];

    return animation;
}

- (NSString *)_fuctionNameWithCurveOptions:(MDAlertControllerAnimationOptions)curveOptions {
    switch (curveOptions) {
        case MDAlertControllerAnimationOptionCurveEaseIn: return kCAMediaTimingFunctionEaseIn;
        case MDAlertControllerAnimationOptionCurveEaseOut: return kCAMediaTimingFunctionEaseOut;
        case MDAlertControllerAnimationOptionCurveLinear: return kCAMediaTimingFunctionLinear;
        default: return kCAMediaTimingFunctionEaseInEaseOut;
    }
}

- (MDAlertControllerAnimationOptions)_systemOptionsWithOptions:(MDAlertControllerAnimationOptions)options displaying:(BOOL)displaying {
    if (displaying) return options;

    MDAlertControllerAnimationOptions animationOptions = options & 0xFFFF;
    MDAlertControllerAnimationOptions curveOption = options & 0xF0000;
    MDAlertControllerAnimationOptions transtionOptions = options & 0xF00000;

    if (curveOption) {
        if (curveOption == MDAlertControllerAnimationOptionCurveEaseIn) {
            curveOption = MDAlertControllerAnimationOptionCurveEaseOut;
        } else if (curveOption == MDAlertControllerAnimationOptionCurveEaseOut) {
            curveOption = MDAlertControllerAnimationOptionCurveEaseIn;
        }
    }
    if (transtionOptions) {
        if (transtionOptions == MDAlertControllerAnimationOptionTransitionFlipFromLeft) {
            transtionOptions = MDAlertControllerAnimationOptionTransitionFlipFromRight;
        } else if (transtionOptions == MDAlertControllerAnimationOptionTransitionFlipFromRight) {
            transtionOptions = MDAlertControllerAnimationOptionTransitionFlipFromLeft;
        } else if (transtionOptions == MDAlertControllerAnimationOptionTransitionFlipFromTop) {
            transtionOptions = MDAlertControllerAnimationOptionTransitionFlipFromBottom;
        } else if (transtionOptions == MDAlertControllerAnimationOptionTransitionFlipFromBottom) {
            transtionOptions = MDAlertControllerAnimationOptionTransitionFlipFromTop;
        } else if (transtionOptions == MDAlertControllerAnimationOptionTransitionCurlUp) {
            transtionOptions = MDAlertControllerAnimationOptionTransitionCurlDown;
        } else if (transtionOptions == MDAlertControllerAnimationOptionTransitionCurlDown) {
            transtionOptions = MDAlertControllerAnimationOptionTransitionCurlUp;
        }
    }
    return animationOptions | curveOption | transtionOptions;
}

- (void)_addAnimations:(NSArray<CAAnimation *> *)animations backgroundAnimation:(CABasicAnimation *)backgroundAnimation {
    CAAnimation *animation = animations.firstObject;
    if (animations.count >= 2) {
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = animations;
        group.removedOnCompletion = NO;
        group.fillMode = kCAFillModeBoth;

        animation = group;
    }

    [self.wrapperView.layer addAnimation:animation forKey:MDAlertControllerWrapperAnimationKey];
    [self.backgroundView.layer addAnimation:backgroundAnimation forKey:MDAlertControllerBackgroundAnimationKey];

    self.hidden = NO;
}

- (void)_display:(BOOL)displaying duration:(CGFloat)duration animations:(NSArray<CAAnimation *> *)animations completion:(void (^)(void))completion {
    if (animations.count) {
        CABasicAnimation *backgroundAnimation = [self alphaAnimationForDisplaying:displaying];
        backgroundAnimation.duration = duration;
        backgroundAnimation.delegate = self;

        self.userInteractionEnabled = NO;
        self.animatedCompletion = completion;

        [self _addAnimations:animations backgroundAnimation:backgroundAnimation];
    } else {
        if (completion) completion();
    }
}

- (void)_addObserver {
    if (_customView) [_customView addObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)_removeObserver {
    if (_customView) [_customView removeObserver:self forKeyPath:NSStringFromSelector(@selector(frame))];
}

#pragma mark - public

- (void)reload {
    self.tableView.separatorInset = self.separatorInset;

    [self _loadCustomViewIfNeeds];
    [self _loadDismissButtonIfNeeds];
}

- (void)displaying:(BOOL)displaying {
    self.wrapperView.alpha = displaying;
    self.backgroundView.alpha = displaying;
}

- (void)display:(BOOL)displaying animated:(BOOL)animated duration:(CGFloat)duration completion:(void (^)(void))completion {
    [self display:displaying duration:duration animations:nil completion:completion];
}

- (void)display:(BOOL)displaying duration:(CGFloat)duration animations:(NSArray<CAAnimation *> *)animations completion:(void (^)(void))completion {
    for (CABasicAnimation *animation in animations) animation.duration = duration;

    [self _display:displaying duration:duration animations:animations completion:completion];
}

- (MDAlertControllerAnimationOptions)systemOptionsWithOptions:(MDAlertControllerAnimationOptions)options displaying:(BOOL)displaying {
    return [self _systemOptionsWithOptions:options displaying:displaying];
}

- (CABasicAnimation *)alphaAnimationForDisplaying:(BOOL)displaying {
    CABasicAnimation *animation = [self _defaultAnimationWithKeyPath:@"opacity" displaying:displaying];
    animation.fromValue = @(displaying ? 0.f : 1.f);
    animation.toValue = @(displaying ? 1.f : 0.f);

    return animation;
}

- (CABasicAnimation *)positionAnimationForDisplaying:(BOOL)displaying {
    BOOL vertical = self.direction == MDAlertControllerAnimationOptionDirectionFromTop || self.direction == MDAlertControllerAnimationOptionDirectionFromBottom;
    BOOL reverse = self.direction == MDAlertControllerAnimationOptionDirectionFromRight || self.direction == MDAlertControllerAnimationOptionDirectionFromBottom;

    NSString *keyPath = vertical ? @"position.y" : @"position.x";
    CABasicAnimation *animation = [self _defaultAnimationWithKeyPath:keyPath displaying:displaying];

    CGRect contentFrame = self.wrapperView.frame;
    CGFloat contentWidth = CGRectGetWidth(contentFrame);
    CGFloat contentHeight = CGRectGetHeight(contentFrame);

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);

    CGFloat size = vertical ? height : width;
    CGFloat contentSize = vertical ? contentHeight : contentWidth;

    CGFloat fromValue = contentSize / 2. * (reverse ? 1 : -1) + size * (reverse ? 1 : 0);
    CGFloat toValue = self.welt ? (size * (reverse ? 1 : 0) + contentSize / 2. * (reverse ? -1 : 1)) : (size * 1 / 2.);

    if (!displaying) {
        CGFloat tmp = fromValue;
        fromValue = toValue;
        toValue = tmp;
    }

    animation.fromValue = @(fromValue);
    animation.toValue = @(toValue);

    return animation;
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

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CABasicAnimation *)animation finished:(BOOL)flag {
    self.userInteractionEnabled = YES;

    if (self.animatedCompletion) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            self.animatedCompletion();

            [self.wrapperView.layer removeAllAnimations];
        });
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:NSStringFromSelector(@selector(frame))]) return;

    CGRect old = [change[NSKeyValueChangeOldKey] CGRectValue];
    CGRect new = [change[NSKeyValueChangeNewKey] CGRectValue];

    if (CGRectEqualToRect(old, new)) return;

    [self setNeedsLayout];
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

@implementation _MDActionSheetTransitionView

#pragma mark - private

- (void)_layoutSubviews {
    [super _layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat contentWidth = width;

    CGSize customViewSize = self.customView.frame.size;
    customViewSize.width = MIN(width, customViewSize.width);

    CGFloat textOffsetX = 13.f;
    CGFloat textWidthOffset = textOffsetX * 2;

    CGFloat titleHeight = [self.titleLabel sizeThatFits:CGSizeMake(contentWidth - textWidthOffset, CGFLOAT_MAX)].height;
    CGFloat messageHeight = [self.messageLabel sizeThatFits:CGSizeMake(contentWidth - textWidthOffset, CGFLOAT_MAX)].height;

    CGFloat textHeight = titleHeight + messageHeight;
    CGFloat titleTopOffset = (textHeight) > 0 ? MDAlertControllerTitleTopOffset : 0;

    CGFloat textOffsetY = titleTopOffset + textHeight;
    CGFloat headerHeight = textOffsetY + customViewSize.height;

    CGFloat actionContentTopOffset = headerHeight > 0 ? MDAlertControllerActionContentTopOffset : 0;
    CGFloat actionContentHeight = (self.preferredAction ? MDAlertControllerDestructiveFooterViewHeight : 0) + (self.actions.count * MDAlertControllerRowHeight);

    CGFloat maxActionContentHeight = height - headerHeight - actionContentTopOffset;
    if (maxActionContentHeight < actionContentHeight && customViewSize.height > 0) {
        customViewSize.height = MAX(0, customViewSize.height - actionContentHeight + maxActionContentHeight);
        headerHeight = textHeight + customViewSize.height;
        maxActionContentHeight = height - headerHeight - actionContentTopOffset;
    }
    actionContentHeight = MIN(actionContentHeight, maxActionContentHeight);
    actionContentTopOffset = actionContentHeight > 0 ? actionContentTopOffset : 0;

    CGFloat contentHeight = headerHeight + actionContentTopOffset + actionContentHeight;

    BOOL welt = self.welt;
    BOOL top = self.direction == MDAlertControllerAnimationOptionDirectionFromTop;
    CGFloat contentY = welt ? (top ? 0 : height - contentHeight) : (height - contentHeight) / 2.f;

    self.wrapperView.frame = CGRectMake(0, contentY, contentWidth, contentHeight);

    self.contentView.frame = CGRectMake(0, 0, contentWidth, contentHeight);

    CGFloat offsetY = 0;
    self.titleLabel.frame = CGRectMake(textOffsetX, offsetY, contentWidth - textWidthOffset, titleHeight);

    offsetY += titleHeight;
    self.messageLabel.frame = CGRectMake(textOffsetX, offsetY, contentWidth - textWidthOffset, messageHeight);

    offsetY += messageHeight;
    self.customView.frame = CGRectMake((contentWidth - customViewSize.width) / 2., offsetY, customViewSize.width, customViewSize.height);

    offsetY += customViewSize.height + actionContentTopOffset;
    self.tableView.frame = CGRectMake(0, offsetY, contentWidth, actionContentHeight);
}

- (CGRect)_dismissButtonFrameWithContentSize:(CGSize)contentSize {
    CGRect frame = [super _dismissButtonFrameWithContentSize:contentSize];

    frame.origin.x = MAX(frame.origin.x, 0);
    frame.origin.x = MIN(frame.origin.x, CGRectGetWidth(self.wrapperView.bounds) - CGRectGetWidth(frame) / 2.);

    frame.origin.y = MIN(frame.origin.y, CGRectGetHeight(self.wrapperView.bounds) - CGRectGetHeight(frame) / 2.);
    return frame;
}

#pragma mark - UITableViewDataSource

- (_MDAlertControllerCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MDAlertAction *action = self.actions[[indexPath row]];
    _MDAlertControllerCell *cell = (_MDAlertControllerCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];

    cell.titleLabel.textAlignment = action.alignment;

    return cell;
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

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }];
}

- (void)display:(BOOL)displaying animated:(BOOL)animated duration:(CGFloat)duration completion:(void (^)(void))completion {
    CABasicAnimation *animation = nil;
    if (animated) {
        animation = [self positionAnimationForDisplaying:displaying];
        animation.duration = duration;
    }
    [self display:displaying duration:duration animations:@[animation] completion:completion];
}

@end

@implementation _MDAlertTransitionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _updateTintColor];
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];

    [self _updateTintColor];
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

    self.wrapperView.layer.cornerRadius = 14.f;
    self.wrapperView.backgroundColor = MDALERT_CONTENT_BACKGROUND_COLOR;
}

- (void)_updateTintColor {
    [super _updateTintColor];

    [self.buttons.copy enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        MDAlertAction *action = self.actions[idx];

        button.tintColor = self.tintColor;
        [button setTitleColor:action.color ?: self.tintColor forState:UIControlStateNormal];
    }];
}

- (void)_updateSeparatorColor {
    [super _updateSeparatorColor];

    UIColor *separatorColor = self.separatorColor ?:  self.tintColor;

    self.lineView.backgroundColor = separatorColor;
    [self.lines setValue:separatorColor forKey:@"backgroundColor"];
}

- (void)_layoutSubviews {
    [super _layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);

    CGSize customViewSize = self.customView.frame.size;
    customViewSize.width = MIN(width, customViewSize.width);

    CGFloat contentWidth = self.customView ? customViewSize.width :  270.f;
    contentWidth = MIN(width, contentWidth);

    CGFloat textOffsetX = 13.f;
    CGFloat textWidthOffset = textOffsetX * 2;

    CGFloat titleHeight = [self.titleLabel sizeThatFits:CGSizeMake(contentWidth - textWidthOffset, CGFLOAT_MAX)].height;
    CGFloat messageHeight = [self.messageLabel sizeThatFits:CGSizeMake(contentWidth - textWidthOffset, CGFLOAT_MAX)].height;

    CGFloat textHeight = titleHeight + messageHeight;
    CGFloat titleTopOffset = (textHeight) > 0 ? MDAlertControllerTitleTopOffset : 0;

    CGFloat textOffsetY = titleTopOffset + textHeight;
    CGFloat headerHeight = textOffsetY + customViewSize.height;

    BOOL buttonEnabled = self.actions.count > 0;
    BOOL needsButtonContent = buttonEnabled && self.actions.count <= 2;

    CGFloat actionContentTopOffset = headerHeight > 0 ? MDAlertControllerActionContentTopOffset : 0;
    CGFloat actionContentHeight = (needsButtonContent ? 1 : self.actions.count) * MDAlertControllerRowHeight;

    CGFloat maxActionContentHeight = height - headerHeight - actionContentTopOffset;
    if (maxActionContentHeight < actionContentHeight && customViewSize.height > 0) {
        customViewSize.height = MAX(0, customViewSize.height - actionContentHeight + maxActionContentHeight);
        headerHeight = titleTopOffset + textHeight + customViewSize.height;
        maxActionContentHeight = height - headerHeight - actionContentTopOffset;
    }
    actionContentHeight = MIN(actionContentHeight, maxActionContentHeight);
    actionContentTopOffset = actionContentHeight > 0 ? actionContentTopOffset : 0;

    CGFloat lineHeight = ((textHeight + customViewSize.height) > 0 && actionContentHeight > 0) ?.5f : 0.f;
    CGFloat contentHeight = headerHeight + actionContentTopOffset + lineHeight + actionContentHeight;

    BOOL welt = self.welt;
    BOOL vertical = self.direction == MDAlertControllerAnimationOptionDirectionFromTop || self.direction == MDAlertControllerAnimationOptionDirectionFromBottom;
    BOOL reverse = self.direction == MDAlertControllerAnimationOptionDirectionFromRight || self.direction == MDAlertControllerAnimationOptionDirectionFromBottom;

    CGFloat size = vertical ? height : width;
    CGFloat contentSize = vertical ? contentHeight : contentWidth;

    CGFloat value = welt ? (size * (reverse ? 1 : 0) + contentSize * (reverse ? -1 : 0)) : ((size - contentSize) * 1 / 2.);

    CGFloat contentX = vertical ? (width - contentWidth) / 2.f : value;
    CGFloat contentY = vertical ? value : (height - contentHeight) / 2.f;

    self.wrapperView.frame = CGRectMake(contentX, contentY, contentWidth, contentHeight);

    self.contentView.frame = CGRectMake(0, 0, contentWidth, contentHeight);

    CGFloat offsetY = titleTopOffset;
    self.titleLabel.frame = CGRectMake(textOffsetX, offsetY, contentWidth - textWidthOffset, titleHeight);

    offsetY += titleHeight;
    self.messageLabel.frame = CGRectMake(textOffsetX, offsetY, contentWidth - textWidthOffset, messageHeight);

    offsetY += messageHeight;
    self.customView.frame = CGRectMake(0, offsetY, customViewSize.width, customViewSize.height);

    offsetY += customViewSize.height;
    offsetY += actionContentTopOffset;
    self.lineView.frame = CGRectMake(0, offsetY, contentWidth, lineHeight);

    offsetY += lineHeight;
    UIView *actionContentView = needsButtonContent ? self.buttonContentView : self.tableView;
    actionContentView.frame = CGRectMake(0, offsetY, contentWidth, actionContentHeight);

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
        line.backgroundColor = self.separatorColor ?: self.tintColor;

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

    button.frame = CGRectMake(index * width, 0, width, bounds.size.height);
}

- (void)_layoutLine:(UIView *)line atIndex:(NSUInteger)index{
    CGRect bounds = self.buttonContentView.bounds;
    CGFloat width = bounds.size.width / self.actions.count;

    CGRect frame = CGRectMake((index + 1) * width, 0, .5f, bounds.size.height);

    line.frame = UIEdgeInsetsInsetRect(frame, self.separatorInset);
}

- (UIButton *)_buttonWithAction:(MDAlertAction *)action atIndex:(NSUInteger)index {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    button.tintColor = self.tintColor;

    button.enabled = action.enabled;
    button.selected = action.selected;
    button.backgroundColor = action.backgroundColor;

    button.showsTouchWhenHighlighted = YES;
    button.reversesTitleShadowWhenHighlighted = YES;
    button.titleLabel.textAlignment = action.alignment;

    UIFont *titleFont = action.font ?: (action == self.preferredAction ? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17]);
    button.titleLabel.font = titleFont;

    static NSDictionary *contentAlignments = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contentAlignments = @{@(NSTextAlignmentLeft): @(UIControlContentHorizontalAlignmentLeft),
                              @(NSTextAlignmentRight): @(UIControlContentHorizontalAlignmentRight),
                              @(NSTextAlignmentCenter): @(UIControlContentHorizontalAlignmentCenter)};
    });
    button.contentHorizontalAlignment = [contentAlignments[@(action.alignment)] unsignedIntegerValue];

    [button setTitle:action.title forState:UIControlStateNormal];
    [button setImage:action.image forState:UIControlStateNormal];
    [button setImage:action.selectedImage forState:UIControlStateSelected];

    [button setTitleColor:action.color ?: self.tintColor forState:UIControlStateNormal];
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

- (CABasicAnimation *)_scaleAnimationForDisplaying:(BOOL)displaying {
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
    NSArray<CABasicAnimation *> *animations = nil;
    if (animated) {
        CABasicAnimation *scaleAnimation = [self _scaleAnimationForDisplaying:displaying];
        CABasicAnimation *alphaAnimation = [self alphaAnimationForDisplaying:displaying];

        animations = @[scaleAnimation, alphaAnimation];
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

    cell.titleLabel.font = action == self.preferredAction ? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17];

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

+ (instancetype)cancelableActionWithTitle:(NSString *)title {
    return [self cancelableActionWithTitle:title image:nil];
}

+ (instancetype)cancelableActionWithTitle:(NSString *)title image:(UIImage *)image {
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
        _alignment = NSTextAlignmentCenter;
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
@synthesize transitionView = _transitionView, actions = _actions, rowActions = _rowActions;
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
        self.separatorColor = HEXCOLOR(0xB8B8B8);
        self.backgroundColor = HEXACOLOR(0x000000, 0.5);
        
        self.backgroundTouchabled = preferredStyle == MDAlertControllerStyleActionSheet;

        self.welt = preferredStyle == MDAlertControllerStyleActionSheet;;

        MDAlertControllerAnimationOptions options = MDAlertControllerAnimationOptionCurveEaseIn;
        if (preferredStyle == MDAlertControllerStyleActionSheet) {
            options |= MDAlertControllerAnimationOptionDirectionFromBottom;
        }

        self.transitionOptions = options;

        super.transitioningDelegate = self;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = preferredStyle == MDAlertControllerStyleAlert ? UIModalPresentationOverFullScreen : UIModalPresentationOverCurrentContext;

        self.definesPresentationContext = YES;
        self.providesPresentationContextTransitionStyle = YES;
    }
    return self;
}

- (void)loadView {
    [super loadView];

    [self.view addSubview:self.transitionView];
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

    if (self.beingPresented) [self _displayControllerAnimated:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self _layoutSubViews];
}

#pragma mark - accessor

- (void)setTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)transitioningDelegate {
    [super setTransitioningDelegate:self];
}

- (UIView *)contentView {
    return self.transitionView.wrapperView;
}

- (UILabel *)titleLabel {
    return self.transitionView.titleLabel;
}

- (UILabel *)messageLabel {
    return self.transitionView.messageLabel;
}

- (UIView<_MDAlertControllerTransitionView> *)transitionView {
    if (!_transitionView) {
        BOOL actionSheet = self.preferredStyle == MDAlertControllerStyleActionSheet;

        _transitionView = actionSheet ? [[_MDActionSheetTransitionView alloc] init] : [[_MDAlertTransitionView alloc] init];
        _transitionView.delegate = self;
    }
    return _transitionView;
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
    self.transitionView.dismissAction = dismissAction;
}

- (MDAlertDismissAction *)dismissAction {
    return self.transitionView.dismissAction;
}

- (void)setCustomView:(UIView *)customView {
    self.transitionView.customView = customView;
}

- (UIView *)customView {
    return self.transitionView.customView;
}

- (void)setCustomViewController:(UIViewController *)customViewController {
    if (_customViewController != customViewController) {
        _customViewController = customViewController;

        self.customView = customViewController.view;
    }
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];

    if ([self isViewLoaded]) {
        self.transitionView.titleLabel.text = title;
    }
}

- (void)setMessage:(NSString *)message {
    if (_message != message) {
        _message = [message copy];

        if ([self isViewLoaded]) {
            self.transitionView.messageLabel.text = message;
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

        self.transitionView.backgroundView.backgroundColor = backgroundColor;
    }
}

#pragma mark - system accessor

- (UIViewController *)childViewControllerForStatusBarStyle {
    return _customViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return _customViewController;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return _customViewController;
}

- (UIViewController *)childViewControllerForScreenEdgesDeferringSystemGestures {
    return _customViewController;
}

#pragma mark - private

- (void)_layoutSubViews {
    self.transitionView.frame = self.view.bounds;
}

- (void)_updateView:(UIView *)view tintColor:(UIColor *)tintColor {
    view.tintColor = tintColor;

    for (UIView *subview in view.subviews) {
        [self _updateView:subview tintColor:tintColor];
    }
}

- (void)_reloadData {
    self.transitionView.welt = self.welt;
    self.transitionView.direction = self.transitionOptions & 0xF0000000;
    self.transitionView.curveOptions = self.transitionOptions & 0xF0000;

    self.transitionView.frame = self.view.bounds;
    self.transitionView.separatorInset = self.separatorInset;
    self.transitionView.separatorColor = self.separatorColor;

    self.transitionView.titleLabel.text = self.title;
    self.transitionView.messageLabel.text = self.message;
    self.transitionView.backgroundView.backgroundColor = self.backgroundColor;
    self.transitionView.backgroundView.userInteractionEnabled = self.backgroundTouchabled;

    self.transitionView.preferredAction = self.preferredAction;
    self.transitionView.actions = self.preferredStyle == MDAlertControllerStyleActionSheet ? self.rowActions : self.actions;

    [self.transitionView reload];
}

- (void)_displayControllerAnimated:(BOOL)animated {
    [self _displayControllerAnimated:animated completion:nil];
}

- (void)_displayControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self.transitionView displaying:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _display:YES animated:animated completion:completion];
    });
}

- (void)_dismissControllerAnimated:(BOOL)animated action:(MDAlertAction *)action {
    __weak MDAlertAction *weakAction = action;
    void (^completion)(void) = ^{
        __strong MDAlertAction *action = weakAction;
        if ([action handler]) action.handler(action);
    };
    [self _dismissControllerAnimated:animated completion:completion];
}

- (void)_dismissControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (self.parentViewController) {
        [self _dismissEmbededViewControllerAnimated:animated completion:completion];
    } else {
        [self _dismissModalViewControllerAnimated:animated completion:completion];
    }
}

- (void)_dismissModalViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    MDAlertController *previous = (MDAlertController *)[self previousAlertController];
    __weak typeof(previous) weakPrevious = previous;
    void (^_completion)(void) = ^{
        [super dismissViewControllerAnimated:NO completion:^{
            if (completion) completion();

            __strong typeof(weakPrevious) previous = weakPrevious;
            previous.transitionView.hidden = NO;
            previous.transitionView.backgroundView.hidden = NO;

            if (!previous.overridable) {
                [previous _display:YES animated:animated completion:nil];
            }
        }];
    };
    [self _dismissAnimated:animated completion:_completion];
}

- (void)_dismissEmbededViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    void (^_completion)(void) = ^{
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];

        if (completion) completion();
    };
    [self _dismissAnimated:animated completion:_completion];
}

- (void)_dismissAnimated:(BOOL)animated completion:(void (^)(void))completion {
    __weak typeof(self) weakSelf = self;
    void (^_completion)(void) = ^{
        __strong typeof(weakSelf) self = weakSelf;
        self.transitionView.hidden = YES;

        if (completion) completion();
    };
    [self _display:NO animated:animated completion:_completion];
}

- (void)_display:(BOOL)displaying animated:(BOOL)animated completion:(void (^)(void))completion {
    void (^_completion)(void) = ^{
        if (completion) completion();
        [self.transitionView displaying:displaying];
    };

    if (animated && self.transitionOptions && self.preferredStyle != MDAlertControllerStyleActionSheet) {
        [self _transitWithOptions:self.transitionOptions displaying:displaying completion:_completion];
    } else {
        NSMutableArray<CAAnimation *> *animations = [NSMutableArray array];
        CAAnimation *animation = displaying ? self.presentingAnimation : self.dismissingAnimation;

        if (animation) [animations addObject:animation];
        if (animated && animations.count) {
            [self.transitionView display:displaying duration:self.transitionDuration animations:animations completion:_completion];
        } else {
            [self.transitionView displaying:YES];
            [self.transitionView display:displaying animated:animated duration:self.transitionDuration completion:_completion];
        }
    }
}

- (void)_transitWithOptions:(MDAlertControllerAnimationOptions)options displaying:(BOOL)displaying completion:(void (^)(void))completion {
    MDAlertControllerAnimationOptions additions = options & 0xF000000;
    if (additions) {
        [self _transitWithAdditionalOptionsForDisplaying:displaying completion:completion];
    } else {
        options = [self.transitionView systemOptionsWithOptions:options displaying:displaying];
        UIViewAnimationOptions UIOptions = options & 0xFFFFFFF;

        [self _transitWithUIOptions:UIOptions displaying:displaying completion:completion];
    }
}

- (void)_transitWithAdditionalOptionsForDisplaying:(BOOL)displaying completion:(void (^)(void))completion {
    CABasicAnimation *positionAnimation = [self.transitionView positionAnimationForDisplaying:displaying];
    CABasicAnimation *alphaAnimation = [self.transitionView alphaAnimationForDisplaying:displaying];

    NSArray<CABasicAnimation *> *animations = @[positionAnimation, alphaAnimation];
    [self.transitionView display:displaying duration:self.transitionDuration animations:animations completion:completion];
}

- (void)_transitWithUIOptions:(UIViewAnimationOptions)options displaying:(BOOL)displaying completion:(void (^)(void))completion {
    [UIView transitionWithView:self.transitionView.wrapperView duration:self.transitionDuration options:options animations:^{
        [self.transitionView displaying:displaying];
    } completion:^(BOOL finished) {
        if (completion) completion();
    }];
    self.transitionView.hidden = NO;
}

#pragma mark - public

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (self.parentViewController) {
        [self _dismissEmbededViewControllerAnimated:animated completion:completion];
    } else {
        [self _dismissModalViewControllerAnimated:animated completion:completion];
    }
}

- (void)presentViewController:(MDAlertController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    if ([viewController isKindOfClass:[MDAlertController class]]) {
        viewController.previousAlertController =  self;

        if (self.overridable) {
            if (viewController.backgroundOptions == MDAlertControllerBackgroundOptionExclusive) {
                self.transitionView.backgroundView.hidden = YES;
            }
        } else {
            [self _display:NO animated:animated completion:^{
                self.transitionView.hidden = YES;
            }];
        }
    }
    [super presentViewController:viewController animated:animated completion:completion];
}

- (void)addAction:(MDAlertAction *)action {
    NSParameterAssert(action);
    NSParameterAssert(![self.actions containsObject:action]);
    NSParameterAssert(action.style != MDAlertActionStyleDestructive || !self.preferredAction);

    if (self.preferredStyle == MDAlertControllerStyleActionSheet && !action.color) {
        action.color = action.style == MDAlertActionStyleDestructive ? HEXCOLOR(0x505050) : HEXCOLOR(0x212121);
    }

    if (action.style != MDAlertActionStyleDestructive) {
        _rowActions = [self.rowActions arrayByAddingObject:action];
        _actions = [self.actions arrayByAddingObject:action];
    } else {
        self.preferredAction = action;
    }
}

#pragma mark - _MDAlertControllerContentViewDelegate

- (void)contentViewDidCancel:(UIView<_MDAlertControllerTransitionView> *)contentView {
    __weak typeof(self) weakSelf = self;
    void (^completion)(void) = ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (self.cancelation) self.cancelation(self);
    };
    [self _dismissControllerAnimated:YES completion:completion];
}

- (void)contentView:(UIView<_MDAlertControllerTransitionView> *)contentView didSelectAction:(MDAlertAction *)action {
    [self _dismissControllerAnimated:YES action:action];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.sourceViewController = presenting;

    return [[_MDAlertControllerAnimationController alloc] init];
}

#pragma mark - rotation

- (BOOL)shouldAutorotate {
    return self.sourceViewController ? self.sourceViewController.shouldAutorotate : [super shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.sourceViewController ? self.sourceViewController.preferredInterfaceOrientationForPresentation : [super preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.sourceViewController ? self.sourceViewController.supportedInterfaceOrientations : [super supportedInterfaceOrientations];
}

@end
