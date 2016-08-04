//
//  MUNotification.m
//  MUNotifications
//
//  Created by Muer on 16/7/27.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "MUNotification.h"
#import "MUNotificationRequest.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@import UserNotifications;
#endif

@interface MUNotification ()

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) MUNotificationRequest *request;

@end

@implementation MUNotification

- (instancetype)initWithDate:(NSDate *)date request:(MUNotificationRequest *)request
{
    self = [super init];
    if (self) {
        self.date = date;
        self.request = request;
    }
    return self;
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.date forKey:NSStringFromSelector(@selector(date))];
    [aCoder encodeObject:self.request forKey:NSStringFromSelector(@selector(request))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.date = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(date))];
        self.request = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(request))];
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
    return [[MUNotification allocWithZone:zone] initWithDate:self.date request:self.request];
}

@end

@interface MUNotification (MUPrivate)

+ (instancetype)p_notificationWithDate:(NSDate *)date request:(MUNotificationRequest *)request;

@end

@implementation MUNotification (MUPrivate)

+ (instancetype)p_notificationWithDate:(NSDate *)date request:(MUNotificationRequest *)request
{
    return [[self alloc] initWithDate:date request:request];
}

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@interface UNNotificationRequest (MUPrivate)

- (MUNotificationRequest *)p_muNotificationRequest;

@end

@interface UNNotification (MUPrivate)

- (MUNotification *)p_muNotification;

@end

@implementation UNNotification (MUPrivate)

- (MUNotification *)p_muNotification
{
    return [[MUNotification alloc] initWithDate:self.date request:[self.request p_muNotificationRequest]];
}

@end
#endif
