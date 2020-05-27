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

    _titleLabel.textColor = _action.color ?: self.tintColor;
}

#pragma mark - private

- (void)_createSubviews {
    _iconImageView = [[UIImageView alloc] init];
    _titleLabel = [[UILabel alloc] init];

    [self.contentView addSubview:_iconImageView];
    [self.contentView addSubview:_titleLabel];
}

- (void)_initializeSubviews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];

    _titleLabel.textColor = self.tintColor;
    _titleLabel.font = [UIFont systemFontOfSize:14];
}

- (void)_layoutSubviews {
    CGRect bounds = self.contentView.bounds;
    CGSize imageSize = _iconImageView.image.size;

    CGFloat imageY = (CGRectGetHeight(bounds) - imageSize.height) / 2.;
    _iconImageView.frame = CGRectMake(20, imageY, imageSize.width, imageSize.height);

    CGFloat titleX = 16 + (imageSize.width > 0 ? 20 : 0) + imageSize.width;
    _titleLabel.frame = CGRectMake(titleX, 0, CGRectGetWidth(bounds) - titleX * 2, CGRectGetHeight(bounds));
}

- (void)_updateContentView {
    _iconImageView.image = _action.image;
    _titleLabel.text = _action.title;

    _titleLabel.font = _action.font ?: (_action.style == MDAlertActionStyleCancel ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14]);
    _titleLabel.textColor = _action.color ?: self.tintColor;
    _titleLabel.textAlignment = _action.alignment;

    self.contentView.backgroundColor = _action.backgroundColor;

    self.userInteractionEnabled = _action.enabled;
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

    [self.contentView addSubview:_selectedImageView];
}

- (void)_layoutSubviews {
    [super _layoutSubviews];

    CGRect bounds = self.contentView.bounds;
    CGSize imageSize = _iconImageView.image.size;
    CGFloat imageX = CGRectGetWidth(bounds) - imageSize.width - 12;
    CGFloat imageY = (CGRectGetHeight(bounds) - imageSize.height) / 2.;

    _selectedImageView.frame = CGRectMake(imageX, imageY, imageSize.width, imageSize.height);
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    _selectedImageView.image = selected ? _action.selectedImage : nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    _selectedImageView.image = selected ? _action.selectedImage : nil;
}

@end

@implementation _MDAlertControllerDestructiveFooterView

- (instancetype)initWithFrame:(CGRect)frame action:(MDAlertAction *)action {
    if (self = [super initWithFrame:frame]) {
        _action = action;
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 5)];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, frame.size.width, frame.size.height - 5)];

        self.backgroundColor = [UIColor clearColor];
        _separatorView.backgroundColor = HEXCOLOR(0xE7E7E7);;

        _titleLabel.text = action.title;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = action.font ?: [UIFont systemFontOfSize:15];
        _titleLabel.textColor = action.color ?: self.tintColor;
        _titleLabel.backgroundColor = action.backgroundColor;

        [self addSubview:_separatorView];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect bounds = self.bounds;
    _separatorView.frame = CGRectMake(0, 0, bounds.size.width, 5);
    _titleLabel.frame = CGRectMake(0, 5, bounds.size.width, bounds.size.height - 5);
}

- (void)tintColorDidChange {
    [super tintColorDidChange];

    _titleLabel.textColor = _action.color ?: self.tintColor;
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
@synthesize delegate = _delegate, actions = _actions;
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

    [_tableView reloadData];
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

    [self addSubview:_backgroundView];
    [self addSubview:_wrapperView];

    [_wrapperView addSubview:_contentView];

    [_contentView addSubview:_titleLabel];
    [_contentView addSubview:_messageLabel];
    [_contentView addSubview:_tableView];

    [_backgroundView addGestureRecognizer:_tapGestureRecognizer];
}

