//
//  MUNotificationResponse.h
//  MUNotifications
//
//  Created by Muer on 16/7/27.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The default action. The user opened the app. Equivalent to UNNotificationDefaultActionIdentifier */
extern NSString *const MUNotificationDefaultActionIdentifier;

/** The dismiss action. The dismissed the notification without acting on it. Equivalent to UNNotificationDismissActionIdentifier */
extern NSString *const MUNotificationDismissActionIdentifier NS_CLASS_AVAILABLE_IOS(10_0);

@class MUNotification;

/**
 *  Contains the user’s response to an actionable notification. Equivalent to UNNotificationResponse
 */
@interface MUNotificationResponse : NSObject <NSCopying, NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;

/** The notification to which the user responded */
@property (nonatomic, readonly) MUNotification *notification;

/**
 *  The action identifier that the user chose:
 
 *  MUNotificationDismissActionIdentifier if the user dismissed the notification
 
 *  MUNotificationDefaultActionIdentifier if the user opened the application from the notification
 
 *  the identifier for a registered MUNotificationAction for other actions
 */
@property (nonatomic, readonly) NSString *actionIdentifier;

@end

/**
 *  Contains the user’s response to an actionable notification, including any custom text that the user typed or dictated. Equivalent to UNTextInputNotificationResponse
 */
NS_CLASS_AVAILABLE_IOS(9_0)
@interface MUTextInputNotificationResponse : MUNotificationResponse

/** The text entered or chosen by the user */
@property (nonatomic, readonly) NSString *userText;

@end
