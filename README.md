# MUUserNotifications
MUUserNotifications API similar to iOS 10 UserNotifications.framework

## Usage

### User authorization

```objective-c

NSMutableArray *actions = [NSMutableArray array];

MUNotificationAction *action1 = [MUNotificationAction actionWithIdentifier:@"action1-identifier" title:@"action1-title" options:MUNotificationActionOptionNone];
[actions addObject:action1];

MUNotificationAction *action2 = [MUNotificationAction actionWithIdentifier:@"action2-identifier" title:@"action2-title" options:MUNotificationActionOptionDestructive | MUNotificationActionOptionForeground];
[actions addObject:action2];

// iOS 9 text input action
if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4) {
    MUNotificationAction *inputAction = [MUTextInputNotificationAction actionWithIdentifier:@"inputAction-identifier" title:@"input-title" options:MUNotificationActionOptionNone textInputButtonTitle:@"Send"];
    [actions addObject:inputAction];
}

MUNotificationCategory *category = [MUNotificationCategory categoryWithIdentifier:@"category-identifier" actions:actions];

[[MUUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:MUUNAuthorizationOptionBadge | MUUNAuthorizationOptionAlert | MUUNAuthorizationOptionSound categories:[NSSet setWithObject:category] completionHandler:^(BOOL granted, NSError * _Nullable error) {
    NSLog(@"requestAuthorizatio granted: %d, error: %@", granted, error);
}];

```

### Authorization status & Authorization options

```objective-c
typedef NS_ENUM(NSInteger, MUUNAuthorizationStatus) {
    MUUNAuthorizationStatusNotDetermined = 0,
    MUUNAuthorizationStatusDenied,
    MUUNAuthorizationStatusAuthorized
};
[MUUserNotificationCenter authorizationStatus];

typedef NS_OPTIONS(NSUInteger, MUUNAuthorizationOptions) {
    MUUNAuthorizationOptionNone     = 0,
    MUUNAuthorizationOptionBadge    = 1 << 0,
    MUUNAuthorizationOptionSound    = 1 << 1,
    MUUNAuthorizationOptionAlert    = 1 << 2,
    MUUNAuthorizationOptionCarPlay  = 1 << 3
};
[MUUserNotificationCenter authorizationOptions];

```

### Remote notification

- Requests authorization and register to receive remote notifications (default options)

```objective-c
[MUUserNotificationCenter registerRemoteNotifications];

```

- Custom options

```objective-c
[[MUUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:MUUNAuthorizationOptionAlert categories:[NSSet setWithObject:category] completionHandler:^(BOOL granted, NSError * _Nullable error) {
    if (granted) {
        [[MUUserNotificationCenter currentNotificationCenter] registerForRemoteNotifications];
    }
}];
```

### Local notification

```objective-c
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

MUNotificationRequest *request = [MUNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString] content:mutableContent trigger:trigger];

[[MUUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
    NSLog(@"addNotificationRequest erro: %@", error);
}];
```

### Unified callback interface
Unified delegate interface for receiving notifications and for handling actions.
![](https://github.com/muer2000/MUUserNotifications/blob/master/Screenshots/callback.png)


note: iOS 10 must open the "Push Notifications" to use the remote push function
![](https://github.com/muer2000/MUUserNotifications/blob/master/Screenshots/openPush.png)

