//
//  MUUserNotificationCenter.m
//  MUNotifications
//
//  Created by Muer on 16/7/14.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "MUUserNotificationCenter.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "MUNotificationCategory.h"
#import "MUNotificationRequest.h"
#import "MUNotificationResponse.h"
#import "MUNotification.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    @import UserNotifications;
#endif

#ifndef NSFoundationVersionNumber_iOS_9_x_Max
    #define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

#define IS_IOS10_OR_GREATER (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max)

static NSString * const MUUserNotificationDeterminedKey = @"MUUserNotificationDeterminedKey";

static MUUNAuthorizationOptions MUUNAuthorizationOptionDefault = MUUNAuthorizationOptionBadge | MUUNAuthorizationOptionSound | MUUNAuthorizationOptionAlert;

@interface MUNotificationCategory (MUPrivate)

- (UIUserNotificationCategory *)p_uiNotificationCategory;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UNNotificationCategory *)p_unNotificationCategory;
#endif

@end

@interface MUNotificationRequest (MUPrivate)

- (UILocalNotification *)p_uiLocalNotification;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UNNotificationRequest *)p_unNotificationRequest;
#endif

@end

@interface UILocalNotification (MUPrivate)

- (MUNotificationRequest *)p_muNotificationRequest;
- (MUNotification *)p_muNotification;
- (MUNotificationResponse *)p_muResponseWithActionIdentifier:(NSString *)actionIdentifier;
- (MUNotificationResponse *)p_muTextInputResponseWithActionIdentifier:(NSString *)actionIdentifier userText:(NSString *)userText;

@property (nonatomic, readonly, nullable) NSString *mu_identifier;

@end

@interface NSDictionary (MURemoteUserInfoPrivate)

- (MUNotificationRequest *)p_muNotificationRequest;
- (MUNotification *)p_muNotification;
- (MUNotificationResponse *)p_muResponseWithActionIdentifier:(NSString *)actionIdentifier;
- (MUNotificationResponse *)p_muTextInputResponseWithActionIdentifier:(NSString *)actionIdentifier userText:(NSString *)userText;

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@interface UNNotificationRequest (MUPrivate)

- (MUNotificationRequest *)p_muNotificationRequest;

@end

@interface UNNotification (MUPrivate)

- (MUNotification *)p_muNotification;

@end

@interface UNNotificationResponse (MUPrivate)

- (MUNotificationResponse *)p_muNotificationResponse;

@end
#endif

static NSSet<UIUserNotificationCategory *> * MUUICategoriesForMUCategories(NSSet<MUNotificationCategory *> *muCategories) {
    if (!muCategories) {
        return nil;
    }
    NSMutableSet *mutableSet = [NSMutableSet set];
    [muCategories enumerateObjectsUsingBlock:^(MUNotificationCategory * _Nonnull obj, BOOL * _Nonnull stop) {
        [mutableSet addObject:[obj p_uiNotificationCategory]];
    }];
    return mutableSet;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
static NSSet<UNNotificationCategory *> * MUUNCategoriesForMUCategories(NSSet<MUNotificationCategory *> *muCategories) {
    if (!muCategories) {
        return nil;
    }
    NSMutableSet *mutableSet = [NSMutableSet set];
    [muCategories enumerateObjectsUsingBlock:^(MUNotificationCategory * _Nonnull obj, BOOL * _Nonnull stop) {
        [mutableSet addObject:[obj p_unNotificationCategory]];
    }];
    return mutableSet;
}
#endif

@interface MUUserNotificationCenter ()

@property (nonatomic, strong) NSSet<MUNotificationCategory *> *categories;
@property (nonatomic, copy) void (^requestAuthorizationCompletionHandler)(BOOL granted, NSError *error);

@end

@implementation MUUserNotificationCenter

+ (MUUNAuthorizationStatus)authorizationStatus
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if (IS_IOS10_OR_GREATER) {
        return (MUUNAuthorizationStatus)[self p_currentNotificationSettings].authorizationStatus;
    }
#endif
    
    // iOS 10 before
    BOOL determined = [[NSUserDefaults standardUserDefaults] boolForKey:MUUserNotificationDeterminedKey];
    if (determined) {
        UIApplication *application = [UIApplication sharedApplication];
        if ([application respondsToSelector:@selector(currentUserNotificationSettings)]) {
            if ([application currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
                return MUUNAuthorizationStatusDenied;
            }
            return MUUNAuthorizationStatusAuthorized;
        }
        else {
            if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
                return MUUNAuthorizationStatusDenied;
            }
            return MUUNAuthorizationStatusAuthorized;
        }
    }
    else {
        return MUUNAuthorizationStatusNotDetermined;
    }
}