- (void)_initializeSubviews {
    self.hidden = YES;
    _separatorColor = HEXCOLOR(0xBFBFBF);
    
    _backgroundView.layer.masksToBounds = YES;

    _wrapperView.layer.masksToBounds = YES;
    _wrapperView.backgroundColor = [UIColor whiteColor];

    _titleLabel.numberOfLines = 0;
    _titleLabel.textColor = HEXCOLOR(0x000000);
    _titleLabel.font = [UIFont systemFontOfSize:17];
    _titleLabel.textAlignment = NSTextAlignmentCenter;

    _messageLabel.numberOfLines = 0;
    _messageLabel.textColor = HEXCOLOR(0x000000);
    _messageLabel.font = [UIFont systemFontOfSize:13];
    _messageLabel.textAlignment = NSTextAlignmentCenter;

    _tableView.bounces = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.backgroundColor = [UIColor clearColor];

    _tableView.rowHeight = 0;
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;

    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;

    _tableView.tableFooterView = [[UIView  alloc] init];

    if (@available(iOS 11, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    [_tableView registerClass:[_MDAlertControllerCell class] forCellReuseIdentifier:NSStringFromClass([_MDAlertControllerCell class])];
    [_tableView registerClass:[_MDAlertControllerCheckCell class] forCellReuseIdentifier:NSStringFromClass([_MDAlertControllerCheckCell class])];
}

- (void)_layoutSubviews {
    _backgroundView.frame = self.bounds;
}

- (void)_updateTintColor {
    [self _updateSeparatorColor];

    _titleLabel.textColor = _titleLabel.textColor ?: self.tintColor;
    _messageLabel.textColor = _messageLabel.textColor ?: self.tintColor;

    _tableView.tableFooterView.tintColor = self.tintColor;
}

- (void)_updateSeparatorColor {
    _tableView.separatorColor = _separatorColor ?: self.tintColor;
}

- (void)_layoutDismissButton {
    CGSize contentSize = _contentView.bounds.size;

    _dismissButton.frame = [self _dismissButtonFrameWithContentSize:contentSize];
}

- (void)_respondSelectAction:(MDAlertAction *)action {
    if ([_delegate respondsToSelector:@selector(contentView:didSelectAction:)]) {
        [_delegate contentView:self didSelectAction:action];
    }
}

- (void)_loadCustomViewIfNeeds {
    if (!_customView) return;

    [_contentView addSubview:_customView];
}

- (void)_loadDismissButtonIfNeeds {
    if (!_dismissAction || _dismissButton) return;

    _dismissButton = [[_MDAlertDismissButton alloc] init];
    _dismissButton.titleLabel.font = _dismissAction.font;
    _dismissButton.backgroundColor = _dismissAction.backgroundColor;
    _dismissButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

    if (_dismissAction.image) {
        [_dismissButton setImage:_dismissAction.image forState:UIControlStateNormal];
    }
    if (_dismissAction.title) {
        [_dismissButton setTitle:_dismissAction.title forState:UIControlStateNormal];
    }
    if (_dismissAction.color) {
        [_dismissButton setTitleColor:_dismissAction.color forState:UIControlStateNormal];
    }
    [_dismissButton addTarget:self action:@selector(didClickDismissButton:) forControlEvents:UIControlEventTouchUpInside];

    [_wrapperView addSubview:_dismissButton];
}

- (CGSize)_dismissButtonSize {
    if (!_dismissButton) return CGSizeZero;

    CGSize size = _dismissAction.size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        [_dismissButton sizeToFit];
        size = _dismissButton.frame.size;
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
    if ([_delegate respondsToSelector:@selector(contentViewDidCancel:)]) {
        [_delegate contentViewDidCancel:self];
    }
}

- (CABasicAnimation *)_defaultAnimationWithKeyPath:(NSString *)keyPath displaying:(BOOL)displaying {
    MDAlertControllerAnimationOptions curveOptions = [self _systemOptionsWithOptions:_curveOptions displaying:displaying];

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

    [_wrapperView.layer addAnimation:animation forKey:MDAlertControllerWrapperAnimationKey];
    [_backgroundView.layer addAnimation:backgroundAnimation forKey:MDAlertControllerBackgroundAnimationKey];

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
    _tableView.separatorInset = _separatorInset;

    [self _loadCustomViewIfNeeds];
    [self _loadDismissButtonIfNeeds];
}

- (void)displaying:(BOOL)displaying {
    _wrapperView.alpha = displaying;
    _backgroundView.alpha = displaying;
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
    BOOL vertical = _direction == MDAlertControllerAnimationOptionDirectionFromTop || _direction == MDAlertControllerAnimationOptionDirectionFromBottom;
    BOOL reverse = _direction == MDAlertControllerAnimationOptionDirectionFromRight || _direction == MDAlertControllerAnimationOptionDirectionFromBottom;

    NSString *keyPath = vertical ? @"position.y" : @"position.x";
    CABasicAnimation *animation = [self _defaultAnimationWithKeyPath:keyPath displaying:displaying];

    CGRect contentFrame = _wrapperView.frame;
    CGFloat contentWidth = CGRectGetWidth(contentFrame);
    CGFloat contentHeight = CGRectGetHeight(contentFrame);

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);

    CGFloat size = vertical ? height : width;
    CGFloat contentSize = vertical ? contentHeight : contentWidth;

    CGFloat fromValue = contentSize / 2. * (reverse ? 1 : -1) + size * (reverse ? 1 : 0);
    CGFloat toValue = _welt ? (size * (reverse ? 1 : 0) + contentSize / 2. * (reverse ? -1 : 1)) : (size * 1 / 2.);

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
    return _actions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MDAlertControllerRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MDAlertAction *action = _actions[[indexPath row]];
    Class cellClass = action.selectedImage ? [_MDAlertControllerCheckCell class] : [_MDAlertControllerCell class];

    _MDAlertControllerCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass)];
    cell.action = action;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MDAlertAction *action = _actions[[indexPath row]];

    [self _respondSelectAction:action];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CABasicAnimation *)animation finished:(BOOL)flag {
    self.userInteractionEnabled = YES;

    void (^animatedCompletion)(void) = self.animatedCompletion;

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (animatedCompletion) animatedCompletion();

        __strong typeof(weakSelf) self = weakSelf;
        [self.wrapperView.layer removeAllAnimations];
        [self.backgroundView.layer removeAllAnimations];
    });

    self.animatedCompletion = nil;
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
    [self _respondSelectAction:_dismissAction];
}

