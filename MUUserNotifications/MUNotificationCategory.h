//
//  MUNotificationCategory.h
//  MUNotifications
//
//  Created by Muer on 16/7/26.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, MUNotificationCategoryOptions) {
    MUNotificationCategoryOptionNone                = 0,
    
    /** Whether dismiss action should be sent to the MUUserNotificationCenter delegate */
    MUNotificationCategoryOptionCustomDismissAction = 1 << 0,
    
    /** Whether notifications of this category should be allowed in CarPlay */
    MUNotificationCategoryOptionAllowInCarPlay      = 2 << 0,
} NS_AVAILABLE_IOS(10_0);

@class MUNotificationAction;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Defines the types of notifications your app supports and the custom actions displayed for each type. Equivalent to UNNotificationCategory or UIUserNotificationCategory
 */
NS_CLASS_AVAILABLE_IOS(8_0)
@interface MUNotificationCategory : NSObject <NSCopying, NSSecureCoding>

/** Creates and returns a category object containing the specified actions and options */
+ (instancetype)categoryWithIdentifier:(NSString *)identifier actions:(NSArray<MUNotificationAction *> *)actions;

/** Creates and returns a category object containing the specified actions and options */
+ (instancetype)categoryWithIdentifier:(NSString *)identifier actions:(NSArray<MUNotificationAction *> *)actions intentIdentifiers:(nullable NSArray<NSString *> *)intentIdentifiers options:(MUNotificationCategoryOptions)options NS_AVAILABLE_IOS(10_0);

- (instancetype)init NS_UNAVAILABLE;

/** The unique string assigned to the category */
@property (nonatomic, readonly) NSString *identifier;

/** The actions to display when a notification of this type is presented */
@property (nonatomic, readonly) NSArray<MUNotificationAction *> *actions;

/** Options for how to handle notifications of this type */
@property (nonatomic, readonly) MUNotificationCategoryOptions options NS_AVAILABLE_IOS(10_0);

/** The intents supported support for notifications of this category. See <Intents/INIntentIdentifiers.h> for possible values */
@property (nonatomic, readonly, nullable) NSArray<NSString *> *intentIdentifiers NS_AVAILABLE_IOS(10_0);

@end

NS_ASSUME_NONNULL_END
