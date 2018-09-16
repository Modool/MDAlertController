//
//  MDAlertController.h
//  MDAlertController
//
//  Created by xulinfeng on 2018/3/21.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for MDAlertController.
FOUNDATION_EXPORT double MDAlertControllerVersionNumber;

//! Project version string for MDAlertController.
FOUNDATION_EXPORT const unsigned char MDAlertControllerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MDAlertController/PublicHeader.h>

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

@property (nonatomic, strong) UIColor *backgroundColor;

@end

@interface MDAlertDismissAction : MDAlertAction

@property (nonatomic, assign, readonly) MDAlertActionPosition position;

/// Default is 'sizeToFit'.
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

typedef NS_ENUM(NSInteger, MDAlertControllerTransitionStyle) {
    MDAlertControllerTransitionStyleDefault = 0,

    MDAlertControllerTransitionStyleFade,
    MDAlertControllerTransitionStylePush,
    MDAlertControllerTransitionStyleReveal,
    MDAlertControllerTransitionStyleMoveIn,

    MDAlertControllerTransitionStyleCube,
    MDAlertControllerTransitionStyleFlip,
    MDAlertControllerTransitionStylePageCurl,
    MDAlertControllerTransitionStylePageUnCurl,
    MDAlertControllerTransitionStyleSuckEffect,
    MDAlertControllerTransitionStyleRippleEffect,
    MDAlertControllerTransitionStyleCameraIrisHollowOpen,
    MDAlertControllerTransitionStyleCameraIrisHollowClose,

    MDAlertControllerTransitionStyleMaximum = 0xFF,

    MDAlertControllerTransitionFromLeft  = 1 << 9,
    MDAlertControllerTransitionFromRight  = 1 << 10,
    MDAlertControllerTransitionFromTop = 1 << 11,
    MDAlertControllerTransitionFromBottom = 1 << 12,
};

@interface MDAlertController : UIViewController

@property (nonatomic, assign, readonly) MDAlertControllerStyle preferredStyle;

@property (nonatomic, copy, readonly) NSArray<MDAlertAction *> *actions;

@property (nonatomic, strong) MDAlertAction *preferredAction;

// The custom view in content view.
@property (nonatomic, strong) UIView *customView;
// Default is 0x000000, 0.5
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, strong) CAAnimation *presentingAnimation;
@property (nonatomic, strong) CAAnimation *dismissingAnimation;

/// Default transition is modal alert or action sheet
@property (nonatomic, assign) MDAlertControllerTransitionStyle transitionStyle;
/// Default is .25f;
@property (nonatomic, assign) NSTimeInterval transitionDuration;

// Default is YES if preferredStyle is MDAlertControllerStyleActionSheet.
@property (nonatomic, assign) BOOL backgroundTouchabled;

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

