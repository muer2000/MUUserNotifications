//
//  MUNotificationRequest.h
//  MUNotifications
//
//  Created by Muer on 16/7/27.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MUNotificationContent;
@class MUNotificationTrigger;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Encompasses a notification’s content and the condition that triggers its delivery. Equivalent to UNNotificationRequest
 */
@interface MUNotificationRequest : NSObject <NSCopying, NSSecureCoding>

/** Creates and returns a local notification request object */
+ (instancetype)requestWithIdentifier:(NSString *)identifier content:(MUNotificationContent *)content trigger:(nullable MUNotificationTrigger *)trigger;

- (instancetype)init NS_UNAVAILABLE;

/** The unique identifier for this notification request */
@property (nonatomic, readonly) NSString *identifier;

/** The content associated with the notification */
@property (nonatomic, readonly) MUNotificationContent *content;

/** The conditions that trigger the delivery of the notification */
@property (nonatomic, readonly, nullable) MUNotificationTrigger *trigger;

@end

NS_ASSUME_NONNULL_END
