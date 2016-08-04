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
// abstract class
@interface MUNotificationTrigger : NSObject <NSCopying, NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) BOOL repeats;

@end

// abstract class
@interface MUPushNotificationTrigger : MUNotificationTrigger

@end

NS_CLASS_AVAILABLE_IOS(10_0)
@interface MUTimeIntervalNotificationTrigger : MUNotificationTrigger

+ (instancetype)triggerWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats;

- (nullable NSDate *)nextTriggerDate;

@property (nonatomic, readonly) NSTimeInterval timeInterval;

@end

NS_CLASS_AVAILABLE_IOS(10_0)
@interface MUCalendarNotificationTrigger : MUNotificationTrigger

+ (instancetype)triggerWithDateMatchingComponents:(NSDateComponents *)dateComponents repeats:(BOOL)repeats;

- (nullable NSDate *)nextTriggerDate;

@property (nonatomic, readonly) NSDateComponents *dateComponents;

@end

NS_CLASS_AVAILABLE_IOS(8_0)
@interface MULocationNotificationTrigger : MUNotificationTrigger

+ (instancetype)triggerWithRegion:(CLRegion *)region repeats:(BOOL)repeats;

@property (nonatomic, readonly) CLRegion *region;

@end


NS_CLASS_DEPRECATED_IOS(4_0, 10_0)
@interface MUClassicNotificationTrigger : MUNotificationTrigger

+ (instancetype)triggerWithFireDate:(NSDate *)fireDate repeatInterval:(NSCalendarUnit)repeatInterval;
+ (instancetype)triggerWithFireDate:(NSDate *)fireDate repeatInterval:(NSCalendarUnit)repeatInterval timeZone:(nullable NSTimeZone *)timeZone repeatCalendar:(nullable NSCalendar *)repeatCalendar;

@property (nonatomic, readonly) NSDate *fireDate;
@property (nonatomic, readonly) NSCalendarUnit repeatInterval;
@property (nonatomic, readonly) NSTimeZone *timeZone;
@property (nonatomic, readonly) NSCalendar *repeatCalendar;

@end

NS_ASSUME_NONNULL_END
