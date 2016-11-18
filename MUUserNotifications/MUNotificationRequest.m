//
//  MUNotificationRequest.m
//  MUNotifications
//
//  Created by Muer on 16/7/27.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "MUNotificationRequest.h"
#import "MUNotificationContent.h"
#import "MUNotificationTrigger.h"
#import "MUNotification.h"
#import "MUNotificationResponse.h"
@import UserNotifications;

static NSString * const MUUILocalNotificationUserInfoIdentifierKey = @"MUUILocalNotificationUserInfoIdentifierKey";

@interface MUNotificationTrigger (MUPrivate)

- (UNNotificationTrigger *)p_unNotificationTrigger;

@end

@interface MUNotificationContent (MUPrivate)

- (NSString *)p_soundName;
- (UNNotificationContent *)p_unNotificationContent;

@end

@interface MUNotification (MUPrivate)

+ (instancetype)p_notificationWithDate:(NSDate *)date request:(MUNotificationRequest *)request;

@end

@interface MUNotificationResponse (MUPrivate)

+ (instancetype)p_responseWithNotification:(MUNotification *)notification actionIdentifier:(NSString *)actionIdentifier;

@end

@interface MUTextInputNotificationResponse (MUPrivate)

+ (instancetype)p_responseWithNotification:(MUNotification *)notification actionIdentifier:(NSString *)actionIdentifier userText:(NSString *)userText;

@end

@interface MUPushNotificationTrigger (MUPrivate)

+ (instancetype)p_defaultPushTrigger;

@end

@interface MUNotificationRequest ()

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) MUNotificationContent *content;
@property (nonatomic, copy) MUNotificationTrigger *trigger;

@end

@implementation MUNotificationRequest

+ (instancetype)requestWithIdentifier:(NSString *)identifier content:(MUNotificationContent *)content trigger:(MUNotificationTrigger *)trigger
{
    return [[self alloc] initWithIdentifier:identifier content:content trigger:trigger];
}

- (instancetype)initWithIdentifier:(NSString *)identifier content:(MUNotificationContent *)content trigger:(MUNotificationTrigger *)trigger
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.content = content;
        self.trigger = trigger;
    }
    return self;
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
    [aCoder encodeObject:self.content forKey:NSStringFromSelector(@selector(content))];
    [aCoder encodeObject:self.trigger forKey:NSStringFromSelector(@selector(trigger))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.identifier = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(identifier))];
        self.content = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(content))];
        self.trigger = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(trigger))];
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
    return [[MUNotificationRequest allocWithZone:zone] initWithIdentifier:self.identifier content:self.content trigger:self.trigger];
}


@end


@interface MUNotificationRequest (MUPrivate)

- (UILocalNotification *)p_uiLocalNotification;
- (UNNotificationRequest *)p_unNotificationRequest;

@end

@implementation MUNotificationRequest (MUPrivate)

- (UILocalNotification *)p_uiLocalNotification
{
    MUNotificationContent *content = self.content;
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = content.body;
    if ([localNotification respondsToSelector:@selector(setAlertTitle:)]) {
        localNotification.alertTitle = content.title;
    }
    localNotification.alertAction = content.alertAction;
    localNotification.alertLaunchImage = content.launchImageName;
    localNotification.applicationIconBadgeNumber = [content.badge integerValue];
    if ([localNotification respondsToSelector:@selector(setCategory:)]) {
        localNotification.category = content.categoryIdentifier;
    }
    
    NSMutableDictionary *mutableUserInfo = [NSMutableDictionary dictionaryWithDictionary:content.userInfo];
    mutableUserInfo[MUUILocalNotificationUserInfoIdentifierKey] = self.identifier;
    localNotification.userInfo = mutableUserInfo;
    
    if (content.sound) {
        localNotification.soundName = content.p_soundName;
    }
    
    if ([self.trigger isKindOfClass:[MUClassicNotificationTrigger class]]) {
        MUClassicNotificationTrigger *trigger = (MUClassicNotificationTrigger *)self.trigger;
        localNotification.fireDate = trigger.fireDate;
        localNotification.repeatInterval = trigger.repeatInterval;
        if (trigger.timeZone) {
            localNotification.timeZone = trigger.timeZone;
        }
        if (trigger.repeatCalendar) {
            localNotification.repeatCalendar = trigger.repeatCalendar;
        }
    }
    else if ([self.trigger isKindOfClass:[MULocationNotificationTrigger class]]) {
        MULocationNotificationTrigger *trigger = (MULocationNotificationTrigger *)self.trigger;
        localNotification.region = trigger.region;
    }
    return localNotification;
}

- (UNNotificationRequest *)p_unNotificationRequest
{
    return [UNNotificationRequest requestWithIdentifier:self.identifier
                                                content:[self.content p_unNotificationContent]
                                                trigger:[self.trigger p_unNotificationTrigger]];
}

@end

@interface UILocalNotification (MUPrivate)

- (MUNotificationRequest *)p_muNotificationRequest;
- (MUNotification *)p_muNotification;
- (MUNotificationResponse *)p_muResponseWithActionIdentifier:(NSString *)actionIdentifier;
- (MUNotificationResponse *)p_muTextInputResponseWithActionIdentifier:(NSString *)actionIdentifier userText:(NSString *)userText;

@property (nonatomic, readonly, nullable) NSString *mu_identifier;

@end

@implementation UILocalNotification (MUPrivate)

