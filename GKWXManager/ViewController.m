//
//  ViewController.m
//  GKWXManager
//
//  Created by 高坤 on 2017/3/9.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "ViewController.h"
#import "GKWXManager.h"

@interface ViewController ()<GKWXManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册代理
    kWXManager.delegate = self;
}


/**
 微信登录
 */
- (IBAction)wxLogin:(id)sender {
    [kWXManager weChatLogin];
}

/**
 微信支付
 */
- (IBAction)wxPay:(id)sender {
    
    // 设置微信支付参数
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    // 这里添加微信支付的参数
    
    [kWXManager weChatPay:params];
}

/**
 微信分享
 */
- (IBAction)wxShare:(id)sender {
    GKShareModel *model = [GKShareModel new];
    model.share_title     = @"分享标题";
    model.share_content   = @"分享内容";
    model.share_url       = @"分享链接";
    model.share_image_url = @"分享的图片链接"; // 或者使用share_image;
    
    [kWXManager weChatShare:model];
}

#pragma mark - GKWXManagerDelegate

// 登录回调
- (void)weChatLoginSuccess:(id)responseObject
{
    NSLog(@"用户信息=====%@",responseObject);
}

- (void)weChatLoginCancel
{
    NSLog(@"用户取消登录");
}

- (void)weChatLoginFailed:(NSError *)error
{
    NSInteger code = error.code;
    
    NSString *message = error.userInfo[@"message"];
    
    NSLog(@"错误码==%zd,错误信息===%@",code,message);
}

// 支付回调
- (void)weChatPaySuccess:(NSString *)returnKey
{
    NSLog(@"支付返回的信息=====%@",returnKey);
}

- (void)weChatPayCancel
{
    NSLog(@"支付取消");
}

- (void)weChatPayFailed:(NSError *)error
{
    NSInteger code = error.code;
    
    NSString *message = error.userInfo[@"message"];
    
    NSLog(@"错误码==%zd,错误信息===%@",code,message);
}

// 分享回调
- (void)weChatShareSuccess
{
    NSLog(@"分享成功");
}

- (void)weChatShareCancel
{
    NSLog(@"分享取消");
}

- (void)weChatShareFailed:(NSError *)error
{
    NSInteger code = error.code;
    
    NSString *message = error.userInfo[@"message"];
    
    NSLog(@"错误码==%zd,错误信息===%@",code,message);
}


@end
