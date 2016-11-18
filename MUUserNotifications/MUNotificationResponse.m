//
//  MUNotificationResponse.m
//  MUNotifications
//
//  Created by Muer on 16/7/27.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "MUNotificationResponse.h"
#import "MUNotification.h"
@import UserNotifications;

NSString *const MUNotificationDefaultActionIdentifier = @"MUNotificationDefaultActionIdentifier";
NSString *const MUNotificationDismissActionIdentifier = @"MUNotificationDismissActionIdentifier";

@interface MUNotificationResponse ()

@property (nonatomic, strong) MUNotification *notification;
@property (nonatomic, copy) NSString *actionIdentifier;

@end

@implementation MUNotificationResponse

- (instancetype)initWithNotification:(MUNotification *)notification actionIdentifier:(NSString *)actionIdentifier
{
    self = [super init];
    if (self) {
        self.notification = notification;
        self.actionIdentifier = actionIdentifier;
    }
    return self;
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.notification forKey:NSStringFromSelector(@selector(notification))];
    [aCoder encodeObject:self.actionIdentifier forKey:NSStringFromSelector(@selector(actionIdentifier))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.notification = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(notification))];
        self.actionIdentifier = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(actionIdentifier))];
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
    return [[MUNotificationResponse allocWithZone:zone] initWithNotification:self.notification actionIdentifier:self.actionIdentifier];
}

@end

@interface MUTextInputNotificationResponse ()

@property (nonatomic, copy) NSString *userText;

@end

@implementation MUTextInputNotificationResponse

- (instancetype)initWithNotification:(MUNotification *)notification actionIdentifier:(NSString *)actionIdentifier userText:(NSString *)userText
{
    self = [super initWithNotification:notification actionIdentifier:actionIdentifier];
    if (self) {
        self.userText = userText;
    }
    return self;
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.userText forKey:NSStringFromSelector(@selector(userText))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.userText = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userText))];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[MUTextInputNotificationResponse allocWithZone:zone] initWithNotification:self.notification actionIdentifier:self.actionIdentifier userText:self.userText];
}

@end

@interface MUNotificationResponse (MUPrivate)

+ (instancetype)p_responseWithNotification:(MUNotification *)notification actionIdentifier:(NSString *)actionIdentifier;

@end

@implementation MUNotificationResponse (MUPrivate)

+ (instancetype)p_responseWithNotification:(MUNotification *)notification actionIdentifier:(NSString *)actionIdentifier
{
    return [[self alloc] initWithNotification:notification actionIdentifier:actionIdentifier];
}

@end

@interface MUTextInputNotificationResponse (MUPrivate)

+ (instancetype)p_responseWithNotification:(MUNotification *)notification actionIdentifier:(NSString *)actionIdentifier userText:(NSString *)userText;

@end

@implementation MUTextInputNotificationResponse (MUPrivate)

+ (instancetype)p_responseWithNotification:(MUNotification *)notification actionIdentifier:(NSString *)actionIdentifier userText:(NSString *)userText
{
    return [[self alloc] initWithNotification:notification actionIdentifier:actionIdentifier userText:userText];
}

@end

@interface UNNotification (MUPrivate)

- (MUNotification *)p_muNotification;

@end

@interface UNNotificationResponse (MUPrivate)

- (MUNotificationResponse *)p_muNotificationResponse;

@end

@implementation UNNotificationResponse (MUPrivate)

- (MUNotificationResponse *)p_muNotificationResponse
{
    MUNotification *muNotification = [self.notification p_muNotification];
    NSString *actionIdentifier = self.actionIdentifier;
    if ([actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        actionIdentifier = MUNotificationDefaultActionIdentifier;
    }
    else if ([actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
        actionIdentifier = MUNotificationDismissActionIdentifier;
    }
    
    if ([self isKindOfClass:[UNTextInputNotificationResponse class]]) {
        return [[MUTextInputNotificationResponse alloc] initWithNotification:muNotification actionIdentifier:actionIdentifier userText:[(UNTextInputNotificationResponse *)self userText]];
    }
    return [[MUNotificationResponse alloc] initWithNotification:muNotification actionIdentifier:actionIdentifier];
}

@end
