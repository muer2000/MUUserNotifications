//
//  MUNotificationAction.h
//  MUNotifications
//
//  Created by Muer on 16/7/26.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, MUNotificationActionOptions) {
    MUNotificationActionOptionNone                      = 0,
    MUNotificationActionOptionAuthenticationRequired    = 1 << 0,
    MUNotificationActionOptionDestructive               = 1 << 1,
    MUNotificationActionOptionForeground                = 1 << 2,
};

NS_ASSUME_NONNULL_BEGIN

NS_CLASS_AVAILABLE_IOS(8_0)
@interface MUNotificationAction : NSObject <NSCopying, NSSecureCoding>

+ (instancetype)actionWithIdentifier:(NSString *)identifier title:(NSString *)title options:(MUNotificationActionOptions)options;

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *title;

@property (nonatomic, readonly) MUNotificationActionOptions options;

@end

NS_CLASS_AVAILABLE_IOS(9_0)
@interface MUTextInputNotificationAction : MUNotificationAction

+ (instancetype)actionWithIdentifier:(NSString *)identifier title:(NSString *)title options:(MUNotificationActionOptions)options textInputButtonTitle:(nullable NSString *)textInputButtonTitle;

+ (instancetype)actionWithIdentifier:(NSString *)identifier title:(NSString *)title options:(MUNotificationActionOptions)options textInputButtonTitle:(nullable NSString *)textInputButtonTitle textInputPlaceholder:(nullable NSString *)textInputPlaceholder NS_AVAILABLE_IOS(10_0);

@property (nonatomic, readonly) NSString *textInputButtonTitle;
@property (nonatomic, readonly) NSString *textInputPlaceholder NS_AVAILABLE_IOS(10_0);

@end

NS_ASSUME_NONNULL_END