+ (MUUNAuthorizationOptions)authorizationOptions
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if (IS_IOS10_OR_GREATER) {
        UNNotificationSettings *settings = [self p_currentNotificationSettings];
        MUUNAuthorizationOptions options = MUUNAuthorizationOptionNone;
        if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
            return options;
        }
        
        if (settings.badgeSetting == UNNotificationSettingEnabled) {
            options |= MUUNAuthorizationOptionBadge;
        }
        if (settings.soundSetting == UNNotificationSettingEnabled) {
            options |= MUUNAuthorizationOptionSound;
        }
        if (settings.alertSetting == UNNotificationSettingEnabled) {
            options |= MUUNAuthorizationOptionAlert;
        }
        return options;
    }
#endif
    
    // iOS 10 before
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(currentUserNotificationSettings)]) {
        return (MUUNAuthorizationOptions)[application currentUserNotificationSettings].types;
    }
    
    // iOS 8 before
    return (MUUNAuthorizationOptions)[application enabledRemoteNotificationTypes];
}

+ (void)registerRemoteNotifications
{
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [[self currentNotificationCenter] requestAuthorizationWithOptions:MUUNAuthorizationOptionDefault categories:nil completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
                [application registerForRemoteNotifications];
            }
        }];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)MUUNAuthorizationOptionDefault];
    }
}

+ (BOOL)isRegisteredForRemoteNotifications
{
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        return [application isRegisteredForRemoteNotifications];
    }
    
    UIRemoteNotificationType types = [application enabledRemoteNotificationTypes];
    return (types & UIRemoteNotificationTypeBadge) || (types & UIRemoteNotificationTypeSound) || (types & UIRemoteNotificationTypeAlert);
}

+ (MUUserNotificationCenter *)currentNotificationCenter
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)registerForRemoteNotifications
{
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)MUUNAuthorizationOptionDefault];
    }
}


- (void)requestAuthorizationWithOptions:(MUUNAuthorizationOptions)options categories:(nullable NSSet<MUNotificationCategory *> *)categories completionHandler:(void (^)(BOOL granted, NSError *__nullable error))completionHandler
{
    if ((floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_8_0)) {
        if (completionHandler) {
            completionHandler(YES, nil);
        }
        return;
    }
    
    self.categories = categories;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if (IS_IOS10_OR_GREATER) {
        UNUserNotificationCenter *currentCenter = [UNUserNotificationCenter currentNotificationCenter];
        [currentCenter requestAuthorizationWithOptions:(UNAuthorizationOptions)options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted && categories) {
                [currentCenter setNotificationCategories:MUUNCategoriesForMUCategories(categories)];
            }
            
            if (completionHandler) {
                completionHandler(granted, error);
            }
        }];
    }
    else {
        if (completionHandler) {
            self.requestAuthorizationCompletionHandler = completionHandler;
        }
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationType)options categories:MUUICategoriesForMUCategories(categories)];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
#else
    if (completionHandler) {
        self.requestAuthorizationCompletionHandler = completionHandler;
    }
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationType)options categories:MUUICategoriesForMUCategories(categories)];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
}

