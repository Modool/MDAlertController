//
//  MDAlertController.h
//  MDAlertController
//
//  Created by xulinfeng on 2018/3/21.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MDAlertActionStyle) {
    MDAlertActionStyleDefault = 0,
    MDAlertActionStyleCancel,
    MDAlertActionStyleDestructive
};

typedef NS_ENUM(NSUInteger, MDAlertActionPosition) {
    MDAlertActionPositionLeft  = 1 << 0,
    MDAlertActionPositionRight = 1 << 1,
    MDAlertActionPositionTop   = 1 << 2,
    MDAlertActionPositionBottom = 1 << 3,

    MDAlertActionPositionLeftTop = MDAlertActionPositionLeft | MDAlertActionPositionTop,
    MDAlertActionPositionLeftBottom = MDAlertActionPositionLeft | MDAlertActionPositionBottom,
    MDAlertActionPositionRightTop = MDAlertActionPositionRight | MDAlertActionPositionTop,
    MDAlertActionPositionRightBottom = MDAlertActionPositionRight | MDAlertActionPositionBottom,

    MDAlertActionPositionHorizontalCenter = MDAlertActionPositionLeft | MDAlertActionPositionRight,
    MDAlertActionPositionVerticalCenter = MDAlertActionPositionTop | MDAlertActionPositionBottom,
    MDAlertActionPositionCenter = MDAlertActionPositionHorizontalCenter | MDAlertActionPositionVerticalCenter
};

@interface MDAlertAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler;
+ (instancetype)actionWithTitle:(NSString *)title image:(UIImage *)image style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler;

+ (instancetype)cancelActionWithTitle:(NSString *)title;
+ (instancetype)cancelActionWithTitle:(NSString *)title image:(UIImage *)image;

+ (instancetype)destructiveActionWithTitle:(NSString *)title;
+ (instancetype)destructiveActionWithTitle:(NSString *)title image:(UIImage *)image;

@property (nonatomic, assign, readonly) MDAlertActionStyle style;

@property (nonatomic, copy, readonly) NSString *title;

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong) UIImage *selectedImage;

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, assign, getter=isSelected) BOOL selected;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *color;

/** Default is left, disabled for alert. */
@property (nonatomic, assign) NSTextAlignment titleAlignment;

@property (nonatomic, strong) UIColor *backgroundColor;

@end

@interface MDAlertDismissAction : MDAlertAction

@property (nonatomic, assign, readonly) MDAlertActionPosition position;

/** Default is 'sizeToFit'. */
@property (nonatomic, assign) CGSize size;

@property (nonatomic, strong) UIImage *selectedImage NS_UNAVAILABLE;

@property (nonatomic, assign, getter=isEnabled) BOOL enabled NS_UNAVAILABLE;
@property (nonatomic, assign, getter=isSelected) BOOL selected NS_UNAVAILABLE;

+ (instancetype)actionWithTitle:(NSString *)title style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler NS_UNAVAILABLE;
+ (instancetype)actionWithTitle:(NSString *)title image:(UIImage *)image style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler NS_UNAVAILABLE;

+ (instancetype)actionWithTitle:(NSString *)title position:(MDAlertActionPosition)position handler:(void (^)(MDAlertAction *action))handler;
+ (instancetype)actionWithImage:(UIImage *)image position:(MDAlertActionPosition)position handler:(void (^)(MDAlertAction *action))handler;

@end

typedef NS_ENUM(NSUInteger, MDAlertControllerStyle) {
    MDAlertControllerStyleActionSheet = 0,
    MDAlertControllerStyleAlert
};

