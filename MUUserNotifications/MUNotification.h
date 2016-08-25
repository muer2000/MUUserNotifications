//
//  MUNotification.h
//  MUNotifications
//
//  Created by Muer on 16/8/3.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MUNotificationRequest;

/**
 *  Contains the data for a delivered notification. Equivalent to UNNotification
 */
@interface MUNotification : NSObject <NSCopying, NSSecureCoding>

/** The date displayed on the notification */
@property (nonatomic, readonly) NSDate *date;

/** The notification request that caused the notification to be delivered */
@property (nonatomic, readonly) MUNotificationRequest *request;

- (instancetype)init NS_UNAVAILABLE;

@end
