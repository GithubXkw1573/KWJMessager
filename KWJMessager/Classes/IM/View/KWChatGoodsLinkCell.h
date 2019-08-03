//
//  KWChatGoodsLinkCell.h
//  WormwormLife
//
//  Created by kaiwei Xu on 2019/3/6.
//  Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
//

#import "KWChatBaseCell.h"
#import "KWGoodsLinkModel.h"

#define kShowSendKey  @"showSendKey" //是否显示发送链接按钮

NS_ASSUME_NONNULL_BEGIN

@interface KWChatGoodsLinkCell : UITableViewCell
@property (nonatomic, assign, readonly) BOOL showSendLinkBtn;//是否显示发送按钮
@property (nonatomic, strong) JMSGMessage *message;//消息model
@property (nonatomic, copy) void (^actionBlock)(void);
@end

NS_ASSUME_NONNULL_END
