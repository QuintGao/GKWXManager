//
//  GKWXManager.h
//  JVTalking
//
//  Created by 高坤 on 2017/1/13.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "GKShareModel.h"

#define kWXManager [GKWXManager defaultManager]
#define kWeChatAppKey    @""
#define kWeChatAppSecret @""

@protocol GKWXManagerDelegate <NSObject>

@optional
#pragma mark - 微信登陆
- (void)weChatLoginSuccess:(id)responseObject;
- (void)weChatLoginCancel;
- (void)weChatLoginFailed:(NSError *)error;

#pragma mark - 微信分享
- (void)weChatShareSuccess;
- (void)weChatShareCancel;
- (void)weChatShareFailed:(NSError *)error;

#pragma mark - 微信支付
// 财付通返回给商家的信息
- (void)weChatPaySuccess:(NSString *)returnKey;
- (void)weChatPayCancel;
- (void)weChatPayFailed:(NSError *)error;

@end

@interface GKWXManager : NSObject<WXApiDelegate>

+ (instancetype)defaultManager;

@property (nonatomic, assign) id<GKWXManagerDelegate> delegate;

#pragma mark - 注册APPKEY
- (void)registerAppKey;
- (void)registerAppKeyWithDescription:(NSString *)description;

#pragma mark - 微信登陆
- (void)weChatLogin;

#pragma mark - 微信分享
- (void)weChatShare:(GKShareModel *)shareModel;

#pragma mark - 微信支付
- (void)weChatPay:(NSDictionary *)params;

@end
