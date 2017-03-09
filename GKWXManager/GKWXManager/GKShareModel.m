//
//  GKShareModel.m
//  GKWXManager
//
//  Created by 高坤 on 2017/3/9.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKShareModel.h"

@implementation GKShareModel

- (UIImage *)share_image
{
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.share_image_url]];
    return [UIImage imageWithData:imageData];
}

@end
