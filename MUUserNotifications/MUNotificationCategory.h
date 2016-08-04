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
    MUNotificationCategoryOptionCustomDismissAction = 1 << 0,
    MUNotificationCategoryOptionAllowInCarPlay      = 2 << 0,
} NS_AVAILABLE_IOS(10_0);

@class MUNotificationAction;

NS_ASSUME_NONNULL_BEGIN

NS_CLASS_AVAILABLE_IOS(8_0)
@interface MUNotificationCategory : NSObject <NSCopying, NSSecureCoding>

+ (instancetype)categoryWithIdentifier:(NSString *)identifier actions:(NSArray<MUNotificationAction *> *)actions minimalActions:(nullable NSArray<MUNotificationAction *> *)minimalActions;

+ (instancetype)categoryWithIdentifier:(NSString *)identifier actions:(NSArray<MUNotificationAction *> *)actions minimalActions:(nullable NSArray<MUNotificationAction *> *)minimalActions intentIdentifiers:(nullable NSArray<NSString *> *)intentIdentifiers options:(MUNotificationCategoryOptions)options NS_AVAILABLE_IOS(10_0);

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSArray<MUNotificationAction *> *actions;
@property (nonatomic, readonly, nullable) NSArray<MUNotificationAction *> *minimalActions;

@property (nonatomic, readonly) MUNotificationCategoryOptions options NS_AVAILABLE_IOS(10_0);
@property (nonatomic, readonly, nullable) NSArray<NSString *> *intentIdentifiers NS_AVAILABLE_IOS(10_0);

@end

NS_ASSUME_NONNULL_END
