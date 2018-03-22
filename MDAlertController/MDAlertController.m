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

const CGFloat MDAlertControllerPresentAnimationDuration = .25f;
const CGFloat MDAlertControllerDismissAnimationDuration = .15f;
const CGFloat MDAlertControllerRowHeight = 50.f;
const CGFloat MDAlertControllerDestructiveFooterViewHeight = 60.f;

@implementation _MDAlertControllerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self _createSubviews];
        [self _initializeSubviews];
        [self _layoutSubviews];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self _layoutSubviews];
}

- (void)tintColorDidChange{
    [super tintColorDidChange];
    
    self.titleLabel.textColor = self.tintColor;
}

#pragma mark - private

- (void)_createSubviews{
    _iconImageView = [UIImageView new];
    _titleLabel = [UILabel new];

    [[self contentView] addSubview:[self iconImageView]];
    [[self contentView] addSubview:[self titleLabel]];
}

- (void)_initializeSubviews{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.titleLabel.textColor = [self tintColor];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
}

- (void)_layoutSubviews{
    CGRect bounds = [[self contentView] bounds];
    CGSize imageSize = [[[self iconImageView] image] size];
    CGFloat imageY = (CGRectGetHeight(bounds) - imageSize.height) / 2.;
    
    self.iconImageView.frame = (CGRect){20, imageY, imageSize};
    
    CGSize fitSize = CGSizeMake(CGRectGetWidth(bounds) - (20 + imageSize.width + 16) * (self.titleAlignmentCenter + 1), CGRectGetHeight(bounds));
    CGSize titleSize = [[self titleLabel] sizeThatFits:fitSize];
    CGFloat titleY = (CGRectGetHeight(bounds) - titleSize.height) / 2.;
    CGFloat titleX = self.titleAlignmentCenter ? (CGRectGetWidth(bounds) - titleSize.width) / 2. : ((imageSize.width ? 20 : 0) + imageSize.width + 16);
    
    self.titleLabel.frame = (CGRect){titleX, titleY, titleSize};
}

- (void)_updateContentView;{
    self.iconImageView.image = [[self action] image];
    self.titleLabel.text = [[self action] title];
    
    self.titleLabel.font = [[self action] font] ?: ([[self action] style] == MDAlertActionStyleCancel ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14]);
    self.titleLabel.textColor = [[self action] color] ?: self.tintColor;
    
    self.contentView.backgroundColor = [[self action] backgroundColor];
    
    self.userInteractionEnabled = [[self action] isEnabled];
}

#pragma mark - accessor

- (void)setAction:(MDAlertAction *)action{
    if (_action != action) {
        _action = action;
        
        [self _updateContentView];
    }
}

- (void)setTitleAlignmentCenter:(BOOL)titleAlignmentCenter{
    _titleAlignmentCenter = titleAlignmentCenter;
    
    [self setNeedsLayout];
}

@end

@implementation _MDAlertControllerCheckCell

#pragma mark - private

- (void)_createSubviews{
    [super _createSubviews];
    _selectedImageView = [UIImageView new];
    
    [[self contentView] addSubview:[self selectedImageView]];
}

- (void)_layoutSubviews{
    [super _layoutSubviews];
    
    CGRect bounds = [[self contentView] bounds];
    CGSize imageSize = [[[self iconImageView] image] size];
    CGFloat imageX = CGRectGetWidth(bounds) - imageSize.width - 12;
    CGFloat imageY = (CGRectGetHeight(bounds) - imageSize.height) / 2.;
    
    self.selectedImageView.frame = (CGRect){imageX, imageY, imageSize};
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
 
    self.selectedImageView.image = selected ? [[self action] selectedImage] : nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    
    self.selectedImageView.image = selected ? [[self action] selectedImage] : nil;
}

@end

@implementation _MDAlertControllerDestructiveFooterView

