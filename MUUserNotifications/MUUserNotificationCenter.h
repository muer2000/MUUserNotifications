//
//  MUUserNotificationCenter.h
//  MUNotifications
//
//  Created by Muer on 16/7/14.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MUNotification;
@class MUNotificationResponse;
@class MUNotificationCategory;
@class MUNotificationRequest;

@protocol MUUserNotificationCenterDelegate;

typedef NS_ENUM(NSInteger, MUUNAuthorizationStatus) {
    MUUNAuthorizationStatusNotDetermined = 0,
    MUUNAuthorizationStatusDenied,
    MUUNAuthorizationStatusAuthorized
};

typedef NS_OPTIONS(NSUInteger, MUUNAuthorizationOptions) {
    MUUNAuthorizationOptionNone     = 0,
    MUUNAuthorizationOptionBadge    = 1 << 0,
    MUUNAuthorizationOptionSound    = 1 << 1,
    MUUNAuthorizationOptionAlert    = 1 << 2,
    MUUNAuthorizationOptionCarPlay  = 1 << 3
};

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@class UNNotificationSettings;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MUUserNotificationCenter : NSObject

+ (MUUNAuthorizationStatus)authorizationStatus;
+ (MUUNAuthorizationOptions)authorizationOptions;

+ (void)registerRemoteNotifications;
+ (BOOL)isRegisteredForRemoteNotifications;

+ (MUUserNotificationCenter *)currentNotificationCenter;

- (instancetype)init NS_UNAVAILABLE;

- (void)registerForRemoteNotifications;

- (void)requestAuthorizationWithOptions:(MUUNAuthorizationOptions)options categories:(nullable NSSet<MUNotificationCategory *> *)categories completionHandler:(void (^)(BOOL granted, NSError *__nullable error))completionHandler NS_AVAILABLE_IOS(8_0);

- (void)addNotificationRequest:(MUNotificationRequest *)request withCompletionHandler:(nullable void(^)(NSError *__nullable error))completionHandler;

- (nullable NSArray<MUNotificationRequest *> *)pendingNotificationRequests;
- (void)removePendingNotificationRequestsWithIdentifiers:(NSArray<NSString *> *)identifiers;
- (void)removeAllPendingNotificationRequests;

- (nullable NSArray<MUNotification *> *)deliveredNotifications NS_AVAILABLE_IOS(10_0);
- (void)removeDeliveredNotificationsWithIdentifiers:(NSArray<NSString *> *)identifiers NS_AVAILABLE_IOS(10_0);
- (void)removeAllDeliveredNotifications NS_AVAILABLE_IOS(10_0);

@property (nonatomic, readonly) NSSet<MUNotificationCategory *> *categories;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic, readonly) UNNotificationSettings *settings NS_AVAILABLE_IOS(10_0);
#endif

@property (nonatomic, weak, nullable) id <MUUserNotificationCenterDelegate> delegate;

@end


typedef NS_OPTIONS(NSUInteger, MUNotificationPresentationOptions) {
    MUNotificationPresentationOptionNone    = 0,
    MUNotificationPresentationOptionBadge   = 1 << 0,
    MUNotificationPresentationOptionSound   = 1 << 1,
    MUNotificationPresentationOptionAlert   = 1 << 2,
} NS_AVAILABLE_IOS(10_0);

@protocol MUUserNotificationCenterDelegate <NSObject>

@optional

// foreground (application:didReceiveLocalNotification, application:didReceiveRemoteNotification...) and userNotificationCenter:willPresentNotification:withCompletionHandler:
- (void)mu_userNotificationCenter:(MUUserNotificationCenter *)center willPresentNotification:(MUNotification *)notification;

// background (application:didReceiveLocalNotification, application:didReceiveRemoteNotification...), application:handleActionWithIdentifier... and userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:
- (void)mu_userNotificationCenter:(MUUserNotificationCenter *)center didReceiveNotificationResponse:(MUNotificationResponse *)response;

// The block to execute with the presentation option for the notification. MUNotificationPresentationOptions = UNNotificationPresentationOptions
- (void)mu_userNotificationCenter:(MUUserNotificationCenter *)center willPresentNotification:(MUNotification *)notification withCompletionHandler:(void (^)(MUNotificationPresentationOptions options))completionHandler NS_AVAILABLE_IOS(10_0);

// The block to execute when you have finished processing the user’s response. You must execute this block from your method, and should call it as quickly as possible. handle application:handleActionWithIdentifier:completionHandler and userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:
- (void)mu_userNotificationCenter:(MUUserNotificationCenter *)center didReceiveNotificationResponse:(MUNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler NS_AVAILABLE_IOS(8_0);

@end

NS_ASSUME_NONNULL_END
