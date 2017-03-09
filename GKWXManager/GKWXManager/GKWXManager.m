//
//  GKWXManager.m
//  JVTalking
//
//  Created by 高坤 on 2017/1/13.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKWXManager.h"

@implementation GKWXManager

+ (instancetype)defaultManager
{
    static GKWXManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [GKWXManager new];
    });
    return manager;
}

#pragma mark - 注册APPKEY
- (void)registerAppKey
{
    [WXApi registerApp:kWeChatAppKey];
}

- (void)registerAppKeyWithDescription:(NSString *)description
{
    [WXApi registerApp:kWeChatAppKey withDescription:description];
}

#pragma mark - 微信登陆
- (void)weChatLogin
{
    // 1. 判断是否安装微信
    [self checkWXAppInstalled];
    
    // 2. 调起微信登录
    // 构造SendAuthReq结构体
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"login";
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

#pragma mark - 微信分享
- (void)weChatShare:(GKShareModel *)shareModel
{
    // 1. 判断是否安装微信
    [self checkWXAppInstalled];
    
    // 2. 微信分享
    // 微信分享多媒体消息
    WXMediaMessage *message = [WXMediaMessage message];
    message.title       = shareModel.share_title;
    message.description = shareModel.share_content;
    [message setThumbImage:shareModel.share_image];
    
    // 多媒体消息中包含的网页数据对象
    WXWebpageObject *webPageObject = [WXWebpageObject object];
    webPageObject.webpageUrl = shareModel.share_url;
    message.mediaObject      = webPageObject;
    
    // 第三方程序发送消息至微信终端程序的消息结构体
    SendMessageToWXReq *requ = [SendMessageToWXReq new];
    requ.bText   = NO;
    requ.message = message;
    requ.scene   = shareModel.share_type;
    
    // 发送请求到微信
    [WXApi sendReq:requ];
}

#pragma mark - 微信支付
- (void)weChatPay:(NSDictionary *)params
{
    // 1. 判断是否安装微信
    [self checkWXAppInstalled];
    
    // 2. 设置参数，发起微信支付
    PayReq *request = [[PayReq alloc] init];
    request.openID    = params[@"appid"];
    request.partnerId = params[@"partnerid"];
    request.prepayId  = params[@"prepayid"];
    request.package   = params[@"package"];
    request.nonceStr  = params[@"noncestr"];
    request.timeStamp = (UInt32)[params[@"timestamp"] integerValue];
    request.sign      = params[@"sign"];
    
    // 调用微信
    [WXApi sendReq:request];
}

#pragma mark - 判断是否安装微信
- (void)checkWXAppInstalled
{
    if (![WXApi isWXAppInstalled]) {
//        [GKMessageTool showTips:@"您还没有安装微信！"];
        return;
    }
}

/**
 根据微信返回的code回去access_token和openid

 @param code 微信返回的code
 */
- (void)getWeChatAccessTokenWithCode:(NSString *)code
{
    // 1. 确定请求路径
    NSString *urlString = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",
                     kWeChatAppKey,kWeChatAppSecret,code];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 2. 创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 3. 获取会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    // 4. 根据会话对象创建一个Task（发送请求）
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            if ([self.delegate respondsToSelector:@selector(weChatLoginFailed:)]) {
                [self.delegate weChatLoginFailed:error];
            }
            return;
        }
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",dic);
        
        NSString *access_token = dic[@"access_token"];
        NSString *openid = dic[@"openid"];
        
        // 根据access_token和openid获取用户信息
        [self getWeChatUserInfoWithAccessToken:access_token openId:openid];
    }];
    
    // 5. 执行任务
    [task resume];
}

// 获取用户信息
/**
 根据access_token及openid请求微信的用户信息

 @param access_token access_token
 @param openId openId
 */