typedef NS_OPTIONS(unsigned long long, MDAlertControllerAnimationOptions) {
    MDAlertControllerAnimationOptionCurveEaseInOut            = 0 << 16, // default
    MDAlertControllerAnimationOptionCurveEaseIn               = 1 << 16,
    MDAlertControllerAnimationOptionCurveEaseOut              = 2 << 16,
    MDAlertControllerAnimationOptionCurveLinear               = 3 << 16,

    MDAlertControllerAnimationOptionTransitionNone            = 0 << 20, // default
    MDAlertControllerAnimationOptionTransitionFlipFromLeft    = 1 << 20,
    MDAlertControllerAnimationOptionTransitionFlipFromRight   = 2 << 20,
    MDAlertControllerAnimationOptionTransitionCurlUp          = 3 << 20,
    MDAlertControllerAnimationOptionTransitionCurlDown        = 4 << 20,
    MDAlertControllerAnimationOptionTransitionCrossDissolve   = 5 << 20,
    MDAlertControllerAnimationOptionTransitionFlipFromTop     = 6 << 20,
    MDAlertControllerAnimationOptionTransitionFlipFromBottom  = 7 << 20,

    MDAlertControllerAnimationOptionTransitionMoveIn     = 1 << 24,

    MDAlertControllerAnimationOptionDirectionFromLeft    = 1 << 28,
    MDAlertControllerAnimationOptionDirectionFromRight   = 2 << 28,
    MDAlertControllerAnimationOptionDirectionFromTop     = 3 << 28,
    MDAlertControllerAnimationOptionDirectionFromBottom  = 4 << 28,
};

@interface MDAlertController : UIViewController

@property (nonatomic, assign, readonly) MDAlertControllerStyle preferredStyle;

@property (nonatomic, copy, readonly) NSArray<MDAlertAction *> *actions;

@property (nonatomic, strong) MDAlertAction *preferredAction;

/** The custom view in content view. */
@property (nonatomic, strong) UIView *customView;
/** Default is 0x000000, 0.5 */
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, strong) CAAnimation *presentingAnimation;
@property (nonatomic, strong) CAAnimation *dismissingAnimation;

@property (nonatomic, assign) UIEdgeInsets separatorInset;

/**
 Default transition is modal alert or action sheet,
 disabled if style is MDAlertControllerStyleActionSheet.
 */
@property (nonatomic, assign) MDAlertControllerAnimationOptions transitionOptions;

/** Default is .25f, disabled if style is MDAlertControllerStyleActionSheet. */
@property (nonatomic, assign) NSTimeInterval transitionDuration;

/** Default is YES if preferredStyle is MDAlertControllerStyleActionSheet. */
@property (nonatomic, assign, getter=isBackgroundTouchabled) BOOL backgroundTouchabled;

/** Default is NO. */
@property (nonatomic, assign, getter=isOverridable) BOOL overridable;

/** Default is NO to align center. */
@property (nonatomic, assign, getter=isWelt) BOOL welt;

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(MDAlertControllerStyle)preferredStyle;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(MDAlertControllerStyle)preferredStyle NS_DESIGNATED_INITIALIZER;

- (void)addAction:(MDAlertAction *)action;

@end

@interface MDAlertController (Additions)

+ (instancetype)alert;
+ (instancetype)alertNamed:(NSString *)title;
+ (instancetype)alertNamed:(NSString *)title message:(NSString *)message;

+ (instancetype)actionSheet;
+ (instancetype)actionSheetNamed:(NSString *)title;
+ (instancetype)actionSheetNamed:(NSString *)title message:(NSString *)message;

- (instancetype)actionNamed:(NSString *)title;
- (instancetype)actionNamed:(NSString *)title style:(MDAlertActionStyle)style;

- (instancetype)actionNamed:(NSString *)title image:(UIImage *)image;
- (instancetype)actionNamed:(NSString *)title image:(UIImage *)image style:(MDAlertActionStyle)style;

- (instancetype)actionNamed:(NSString *)title handler:(void (^)(MDAlertAction *action))handler;
- (instancetype)actionNamed:(NSString *)title style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler;

- (instancetype)actionNamed:(NSString *)title image:(UIImage *)image handler:(void (^)(MDAlertAction *action))handler;
- (instancetype)actionNamed:(NSString *)title image:(UIImage *)image style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler;

@end