- (instancetype)initWithFrame:(CGRect)frame action:(MDAlertAction *)action{
    if (self = [super initWithFrame:frame]) {
        _action = action;
        _titleLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 5, frame.size.width, frame.size.height - 5}];
    
        self.backgroundColor = HEXCOLOR(0xE7E7E7);
        
        self.titleLabel.text = [action title];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [action font] ?: [UIFont systemFontOfSize:15];
        self.titleLabel.textColor = [action color] ?: [self tintColor];
        self.titleLabel.backgroundColor = [action backgroundColor] ?: [UIColor whiteColor];
        
        [self addSubview:[self titleLabel]];
    }
    return self;
}

- (void)tintColorDidChange{
    [super tintColorDidChange];
    
    self.titleLabel.textColor = [self tintColor];
}

@end

@implementation _MDAlertControllerTextLabel

- (CGSize)sizeThatFits:(CGSize)size{
    if (![[self text] length] || ![[self attributedText] length]) return CGSizeZero;
    
    CGSize result = [super sizeThatFits:size];
    result.height += 16;
    
    return result;
}

- (CGSize)intrinsicContentSize{
    if (![[self text] length] || ![[self attributedText] length]) return CGSizeZero;
    
    CGSize size = [super intrinsicContentSize];
    size.height += 16;
    
    return size;
}

@end

@implementation MDAlertControllerContentView
@synthesize delegate, actions = _actions, preferredAction;
@synthesize backgroundView = _backgroundView, titleLabel = _titleLabel, messageLabel = _messageLabel;

@dynamic tintColor;

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self _createSubviews];
        [self _initializeSubviews];
        [self _layoutSubviews];
    }
    return self;
}

- (void)tintColorDidChange{
    [super tintColorDidChange];
    
    self.titleLabel.textColor = self.tintColor;
    self.messageLabel.textColor = self.tintColor;
    
    self.tableView.separatorColor = self.tintColor;
    self.tableView.tableFooterView.tintColor = self.tintColor;
    
    [[self tableView] reloadData];
}

#pragma mark - accessor

- (NSArray<MDAlertAction *> *)actions{
    if (!_actions) {
        _actions = @[];
    }
    return _actions;
}

#pragma mark - private

- (void)_createSubviews{
    _backgroundView = [UIView new];
    _contentView = [UIView new];
    _titleLabel = [_MDAlertControllerTextLabel new];
    _messageLabel = [_MDAlertControllerTextLabel new];
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBackgroundView:)];
    
    [self addSubview:[self backgroundView]];
    [self addSubview:[self contentView]];
    
    [[self contentView] addSubview:[self titleLabel]];
    [[self contentView] addSubview:[self messageLabel]];
    [[self contentView] addSubview:[self tableView]];
    
    [[self backgroundView] addGestureRecognizer:[self tapGestureRecognizer]];
}

- (void)_initializeSubviews{
    self.contentView.backgroundColor = [UIColor whiteColor];
    
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
    
    self.tableView.tableFooterView = [UIView new];
    
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [[self tableView] registerClass:[_MDAlertControllerCell class] forCellReuseIdentifier:NSStringFromClass([_MDAlertControllerCell class])];
    [[self tableView] registerClass:[_MDAlertControllerCheckCell class] forCellReuseIdentifier:NSStringFromClass([_MDAlertControllerCheckCell class])];
}

- (void)_layoutSubviews{
    self.backgroundView.frame = [self bounds];
}

- (void)_respondSelectAction:(MDAlertAction *)action {
    if ([[self delegate] respondsToSelector:@selector(contentView:didSelectAction:)]) {
        [[self delegate] contentView:self didSelectAction:action];
    }
}

#pragma mark - public

- (void)reload{}

- (void)displayAnimated:(BOOL)animated completion:(void (^)(void))completion;{
    [self displayWithAnimation:nil completion:nil];
}

