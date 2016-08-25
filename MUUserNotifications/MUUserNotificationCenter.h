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
    /** The user has not yet made a choice about whether the app is allowed to schedule notifications */
    MUUNAuthorizationStatusNotDetermined = 0,

    /** The app is not authorized to schedule notifications */
    MUUNAuthorizationStatusDenied,

    /** The app is authorized to schedule notifications */
    MUUNAuthorizationStatusAuthorized
};

typedef NS_OPTIONS(NSUInteger, MUUNAuthorizationOptions) {
    MUUNAuthorizationOptionNone     = 0,

    /** The ability to update the app’s badge */
    MUUNAuthorizationOptionBadge    = 1 << 0,
    
    /** The ability to play sounds */
    MUUNAuthorizationOptionSound    = 1 << 1,
    
    /** The ability to display alerts */
    MUUNAuthorizationOptionAlert    = 1 << 2,

    /** The ability to display notifications in a CarPlay environment */
    MUUNAuthorizationOptionCarPlay  = 1 << 3
};

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@class UNNotificationSettings;
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 *  Manages the notification-related activities for your app. Equivalent to UNUserNotificationCenter
 */
@interface MUUserNotificationCenter : NSObject

/** The authorization status indicating the app’s ability to interact with the user */
+ (MUUNAuthorizationStatus)authorizationStatus;

/** The authorization options your app is requesting */
+ (MUUNAuthorizationOptions)authorizationOptions;

/** Requests authorization and register to receive remote notifications */
+ (void)registerRemoteNotifications;

/** Returns YES if the application is currently registered for remote notifications */
+ (BOOL)isRegisteredForRemoteNotifications;

/** Returns the singleton user notification center object for your app */
+ (MUUserNotificationCenter *)currentNotificationCenter;

- (instancetype)init NS_UNAVAILABLE;

/** Register to receive remote notifications via Apple Push Notification service */
- (void)registerForRemoteNotifications;

/**
 *  Requests authorization to interact with the user when local and remote notifications arrive.
 *
 *  @param options           The authorization options your app is requesting. You may combine the available constants to request authorization for multiple items.
 *  @param categories        A set of MUNotificationCategory objects, each of which defines the actions and information for a single type of notification.
 *  @param completionHandler The block to execute asynchronously with the results
 */
- (void)requestAuthorizationWithOptions:(MUUNAuthorizationOptions)options categories:(nullable NSSet<MUNotificationCategory *> *)categories completionHandler:(void (^)(BOOL granted, NSError *__nullable error))completionHandler NS_AVAILABLE_IOS(8_0);

/**
 *  Schedules a local notification for delivery.
 *
 *  @param request           The notification request to schedule.This parameter must not be nil.
 *  @param completionHandler The block to execute with the results. Use this block to determine if the notification request was added successfully.
 */
- (void)addNotificationRequest:(MUNotificationRequest *)request withCompletionHandler:(nullable void(^)(NSError *__nullable error))completionHandler;

/** Returns a list of all notification requests that are scheduled and waiting to be delivered */
- (nullable NSArray<MUNotificationRequest *> *)pendingNotificationRequests;

/** Unschedules the specified notification requests */
- (void)removePendingNotificationRequestsWithIdentifiers:(NSArray<NSString *> *)identifiers;

/** Unschedules all pending notification requests */
- (void)removeAllPendingNotificationRequests;

/** Provides you with a list of the app’s notifications that are still displayed in Notification Center */
- (nullable NSArray<MUNotification *> *)deliveredNotifications NS_AVAILABLE_IOS(10_0);

/** Removes the specified notifications from Notification Center */
- (void)removeDeliveredNotificationsWithIdentifiers:(NSArray<NSString *> *)identifiers NS_AVAILABLE_IOS(10_0);

/** Removes all of the app’s notifications from Notification Center */
- (void)removeAllDeliveredNotifications NS_AVAILABLE_IOS(10_0);

