//
//  KWChatBaseCell.h
//  WormwormLife
//
//  Created by kaiwei Xu on 2019/3/6.
//  Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JMessage/JMessage.h>

#define kMarginX       12   //聊天室排版内容距离屏幕左右边距
#define kShowTimeKey   @"showTime"  //是否显示发送时间的标识key,value类型：NSNumber(bool)
#define kTimeKey       @"timestamp" //发送时间的毫秒级时间戳，value类型：NSNumber(long)
#define kShowGoodsKey  @"showGoods" //是否是商品链接 value类型：NSNumber(bool)

#define kHaveReadKey   @"kHaveReadKey"  //是否已读

typedef NS_ENUM(NSInteger, MessagerOwner) {
    MessagerOwnerSelf, //自己发的消息
    MessagerOwnerOther, //别人发的消息
};
typedef NS_ENUM(NSInteger, ActionType) {
    ActionTypeLookDetail, //查看消息详情
    ActionTypeResend, //重发消息
};

NS_ASSUME_NONNULL_BEGIN

@interface KWChatBaseCell : UITableViewCell
@property (nonatomic, strong) UIImageView *userAvater;
@property (nonatomic, strong) UILabel *nikenameLabel;
@property (nonatomic, strong) UILabel *readLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *stateIcon;//消息状态标志
//这个是消息主体内容，可以是文字、语音、图片、视频、自定义商品链接等，具体内容由子类cell填充
@property (nonatomic, strong) UIView *messageView;
//@property (nonatomic, assign) MessagerOwner messageOwner;//消息所属人是自己还是别人
@property (nonatomic, strong) JMSGMessage *message;//消息model

@property (nonatomic, copy) void (^actionBlock)(ActionType type);

//子类必须覆写该方法
- (void)layout;

- (void)removeView:(UIView *)view;

- (BOOL)showTime;
- (void)setShowTime:(BOOL)showTime;
- (NSString *)formatSendTime;
- (void)setSendTime:(NSDate *)sendTime;

@end

NS_ASSUME_NONNULL_END