@end

@implementation _MDActionSheetTransitionView

#pragma mark - private

- (void)_layoutSubviews {
    [super _layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat contentWidth = width;

    CGSize customViewSize = _customView.frame.size;
    customViewSize.width = MIN(width, customViewSize.width);

    CGFloat textOffsetX = 13.f;
    CGFloat textWidthOffset = textOffsetX * 2;

    CGFloat titleHeight = [_titleLabel sizeThatFits:CGSizeMake(contentWidth - textWidthOffset, CGFLOAT_MAX)].height;
    CGFloat messageHeight = [_messageLabel sizeThatFits:CGSizeMake(contentWidth - textWidthOffset, CGFLOAT_MAX)].height;

    CGFloat textHeight = titleHeight + messageHeight;
    CGFloat titleTopOffset = (textHeight) > 0 ? MDAlertControllerTitleTopOffset : 0;

    CGFloat textOffsetY = titleTopOffset + textHeight;
    CGFloat headerHeight = textOffsetY + customViewSize.height;

    CGFloat actionContentTopOffset = headerHeight > 0 ? MDAlertControllerActionContentTopOffset : 0;
    CGFloat actionContentHeight = (_preferredAction ? MDAlertControllerDestructiveFooterViewHeight : 0) + (_actions.count * MDAlertControllerRowHeight);

    CGFloat maxActionContentHeight = height - headerHeight - actionContentTopOffset;
    if (maxActionContentHeight < actionContentHeight && customViewSize.height > 0) {
        customViewSize.height = MAX(0, customViewSize.height - actionContentHeight + maxActionContentHeight);
        headerHeight = textHeight + customViewSize.height;
        maxActionContentHeight = height - headerHeight - actionContentTopOffset;
    }
    actionContentHeight = MIN(actionContentHeight, maxActionContentHeight);
    actionContentTopOffset = actionContentHeight > 0 ? actionContentTopOffset : 0;

    CGFloat contentHeight = headerHeight + actionContentTopOffset + actionContentHeight;

    BOOL welt = _welt;
    BOOL top = _direction == MDAlertControllerAnimationOptionDirectionFromTop;
    CGFloat contentY = welt ? (top ? 0 : height - contentHeight) : (height - contentHeight) / 2.f;

    _wrapperView.frame = CGRectMake(0, contentY, contentWidth, contentHeight);

    _contentView.frame = CGRectMake(0, 0, contentWidth, contentHeight);

    CGFloat offsetY = 0;
    _titleLabel.frame = CGRectMake(textOffsetX, offsetY, contentWidth - textWidthOffset, titleHeight);

    offsetY += titleHeight;
    _messageLabel.frame = CGRectMake(textOffsetX, offsetY, contentWidth - textWidthOffset, messageHeight);

    offsetY += messageHeight;
    _customView.frame = CGRectMake((contentWidth - customViewSize.width) / 2., offsetY, customViewSize.width, customViewSize.height);

    offsetY += customViewSize.height + actionContentTopOffset;
    _tableView.frame = CGRectMake(0, offsetY, contentWidth, actionContentHeight);
}

- (CGRect)_dismissButtonFrameWithContentSize:(CGSize)contentSize {
    CGRect frame = [super _dismissButtonFrameWithContentSize:contentSize];

    frame.origin.x = MAX(frame.origin.x, 0);
    frame.origin.x = MIN(frame.origin.x, CGRectGetWidth(_wrapperView.bounds) - CGRectGetWidth(frame) / 2.);

    frame.origin.y = MIN(frame.origin.y, CGRectGetHeight(_wrapperView.bounds) - CGRectGetHeight(frame) / 2.);
    return frame;
}

#pragma mark - UITableViewDataSource

- (_MDAlertControllerCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MDAlertAction *action = _actions[[indexPath row]];
    _MDAlertControllerCell *cell = (_MDAlertControllerCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];

    cell.titleLabel.textAlignment = action.alignment;

    return cell;
}

#pragma mark - public

- (void)reload {
    [super reload];

    [self _layoutSubviews];

    _MDAlertControllerDestructiveFooterView *footerView = nil;
    if (_preferredAction) {
        footerView = [[_MDAlertControllerDestructiveFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), MDAlertControllerDestructiveFooterViewHeight) action:_preferredAction];

        [footerView addTarget:self action:@selector(didClickDestructFooterView:) forControlEvents:UIControlEventTouchUpInside];
    }
    _tableView.tableFooterView = footerView;

    [_tableView reloadData];

    [_actions enumerateObjectsUsingBlock:^(MDAlertAction *action, NSUInteger index, BOOL *stop) {
        if (!action.selected) return;

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
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

    [_contentView addSubview:_buttonContentView];
    [_contentView addSubview:_lineView];
}

- (void)_initializeSubviews {
    [super _initializeSubviews];

    _wrapperView.layer.cornerRadius = 14.f;
    _wrapperView.backgroundColor = MDALERT_CONTENT_BACKGROUND_COLOR;
}

- (void)_updateTintColor {
    [super _updateTintColor];

    [_buttons.copy enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        MDAlertAction *action = _actions[idx];

        button.tintColor = self.tintColor;
        [button setTitleColor:action.color ?: self.tintColor forState:UIControlStateNormal];
    }];
}

- (void)_updateSeparatorColor {
    [super _updateSeparatorColor];

    UIColor *separatorColor = _separatorColor ?: self.tintColor;

    _lineView.backgroundColor = separatorColor;
    [_lines setValue:separatorColor forKey:@"backgroundColor"];
}

- (void)_layoutSubviews {
    [super _layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);

    CGSize customViewSize = _customView.frame.size;
    customViewSize.width = MIN(width, customViewSize.width);

    CGFloat contentWidth = _customView ? customViewSize.width :  270.f;
    contentWidth = MIN(width, contentWidth);

    CGFloat textOffsetX = 13.f;
    CGFloat textWidthOffset = textOffsetX * 2;

    CGFloat titleHeight = [_titleLabel sizeThatFits:CGSizeMake(contentWidth - textWidthOffset, CGFLOAT_MAX)].height;
    CGFloat messageHeight = [_messageLabel sizeThatFits:CGSizeMake(contentWidth - textWidthOffset, CGFLOAT_MAX)].height;

    CGFloat textHeight = titleHeight + messageHeight;
    CGFloat titleTopOffset = (textHeight) > 0 ? MDAlertControllerTitleTopOffset : 0;

    CGFloat textOffsetY = titleTopOffset + textHeight;
    CGFloat headerHeight = textOffsetY + customViewSize.height;

    BOOL buttonEnabled = _actions.count > 0;
    BOOL needsButtonContent = buttonEnabled && _actions.count <= 2;

    CGFloat actionContentTopOffset = headerHeight > 0 ? MDAlertControllerActionContentTopOffset : 0;
    CGFloat actionContentHeight = (needsButtonContent ? 1 : _actions.count) * MDAlertControllerRowHeight;

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

    BOOL welt = _welt;
    BOOL vertical = _direction == MDAlertControllerAnimationOptionDirectionFromTop || _direction == MDAlertControllerAnimationOptionDirectionFromBottom;
    BOOL reverse = _direction == MDAlertControllerAnimationOptionDirectionFromRight || _direction == MDAlertControllerAnimationOptionDirectionFromBottom;

    CGFloat size = vertical ? height : width;
    CGFloat contentSize = vertical ? contentHeight : contentWidth;

    CGFloat value = welt ? (size * (reverse ? 1 : 0) + contentSize * (reverse ? -1 : 0)) : ((size - contentSize) * 1 / 2.);

    CGFloat contentX = vertical ? (width - contentWidth) / 2.f : value;
    CGFloat contentY = vertical ? value : (height - contentHeight) / 2.f;

    _wrapperView.frame = CGRectMake(contentX, contentY, contentWidth, contentHeight);

    _contentView.frame = CGRectMake(0, 0, contentWidth, contentHeight);

    CGFloat offsetY = titleTopOffset;
    _titleLabel.frame = CGRectMake(textOffsetX, offsetY, contentWidth - textWidthOffset, titleHeight);

    offsetY += titleHeight;
    _messageLabel.frame = CGRectMake(textOffsetX, offsetY, contentWidth - textWidthOffset, messageHeight);

    offsetY += messageHeight;
    _customView.frame = CGRectMake(0, offsetY, customViewSize.width, customViewSize.height);

    offsetY += customViewSize.height;
    offsetY += actionContentTopOffset;
    _lineView.frame = CGRectMake(0, offsetY, contentWidth, lineHeight);

    offsetY += lineHeight;
    UIView *actionContentView = needsButtonContent ? _buttonContentView : _tableView;
    actionContentView.frame = CGRectMake(0, offsetY, contentWidth, actionContentHeight);

    if (needsButtonContent) {
        [_buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger index, BOOL *stop) {
            [self _layoutButton:button atIndex:index];
        }];
        [_lines enumerateObjectsUsingBlock:^(UIView *line, NSUInteger index, BOOL *stop) {
            [self _layoutLine:line atIndex:index];
        }];
    }
}

