//
//  ViewController.m
//  MUUserNotificationsExample
//
//  Created by Muer on 16/8/3.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "ViewController.h"
#import "MUUserNotifications.h"

#ifndef NSFoundationVersionNumber_iOS_9_x_Max
    #define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

#define IS_IOS10_OR_GREATER (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MUNotifications Example";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // authorization
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self showAlert:[NSString stringWithFormat:@"Status: %@\nOptions: %@",
                             [self currentAuthorizationStatusString],
                             [self currentAuthorizationOptionsString]]];
        }
        else {
            [[MUUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:[self defaultAuthorizationOptions] categories:[self notificationCategories] completionHandler:^(BOOL granted, NSError * _Nullable error) {
                NSLog(@"requestAuthorizatio granted: %d, error: %@", granted, error);
            }];
        }
    }
    // remote notification
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [MUUserNotificationCenter registerRemoteNotifications];
        }
        else {
            [[MUUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:[self defaultAuthorizationOptions] categories:[self notificationCategories] completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    [[MUUserNotificationCenter currentNotificationCenter] registerForRemoteNotifications];
                }
            }];
        }
    }
    // local notification
    else {
        [[MUUserNotificationCenter currentNotificationCenter] addNotificationRequest:[self notificationRequest] withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"addNotificationRequest erro: %@", error);
        }];
    }
}


#pragma mark - Private

- (void)showAlert:(NSString *)alert
{
    [[[UIAlertView alloc] initWithTitle:nil message:alert delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (NSString *)currentAuthorizationStatusString
{
    NSArray *statusStrings = @[@"Not Determined", @"Denied", @"Authorized"];
    return statusStrings[[MUUserNotificationCenter authorizationStatus]];
}

- (NSString *)currentAuthorizationOptionsString
{
    MUUNAuthorizationOptions options = [MUUserNotificationCenter authorizationOptions];
    if (options == 0) {
        return @"None";
    }
    NSArray *optionsStrings = @[@"Badge", @"Sound", @"Alert", @"CarPlay"];
    NSMutableString *mutableString = [NSMutableString string];
    for (int i = 0; i < optionsStrings.count; i++) {
        if (options & (1 << i)) {
            [mutableString appendFormat:@"%@ ", optionsStrings[i]];
        }
    }
    return mutableString;
}

- (MUUNAuthorizationOptions)defaultAuthorizationOptions
{
    return MUUNAuthorizationOptionBadge | MUUNAuthorizationOptionAlert | MUUNAuthorizationOptionSound;
}

- (NSSet *)notificationCategories
{
    MUNotificationAction *action1 = [MUNotificationAction actionWithIdentifier:@"action1-identifier" title:@"action1-title" options:MUNotificationActionOptionNone];
    
    MUNotificationAction *action2 = [MUNotificationAction actionWithIdentifier:@"action2-identifier" title:@"action2-title" options:MUNotificationActionOptionDestructive | MUNotificationActionOptionForeground];

    // iOS 9
    MUNotificationAction *inputAction = nil;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4) {
        inputAction = [MUTextInputNotificationAction actionWithIdentifier:@"inputAction-identifier" title:@"input-title" options:MUNotificationActionOptionNone textInputButtonTitle:@"回复"];
    
    }
    
    NSMutableArray *actions = [NSMutableArray array];
    [actions addObject:action1];
    [actions addObject:action2];
    if (inputAction) {
        [actions addObject:inputAction];
    }
    
    MUNotificationCategory *category = [MUNotificationCategory categoryWithIdentifier:@"category-identifier" actions:actions];
    return [NSSet setWithObject:category];
}

- (MUNotificationRequest *)notificationRequest
{
    MUMutableNotificationContent *mutableContent = [[MUMutableNotificationContent alloc] init];
    mutableContent.body = @"body...";
    mutableContent.categoryIdentifier = @"category-identifier";
    mutableContent.userInfo = @{@"key1": @"value1", @"key2": @"value2"};
    mutableContent.sound = [MUNotificationSound defaultSound];
    mutableContent.badge = @6;
    
    MUNotificationTrigger *trigger = nil;
    if (IS_IOS10_OR_GREATER) {
        trigger = [MUTimeIntervalNotificationTrigger triggerWithTimeInterval:6 repeats:NO];
    }
    else {
        trigger = [MUClassicNotificationTrigger triggerWithFireDate:[[NSDate date] dateByAddingTimeInterval:6] repeatInterval:0];
    }
    
    return [MUNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString] content:mutableContent trigger:trigger];
}

@end
