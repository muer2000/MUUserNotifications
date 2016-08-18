//
//  MUNotificationCategory.m
//  MUNotifications
//
//  Created by Muer on 16/7/26.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "MUNotificationCategory.h"
#import <UIKit/UIKit.h>
#import "MUNotificationAction.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@import UserNotifications;
#endif

@interface MUNotificationCategory ()

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSArray<MUNotificationAction *> *actions;

@property (nonatomic, assign) MUNotificationCategoryOptions options;
@property (nonatomic, copy) NSArray<NSString *> *intentIdentifiers;

@end

@implementation MUNotificationCategory

+ (instancetype)categoryWithIdentifier:(NSString *)identifier actions:(NSArray<MUNotificationAction *> *)actions
{
    return [self categoryWithIdentifier:identifier actions:actions intentIdentifiers:nil options:MUNotificationCategoryOptionNone];
}

+ (instancetype)categoryWithIdentifier:(NSString *)identifier actions:(NSArray<MUNotificationAction *> *)actions intentIdentifiers:(nullable NSArray<NSString *> *)intentIdentifiers options:(MUNotificationCategoryOptions)options
{
    return [[self alloc] initWithIdentifier:identifier actions:actions intentIdentifiers:intentIdentifiers options:options];
}

- (instancetype)initWithIdentifier:(NSString *)identifier actions:(NSArray<MUNotificationAction *> *)actions intentIdentifiers:(nullable NSArray<NSString *> *)intentIdentifiers options:(MUNotificationCategoryOptions)options
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.actions = actions;
        self.intentIdentifiers = intentIdentifiers;
        self.options = options;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"MUNotificationCategory: %p, identifier: %@, actions: %@, options: %zd, intentIdentifiers: %@", self, self.identifier, self.actions, self.options, self.intentIdentifiers];
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
    [aCoder encodeObject:self.actions forKey:NSStringFromSelector(@selector(actions))];
    [aCoder encodeInteger:self.options forKey:NSStringFromSelector(@selector(options))];
    [aCoder encodeObject:self.intentIdentifiers forKey:NSStringFromSelector(@selector(intentIdentifiers))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.identifier = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(identifier))];
        self.actions = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(actions))];
        self.intentIdentifiers = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(intentIdentifiers))];
        self.options = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(options))];
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
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

@end


@interface MUNotificationAction (MUPrivate)

- (UIUserNotificationAction *)p_uiNotificationAction;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UNNotificationAction *)p_unNotificationAction;
#endif

@end


@interface MUNotificationCategory (MUPrivate)

- (UIUserNotificationCategory *)p_uiNotificationCategory;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UNNotificationCategory *)p_unNotificationCategory;
#endif

@end

static NSArray<UIUserNotificationAction *> * MUUIActionsForMUActions(NSArray<MUNotificationAction *> *muActions) {
    if (!muActions) {
        return nil;
    }
    NSMutableArray *mutableActions = [NSMutableArray array];
    [muActions enumerateObjectsUsingBlock:^(MUNotificationAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableActions addObject:[obj p_uiNotificationAction]];
    }];
    return mutableActions;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
static NSArray<UNNotificationAction *> * MUUNActionsForMUActions(NSArray<MUNotificationAction *> *muActions) {
    if (!muActions) {
        return nil;
    }
    NSMutableArray *mutableActions = [NSMutableArray array];
    [muActions enumerateObjectsUsingBlock:^(MUNotificationAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableActions addObject:[obj p_unNotificationAction]];
    }];
    return mutableActions;
}
#endif

@implementation MUNotificationCategory (MUPrivate)

- (UIUserNotificationCategory *)p_uiNotificationCategory
{
    UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
    category.identifier = self.identifier;
    if (self.actions) {
        [category setActions:MUUIActionsForMUActions(self.actions) forContext:UIUserNotificationActionContextDefault];
    }
    return category;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UNNotificationCategory *)p_unNotificationCategory
{
    return [UNNotificationCategory categoryWithIdentifier:self.identifier
                                                  actions:MUUNActionsForMUActions(self.actions)
                                        intentIdentifiers:self.intentIdentifiers
                                                  options:(UNNotificationCategoryOptions)self.options];
}
#endif

@end
