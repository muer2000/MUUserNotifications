//
//  MUNotificationAction.m
//  MUNotifications
//
//  Created by Muer on 16/7/26.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "MUNotificationAction.h"
#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@import UserNotifications;
#endif

@interface MUNotificationAction ()

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) MUNotificationActionOptions options;

@end

@implementation MUNotificationAction

+ (instancetype)actionWithIdentifier:(NSString *)identifier title:(NSString *)title options:(MUNotificationActionOptions)options
{
    return [[self alloc] initWithIdentifier:identifier title:title options:options];
}

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title options:(MUNotificationActionOptions)options
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.title = title;
        self.options = options;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"MUNotificationAction: %p, identifier: %@, title: %@, options: %zd", self, self.identifier, self.title, self.options];
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeInteger:self.options forKey:NSStringFromSelector(@selector(options))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.identifier = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(identifier))];
        self.title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
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
    return [[MUNotificationAction allocWithZone:zone] initWithIdentifier:self.identifier title:self.title options:self.options];
}

@end


@interface MUTextInputNotificationAction ()

@property (nonatomic, copy) NSString *textInputButtonTitle;
@property (nonatomic, copy) NSString *textInputPlaceholder;

@end

@implementation MUTextInputNotificationAction

+ (instancetype)actionWithIdentifier:(NSString *)identifier title:(NSString *)title options:(MUNotificationActionOptions)options textInputButtonTitle:(nullable NSString *)textInputButtonTitle
{
    return [self actionWithIdentifier:identifier title:title options:options textInputButtonTitle:textInputButtonTitle textInputPlaceholder:nil];
}

+ (instancetype)actionWithIdentifier:(NSString *)identifier title:(NSString *)title options:(MUNotificationActionOptions)options textInputButtonTitle:(nullable NSString *)textInputButtonTitle textInputPlaceholder:(nullable NSString *)textInputPlaceholder
{
    return [[self alloc] initWithIdentifier:identifier title:title options:options textInputButtonTitle:textInputButtonTitle textInputPlaceholder:textInputPlaceholder];
}

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title options:(MUNotificationActionOptions)options textInputButtonTitle:(NSString *)textInputButtonTitle textInputPlaceholder:(NSString *)textInputPlaceholder
{
    self = [super initWithIdentifier:identifier title:title options:options];
    if (self) {
        self.textInputButtonTitle = textInputButtonTitle;
        self.textInputPlaceholder = textInputPlaceholder;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"MUTextInputNotificationAction: %p, identifier: %@, title: %@, options: %zd, textInputButtonTitle: %@, textInputPlaceholder: %@", self, self.identifier, self.title, self.options, self.textInputButtonTitle, self.textInputPlaceholder];
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.textInputButtonTitle forKey:NSStringFromSelector(@selector(textInputButtonTitle))];
    [aCoder encodeObject:self.textInputPlaceholder forKey:NSStringFromSelector(@selector(textInputPlaceholder))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.textInputButtonTitle = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(textInputButtonTitle))];
        self.textInputPlaceholder = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(textInputPlaceholder))];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MUTextInputNotificationAction *action = [super copyWithZone:zone];
    action.textInputButtonTitle = self.textInputButtonTitle;
    action.textInputPlaceholder = self.textInputPlaceholder;
    return action;
}

@end


@interface MUNotificationAction (MUPrivate)

- (UIUserNotificationAction *)p_uiNotificationAction;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UNNotificationAction *)p_unNotificationAction;
#endif

@end

@implementation MUNotificationAction (MUPrivate)

- (UIUserNotificationAction *)p_uiNotificationAction
{
    UIMutableUserNotificationAction *uiAction = [[UIMutableUserNotificationAction alloc] init];
    uiAction.identifier = self.identifier;
    uiAction.title = self.title;
    // iOS 9 text input action
    if ([uiAction respondsToSelector:@selector(setBehavior:)] && [self isKindOfClass:[MUTextInputNotificationAction class]]) {
        uiAction.behavior = UIUserNotificationActionBehaviorTextInput;
        MUTextInputNotificationAction *inputAction = (MUTextInputNotificationAction *)self;
        if (inputAction.textInputButtonTitle) {
            uiAction.parameters = @{UIUserNotificationTextInputActionButtonTitleKey: inputAction.textInputButtonTitle};
        }
    }
    if (self.options & MUNotificationActionOptionForeground) {
        uiAction.activationMode = UIUserNotificationActivationModeForeground;
    }
    else {
        uiAction.activationMode = UIUserNotificationActivationModeBackground;
    }
    uiAction.authenticationRequired = ((self.options & MUNotificationActionOptionAuthenticationRequired) != 0);
    uiAction.destructive = ((self.options & MUNotificationActionOptionDestructive) != 0);
    
    return uiAction;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UNNotificationAction *)p_unNotificationAction
{
    // iOS 9 text input action
    if ([self isKindOfClass:[MUTextInputNotificationAction class]]) {
        MUTextInputNotificationAction *inputAction = (MUTextInputNotificationAction *)self;
        return [UNTextInputNotificationAction actionWithIdentifier:self.identifier
                                                             title:self.title
                                                           options:(UNNotificationActionOptions)self.options
                                              textInputButtonTitle:inputAction.textInputButtonTitle
                                              textInputPlaceholder:inputAction.textInputPlaceholder];
    }
    
    return [UNNotificationAction actionWithIdentifier:self.identifier
                                                title:self.title
                                              options:(UNNotificationActionOptions)self.options];
}
#endif

@end

@interface UIUserNotificationAction (MUPrivate)

- (MUNotificationAction *)p_muNotificationAction;

@end

@implementation UIUserNotificationAction (MUPrivate)

- (MUNotificationAction *)p_muNotificationAction
{
    MUNotificationActionOptions muActionOptions = 0;
    if (self.activationMode == UIUserNotificationActivationModeForeground) {
        muActionOptions |= MUNotificationActionOptionForeground;
    }
    if (self.authenticationRequired) {
        muActionOptions |= MUNotificationActionOptionAuthenticationRequired;
    }
    if (self.isDestructive) {
        muActionOptions |= MUNotificationActionOptionDestructive;
    }
    
    if ([self respondsToSelector:@selector(behavior)] && self.behavior == UIUserNotificationActionBehaviorTextInput) {
        return [MUTextInputNotificationAction actionWithIdentifier:self.identifier
                                                             title:self.title
                                                           options:muActionOptions
                                              textInputButtonTitle:self.parameters[UIUserNotificationTextInputActionButtonTitleKey]];
    }
    return [MUNotificationAction actionWithIdentifier:self.identifier title:self.title options:muActionOptions];
}

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@interface UNNotificationAction (MUPrivate)

- (MUNotificationAction *)p_muNotificationAction;

@end

@implementation UNNotificationAction (MUPrivate)

- (MUNotificationAction *)p_muNotificationAction
{
    if ([self isKindOfClass:[UNTextInputNotificationAction class]]) {
        UNTextInputNotificationAction *unInputAction = (UNTextInputNotificationAction *)self;
        return [MUTextInputNotificationAction actionWithIdentifier:self.identifier
                                                             title:self.title
                                                           options:(MUNotificationActionOptions)self.options
                                              textInputButtonTitle:unInputAction.textInputButtonTitle
                                              textInputPlaceholder:unInputAction.textInputPlaceholder];
    }
    return [MUNotificationAction actionWithIdentifier:self.identifier
                                                title:self.title
                                              options:(MUNotificationActionOptions)self.options];
}

@end
#endif
