//
//  GKShareModel.h
//  GKWXManager
//
//  Created by 高坤 on 2017/3/9.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>

// 分享类型
typedef NS_ENUM(NSUInteger, GKShareType) {
    GKShareTypeSession,     // 聊天界面
    GKShareTypeTimeline,    // 朋友圈
    GKShareTypeFavorite     // 收藏
};

@interface GKShareModel : NSObject

/**
 分享的标题
 */
@property (nonatomic, copy) NSString *share_title;

/**
 分享的内容
 */
@property (nonatomic, copy) NSString *share_content;

/**
 分享的跳转链接
 */
@property (nonatomic, copy) NSString *share_url;

/**
 分享的图片链接
 */
@property (nonatomic, copy) NSString *share_image_url;

/**
 分享的图片对象,注意：分享图片大小不能超过32K，自己需要处理一下
 */
@property (nonatomic, strong) UIImage *share_image;


/**
 分享的类型
 */
@property (nonatomic, assign) GKShareType share_type;

@end