/** return the app’s currently registered notification categories */
@property (nonatomic, readonly) NSSet<MUNotificationCategory *> *categories;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
/** return the notification settings for this app */
@property (nonatomic, readonly) UNNotificationSettings *settings NS_AVAILABLE_IOS(10_0);
#endif

/** The delegate used to process delivered notifications */
@property (nonatomic, weak, nullable) id <MUUserNotificationCenterDelegate> delegate;

@end


typedef NS_OPTIONS(NSUInteger, MUNotificationPresentationOptions) {
    MUNotificationPresentationOptionNone    = 0,
    /** Apply the badge value to the app’s icon */
    MUNotificationPresentationOptionBadge   = 1 << 0,
    /** Play the sound associated with the notification */
    MUNotificationPresentationOptionSound   = 1 << 1,
    /** Display the alert using the text provided by the notification */
    MUNotificationPresentationOptionAlert   = 1 << 2,
} NS_AVAILABLE_IOS(10_0);

@protocol MUUserNotificationCenterDelegate <NSObject>

@optional

/**
 *  Called when a notification is delivered to a foreground app.
 *
 *  foreground (application:didReceiveLocalNotification, application:didReceiveRemoteNotification...) and userNotificationCenter:willPresentNotification:withCompletionHandler:
 *
 *  @param center       The notification center that received the notification.
 *  @param notification The notification that is about to be delivered. Use the information in this object to determine an appropriate course of action.
 */
- (void)mu_userNotificationCenter:(MUUserNotificationCenter *)center willPresentNotification:(MUNotification *)notification;

/**
 *  Called to let your app know which action was selected by the user for a given notification.
 *
 *  background (application:didReceiveLocalNotification, application:didReceiveRemoteNotification...), application:handleActionWithIdentifier... and userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:
 *
 *  @param center   The notification center that received the notification.
 *  @param response The user’s response to the notification. This object contains the original notification and the identifier string for the selected action. If the action allowed the user to provide a textual response, this object is an instance of the MUTextInputNotificationResponse class.
 */
- (void)mu_userNotificationCenter:(MUUserNotificationCenter *)center didReceiveNotificationResponse:(MUNotificationResponse *)response;

/**
 *  Called when a notification is delivered to a foreground app.
 *
 *  foreground (application:didReceiveLocalNotification, application:didReceiveRemoteNotification...) and userNotificationCenter:willPresentNotification:withCompletionHandler:
 *
 *  @param center            The notification center that received the notification.
 *  @param notification      The notification that is about to be delivered. Use the information in this object to determine an appropriate course of action.
 *  @param completionHandler The block to execute with the presentation option for the notification. Always execute this block at some point during your implementation of this method. Specify an option indicating how you want the system to alert the user, if at all.
 */
- (void)mu_userNotificationCenter:(MUUserNotificationCenter *)center willPresentNotification:(MUNotification *)notification withCompletionHandler:(void (^)(MUNotificationPresentationOptions options))completionHandler NS_AVAILABLE_IOS(10_0);

/**
 *  Called to let your app know which action was selected by the user for a given notification.
 *
 *  background (application:didReceiveLocalNotification, application:didReceiveRemoteNotification...), application:handleActionWithIdentifier... and userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:
 *
 *  @param center            The notification center that received the notification.
 *  @param response          The user’s response to the notification. This object contains the original notification and the identifier string for the selected action. If the action allowed the user to provide a textual response, this object is an instance of the MUTextInputNotificationResponse class.
 *  @param completionHandler The block to execute when you have finished processing the user’s response. You must execute this block from your method and should call it as quickly as possible.
 */
- (void)mu_userNotificationCenter:(MUUserNotificationCenter *)center didReceiveNotificationResponse:(MUNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler NS_AVAILABLE_IOS(8_0);

@end

NS_ASSUME_NONNULL_END
