//
//  MUNotificationContent.m
//  MUNotifications
//
//  Created by Muer on 16/7/27.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "MUNotificationContent.h"
#import <UIKit/UIKit.h>
@import UserNotifications;

@interface MUNotificationContent ()

@property (nonatomic, copy) NSNumber *badge;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *categoryIdentifier;
@property (nonatomic, copy) NSString *launchImageName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDictionary *userInfo;
@property (nonatomic, copy) MUNotificationSound *sound;
@property (nonatomic, copy) NSArray <UNNotificationAttachment *> *attachments;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *threadIdentifier;
@property (nonatomic, copy) NSString *alertAction;

@end

@implementation MUNotificationContent

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p>, badge: %@, body: %@, categoryIdentifier: %@, userInfo: %@, sound: %@", NSStringFromClass([self class]), self, self.badge, self.body, self.categoryIdentifier, self.userInfo, self.sound];
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.badge forKey:NSStringFromSelector(@selector(badge))];
    [aCoder encodeObject:self.body forKey:NSStringFromSelector(@selector(body))];
    [aCoder encodeObject:self.categoryIdentifier forKey:NSStringFromSelector(@selector(categoryIdentifier))];
    [aCoder encodeObject:self.launchImageName forKey:NSStringFromSelector(@selector(launchImageName))];
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeObject:self.userInfo forKey:NSStringFromSelector(@selector(userInfo))];
    [aCoder encodeObject:self.sound forKey:NSStringFromSelector(@selector(sound))];
    [aCoder encodeObject:self.attachments forKey:NSStringFromSelector(@selector(attachments))];
    [aCoder encodeObject:self.subtitle forKey:NSStringFromSelector(@selector(subtitle))];
    [aCoder encodeObject:self.threadIdentifier forKey:NSStringFromSelector(@selector(threadIdentifier))];
    [aCoder encodeObject:self.alertAction forKey:NSStringFromSelector(@selector(alertAction))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.badge = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(badge))];
        self.body = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(body))];
        self.categoryIdentifier = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(categoryIdentifier))];
        self.launchImageName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(launchImageName))];
        self.title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
        self.userInfo = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userInfo))];
        self.sound = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(sound))];
        self.attachments = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(attachments))];
        self.subtitle = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(subtitle))];
        self.threadIdentifier = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(threadIdentifier))];
        self.alertAction = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(alertAction))];
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
    MUNotificationContent *content = [[MUNotificationContent allocWithZone:zone] init];
    content.badge = self.badge;
    content.body = self.body;
    content.categoryIdentifier = self.categoryIdentifier;
    content.launchImageName = self.launchImageName;
    content.title = self.title;
    content.userInfo = self.userInfo;
    content.sound = self.sound;
    content.attachments = self.attachments;
    content.subtitle = self.subtitle;
    content.threadIdentifier = self.threadIdentifier;
    content.alertAction = self.alertAction;
    return content;
}

@end

@interface MUMutableNotificationContent ()

@end

@implementation MUMutableNotificationContent

@dynamic badge;
@dynamic body;
@dynamic categoryIdentifier;
@dynamic launchImageName;
@dynamic title;
@dynamic userInfo;
@dynamic sound;
@dynamic attachments;
@dynamic subtitle;
@dynamic threadIdentifier;
@dynamic alertAction;

@end


@interface MUNotificationSound ()

@property (nonatomic, copy) NSString *soundName;

@end

@implementation MUNotificationSound

+ (instancetype)defaultSound
{
    static MUNotificationSound *sound;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sound = [[self alloc] init];
        sound.soundName = UILocalNotificationDefaultSoundName;
    });
    return sound;
}

+ (instancetype)soundNamed:(NSString *)name
{
    MUNotificationSound *sound = [[self alloc] init];
    sound.soundName = name;
    return sound;
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.soundName forKey:NSStringFromSelector(@selector(soundName))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.soundName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(soundName))];
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
    MUNotificationSound *sound = [MUNotificationSound allocWithZone:zone];
    sound.soundName = self.soundName;
    return sound;
}

@end


@interface MUNotificationContent (MUPrivate)

- (NSString *)p_soundName;
- (UNNotificationContent *)p_unNotificationContent;

@end

@implementation MUNotificationContent (MUPrivate)

- (NSString *)p_soundName
{
    if (self.sound) {
        return self.sound.soundName;
    }
    return nil;
}

- (UNNotificationContent *)p_unNotificationContent
{
    UNMutableNotificationContent *unContent = [[UNMutableNotificationContent alloc] init];
    unContent.badge = self.badge;
    unContent.body = self.body;
    unContent.categoryIdentifier = self.categoryIdentifier;
    unContent.launchImageName = self.launchImageName;
    unContent.title = self.title;
    unContent.userInfo = self.userInfo;
    if (self.sound) {
        if (self.sound == [MUNotificationSound defaultSound]) {
            unContent.sound = [UNNotificationSound defaultSound];
        }
        else {
            unContent.sound = [UNNotificationSound soundNamed:self.sound.soundName];
        }
    }
    unContent.attachments = self.attachments;
    unContent.subtitle = self.subtitle;
    unContent.threadIdentifier = self.threadIdentifier;
    return unContent;
}

@end

@interface UNNotificationContent (MUPrivate)

- (MUNotificationContent *)p_muNotificationContent;

@end

@implementation UNNotificationContent (MUPrivate)

- (MUNotificationContent *)p_muNotificationContent
{
    MUMutableNotificationContent *muContent = [[MUMutableNotificationContent alloc] init];
    muContent.badge = self.badge;
    muContent.body = self.body;
    muContent.categoryIdentifier = self.categoryIdentifier;
    muContent.launchImageName = self.launchImageName;
    muContent.title = self.title;
    muContent.userInfo = self.userInfo;
    if (self.sound) {
        if (self.sound == [UNNotificationSound defaultSound]) {
            muContent.sound = [MUNotificationSound defaultSound];
        }
        else {
            NSString *toneFileName = [self.sound valueForKey:@"toneFileName"];
            if (toneFileName) {
                muContent.sound = [MUNotificationSound soundNamed:toneFileName];
            }
        }
    }
    muContent.attachments = self.attachments;
    muContent.subtitle = self.subtitle;
    muContent.threadIdentifier = self.threadIdentifier;
    return muContent;
}

@end
