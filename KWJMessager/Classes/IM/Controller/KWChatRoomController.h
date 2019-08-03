//
//  KWChatRoomController.h
//  WormwormLife
//
//  Created by kaiwei Xu on 2019/3/5.
//  Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
//  聊天室

#import <UIKit/UIKit.h>
#import <KWBaseViewController/YWBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface KWChatRoomController : YWBaseViewController

@property (nonatomic, copy) NSString *userName;//聊天对象

//@optional
@property (nonatomic, strong) NSDictionary *serviceDic;//服务链接的字段

@end

NS_ASSUME_NONNULL_END