- (MUNotificationRequest *)p_muNotificationRequest
{
    MUMutableNotificationContent *muContent = [[MUMutableNotificationContent alloc] init];
    muContent.body = self.alertBody;
    if ([self respondsToSelector:@selector(setAlertTitle:)]) {
        muContent.title = self.alertTitle;
    }
    muContent.alertAction = self.alertAction;
    muContent.launchImageName = self.alertLaunchImage;
    muContent.badge = @(self.applicationIconBadgeNumber);
    if ([self respondsToSelector:@selector(setCategory:)]) {
        muContent.categoryIdentifier = self.category;
    }

    if (self.userInfo) {
        NSMutableDictionary *mutableUserInfo = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
        [mutableUserInfo removeObjectForKey:MUUILocalNotificationUserInfoIdentifierKey];
        muContent.userInfo = mutableUserInfo;
    }
    
    if (self.soundName) {
        if ([self.soundName isEqualToString:UILocalNotificationDefaultSoundName]) {
            muContent.sound = [MUNotificationSound defaultSound];
        }
        else {
            muContent.sound = [MUNotificationSound soundNamed:self.soundName];
        }
    }
    
    MUNotificationTrigger *muTrigger = nil;
    if (self.region) {
        muTrigger = [MULocationNotificationTrigger triggerWithRegion:self.region repeats:!self.regionTriggersOnce];
    }
    else {
        muTrigger = [MUClassicNotificationTrigger triggerWithFireDate:self.fireDate repeatInterval:self.repeatInterval timeZone:self.timeZone repeatCalendar:self.repeatCalendar];
    }
    
    NSString *identifier = self.mu_identifier ? : [[NSUUID UUID] UUIDString];
    
    return [MUNotificationRequest requestWithIdentifier:identifier content:muContent trigger:muTrigger];
}

- (MUNotification *)p_muNotification
{
    return [MUNotification p_notificationWithDate:self.fireDate ? : [NSDate date] request:[self p_muNotificationRequest]];
}

- (MUNotificationResponse *)p_muResponseWithActionIdentifier:(NSString *)actionIdentifier
{
    return [MUNotificationResponse p_responseWithNotification:[self p_muNotification] actionIdentifier:actionIdentifier];
}

- (MUNotificationResponse *)p_muTextInputResponseWithActionIdentifier:(NSString *)actionIdentifier userText:(NSString *)userText
{
    return [MUTextInputNotificationResponse p_responseWithNotification:[self p_muNotification] actionIdentifier:actionIdentifier userText:userText];
}

- (NSString *)mu_identifier
{
    return self.userInfo[MUUILocalNotificationUserInfoIdentifierKey];
}

@end

@interface NSDictionary (MURemoteUserInfoPrivate)

- (MUNotificationRequest *)p_muNotificationRequest;
- (MUNotification *)p_muNotification;
- (MUNotificationResponse *)p_muResponseWithActionIdentifier:(NSString *)actionIdentifier;
- (MUNotificationResponse *)p_muTextInputResponseWithActionIdentifier:(NSString *)actionIdentifier userText:(NSString *)userText;

@end

@implementation NSDictionary (MURemoteUserInfoPrivate)

- (MUNotificationRequest *)p_muNotificationRequest
{
    NSDictionary *apsInfo = self[@"aps"];
    if (!apsInfo) {
        return nil;
    }
    
    MUMutableNotificationContent *muContent = [[MUMutableNotificationContent alloc] init];
    muContent.body = apsInfo[@"alert"];
    muContent.badge = @([apsInfo[@"badge"] integerValue]);
    muContent.categoryIdentifier = apsInfo[@"category"];
    muContent.userInfo = self;
    if (apsInfo[@"sound"]) {
        muContent.sound = [MUNotificationSound soundNamed:apsInfo[@"sound"]];
    }
    
    return [MUNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString]
                                                content:muContent
                                                trigger:[MUPushNotificationTrigger p_defaultPushTrigger]];
}

- (MUNotification *)p_muNotification
{
    return [MUNotification p_notificationWithDate:[NSDate date] request:[self p_muNotificationRequest]];
}

- (MUNotificationResponse *)p_muResponseWithActionIdentifier:(NSString *)actionIdentifier
{
    return [MUNotificationResponse p_responseWithNotification:[self p_muNotification] actionIdentifier:actionIdentifier];
}

- (MUNotificationResponse *)p_muTextInputResponseWithActionIdentifier:(NSString *)actionIdentifier userText:(NSString *)userText
{
    return [MUTextInputNotificationResponse p_responseWithNotification:[self p_muNotification] actionIdentifier:actionIdentifier userText:userText];
}

@end

@interface UNNotificationContent (MUPrivate)

- (MUNotificationContent *)p_muNotificationContent;

@end

@interface UNNotificationTrigger (MUPrivate)

- (MUNotificationTrigger *)p_muNotificationTrigger;

@end

@interface UNNotificationRequest (MUPrivate)

- (MUNotificationRequest *)p_muNotificationRequest;

@end

@implementation UNNotificationRequest (MUPrivate)

- (MUNotificationRequest *)p_muNotificationRequest
{
    MUNotificationRequest *muRequest = [MUNotificationRequest requestWithIdentifier:self.identifier
                                                                            content:[self.content p_muNotificationContent]
                                                                            trigger:[self.trigger p_muNotificationTrigger]];
    return muRequest;
}

@end