- (void)_reloadButtonContentView {
    NSArray<MDAlertAction *> *actions = _actions.copy;
    NSUInteger count = actions.count;

    [actions enumerateObjectsUsingBlock:^(MDAlertAction *action, NSUInteger index, BOOL *stop) {
        UIButton *button = [self _buttonWithAction:action atIndex:index];

        [self _reloadButton:button count:count atIndex:index];
    }];
}

- (void)_reloadButton:(UIButton *)button count:(NSUInteger)count atIndex:(NSUInteger)index {
    UIView *line = index == (count - 1) ? nil : [[UIView  alloc] init];
    line.backgroundColor = _separatorColor ?: self.tintColor;

    [_buttons addObject:button];
    [_buttonContentView addSubview:button];
    [self _layoutButton:button atIndex:index];

    if (line) {
        [_lines addObject:line];
        [_buttonContentView addSubview:line];
        [self _layoutLine:line atIndex:index];
    }
}

- (void)_layoutButton:(UIButton *)button atIndex:(NSUInteger)index {
    CGRect bounds = [_buttonContentView bounds];
    CGFloat width = CGRectGetWidth(bounds) / _actions.count;

    button.frame = CGRectMake(index * width, 0, width, bounds.size.height);
}

- (void)_layoutLine:(UIView *)line atIndex:(NSUInteger)index{
    CGRect bounds = _buttonContentView.bounds;
    CGFloat width = bounds.size.width / _actions.count;

    CGRect frame = CGRectMake((index + 1) * width, 0, .5f, bounds.size.height);

    line.frame = UIEdgeInsetsInsetRect(frame, _separatorInset);
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

    UIFont *titleFont = action.font ?: (action == _preferredAction ? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17]);
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
    [_tableView reloadData];

    [_actions enumerateObjectsUsingBlock:^(MDAlertAction *action, NSUInteger index, BOOL *stop) {
        if (!action.selected) return;

        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
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

    for (UIView *view in [_buttonContentView subviews]) [view removeFromSuperview];

    [_buttons removeAllObjects];
    [_lines removeAllObjects];

    _buttonContentView.hidden = _actions.count > 2;
    _lineView.hidden = _actions.count > 2;
    _tableView.hidden = _actions.count <= 2;

    if (_actions.count <= 2) {
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
    NSUInteger index = [_buttons indexOfObject:sender];
    MDAlertAction *action = _actions[index];

    [self _respondSelectAction:action];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MDAlertAction *action = _actions[[indexPath row]];
    _MDAlertControllerCell *cell = (id)[super tableView:tableView cellForRowAtIndexPath:indexPath];

    cell.titleLabel.font = action == _preferredAction ? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17];

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
        _actions = [NSMutableArray array];
        _rowActions = [NSMutableArray array];

        BOOL actionSheet = preferredStyle == MDAlertControllerStyleActionSheet;
        _transitionView = actionSheet ? [[_MDActionSheetTransitionView alloc] init] : [[_MDAlertTransitionView alloc] init];
        _transitionView.delegate = self;

        self.title = title;
        _message = message;
        _separatorColor = HEXCOLOR(0xB8B8B8);
        _backgroundColor = HEXACOLOR(0x000000, 0.5);

        _welt = actionSheet;
        _backgroundTouchabled = actionSheet;

        MDAlertControllerAnimationOptions options = MDAlertControllerAnimationOptionCurveEaseIn;
        if (preferredStyle == MDAlertControllerStyleActionSheet) {
            options |= MDAlertControllerAnimationOptionDirectionFromBottom;
        }

        _transitionOptions = options;

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

    [self.view addSubview:_transitionView];
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
    return _transitionView.wrapperView;
}

- (UILabel *)titleLabel {
    return _transitionView.titleLabel;
}

- (UILabel *)messageLabel {
    return _transitionView.messageLabel;
}

- (NSArray<MDAlertAction *> *)actions {
    return _actions.copy;
}

- (NSArray<MDAlertAction *> *)rowActions {
    return _rowActions.copy;
}

- (void)setPreferredAction:(MDAlertAction *)preferredAction {
    if (_preferredAction != preferredAction) {
        [_actions removeObject:_preferredAction];

        if (preferredAction) {
            [_actions addObject:preferredAction];
        }
        _preferredAction = preferredAction;

        if ([self isViewLoaded]) {
            [self _reloadData];
        }
    }
}

- (void)setDismissAction:(MDAlertDismissAction *)dismissAction {
    _transitionView.dismissAction = dismissAction;
}

- (MDAlertDismissAction *)dismissAction {
    return _transitionView.dismissAction;
}

- (void)setCustomView:(UIView *)customView {
    _transitionView.customView = customView;
}

- (UIView *)customView {
    return _transitionView.customView;
}

- (void)setCustomViewController:(UIViewController *)customViewController {
    if (_customViewController != customViewController) {
        _customViewController = customViewController;

        _transitionView.customView  = customViewController.view;
    }
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];

    if ([self isViewLoaded]) {
        _transitionView.titleLabel.text = title;
    }
}

