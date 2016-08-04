//
//  MUNotificationResponse.h
//  MUNotifications
//
//  Created by Muer on 16/7/27.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const MUNotificationDefaultActionIdentifier;
extern NSString *const MUNotificationDismissActionIdentifier NS_CLASS_AVAILABLE_IOS(10_0);

@class MUNotification;

@interface MUNotificationResponse : NSObject <NSCopying, NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) MUNotification *notification;
@property (nonatomic, readonly) NSString *actionIdentifier;

@end

NS_CLASS_AVAILABLE_IOS(9_0)
@interface MUTextInputNotificationResponse : MUNotificationResponse

@property (nonatomic, readonly) NSString *userText;

@end