- (void)displayWithAnimation:(CAAnimation *)animation completion:(void (^)(void))completion{
    if (animation) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @(0.f);
        opacityAnimation.toValue = @(1.f);
        opacityAnimation.duration = animation.duration * MAX(animation.repeatCount, 1);
        opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        animation.delegate = self;
        self.animatedCompletion = completion;
        
        [[[self contentView] layer] addAnimation:animation forKey:@"content.view.animation.display"];
        [[[self backgroundView] layer] addAnimation:opacityAnimation forKey:@"background.view.animation.opacity.display"];
    } else {
        if (completion) completion();
    }
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;{
    [self dismissWithAnimation:nil completion:nil];
}

- (void)dismissWithAnimation:(CAAnimation *)animation completion:(void (^)(void))completion;{
    if (animation) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.toValue = @(0.f);
        opacityAnimation.duration = animation.duration * MAX(animation.repeatCount, 1);
        opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        animation.delegate = self;
        self.animatedCompletion = completion;
        
        [[[self contentView] layer] addAnimation:animation forKey:@"content.view.animation.dismiss"];
        [[[self backgroundView] layer] addAnimation:opacityAnimation forKey:@"background.view.animation.opacity.dismiss"];
    } else {
        if (completion) completion();
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self actions] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return MDAlertControllerRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MDAlertAction *action = [self actions][[indexPath row]];
    Class cellClass = [action selectedImage] ? [_MDAlertControllerCheckCell class] : [_MDAlertControllerCell class];
    
    _MDAlertControllerCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass)];
    cell.action = action;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MDAlertAction *action = [self actions][[indexPath row]];
    
    [self _respondSelectAction:action];
}

#pragma mark - actions

- (IBAction)didTapBackgroundView:(UITapGestureRecognizer *)tapGestureRecognizer{
    if ([[self delegate] respondsToSelector:@selector(contentViewDidCancel:)]) {
        [[self delegate] contentViewDidCancel:self];
    }
}