- (void)setMessage:(NSString *)message {
    if (_message != message) {
        _message = [message copy];

        if ([self isViewLoaded]) {
            _transitionView.messageLabel.text = message;
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

        _transitionView.backgroundView.backgroundColor = backgroundColor;
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
    _transitionView.frame = self.view.bounds;
}

- (void)_updateView:(UIView *)view tintColor:(UIColor *)tintColor {
    view.tintColor = tintColor;

    for (UIView *subview in view.subviews) {
        [self _updateView:subview tintColor:tintColor];
    }
}

- (void)_reloadData {
    _transitionView.welt = _welt;
    _transitionView.direction = _transitionOptions & 0xF0000000;
    _transitionView.curveOptions = _transitionOptions & 0xF0000;

    _transitionView.frame = self.view.bounds;
    _transitionView.separatorInset = _separatorInset;
    _transitionView.separatorColor = _separatorColor;

    _transitionView.titleLabel.text = self.title;
    _transitionView.messageLabel.text = _message;
    _transitionView.backgroundView.backgroundColor = _backgroundColor;
    _transitionView.backgroundView.userInteractionEnabled = _backgroundTouchabled;

    _transitionView.preferredAction = _preferredAction;
    _transitionView.actions = _preferredStyle == MDAlertControllerStyleActionSheet ? _rowActions : _actions;

    [_transitionView reload];
}

- (void)_displayControllerAnimated:(BOOL)animated {
    [self _displayControllerAnimated:animated completion:nil];
}

- (void)_displayControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [_transitionView displaying:NO];

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self _display:YES animated:animated completion:completion];
    });
}

