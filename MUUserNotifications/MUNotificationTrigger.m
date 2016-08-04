//
//  MUNotificationTrigger.m
//  MUNotifications
//
//  Created by Muer on 16/7/27.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "MUNotificationTrigger.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@import UserNotifications;
#endif

@interface MUNotificationTrigger ()

@property (nonatomic, assign) BOOL repeats;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic, strong) UNNotificationTrigger *unTrigger;
#endif

@end

@implementation MUNotificationTrigger

- (instancetype)initWithRepeats:(BOOL)repeats
{
    self = [super init];
    if (self) {
        self.repeats = repeats;
    }
    return self;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UNNotificationTrigger *)unTrigger
{
    if (_unTrigger == nil) {
        if ([self isKindOfClass:[MUTimeIntervalNotificationTrigger class]]) {
            _unTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:[(MUTimeIntervalNotificationTrigger *)self timeInterval] repeats:self.repeats];
        }
        else if ([self isKindOfClass:[MUCalendarNotificationTrigger class]]) {
            _unTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:[(MUCalendarNotificationTrigger *)self dateComponents] repeats:self.repeats];
        }
        else if ([self isKindOfClass:[MULocationNotificationTrigger class]]) {
            _unTrigger = [UNLocationNotificationTrigger triggerWithRegion:[(MULocationNotificationTrigger *)self region] repeats:self.repeats];
        }
    }
    return _unTrigger;
}
#endif

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.repeats forKey:NSStringFromSelector(@selector(repeats))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.repeats = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(repeats))];
    }
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[MUNotificationTrigger allocWithZone:zone] initWithRepeats:self.repeats];
}

@end

@implementation MUPushNotificationTrigger

@end

@interface MUPushNotificationTrigger (MUPrivate)

+ (instancetype)p_defaultPushTrigger;

@end

@implementation MUPushNotificationTrigger (MUPrivate)

+ (instancetype)p_defaultPushTrigger
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithRepeats:NO];
    });
    return instance;
}

@end

@interface MUTimeIntervalNotificationTrigger ()

@property (nonatomic, assign) NSTimeInterval timeInterval;

@end

@implementation MUTimeIntervalNotificationTrigger

+ (instancetype)triggerWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats
{
    MUTimeIntervalNotificationTrigger *trigger = [[self alloc] initWithRepeats:repeats];
    trigger.timeInterval = timeInterval;
    return trigger;
}

- (nullable NSDate *)nextTriggerDate
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    return [(UNTimeIntervalNotificationTrigger *)self.unTrigger nextTriggerDate];
#else
    return nil;
#endif
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.timeInterval forKey:NSStringFromSelector(@selector(timeInterval))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.timeInterval = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(timeInterval))];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MUTimeIntervalNotificationTrigger *trigger = [[MUTimeIntervalNotificationTrigger allocWithZone:zone] initWithRepeats:self.repeats];
    trigger.timeInterval = self.timeInterval;
    return trigger;
}

@end

@interface MUCalendarNotificationTrigger ()

@property (nonatomic, copy) NSDateComponents *dateComponents;

@end

@implementation MUCalendarNotificationTrigger

+ (instancetype)triggerWithDateMatchingComponents:(NSDateComponents *)dateComponents repeats:(BOOL)repeats
{
    MUCalendarNotificationTrigger *trigger = [[self alloc] initWithRepeats:repeats];
    trigger.dateComponents = dateComponents;
    return trigger;
}

- (nullable NSDate *)nextTriggerDate
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    return [(UNCalendarNotificationTrigger *)self.unTrigger nextTriggerDate];
#else
    return nil;
#endif
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.dateComponents forKey:NSStringFromSelector(@selector(dateComponents))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.dateComponents = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dateComponents))];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MUCalendarNotificationTrigger *trigger = [[MUCalendarNotificationTrigger allocWithZone:zone] initWithRepeats:self.repeats];
    trigger.dateComponents = self.dateComponents;
    return trigger;
}

@end

@class CLRegion;

@interface MULocationNotificationTrigger ()

@property (nonatomic, copy) CLRegion *region;

@end

@implementation MULocationNotificationTrigger

