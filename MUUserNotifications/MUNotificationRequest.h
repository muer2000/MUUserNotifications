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

@interface MUNotificationRequest : NSObject <NSCopying, NSSecureCoding>

+ (instancetype)requestWithIdentifier:(NSString *)identifier content:(MUNotificationContent *)content trigger:(nullable MUNotificationTrigger *)trigger;

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) MUNotificationContent *content;
@property (nonatomic, readonly, nullable) MUNotificationTrigger *trigger;

@end

NS_ASSUME_NONNULL_END