- (void)_dismissControllerAnimated:(BOOL)animated action:(MDAlertAction *)action {
    void (^handler)(MDAlertAction *action) = action.handler;

    __weak MDAlertAction *weakAction = action;
    void (^completion)(void) = ^{
        if (handler) handler(weakAction);
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

- (void)_superDismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:animated completion:completion];
}

- (void)_revertPreviousViewControllerAnimated:(BOOL)animated {
    _previousAlertController.transitionView.hidden = NO;
    _previousAlertController.transitionView.backgroundView.hidden = NO;

    if (!_previousAlertController.overridable) {
        [_previousAlertController _display:YES animated:animated completion:nil];
    }
}

- (void)_dismissModalViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    __weak typeof(self) weakSelf = self;
    void (^_completion)(void) = ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self _superDismissViewControllerAnimated:NO completion:^{
            if (completion) completion();

            __strong typeof(weakSelf) self = weakSelf;
            [self _revertPreviousViewControllerAnimated:animated];
        }];
    };
    [self _dismissAnimated:animated completion:_completion];
}

- (void)_dismissEmbededViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    __weak typeof(self) weakSelf = self;
    void (^_completion)(void) = ^{
        __strong typeof(weakSelf) self = weakSelf;
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
    __weak typeof(self) weakSelf = self;
    void (^_completion)(void) = ^{
        __strong typeof(weakSelf) self = weakSelf;

        if (completion) completion();
        [self.transitionView displaying:displaying];
    };

    if (animated && _transitionOptions && _preferredStyle != MDAlertControllerStyleActionSheet) {
        [self _transitWithOptions:_transitionOptions displaying:displaying completion:_completion];
    } else {
        NSMutableArray<CAAnimation *> *animations = [NSMutableArray array];
        CAAnimation *animation = displaying ? _presentingAnimation : _dismissingAnimation;

        if (animation) [animations addObject:animation];
        if (animated && animations.count) {
            [_transitionView display:displaying duration:_transitionDuration animations:animations completion:_completion];
        } else {
            [_transitionView displaying:YES];
            [_transitionView display:displaying animated:animated duration:_transitionDuration completion:_completion];
        }
    }
}

