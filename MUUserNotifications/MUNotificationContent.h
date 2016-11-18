//
//  MUNotificationContent.h
//  MUNotifications
//
//  Created by Muer on 16/7/27.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UNNotificationAttachment;
@class MUNotificationSound;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Stores the content of a local or remote notification. Equivalent to UNNotificationContent
 */
@interface MUNotificationContent : NSObject <NSCopying, NSSecureCoding>

/** The application badge number */
@property (nonatomic, readonly, nullable) NSNumber *badge;

/** The body of the notification */
@property (nonatomic, readonly) NSString *body;

/** The identifier of the app-defined category object */
@property (nonatomic, readonly) NSString *categoryIdentifier;

/** The launch image that will be used when the app is opened from the notification */
@property (nonatomic, readonly) NSString *launchImageName;

/** The title of the notification */
@property (nonatomic, readonly) NSString *title NS_AVAILABLE_IOS(8_2);

/** A dictionary of custom information associated with the notification */
@property (nonatomic, readonly) NSDictionary *userInfo;

/** The sound that will be played for the notification */
@property (nonatomic, readonly, nullable) MUNotificationSound *sound;

/** Optional array of attachments */
@property (nonatomic, readonly) NSArray <UNNotificationAttachment *> *attachments NS_AVAILABLE_IOS(10_0);

/** The subtitle of the notification */
@property (nonatomic, readonly) NSString *subtitle NS_AVAILABLE_IOS(10_0);

/** An app-specific identifier that you attach to related notifications */
@property (nonatomic, readonly) NSString *threadIdentifier NS_AVAILABLE_IOS(10_0);

/** The title of the action button or slider */
@property (nonatomic, readonly) NSString *alertAction NS_DEPRECATED_IOS(2_0, 10_0);

@end

/**
 *  Provides the editable content for a notification. Equivalent to UNMutableNotificationContent
 */
@interface MUMutableNotificationContent : MUNotificationContent

/** The application badge number */
@property (nonatomic, copy, nullable) NSNumber *badge;

/** The body of the notification */
@property (nonatomic, copy) NSString *body;

/** The identifier of the app-defined category object */
@property (nonatomic, copy) NSString *categoryIdentifier;

/** The launch image that will be used when the app is opened from the notification */
@property (nonatomic, copy) NSString *launchImageName;

/** The title of the notification */
@property (nonatomic, copy) NSString *title NS_AVAILABLE_IOS(8_2);

/** A dictionary of custom information associated with the notification */
@property (nonatomic, copy) NSDictionary *userInfo;

/** The sound that will be played for the notification */
@property (nonatomic, copy, nullable) MUNotificationSound *sound;

/** Optional array of attachments */
@property (nonatomic, copy) NSArray <UNNotificationAttachment *> *attachments NS_AVAILABLE_IOS(10_0);

/** The subtitle of the notification */
@property (nonatomic, copy) NSString *subtitle NS_AVAILABLE_IOS(10_0);

/** An app-specific identifier that you attach to related notifications */
@property (nonatomic, copy) NSString *threadIdentifier NS_AVAILABLE_IOS(10_0);

/** The title of the action button or slider */
@property (nonatomic, copy) NSString *alertAction NS_DEPRECATED_IOS(2_0, 10_0);

@end

/**
 *  Represents a sound to be played when a notification is delivered. Equivalent to UNNotificationSound
 */
@interface MUNotificationSound : NSObject <NSCopying, NSSecureCoding>

/** The default sound used for notifications */
+ (instancetype)defaultSound;

/** Creates and returns a notification sound object that plays the specified sound file */
+ (instancetype)soundNamed:(NSString *)name;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
