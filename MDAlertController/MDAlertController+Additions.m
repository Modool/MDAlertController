//
//  MDAlertController+Additions.m
//  MDAlertController
//
//  Created by xulinfeng on 2018/8/24.
//  Copyright © 2018年 Modool. All rights reserved.
//

#import "MDAlertController.h"

@implementation MDAlertController (Additions)

+ (instancetype)alert;{
    return [self alertNamed:nil];
}

+ (instancetype)alertNamed:(NSString *)title;{
    return [self alertNamed:title message:nil];
}

+ (instancetype)alertNamed:(NSString *)title message:(NSString *)message;{
    return [self alertControllerWithTitle:title message:message preferredStyle:MDAlertControllerStyleAlert];
}

+ (instancetype)actionSheet;{
    return [self actionSheetNamed:nil];
}

+ (instancetype)actionSheetNamed:(NSString *)title{
    return [self actionSheetNamed:title message:nil];
}

+ (instancetype)actionSheetNamed:(NSString *)title message:(NSString *)message;{
    return [self alertControllerWithTitle:title message:message preferredStyle:MDAlertControllerStyleActionSheet];
}

- (instancetype)actionNamed:(NSString *)title;{
    return [self actionNamed:title style:MDAlertActionStyleDefault];
}

- (instancetype)actionNamed:(NSString *)title style:(MDAlertActionStyle)style;{
    return [self actionNamed:title style:style handler:nil];
}

- (instancetype)actionNamed:(NSString *)title image:(UIImage *)image;{
    return [self actionNamed:title image:image handler:nil];
}

- (instancetype)actionNamed:(NSString *)title image:(UIImage *)image style:(MDAlertActionStyle)style;{
    return [self actionNamed:title image:image style:style handler:nil];
}

- (instancetype)actionNamed:(NSString *)title handler:(void (^)(MDAlertAction *action))handler;{
    return [self actionNamed:title style:MDAlertActionStyleDefault handler:handler];
}

- (instancetype)actionNamed:(NSString *)title style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler;{
    return [self actionNamed:title image:nil style:style handler:handler];
}

- (instancetype)actionNamed:(NSString *)title image:(UIImage *)image handler:(void (^)(MDAlertAction *action))handler;{
    return [self actionNamed:title image:image style:MDAlertActionStyleDefault handler:handler];
}

- (instancetype)actionNamed:(NSString *)title image:(UIImage *)image style:(MDAlertActionStyle)style handler:(void (^)(MDAlertAction *action))handler;{
    [self addAction:[MDAlertAction actionWithTitle:title image:image style:style handler:handler]];
    
    return self;
}

@end