- (void)_transitWithOptions:(MDAlertControllerAnimationOptions)options displaying:(BOOL)displaying completion:(void (^)(void))completion {
    MDAlertControllerAnimationOptions additions = options & 0xF000000;
    if (additions) {
        [self _transitWithAdditionalOptionsForDisplaying:displaying completion:completion];
    } else {
        options = [_transitionView systemOptionsWithOptions:options displaying:displaying];
        UIViewAnimationOptions UIOptions = options & 0xFFFFFFF;

        [self _transitWithUIOptions:UIOptions displaying:displaying completion:completion];
    }
}

- (void)_transitWithAdditionalOptionsForDisplaying:(BOOL)displaying completion:(void (^)(void))completion {
    CABasicAnimation *positionAnimation = [_transitionView positionAnimationForDisplaying:displaying];
    CABasicAnimation *alphaAnimation = [_transitionView alphaAnimationForDisplaying:displaying];

    NSArray<CABasicAnimation *> *animations = @[positionAnimation, alphaAnimation];
    [_transitionView display:displaying duration:_transitionDuration animations:animations completion:completion];
}

- (void)_transitWithUIOptions:(UIViewAnimationOptions)options displaying:(BOOL)displaying completion:(void (^)(void))completion {
    __weak typeof(self) weakSelf = self;
    [UIView transitionWithView:_transitionView.wrapperView duration:_transitionDuration options:options animations:^{
        __strong typeof(weakSelf) self = weakSelf;
        [self.transitionView displaying:displaying];
    } completion:^(BOOL finished) {
        if (completion) completion();
    }];
    _transitionView.hidden = NO;
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
        viewController.previousAlertController = self;

        if (_overridable) {
            if (viewController.backgroundOptions == MDAlertControllerBackgroundOptionExclusive) {
                _transitionView.backgroundView.hidden = YES;
            }
        } else {
            __weak typeof(self) weakSelf = self;
            [self _display:NO animated:animated completion:^{
                __strong typeof(weakSelf) self = weakSelf;
                self.transitionView.hidden = YES;
            }];
        }
    }
    [super presentViewController:viewController animated:animated completion:completion];
}

