//
//  MUNotificationTrigger.h
//  MUNotifications
//
//  Created by Muer on 16/7/27.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLRegion;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Abstract class. Provides common behavior for subclasses that trigger the delivery of a notification. Equivalent to UNNotificationTrigger
 */
@interface MUNotificationTrigger : NSObject <NSCopying, NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;

/** A Boolean value indicating whether the event repeats */
@property (nonatomic, readonly) BOOL repeats;

@end

/**
 *  Abstract class. Indicates that a delivered notification was sent using the Apple Push Notification Service. Equivalent to UNPushNotificationTrigger
 */
@interface MUPushNotificationTrigger : MUNotificationTrigger

@end

/**
 *  Triggers the delivery of a local notification after the specified amount of time. Equivalent to UNTimeIntervalNotificationTrigger
 */
NS_CLASS_AVAILABLE_IOS(10_0)
@interface MUTimeIntervalNotificationTrigger : MUNotificationTrigger

/** Creates and returns a time interval trigger from the specified time value */
+ (instancetype)triggerWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats;

/** The next date at which the trigger conditions will be met */
- (nullable NSDate *)nextTriggerDate;

/** The time interval used to create the trigger */
@property (nonatomic, readonly) NSTimeInterval timeInterval;

@end

/**
 *  Triggers a notification at the specified date and time. Equivalent to UNCalendarNotificationTrigger
 */
NS_CLASS_AVAILABLE_IOS(10_0)
@interface MUCalendarNotificationTrigger : MUNotificationTrigger

/** Creates and returns a calendar trigger from the specified date components */
+ (instancetype)triggerWithDateMatchingComponents:(NSDateComponents *)dateComponents repeats:(BOOL)repeats;

/** The next date at which the trigger conditions will be met */
- (nullable NSDate *)nextTriggerDate;

/** The date components used to construct this object */
@property (nonatomic, readonly) NSDateComponents *dateComponents;

@end

/**
 *  Triggers the delivery of a notification when the user reaches the specified geographic location. Equivalent to UNLocationNotificationTrigger
 */
NS_CLASS_AVAILABLE_IOS(8_0)
@interface MULocationNotificationTrigger : MUNotificationTrigger

/** Creates and returns a location trigger for the specified region */
+ (instancetype)triggerWithRegion:(CLRegion *)region repeats:(BOOL)repeats;

/** The region used to determine when the notification is sent */
@property (nonatomic, readonly) CLRegion *region;

@end

/**
 *  Triggers a notification at the specified date and calendar interval. Equivalent to UILocalNotification
 */
NS_CLASS_DEPRECATED_IOS(4_0, 10_0)
@interface MUClassicNotificationTrigger : MUNotificationTrigger

/** Creates and returns a classic trigger from the specified date and calendar interval */
+ (instancetype)triggerWithFireDate:(NSDate *)fireDate repeatInterval:(NSCalendarUnit)repeatInterval;

/** Creates and returns a classic trigger from the specified date and calendar interval */
+ (instancetype)triggerWithFireDate:(NSDate *)fireDate repeatInterval:(NSCalendarUnit)repeatInterval timeZone:(nullable NSTimeZone *)timeZone repeatCalendar:(nullable NSCalendar *)repeatCalendar;

/** The date and time when the system should deliver the notification */
@property (nonatomic, readonly) NSDate *fireDate;

/** The calendar interval at which to reschedule the notification. 0 means don't repeat */
@property (nonatomic, readonly) NSCalendarUnit repeatInterval;

/** The time zone of the notification’s fire date */
@property (nonatomic, readonly) NSTimeZone *timeZone;

/** The calendar the system should refer to when it reschedules a repeating notification */
@property (nonatomic, readonly) NSCalendar *repeatCalendar;

@end

NS_ASSUME_NONNULL_END
