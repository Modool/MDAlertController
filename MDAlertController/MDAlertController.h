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

typedef NS_ENUM(NSUInteger, MDAlertControllerStyle) {
    MDAlertControllerStyleActionSheet = 0,
    MDAlertControllerStyleAlert
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

@property (nonatomic, strong, readonly) UIImage *selectedImage;

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, assign, getter=isSelected) BOOL selected;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, strong) UIColor *backgroundColor;

@end

@interface MDAlertController : UIViewController

@property (nonatomic, assign, readonly) MDAlertControllerStyle preferredStyle;

@property (nonatomic, copy, readonly) NSArray<MDAlertAction *> *actions;

@property (nonatomic, strong) MDAlertAction *preferredAction;

// Default is 0x000000, 0.5
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, strong) CAAnimation *presentingAnimation;
@property (nonatomic, strong) CAAnimation *dismissingAnimation;

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