- (void)getWeChatUserInfoWithAccessToken:(NSString *)access_token openId:(NSString *)openId
{
    // 1. 设置请求路径
    NSString *urlString =[NSString stringWithFormat:
                    @"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",access_token,openId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 2. 创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 3. 获取会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    // 4. 根据会话对象，创建一个请求task
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if ([self.delegate respondsToSelector:@selector(weChatLoginFailed:)]) {
                [self.delegate weChatLoginFailed:error];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(weChatLoginSuccess:)]) {
                [self.delegate weChatLoginSuccess:data];
            }
        }
    }];
    
    // 5. 执行任务
    [task resume];
}

//    WXSuccess           = 0,    /**< 成功    */
//    WXErrCodeCommon     = -1,   /**< 普通错误类型    */
//    WXErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
//    WXErrCodeSentFail   = -3,   /**< 发送失败    */
//    WXErrCodeAuthDeny   = -4,   /**< 授权失败    */
//    WXErrCodeUnsupport  = -5,   /**< 微信不支持    */

#pragma mark - WXApiDelegate

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp 具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[SendAuthResp class]]) { // 微信登录
        [self handleWXLogin:(SendAuthResp *)resp];
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]) { // 微信分享
        [self handleWXShare:(SendMessageToWXResp *)resp];
    }else if ([resp isKindOfClass:[PayResp class]]) {// 微信支付
        [self handleWXPay:(PayResp *)resp];
    }
}

#pragma mark - Handle Method

/**
 处理微信登录的返回信息

 @param resp 请求授权的返回对象
 */
- (void)handleWXLogin:(SendAuthResp *)resp
{
    if (resp.errCode == WXSuccess) { // 登录返回code成功
        [self getWeChatAccessTokenWithCode:resp.code];
    }else if (resp.errCode == WXErrCodeUserCancel) { // 登录用户取消
        if ([self.delegate respondsToSelector:@selector(weChatLoginCancel)]) {
            [self.delegate weChatLoginCancel];
        }
    }else{
        NSError *error = [NSError errorWithDomain:@"com.qq.wexin.api" code:resp.errCode userInfo:@{@"message" : resp.errStr}];
        
        if ([self.delegate respondsToSelector:@selector(weChatLoginFailed:)]) {
            [self.delegate weChatLoginFailed:error];
        }
    }
}

/**
 处理微信分享的返回信息

 @param resp 请求发消息到微信的返回对象
 */
- (void)handleWXShare:(SendMessageToWXResp *)resp
{
    if (resp.errCode == WXSuccess) {
        if ([self.delegate respondsToSelector:@selector(weChatShareSuccess)]) {
            [self.delegate weChatShareSuccess];
        }
    }else if (resp.errCode == WXErrCodeUserCancel) {
        if ([self.delegate respondsToSelector:@selector(weChatShareCancel)]) {
            [self.delegate weChatShareCancel];
        }
    }else{
        NSError *error = [NSError errorWithDomain:@"com.qq.wexin.api" code:resp.errCode userInfo:@{@"message" : resp.errStr}];
        
        if ([self.delegate respondsToSelector:@selector(weChatShareFailed:)]) {
            [self.delegate weChatShareFailed:error];
        }
    }
}

/**
 处理微信支付的返回信息

 @param resp 请求支付的返回对象
 */
- (void)handleWXPay:(PayResp *)resp
{
    if (resp.errCode == WXSuccess) {
        if ([self.delegate respondsToSelector:@selector(weChatPaySuccess:)]) {
            [self.delegate weChatPaySuccess:resp.returnKey];
        }
    }else if (resp.errCode == WXErrCodeUserCancel) {
        if ([self.delegate respondsToSelector:@selector(weChatPayCancel)]) {
            [self.delegate weChatPayCancel];
        }
    }else{
        NSError *error = [NSError errorWithDomain:@"com.qq.wexin.api" code:resp.errCode userInfo:@{@"message" : resp.errStr}];
        
        if ([self.delegate respondsToSelector:@selector(weChatPayFailed:)]) {
            [self.delegate weChatPayFailed:error];
        }
    }
}

@end
