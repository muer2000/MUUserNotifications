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

@interface UIUserNotificationAction (MUPrivate)

- (MUNotificationAction *)p_muNotificationAction;

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@interface UNNotificationAction (MUPrivate)

- (MUNotificationAction *)p_muNotificationAction;

@end
#endif

@implementation UIUserNotificationCategory (MUPrivate)

- (MUNotificationCategory *)p_muNotificationCategory
{
    NSMutableArray<MUNotificationAction *> *mutableActions = [NSMutableArray array];
    NSArray<UIUserNotificationAction *> *uiActions = [self actionsForContext:UIUserNotificationActionContextDefault];
    [uiActions enumerateObjectsUsingBlock:^(UIUserNotificationAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableActions addObject:[obj p_muNotificationAction]];
    }];
    return [MUNotificationCategory categoryWithIdentifier:self.identifier actions:mutableActions];
}

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@implementation UNNotificationCategory (MUPrivate)

- (MUNotificationCategory *)p_muNotificationCategory
{
    NSMutableArray<MUNotificationAction *> *mutableActions = [NSMutableArray array];
    [self.actions enumerateObjectsUsingBlock:^(UNNotificationAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableActions addObject:[obj p_muNotificationAction]];
    }];
    return [MUNotificationCategory categoryWithIdentifier:self.identifier actions:mutableActions];
}

@end
#endif

@interface MUNotificationCategory (MUPrivate)

+ (NSMutableSet <UIUserNotificationCategory *> *)p_UICategoriesForMUCategories:(NSSet<MUNotificationCategory *> *)muCategories;
+ (NSMutableSet <MUNotificationCategory *> *)p_MUCategoriesForUICategories:(NSSet<UIUserNotificationCategory *> *)uiCategories;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
+ (NSMutableSet <UNNotificationCategory *> *)p_UNCategoriesForMUCategories:(NSSet<MUNotificationCategory *> *)muCategories;
+ (NSMutableSet <MUNotificationCategory *> *)p_MUCategoriesForUNCategories:(NSSet<UNNotificationCategory *> *)unCategories;
#endif

@end

@implementation MUNotificationCategory (MUPrivate)

- (UIUserNotificationCategory *)p_uiNotificationCategory
{
    NSMutableArray<UIUserNotificationAction *> *mutableActions = [NSMutableArray array];
    [self.actions enumerateObjectsUsingBlock:^(MUNotificationAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableActions addObject:[obj p_uiNotificationAction]];
    }];
    
    UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
    category.identifier = self.identifier;
    [category setActions:mutableActions forContext:UIUserNotificationActionContextDefault];
    return category;
}

+ (NSMutableSet <UIUserNotificationCategory *> *)p_UICategoriesForMUCategories:(NSSet<MUNotificationCategory *> *)muCategories
{
    if (!muCategories || muCategories.count == 0) {
        return nil;
    }
    NSMutableSet <UIUserNotificationCategory *> *mutableSet = [NSMutableSet set];
    [muCategories enumerateObjectsUsingBlock:^(MUNotificationCategory * _Nonnull obj, BOOL * _Nonnull stop) {
        [mutableSet addObject:[obj p_uiNotificationCategory]];
    }];
    return mutableSet;
}

+ (NSMutableSet <MUNotificationCategory *> *)p_MUCategoriesForUICategories:(NSSet<UIUserNotificationCategory *> *)uiCategories
{
    if (!uiCategories || uiCategories.count == 0) {
        return nil;
    }
    NSMutableSet <MUNotificationCategory *> *mutableSet = [NSMutableSet set];
    [uiCategories enumerateObjectsUsingBlock:^(UIUserNotificationCategory * _Nonnull obj, BOOL * _Nonnull stop) {
        [mutableSet addObject:[obj p_muNotificationCategory]];
    }];
    return mutableSet;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UNNotificationCategory *)p_unNotificationCategory
{
    NSMutableArray <UNNotificationAction *> *mutableActions = [NSMutableArray array];
    [self.actions enumerateObjectsUsingBlock:^(MUNotificationAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableActions addObject:[obj p_unNotificationAction]];
    }];
    
    return [UNNotificationCategory categoryWithIdentifier:self.identifier
                                                  actions:mutableActions
                                        intentIdentifiers:self.intentIdentifiers
                                                  options:(UNNotificationCategoryOptions)self.options];
}

+ (NSMutableSet <UNNotificationCategory *> *)p_UNCategoriesForMUCategories:(NSSet<MUNotificationCategory *> *)muCategories
{
    if (!muCategories || muCategories.count == 0) {
        return nil;
    }
    NSMutableSet <UNNotificationCategory *> *mutableSet = [NSMutableSet set];
    [muCategories enumerateObjectsUsingBlock:^(MUNotificationCategory * _Nonnull obj, BOOL * _Nonnull stop) {
        [mutableSet addObject:[obj p_unNotificationCategory]];
    }];
    return mutableSet;
}

+ (NSMutableSet <MUNotificationCategory *> *)p_MUCategoriesForUNCategories:(NSSet<UNNotificationCategory *> *)unCategories
{
    if (!unCategories || unCategories.count == 0) {
        return nil;
    }
    NSMutableSet <MUNotificationCategory *> *mutableSet = [NSMutableSet set];
    [unCategories enumerateObjectsUsingBlock:^(UNNotificationCategory * _Nonnull obj, BOOL * _Nonnull stop) {
        [mutableSet addObject:[obj p_muNotificationCategory]];
    }];
    return mutableSet;
}
#endif

@end
