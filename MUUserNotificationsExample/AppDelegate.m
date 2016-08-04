//
//  AppDelegate.m
//  MUUserNotificationsExample
//
//  Created by Muer on 16/8/3.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "AppDelegate.h"
#import "MUUserNotifications.h"

@interface AppDelegate () <MUUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [MUUserNotificationCenter currentNotificationCenter].delegate = self;

    return YES;
}


#pragma mark - MUUserNotificationCenterDelegate

- (void)mu_userNotificationCenter:(MUUserNotificationCenter *)center willPresentNotification:(MUNotification *)notification
{
    NSLog(@"*** willPresentNotification userInfo: %@", notification.request.content.userInfo);
}

- (void)mu_userNotificationCenter:(MUUserNotificationCenter *)center didReceiveNotificationResponse:(MUNotificationResponse *)response
{
    NSLog(@"*** didReceiveNotificationResponse userInfo: %@", response.notification.request.content.userInfo);
}

- (void)mu_userNotificationCenter:(MUUserNotificationCenter *)center willPresentNotification:(MUNotification *)notification withCompletionHandler:(void (^)(MUNotificationPresentationOptions options))completionHandler
{
    NSLog(@"*** willPresentNotification completionHandler userInfo: %@", notification.request.content.userInfo);
    completionHandler(MUNotificationPresentationOptionAlert);
}

- (void)mu_userNotificationCenter:(MUUserNotificationCenter *)center didReceiveNotificationResponse:(MUNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler
{
    NSLog(@"*** didReceiveNotificationResponse completionHandler userInfo: %@", response.notification.request.content.userInfo);
    completionHandler();
}

@end