- (void)addAction:(MDAlertAction *)action {
    NSParameterAssert(action);
    NSParameterAssert(![_actions containsObject:action]);
    NSParameterAssert(action.style != MDAlertActionStyleDestructive || !_preferredAction);

    if (_preferredStyle == MDAlertControllerStyleActionSheet && !action.color) {
        action.color = action.style == MDAlertActionStyleDestructive ? HEXCOLOR(0x505050) : HEXCOLOR(0x212121);
    }
    
    [_actions addObject:action];
    
    if (action.style != MDAlertActionStyleDestructive) {
        [_rowActions addObject:action];
    } else {
        _preferredAction = action;
    }
}

#pragma mark - _MDAlertControllerContentViewDelegate

- (void)contentViewDidCancel:(UIView<_MDAlertControllerTransitionView> *)contentView {
    void (^cancelation)(MDAlertController *alertController) = [_cancelation copy];

    __weak typeof(self) weakSelf = self;
    [self _dismissControllerAnimated:YES completion:^{
        if (cancelation) cancelation(weakSelf);
    }];
}

- (void)contentView:(UIView<_MDAlertControllerTransitionView> *)contentView didSelectAction:(MDAlertAction *)action {
    [self _dismissControllerAnimated:YES action:action];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _sourceViewController = presenting;

    return [[_MDAlertControllerAnimationController alloc] init];
}

#pragma mark - rotation

- (BOOL)shouldAutorotate {
    return _sourceViewController ? _sourceViewController.shouldAutorotate : [super shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return _sourceViewController ? _sourceViewController.preferredInterfaceOrientationForPresentation : [super preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return _sourceViewController ? _sourceViewController.supportedInterfaceOrientations : [super supportedInterfaceOrientations];
}

@end
