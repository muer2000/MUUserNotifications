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
    
    /** Whether this action should require unlocking before being performed */
    MUNotificationActionOptionAuthenticationRequired    = 1 << 0,
    
    /** Whether this action should be indicated as destructive */
    MUNotificationActionOptionDestructive               = 1 << 1,
    
    /** Whether this action should cause the application to launch in the foreground */
    MUNotificationActionOptionForeground                = 1 << 2,
};

NS_ASSUME_NONNULL_BEGIN

/**
 *  Defines a task to perform in response to a delivered notification. Equivalent to UNNotificationAction or UIUserNotificationAction
 */
NS_CLASS_AVAILABLE_IOS(8_0)
@interface MUNotificationAction : NSObject <NSCopying, NSSecureCoding>

/** Creates an action with the specified title and options */
+ (instancetype)actionWithIdentifier:(NSString *)identifier title:(NSString *)title options:(MUNotificationActionOptions)options;

- (instancetype)init NS_UNAVAILABLE;

/** The unique identifier for this action */
@property (nonatomic, readonly) NSString *identifier;

/** The title to display for this action */
@property (nonatomic, readonly) NSString *title;

/** The options configured for this action */
@property (nonatomic, readonly) MUNotificationActionOptions options;

@end

/**
 *  Defines an action that contains user-specified text. Equivalent to UNTextInputNotificationAction
 */
NS_CLASS_AVAILABLE_IOS(9_0)
@interface MUTextInputNotificationAction : MUNotificationAction

/** Creates and returns an action that accepts text input from the user */
+ (instancetype)actionWithIdentifier:(NSString *)identifier title:(NSString *)title options:(MUNotificationActionOptions)options textInputButtonTitle:(nullable NSString *)textInputButtonTitle;

/** Creates and returns an action that accepts text input from the user */
+ (instancetype)actionWithIdentifier:(NSString *)identifier title:(NSString *)title options:(MUNotificationActionOptions)options textInputButtonTitle:(nullable NSString *)textInputButtonTitle textInputPlaceholder:(nullable NSString *)textInputPlaceholder NS_AVAILABLE_IOS(10_0);

/** The title of the text input button that is displayed to the user */
@property (nonatomic, readonly) NSString *textInputButtonTitle;

/** The placeholder text to display in the text input field */
@property (nonatomic, readonly) NSString *textInputPlaceholder NS_AVAILABLE_IOS(10_0);

@end

NS_ASSUME_NONNULL_END