+ (instancetype)triggerWithRegion:(CLRegion *)region repeats:(BOOL)repeats
{
    MULocationNotificationTrigger *trigger = [[self alloc] initWithRepeats:repeats];
    trigger.region = region;
    return trigger;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p>, region: %@", NSStringFromClass([self class]), self, self.region];
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.region forKey:NSStringFromSelector(@selector(region))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.region = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(region))];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MULocationNotificationTrigger *trigger = [[MULocationNotificationTrigger allocWithZone:zone] initWithRepeats:self.repeats];
    trigger.region = self.region;
    return trigger;
}

@end

@interface MUClassicNotificationTrigger ()

@property (nonatomic, copy) NSDate *fireDate;
@property (nonatomic, assign) NSCalendarUnit repeatInterval;
@property (nonatomic, copy) NSTimeZone *timeZone;
@property (nonatomic, copy) NSCalendar *repeatCalendar;

@end

@implementation MUClassicNotificationTrigger

+ (instancetype)triggerWithFireDate:(NSDate *)fireDate repeatInterval:(NSCalendarUnit)repeatInterval
{
    return [self triggerWithFireDate:fireDate repeatInterval:repeatInterval timeZone:nil repeatCalendar:nil];
}

+ (instancetype)triggerWithFireDate:(NSDate *)fireDate repeatInterval:(NSCalendarUnit)repeatInterval timeZone:(nullable NSTimeZone *)timeZone repeatCalendar:(nullable NSCalendar *)repeatCalendar
{
    MUClassicNotificationTrigger *trigger = [[self alloc] initWithRepeats:repeatInterval > 0];
    trigger.fireDate = fireDate;
    trigger.repeatInterval = repeatInterval;
    trigger.timeZone = timeZone;
    trigger.repeatCalendar = repeatCalendar;
    return trigger;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p>, fireDate: %@, repeatInterval: %zd, timeZone: %@, repeatCalendar: %@", NSStringFromClass([self class]), self, self.fireDate, self.repeatInterval, self.timeZone, self.repeatCalendar];
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.fireDate forKey:NSStringFromSelector(@selector(fireDate))];
    [aCoder encodeInteger:self.repeatInterval forKey:NSStringFromSelector(@selector(repeatInterval))];
    [aCoder encodeObject:self.timeZone forKey:NSStringFromSelector(@selector(timeZone))];
    [aCoder encodeObject:self.repeatCalendar forKey:NSStringFromSelector(@selector(repeatCalendar))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.fireDate = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fireDate))];
        self.repeatInterval = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(repeatInterval))];
        self.timeZone = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(timeZone))];
        self.repeatCalendar = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(repeatCalendar))];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MUClassicNotificationTrigger *trigger = [[MUClassicNotificationTrigger allocWithZone:zone] initWithRepeats:self.repeats];
    trigger.fireDate = self.fireDate;
    trigger.repeatInterval = self.repeatInterval;
    trigger.timeZone = self.timeZone;
    trigger.repeatCalendar = self.repeatCalendar;
    return trigger;
}

@end

@interface MUNotificationTrigger (MUPrivate)

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UNNotificationTrigger *)p_unNotificationTrigger;
#endif

@end

@implementation MUNotificationTrigger (MUPrivate)

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UNNotificationTrigger *)p_unNotificationTrigger
{
    return self.unTrigger;
}
#endif

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@interface UNNotificationTrigger (MUPrivate)

- (MUNotificationTrigger *)p_muNotificationTrigger;

@end

@implementation UNNotificationTrigger (MUPrivate)

- (MUNotificationTrigger *)p_muNotificationTrigger
{
    if ([self isKindOfClass:[UNPushNotificationTrigger class]]) {
        return [[MUPushNotificationTrigger alloc] initWithRepeats:self.repeats];
    }
    else if ([self isKindOfClass:[UNTimeIntervalNotificationTrigger class]]) {
        return [MUTimeIntervalNotificationTrigger triggerWithTimeInterval:[(UNTimeIntervalNotificationTrigger *)self timeInterval] repeats:self.repeats];
    }
    else if ([self isKindOfClass:[UNCalendarNotificationTrigger class]]) {
        return [MUCalendarNotificationTrigger triggerWithDateMatchingComponents:[(UNCalendarNotificationTrigger *)self dateComponents] repeats:self.repeats];
    }
    else if ([self isKindOfClass:[UNLocationNotificationTrigger class]]) {
        return [MULocationNotificationTrigger triggerWithRegion:[(UNLocationNotificationTrigger *)self region] repeats:self.repeats];
    }
    return nil;
}

@end
#endif
