//
//  MUNotification.h
//  MUNotifications
//
//  Created by Muer on 16/8/3.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MUNotificationRequest;

@interface MUNotification : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) MUNotificationRequest *request;

- (instancetype)init NS_UNAVAILABLE;

@end