- (void)addNotificationRequest:(MUNotificationRequest *)request withCompletionHandler:(nullable void(^)(NSError *__nullable error))completionHandler
{
    if (!request) {
        if (completionHandler) {
            completionHandler(nil);
        }
        return;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if (IS_IOS10_OR_GREATER) {
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:[request p_unNotificationRequest] withCompletionHandler:^(NSError * _Nullable error) {
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
    else {
        if (request.trigger) {
            [[UIApplication sharedApplication] scheduleLocalNotification:[request p_uiLocalNotification]];
        }
        else {
            [[UIApplication sharedApplication] presentLocalNotificationNow:[request p_uiLocalNotification]];
        }
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }
#else
    if (request.trigger) {
        [[UIApplication sharedApplication] scheduleLocalNotification:[request p_uiLocalNotification]];
    }
    else {
        [[UIApplication sharedApplication] presentLocalNotificationNow:[request p_uiLocalNotification]];
    }
    
    if (completionHandler) {
        completionHandler(nil);
    }
#endif
    
}


#pragma mark - Pending Notification

- (nullable NSArray<MUNotificationRequest *> *)pendingNotificationRequests
{
    NSMutableArray *mutableRequests = [NSMutableArray array];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if (IS_IOS10_OR_GREATER) {
        NSArray<UNNotificationRequest *> *requests = [MUUserNotificationCenter p_currentPendingNotificationRequests];
        [requests enumerateObjectsUsingBlock:^(UNNotificationRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mutableRequests addObject:[obj p_muNotificationRequest]];
        }];
    }
    else {
        NSArray<UILocalNotification *> *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        [notifications enumerateObjectsUsingBlock:^(UILocalNotification * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mutableRequests addObject:[obj p_muNotificationRequest]];
        }];
    }
#else
    NSArray<UILocalNotification *> *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    [notifications enumerateObjectsUsingBlock:^(UILocalNotification * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableRequests addObject:[obj p_muNotificationRequest]];
    }];
#endif
    
    return mutableRequests;
}

- (void)removePendingNotificationRequestsWithIdentifiers:(NSArray<NSString *> *)identifiers
{
    if (identifiers.count == 0) {
        return;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if (IS_IOS10_OR_GREATER) {
        [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:identifiers];
    }
    else {
        NSArray<UILocalNotification *> *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *itemNotification in notifications) {
            if ([identifiers containsObject:itemNotification.mu_identifier]) {
                [[UIApplication sharedApplication] cancelLocalNotification:itemNotification];
            }
        }
    }
#else
    NSArray<UILocalNotification *> *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *itemNotification in notifications) {
        if ([identifiers containsObject:itemNotification.mu_identifier]) {
            [[UIApplication sharedApplication] cancelLocalNotification:itemNotification];
        }
    }
#endif
}

- (void)removeAllPendingNotificationRequests
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if (IS_IOS10_OR_GREATER) {
        [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    }
    else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
#else
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
#endif
}


#pragma mark - Delivered Notifications

- (nullable NSArray<MUNotification *> *)deliveredNotifications
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    NSMutableArray *mutableNotifications = [NSMutableArray array];
    NSArray<UNNotification *> *unNotifications = [MUUserNotificationCenter p_currentDeliveredNotifications];
    [unNotifications enumerateObjectsUsingBlock:^(UNNotification * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableNotifications addObject:[obj p_muNotification]];
    }];
    return mutableNotifications;
#else
    return nil;
#endif
}

- (void)removeDeliveredNotificationsWithIdentifiers:(NSArray<NSString *> *)identifiers
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:identifiers];
#endif
}

- (void)removeAllDeliveredNotifications
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
#endif
}


#pragma mark - Property get methods

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UNNotificationSettings *)settings
{
    return [MUUserNotificationCenter p_currentNotificationSettings];
}
#endif

#pragma mark - Private

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
+ (UNNotificationSettings *)p_currentNotificationSettings
{
    __block UNNotificationSettings *bSettings = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        bSettings = settings;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return bSettings;
}

+ (NSArray<UNNotificationRequest *> *)p_currentPendingNotificationRequests
{
    __block NSArray<UNNotificationRequest *> *bRequests = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        bRequests = requests;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return bRequests;
}

+ (NSArray<UNNotification *> *)p_currentDeliveredNotifications
{
    __block NSArray<UNNotification *> *bNotification = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
        bNotification = notifications;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return bNotification;
}
#endif

- (void)p_handleRegisterUserNotificationCallbackWithSettings:(UIUserNotificationSettings *)settings
{
    if (self.requestAuthorizationCompletionHandler) {
        self.requestAuthorizationCompletionHandler(settings.types != UIUserNotificationTypeNone, nil);
        self.requestAuthorizationCompletionHandler = nil;
    }
}

- (void)p_handleUndeterminedTag
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:MUUserNotificationDeterminedKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:MUUserNotificationDeterminedKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)p_handleReceiveNotificationWithApplication:(UIApplication *)application response:(MUNotificationResponse *)response
{
    if (application.applicationState == UIApplicationStateActive) {
        if ([self.delegate respondsToSelector:@selector(mu_userNotificationCenter:willPresentNotification:)]) {
            [self.delegate mu_userNotificationCenter:self willPresentNotification:response.notification];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(mu_userNotificationCenter:didReceiveNotificationResponse:)]) {
            [self.delegate mu_userNotificationCenter:self didReceiveNotificationResponse:response];
        }
    }
}

