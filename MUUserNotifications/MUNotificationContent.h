//
//  MUNotificationContent.h
//  MUNotifications
//
//  Created by Muer on 16/7/27.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UNNotificationAttachment;
@class MUNotificationSound;

NS_ASSUME_NONNULL_BEGIN

@interface MUNotificationContent : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, readonly, nullable) NSNumber *badge;
@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSString *categoryIdentifier;
@property (nonatomic, readonly) NSString *launchImageName;
@property (nonatomic, readonly) NSString *title NS_AVAILABLE_IOS(8_2);
@property (nonatomic, readonly) NSDictionary *userInfo;
@property (nonatomic, readonly, nullable) MUNotificationSound *sound;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic, readonly) NSArray <UNNotificationAttachment *> *attachments NS_AVAILABLE_IOS(10_0);
#endif
@property (nonatomic, readonly) NSString *subtitle NS_AVAILABLE_IOS(10_0);
@property (nonatomic, readonly) NSString *threadIdentifier NS_AVAILABLE_IOS(10_0);

@property (nonatomic, readonly) NSString *alertAction NS_DEPRECATED_IOS(2_0, 10_0);

@end

@interface MUMutableNotificationContent : MUNotificationContent

@property (nonatomic, copy, nullable) NSNumber *badge;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *categoryIdentifier;
@property (nonatomic, copy) NSString *launchImageName;
@property (nonatomic, copy) NSString *title NS_AVAILABLE_IOS(8_2);
@property (nonatomic, copy) NSDictionary *userInfo;
@property (nonatomic, copy, nullable) MUNotificationSound *sound;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic, copy) NSArray <UNNotificationAttachment *> *attachments NS_AVAILABLE_IOS(10_0);
#endif
@property (nonatomic, copy) NSString *subtitle NS_AVAILABLE_IOS(10_0);
@property (nonatomic, copy) NSString *threadIdentifier NS_AVAILABLE_IOS(10_0);

@property (nonatomic, copy) NSString *alertAction NS_DEPRECATED_IOS(2_0, 10_0);

@end


@interface MUNotificationSound : NSObject <NSCopying, NSSecureCoding>

+ (instancetype)defaultSound;
+ (instancetype)soundNamed:(NSString *)name;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