- (IBAction)didClickDestructFooterView:(_MDAlertControllerDestructiveFooterView *)footerView{
    [self _respondSelectAction:[footerView action]];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag;{
    void (^completion)(void) = self.animatedCompletion;
    
    if (completion) dispatch_async(dispatch_get_main_queue(), completion);
}

@end

@implementation MDActionSheetContentView

#pragma mark - private

- (void)_layoutSubviews{
    [super _layoutSubviews];
    
    CGFloat height = ([self preferredAction] ? MDAlertControllerDestructiveFooterViewHeight : 0) + ([[self actions] count] * MDAlertControllerRowHeight);
    CGFloat titleHeight = [[self titleLabel] sizeThatFits:CGSizeMake(CGRectGetWidth([self bounds]), CGFLOAT_MAX)].height;
    CGFloat messageHeight = [[self messageLabel] sizeThatFits:CGSizeMake(CGRectGetWidth([self bounds]), CGFLOAT_MAX)].height;
    CGFloat tableViewHeight = MIN(CGRectGetHeight([self bounds]) - titleHeight - messageHeight, height);;
    
    CGFloat contentWidth = CGRectGetWidth([self bounds]);
    CGFloat contentHeight = titleHeight + messageHeight + tableViewHeight;
    CGFloat contentY = CGRectGetHeight([self bounds]) - contentHeight;
    
    self.contentView.frame = (CGRect){0, contentY, contentWidth, contentHeight};
    self.titleLabel.frame = (CGRect){0, 0, contentWidth, titleHeight};
    self.messageLabel.frame = (CGRect){0, titleHeight, contentWidth, messageHeight};
    self.tableView.frame = (CGRect){0, titleHeight + messageHeight, contentWidth, tableViewHeight};
}

#pragma mark - public

- (void)reload;{
    [self _layoutSubviews];
    
    _MDAlertControllerDestructiveFooterView *footerView = nil;
    if ([self preferredAction]) {
        footerView = [[_MDAlertControllerDestructiveFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([self bounds]), MDAlertControllerDestructiveFooterViewHeight) action:[self preferredAction]];
        
        [footerView addTarget:self action:@selector(didClickDestructFooterView:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.tableView.tableFooterView = footerView;
    
    [[self tableView] reloadData];
    
    [[self actions] enumerateObjectsUsingBlock:^(MDAlertAction *action, NSUInteger index, BOOL *stop) {
        if (![action isSelected]) return;
        [[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }];
}

- (void)displayAnimated:(BOOL)animated completion:(void (^)(void))completion;{
    if (animated) {
        CGRect contentFrame = self.contentView.frame;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        animation.fromValue = @(CGRectGetHeight([self bounds]) + CGRectGetHeight(contentFrame) / 2.);
        animation.toValue = @(CGRectGetHeight([self bounds]) - CGRectGetHeight(contentFrame) / 2.);
        
        animation.duration = MDAlertControllerPresentAnimationDuration;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        [self displayWithAnimation:animation completion:completion];
    } else {
        [self displayWithAnimation:nil completion:completion];
    }
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion{
    if (animated) {
        CGRect contentFrame = self.contentView.frame;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        animation.fromValue = @(CGRectGetHeight([self bounds]) - CGRectGetHeight(contentFrame) / 2.);
        animation.toValue = @(CGRectGetHeight([self bounds]) + CGRectGetHeight(contentFrame) / 2.);
        
        animation.duration = MDAlertControllerPresentAnimationDuration;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        [self dismissWithAnimation:animation completion:completion];
    } else {
        [self dismissWithAnimation:nil completion:completion];
    }
}

@end

@implementation MDAlertContentView

- (void)tintColorDidChange{
    [super tintColorDidChange];
    
    self.lineView.backgroundColor = self.tintColor;
    
    [[self lines] setValue:self.tintColor forKey:@"backgroundColor"];
    
    for (UIButton *button in _buttons) {
        [button setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
}

#pragma mark - private

- (void)_createSubviews{
    [super _createSubviews];
    
    self.buttons = [NSMutableArray new];
    self.lines = [NSMutableArray new];
    self.buttonContentView = [UIView new];
    self.lineView = [UIView new];
    
    [[self contentView] addSubview:[self buttonContentView]];
    [[self contentView] addSubview:[self lineView]];
}

- (void)_initializeSubviews{
    [super _initializeSubviews];
    
    self.contentView.layer.cornerRadius = 10.f;
    self.contentView.layer.masksToBounds = YES;
    
    self.lineView.backgroundColor = self.tintColor;
}

- (void)_layoutSubviews{
    [super _layoutSubviews];
    
    CGFloat titleHeight = [[self titleLabel] sizeThatFits:CGSizeMake(CGRectGetWidth([self bounds]), CGFLOAT_MAX)].height;
    CGFloat messageHeight = [[self messageLabel] sizeThatFits:CGSizeMake(CGRectGetWidth([self bounds]), CGFLOAT_MAX)].height;
    
    BOOL needsButtonContent = [[self actions] count] <= 2;
    CGFloat actionContentHeight = (needsButtonContent ? 1 : [[self actions] count]) * MDAlertControllerRowHeight;
    
    CGFloat contentWidth = CGRectGetWidth([self bounds]) * .75f;
    CGFloat contentHeight = titleHeight + messageHeight + actionContentHeight;
    CGFloat contentX = (CGRectGetWidth([self bounds]) - contentWidth) / 2.f;
    CGFloat contentY = (CGRectGetHeight([self bounds]) - contentHeight) / 2.f;
    
    UIView *actionContentView = needsButtonContent ? [self buttonContentView] : [self tableView];
    actionContentView.frame = (CGRect){0, titleHeight + messageHeight, contentWidth, actionContentHeight};
    
    self.contentView.frame = (CGRect){contentX, contentY, contentWidth, contentHeight};
    self.titleLabel.frame = (CGRect){0, 0, contentWidth, titleHeight};
    self.messageLabel.frame = (CGRect){0, titleHeight, contentWidth, messageHeight};
    self.lineView.frame = (CGRect){0, titleHeight + messageHeight, contentWidth, .5f};
    
    if (needsButtonContent) {
        [[self buttons] enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger index, BOOL *stop) {
            [self _layoutButton:button atIndex:index];
        }];
        [[self lines] enumerateObjectsUsingBlock:^(UIView *line, NSUInteger index, BOOL *stop) {
            [self _layoutLine:line atIndex:index];
        }];
    }
}

- (void)_reloadButtonContentView{
    [[[self actions] copy] enumerateObjectsUsingBlock:^(MDAlertAction *action, NSUInteger index, BOOL *stop) {
        UIButton *button = [self _buttonWithAction:action atIndex:index];
        UIView *line = index == ([[self actions] count] - 1) ? nil : [UIView new];
        line.backgroundColor = [self tintColor];
        
        [[self buttons] addObject:button];
        [[self buttonContentView] addSubview:button];
        [self _layoutButton:button atIndex:index];
        
        if (line) {
            [[self lines] addObject:line];
            [[self buttonContentView] addSubview:line];
            [self _layoutLine:line atIndex:index];
        }
    }];
}

- (void)_layoutButton:(UIButton *)button atIndex:(NSUInteger)index{
    CGRect bounds = [[self buttonContentView] bounds];
    CGFloat width = CGRectGetWidth(bounds) / [[self actions] count];
    
    button.frame = (CGRect){index * width, 0, width, bounds.size.height};
}

- (void)_layoutLine:(UIView *)line atIndex:(NSUInteger)index{
    CGRect bounds = self.buttonContentView.bounds;
    CGFloat width = bounds.size.width / self.actions.count;
    
    line.frame = (CGRect){(index + 1) * width, 0, .5f, bounds.size.height};
}

- (UIButton *)_buttonWithAction:(MDAlertAction *)action atIndex:(NSUInteger)index{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    button.tag = index;
    button.enabled = [action isEnabled];
    button.selected = [action isSelected];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.backgroundColor = [action backgroundColor];
    
    UIFont *titleFont = [action font] ?: (action == [self preferredAction] ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14]);
    button.titleLabel.font = titleFont;
    
    [button setTitle:[action title] forState:UIControlStateNormal];
    [button setImage:[action image] forState:UIControlStateNormal];
    [button setImage:[action selectedImage] forState:UIControlStateSelected];
    
    UIColor *titleColor = [action color] ?: (action == [self preferredAction] ? HEXCOLOR(0x505050) : HEXCOLOR(0x212121));
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)_reloadTableView{
    [[self tableView] reloadData];
    
    [[self actions] enumerateObjectsUsingBlock:^(MDAlertAction *action, NSUInteger index, BOOL *stop) {
        if (![action isSelected]) return;
        
        [[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }];
}

#pragma mark - public

- (void)reload;{
    [self _layoutSubviews];
    
    for (UIView *view in [[self buttonContentView] subviews]) [view removeFromSuperview];
    
    [[self buttons] removeAllObjects];
    [[self lines] removeAllObjects];
    
    self.buttonContentView.hidden = [[self actions] count] > 2;
    self.lineView.hidden = [[self actions] count] > 2;
    self.tableView.hidden = [[self actions] count] <= 2;
    
    if ([[self actions] count] <= 2) {
        [self _reloadButtonContentView];
    } else {
        [self _reloadTableView];
    }
}

- (void)displayAnimated:(BOOL)animated completion:(void (^)(void))completion{
    if (animated) {
        CGFloat height = CGRectGetHeight([self bounds]);
        CGRect contentFrame = [[self contentView] frame];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        animation.fromValue = @(-CGRectGetHeight(contentFrame) / 2.);
        animation.toValue = @((height - CGRectGetHeight(contentFrame)) / 2.);
        
        animation.duration = MDAlertControllerPresentAnimationDuration;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        [self displayWithAnimation:animation completion:completion];
    } else {
        [self displayWithAnimation:nil completion:completion];
    }
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion{
    if (animated) {
        CGFloat height = CGRectGetHeight([self bounds]);
        CGRect contentFrame = [[self contentView] frame];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        animation.toValue = @(height + CGRectGetHeight(contentFrame) / 2.);
        
        animation.duration = MDAlertControllerPresentAnimationDuration;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        [self dismissWithAnimation:animation completion:completion];
    } else {
        [self dismissWithAnimation:nil completion:completion];
    }
}

#pragma mark - actions

- (IBAction)didClickButton:(UIButton *)sender{
    NSUInteger index = [sender tag];
    MDAlertAction *action = self.actions[index];
    
    [self _respondSelectAction:action];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MDAlertAction *action = [self actions][[indexPath row]];
    _MDAlertControllerCell *cell = (id)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.titleAlignmentCenter = YES;
    cell.titleLabel.font = action == [self preferredAction] ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14];
    
    return cell;
}

@end

@implementation MDAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler;{
    return [self actionWithTitle:title image:nil style:style handler:handler];
}

+ (instancetype)actionWithTitle:(NSString *)title image:(UIImage *)image style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler;{
    return [[self alloc] initWithTitle:title image:image style:style handler:handler];
}

+ (instancetype)cancelActionWithTitle:(NSString *)title;{
    return [self cancelActionWithTitle:title image:nil];
}

+ (instancetype)cancelActionWithTitle:(NSString *)title image:(UIImage *)image;{
    return [[self alloc] initWithTitle:title image:image style:MDAlertActionStyleCancel handler:nil];
}

+ (instancetype)destructiveActionWithTitle:(NSString *)title;{
    return [self destructiveActionWithTitle:title image:nil];
}

+ (instancetype)destructiveActionWithTitle:(NSString *)title image:(UIImage *)image;{
    return [[self alloc] initWithTitle:title image:image style:MDAlertActionStyleDestructive handler:nil];
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler;{
    if (self = [super init]) {
        self.enabled = YES;
        
        self.title = title;
        self.image = image;
        self.style = style;
        self.handler = handler;
    }
    return self;
}

@end

@implementation MDAlertController
@dynamic title;

- (instancetype)init{
    return [self initWithTitle:nil message:nil preferredStyle:MDAlertControllerStyleActionSheet];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    return [self initWithTitle:nil message:nil preferredStyle:MDAlertControllerStyleAlert];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    return [self initWithTitle:nil message:nil preferredStyle:MDAlertControllerStyleAlert];
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(MDAlertControllerStyle)preferredStyle;{
    return [[self alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(MDAlertControllerStyle)preferredStyle;{
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.preferredStyle = preferredStyle;
        
        self.title = title;
        self.message = message;
        self.backgroundColor = HEXACOLOR(0x000000, 0.5);
        self.backgroundTouchabled = preferredStyle == MDAlertControllerStyleActionSheet;
        
        self.backgroundTouchabled = YES;
        
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)loadView{
    [super loadView];
    [[self view] addSubview:[self contentView]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self _reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    dispatch_once(&_onceToken, ^{
        [self _displayAnimated:animated];
    });
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    [[self contentView] _layoutSubviews];
}

#pragma mark - accessor

- (UIView<MDAlertControllerContentView> *)contentView{
    if (!_contentView) {
        _contentView = [self preferredStyle] == MDAlertControllerStyleActionSheet ? [MDActionSheetContentView new] : [MDAlertContentView new];
        _contentView.delegate = self;
    }
    return _contentView;
}

- (NSArray<MDAlertAction *> *)actions{
    if (!_actions) {
        _actions = @[];
    }
    return _actions;
}

- (NSArray<MDAlertAction *> *)rowActions{
    if (!_rowActions) {
        _rowActions = @[];
    }
    return _rowActions;
}

- (void)setPreferredAction:(MDAlertAction *)preferredAction{
    if (_preferredAction != preferredAction) {
        NSMutableArray *actions = [[self actions] mutableCopy];
        [actions removeObject:_preferredAction];
        
        self.actions = [actions copy];
        
        if (preferredAction) {
            self.actions = [[self actions] arrayByAddingObject:preferredAction];
        }
        _preferredAction = preferredAction;
        
        if ([self isViewLoaded]) {
            [self _reloadData];
        }
    }
}

- (NSString *)title{
    return _alertTitle;
}

- (void)setTitle:(NSString *)title{
    if (_alertTitle != title) {
        _alertTitle = [title copy];
        
        if ([self isViewLoaded]) {
            self.contentView.titleLabel.text = title;
        }
    }
}

- (void)setMessage:(NSString *)message{
    if (_message != message) {
        _message = [message copy];
        
        if ([self isViewLoaded]) {
            self.contentView.messageLabel.text = message;
        }
    }
}

- (void)setTintColor:(UIColor *)tintColor{
    if (_tintColor != tintColor) {
        _tintColor = tintColor;
        
        [self _updateView:self.view tintColor:tintColor];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = backgroundColor;
        
        self.contentView.backgroundView.backgroundColor = backgroundColor;
    }
}

#pragma mark - private

- (void)_updateView:(UIView *)view tintColor:(UIColor *)tintColor{
    view.tintColor = tintColor;
    
    for (UIView *subview in view.subviews) {
        [self _updateView:subview tintColor:tintColor];
    }
}

- (void)_reloadData{
    self.contentView.frame = self.view.bounds;
    self.contentView.titleLabel.text = self.title;
    self.contentView.messageLabel.text = self.message;
    self.contentView.backgroundView.backgroundColor = self.backgroundColor;
    self.contentView.backgroundView.userInteractionEnabled = self.backgroundTouchabled;
    
    self.contentView.preferredAction = [self preferredAction];
    self.contentView.actions = [self preferredStyle] == MDAlertControllerStyleActionSheet ? [self rowActions] : [self actions];
    
    [[self contentView] reload];
}

- (void)_displayAnimated:(BOOL)animated{
    if (animated && [self presentingAnimation]) {
        [[self contentView] displayWithAnimation:[self presentingAnimation] completion:nil];
    } else {
        [[self contentView] displayAnimated:animated completion:nil];
    }
}

- (void)_dismissAnimated:(BOOL)animated action:(MDAlertAction *)action{
    void (^completion)(void) = ^{
        [self dismissViewControllerAnimated:NO completion:^{
            if ([action handler]) action.handler(action);
        }];
    };
    if (animated && [self dismissingAnimation]) {
        [[self contentView] dismissWithAnimation:[self dismissingAnimation] completion:completion];
    } else {
        [[self contentView] dismissAnimated:animated completion:completion];
    }
}

#pragma mark - public

- (void)addAction:(MDAlertAction *)action;{
    NSParameterAssert(action);
    NSParameterAssert(![[self actions] containsObject:action]);
    NSParameterAssert([action style] != MDAlertActionStyleDestructive || ![self preferredAction]);
    
    if ([action style] != MDAlertActionStyleDestructive) {
        self.rowActions = [[self rowActions] arrayByAddingObject:action];
        self.actions = [[self actions] arrayByAddingObject:action];
    } else {
        self.preferredAction = action;
    }
}

#pragma mark - MDAlertControllerContentViewDelegate

- (void)contentViewDidCancel:(UIView<MDAlertControllerContentView> *)contentView;{
    [self _dismissAnimated:YES action:nil];
}

- (void)contentView:(UIView<MDAlertControllerContentView> *)contentView didSelectAction:(MDAlertAction *)action;{
    [self _dismissAnimated:YES action:action];
}

@end