- (BOOL)p_handleActionWithApplication:(UIApplication *)application response:(MUNotificationResponse *)response completionHandler:(void(^)())completionHandler
{
    if ([self.delegate respondsToSelector:@selector(mu_userNotificationCenter:didReceiveNotificationResponse:)]) {
        [self.delegate mu_userNotificationCenter:self didReceiveNotificationResponse:response];
    }
    
    BOOL respondsHandler = NO;
    
    if ([self.delegate respondsToSelector:@selector(mu_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)]) {
        [self.delegate mu_userNotificationCenter:self didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
        respondsHandler = YES;
    }
    
    return respondsHandler;
}

- (void)p_handleWillPresentNotification:(MUNotification *)notification withCompletionHandler:(void (^)(MUNotificationPresentationOptions options))completionHandler
{
    if ([self.delegate respondsToSelector:@selector(mu_userNotificationCenter:willPresentNotification:)]) {
        [self.delegate mu_userNotificationCenter:self willPresentNotification:notification];
    }
    
    if ([self.delegate respondsToSelector:@selector(mu_userNotificationCenter:willPresentNotification:withCompletionHandler:)]) {
        [self.delegate mu_userNotificationCenter:self willPresentNotification:notification withCompletionHandler:completionHandler];
    }
}

- (BOOL)p_handleDidReceiveNotificationResponse:(MUNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler
{
    if ([self.delegate respondsToSelector:@selector(mu_userNotificationCenter:didReceiveNotificationResponse:)]) {
        [self.delegate mu_userNotificationCenter:self didReceiveNotificationResponse:response];
    }
    
    BOOL respondsHandler = NO;

    if ([self.delegate respondsToSelector:@selector(mu_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)]) {
        [self.delegate mu_userNotificationCenter:self didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
        respondsHandler = YES;
    }
    
    return respondsHandler;
}

@end


static Class MUClassWithProtocolInHierarchy(Class aClass, Protocol *aProtocol) {
    Class tmpClass = aClass;
    while (tmpClass) {
        if (class_conformsToProtocol(tmpClass, aProtocol)) {
            break;
        }
        tmpClass = [tmpClass superclass];
    }
    return tmpClass;
}

static void MUSwizzleProtocolSelector(Class delegateClass, SEL delegateSelector, Class swizzledClass, SEL swizzledSelector) {
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    IMP swizzledSelectorIMP = method_getImplementation(swizzledMethod);
    
    if (!class_addMethod(delegateClass, delegateSelector, swizzledSelectorIMP, method_getTypeEncoding(swizzledMethod))) {
        class_addMethod(delegateClass, swizzledSelector, swizzledSelectorIMP, method_getTypeEncoding(swizzledMethod));
        swizzledMethod = class_getInstanceMethod(delegateClass, swizzledSelector);
        
        Method originalMethod = class_getInstanceMethod(delegateClass, delegateSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


#define kCurrentNotificationCenter ([MUUserNotificationCenter currentNotificationCenter])

@implementation UIApplication (MUUserNotificationsPrivate)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([self class], @selector(setDelegate:));
        Method swizzledMethod = class_getInstanceMethod([self class], @selector(muun_setDelegate:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        if (!IS_IOS10_OR_GREATER) {
            if ((floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0)) {
                originalMethod = class_getInstanceMethod([self class], @selector(registerUserNotificationSettings:));
                swizzledMethod = class_getInstanceMethod([self class], @selector(muun_registerUserNotificationSettings:));
            }
            else {
                originalMethod = class_getInstanceMethod([self class], @selector(registerForRemoteNotificationTypes:));
                swizzledMethod = class_getInstanceMethod([self class], @selector(muun_registerForRemoteNotificationTypes:));
            }
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)muun_setDelegate:(id <UIApplicationDelegate>)delegate
{
    static Class delegateClass = nil;
    // only once
    if (delegateClass) {
        // calling the original method (setDelegate:)
        [self muun_setDelegate:delegate];
        return;
    }
    
    double versionNumber = floor(NSFoundationVersionNumber);
    
    delegateClass = MUClassWithProtocolInHierarchy([delegate class], @protocol(UIApplicationDelegate));
    
    // handle requestAuthorizationCompletionHandler
    MUSwizzleProtocolSelector(delegateClass, @selector(application:didRegisterUserNotificationSettings:), [self class], @selector(muun_application:didRegisterUserNotificationSettings:));
    
    // local notification
    MUSwizzleProtocolSelector(delegateClass, @selector(application:didReceiveLocalNotification:), [self class], @selector(muun_application:didReceiveLocalNotification:));
    
    // remote notification / iOS 7 silent remote notifications
    if (versionNumber >= NSFoundationVersionNumber_iOS_7_0 && [delegate respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
        MUSwizzleProtocolSelector(delegateClass, @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:), [self class], @selector(muun_application:didReceiveRemoteNotification:fetchCompletionHandler:));
    }
    else {
        MUSwizzleProtocolSelector(delegateClass, @selector(application:didReceiveRemoteNotification:), [self class], @selector(muun_application:didReceiveRemoteNotification:));
    }
    
    // iOS 8 notification action
    if (versionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        MUSwizzleProtocolSelector(delegateClass, @selector(application:handleActionWithIdentifier:forLocalNotification:completionHandler:), [self class], @selector(muun_application:handleActionWithIdentifier:forLocalNotification:completionHandler:));
        MUSwizzleProtocolSelector(delegateClass, @selector(application:handleActionWithIdentifier:forRemoteNotification:completionHandler:), [self class], @selector(muun_application:handleActionWithIdentifier:forRemoteNotification:completionHandler:));
    }

    // iOS 9 notification action behavior text input
    if (versionNumber > NSFoundationVersionNumber_iOS_8_4) {
        MUSwizzleProtocolSelector(delegateClass, @selector(application:handleActionWithIdentifier:forLocalNotification:withResponseInfo:completionHandler:), [self class], @selector(muun_application:handleActionWithIdentifier:forLocalNotification:withResponseInfo:completionHandler:));
        MUSwizzleProtocolSelector(delegateClass, @selector(application:handleActionWithIdentifier:forRemoteNotification:withResponseInfo:completionHandler:), [self class], @selector(muun_application:handleActionWithIdentifier:forRemoteNotification:withResponseInfo:completionHandler:));
    }
    
    // calling the original method (setDelegate:)
    [self muun_setDelegate:delegate];
}

#pragma mark - Swizzle registerUserNotificationSettings / registerForRemoteNotificationTypes

- (void)muun_registerUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [kCurrentNotificationCenter p_handleUndeterminedTag];
    [self muun_registerUserNotificationSettings:notificationSettings];
}

- (void)muun_registerForRemoteNotificationTypes:(UIRemoteNotificationType)types
{
    [kCurrentNotificationCenter p_handleUndeterminedTag];
    [self muun_registerForRemoteNotificationTypes:types];
}

#pragma mark - Swizzle UIApplicationDelegate

- (void)muun_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [kCurrentNotificationCenter p_handleRegisterUserNotificationCallbackWithSettings:notificationSettings];
    
    if ([self respondsToSelector:@selector(muun_application:didRegisterUserNotificationSettings:)]) {
        [self muun_application:application didRegisterUserNotificationSettings:notificationSettings];
    }
}

#pragma mark Local Notification

- (void)muun_application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [kCurrentNotificationCenter p_handleReceiveNotificationWithApplication:application response:[notification p_muResponseWithActionIdentifier:MUNotificationDefaultActionIdentifier]];
    
    if ([self respondsToSelector:@selector(muun_application:didReceiveLocalNotification:)]) {
        [self muun_application:application didReceiveLocalNotification:notification];
    }
}

#pragma mark Remote Notification

- (void)muun_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [kCurrentNotificationCenter p_handleReceiveNotificationWithApplication:application response:[userInfo p_muResponseWithActionIdentifier:MUNotificationDefaultActionIdentifier]];
    
    if ([self respondsToSelector:@selector(muun_application:didReceiveRemoteNotification:)]) {
        [self muun_application:application didReceiveRemoteNotification:userInfo];
    }
}

- (void)muun_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    [kCurrentNotificationCenter p_handleReceiveNotificationWithApplication:application response:[userInfo p_muResponseWithActionIdentifier:MUNotificationDefaultActionIdentifier]];
    
    if ([self respondsToSelector:@selector(muun_application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
        [self muun_application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }
}

#pragma mark iOS 8 Notification Action

- (void)muun_application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler
{
    BOOL respondsHandler = [kCurrentNotificationCenter p_handleActionWithApplication:application response:[notification p_muResponseWithActionIdentifier:identifier] completionHandler:completionHandler];
    
    if ([self respondsToSelector:@selector(muun_application:handleActionWithIdentifier:forLocalNotification:completionHandler:)]) {
        [self muun_application:application handleActionWithIdentifier:identifier forLocalNotification:notification completionHandler:completionHandler];
    }
    else if (!respondsHandler) {
        completionHandler();
    }
}

- (void)muun_application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    BOOL respondsHandler = [kCurrentNotificationCenter p_handleActionWithApplication:application response:[userInfo p_muResponseWithActionIdentifier:identifier] completionHandler:completionHandler];

    if ([self respondsToSelector:@selector(muun_application:handleActionWithIdentifier:forRemoteNotification:completionHandler:)]) {
        [self muun_application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:completionHandler];
    }
    else if (!respondsHandler) {
        completionHandler();
    }
}

#pragma mark - iOS 9 Notification Action Behavior Text Input

- (void)muun_application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler
{
    BOOL respondsHandler = [kCurrentNotificationCenter p_handleActionWithApplication:application response:[notification p_muTextInputResponseWithActionIdentifier:identifier userText:responseInfo[UIUserNotificationActionResponseTypedTextKey]] completionHandler:completionHandler];
    
    if ([self respondsToSelector:@selector(muun_application:handleActionWithIdentifier:forLocalNotification:withResponseInfo:completionHandler:)]) {
        [self muun_application:application handleActionWithIdentifier:identifier forLocalNotification:notification withResponseInfo:responseInfo completionHandler:completionHandler];
    }
    else if (!respondsHandler) {
        completionHandler();
    }
}

- (void)muun_application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler
{
    BOOL respondsHandler = [kCurrentNotificationCenter p_handleActionWithApplication:application response:[userInfo p_muTextInputResponseWithActionIdentifier:identifier userText:responseInfo[UIUserNotificationActionResponseTypedTextKey]] completionHandler:completionHandler];

    if ([self respondsToSelector:@selector(muun_application:handleActionWithIdentifier:forRemoteNotification:withResponseInfo:completionHandler:)]) {
        [self muun_application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo withResponseInfo:responseInfo completionHandler:completionHandler];
    }
    else if (!respondsHandler) {
        completionHandler();
    }
}

@end


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@implementation UNUserNotificationCenter (MUUserNotificationsPrivate)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([self class], @selector(setDelegate:));
        Method swizzledMethod = class_getInstanceMethod([self class], @selector(muun_setDelegate:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)muun_setDelegate:(id<UNUserNotificationCenterDelegate>)delegate
{
    static Class delegateClass = nil;
    // only once
    if (delegateClass) {
        // calling the original method (setDelegate:)
        [self muun_setDelegate:delegate];
        return;
    }

    delegateClass = MUClassWithProtocolInHierarchy([delegate class], @protocol(UNUserNotificationCenterDelegate));
    
    MUSwizzleProtocolSelector(delegateClass,
                              @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:),
                              [self class],
                              @selector(muun_userNotificationCenter:willPresentNotification:withCompletionHandler:));
    
    MUSwizzleProtocolSelector(delegateClass,
                              @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:),
                              [self class],
                              @selector(muun_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:));
    
    // calling the original method (setDelegate:)
    [self muun_setDelegate:delegate];
}


#pragma mark - Swizzle UNUserNotificationCenterDelegate

- (void)muun_userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    [kCurrentNotificationCenter p_handleWillPresentNotification:[notification p_muNotification] withCompletionHandler:^(MUNotificationPresentationOptions options) {
        completionHandler((UNNotificationPresentationOptions)options);
    }];

    if ([self respondsToSelector:@selector(muun_userNotificationCenter:willPresentNotification:withCompletionHandler:)]) {
        [self muun_userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
    }
}

- (void)muun_userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler
{
    BOOL respondsHandler = [kCurrentNotificationCenter p_handleDidReceiveNotificationResponse:[response p_muNotificationResponse] withCompletionHandler:completionHandler];
    
    if ([self respondsToSelector:@selector(muun_userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)]) {
        [self muun_userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    }
    else if (!respondsHandler) {
        completionHandler();
    }
}

@end
#endif
