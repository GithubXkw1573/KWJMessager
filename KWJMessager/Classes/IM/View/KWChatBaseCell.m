//
//  KWChatBaseCell.m
//  WormwormLife
//
//  Created by kaiwei Xu on 2019/3/6.
//  Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
//

#import "KWChatBaseCell.h"
#import "PrefixHeader.pch"
#import <SDWebImage/UIImageView+WebCache.h>
@interface KWChatBaseCell ()
@property (nonatomic, strong) UIActivityIndicatorView *circleIcon;//显示发送中的菊花
@end

@implementation KWChatBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //cell背景色、选中样式设置
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //添加子view
        [self setup];
        //设置约束
//        [self layout];
    }
    return self;
}

//添加子view
- (void)setup {
    [self.contentView addSubview:self.userAvater];
    [self.contentView addSubview:self.nikenameLabel];
    [self.contentView addSubview:self.messageView];
    [self.contentView addSubview:self.readLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.stateIcon];
    [self.contentView addSubview:self.circleIcon];
}

//添加约束
- (void)layout {
    //首先看，要不要显示消息时间
    if ([self showTime]) {
        [self timeConstraint];
    }else {
        [self removeView:self.timeLabel];
    }
    //是否是商品链接类型message
    if ([self showGoods]) {
        //显示自定义的商品链接UI
        [self removeView:self.userAvater];
        [self removeView:self.nikenameLabel];
        //商品链接布局
        [self makeGoodLinkConstraint];
    }else {
        //常规几种类型的消息
        //头像位置布局
        [self userAvaterConstraint];
        //是否需要昵称
        if (self.message.isReceived) {
            //别人发的，要显示昵称
            [self nikenameConstraint];
        }else {
            //隐藏昵称
            [self removeView:self.nikenameLabel];
        }
        //消息主体布局
        [self makeContentConstraints];
        //消息状态
        [self makeStateIconConstraints];
    }
    //是否需要已读未读
    if (self.message.isReceived) {
        //别人发的，不显示阅读标识
        [self removeView:self.readLabel];
    }else {
//        //自己发的，显示阅读标志
//        [self readConstraint];
        //鉴于极光iOS已读未读SDK问题，暂不显示已读、未读功能
        [self removeView:self.readLabel];
    }
}

- (void)setMessage:(JMSGMessage *)message {
    _message = message;
    //首先看，要不要显示消息时间
    if ([self showTime]) {
        self.timeLabel.text = [self formatSendTime];
    }
    //是否是商品链接类型message
    if (![self showGoods]) {
        //获取头像
        NSString *avater = self.message.fromUser.avatar;
        [self.userAvater sd_setImageWithURL:[NSURL URLWithString:avater]
                              placeholderImage:[UIImage imageNamed:@"share"]];
        //是否需要昵称
        if (self.message.isReceived) {
            //别人发的，要显示昵称
            self.nikenameLabel.text = [self.message.fromUser displayName];
        }
        if (message.status == kJMSGMessageStatusSendFailed ||
            message.status == kJMSGMessageStatusSendUploadFailed) {
            self.stateIcon.hidden = NO;
        }else {
            self.stateIcon.hidden = YES;
        }
        if (message.status == kJMSGMessageStatusSending ||
            message.status == kJMSGMessageStatusSendDraft) {
            self.circleIcon.hidden = NO;
            [self.circleIcon startAnimating];
        }else {
            self.circleIcon.hidden = YES;
            [self.circleIcon stopAnimating];
        }
    }else {
        self.stateIcon.hidden = YES;
        self.circleIcon.hidden = YES;
    }
    //是否需要已读未读
    if (!self.message.isReceived) {
        //消息已读未读
        self.readLabel.text = [self haveReadFlag] ? @"已读" : @"未读";
        self.readLabel.textColor = [self haveReadFlag] ? hexColor(@"#B3B3B3") : hexColor(@"ff3432");
        if (message.status == kJMSGMessageStatusSendFailed ||
            message.status == kJMSGMessageStatusSendUploadFailed ||
            message.status == kJMSGMessageStatusSendDraft ||
            message.status == kJMSGMessageStatusSending) {
            self.readLabel.text = @"";
        }
    }
    //添加布局
    [self layout];
}

- (BOOL)haveReadFlag {
//    BOOL readFlag = [[self.message.content.extras objectForKey:kHaveReadKey] boolValue];
//    return readFlag;
    return [self.message.flag boolValue];
}

- (BOOL)showTime {
    BOOL showTime = [[self.message.content.extras objectForKey:kShowTimeKey] boolValue];
    return showTime;
}

- (void)setShowTime:(BOOL)showTime {
    [self.message.content addNumberExtra:@(showTime) forKey:kShowTimeKey];
}

- (NSString *)formatSendTime {
    long time = [[self.message.content.extras objectForKey:kTimeKey] longValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time/1000.0];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    if ([[format stringFromDate:date] isEqualToString:
         [format stringFromDate:[NSDate date]]]) {
        //今天
        [format setDateFormat:@"HH:mm"];
    }else {
        [format setDateFormat:@"MM-dd HH:mm"];
    }
    return [format stringFromDate:date];
}

- (void)setSendTime:(NSDate *)sendTime {
    NSTimeInterval secs = [sendTime timeIntervalSince1970];
    long timestamp = secs * 1000;
    NSNumber *time = [NSNumber numberWithLong:timestamp];
    [self.message.content addNumberExtra:time forKey:kTimeKey];
}

- (BOOL)showGoods {
    BOOL showGoods = [[self.message.content.extras objectForKey:kShowGoodsKey] boolValue];
    return showGoods;
}

- (UIImageView *)userAvater {
    if (!_userAvater) {
        _userAvater = [[UIImageView alloc] init];
        _userAvater.backgroundColor = hexColor(@"f5f5f5");
        _userAvater.layer.cornerRadius = 5;
        _userAvater.layer.masksToBounds = YES;
        _userAvater.contentMode = UIViewContentModeScaleAspectFill;
        _userAvater.image = [UIImage imageNamed:@"share"];
    }
    return _userAvater;
}

- (UILabel *)nikenameLabel {
    if (!_nikenameLabel) {
        _nikenameLabel = [[UILabel alloc] init];
        _nikenameLabel.textColor = hexColor(@"666666");
        _nikenameLabel.font = kFont(12);
    }
    return _nikenameLabel;
}

- (UILabel *)readLabel {
    if (!_readLabel) {
        _readLabel = [[UILabel alloc] init];
        _readLabel.textColor = hexColor(@"#B3B3B3");
        _readLabel.font = kFont(11);
    }
    return _readLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = KWhite;
        _timeLabel.font = kFont(13);
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.layer.cornerRadius = 12.5;
        _timeLabel.backgroundColor = hexColor(@"#D4D5D9");
        _timeLabel.layer.masksToBounds = YES;
    }
    return _timeLabel;
}

- (UIView *)messageView {
    if (!_messageView) {
        _messageView = [[UIView alloc] init];
    }
    return _messageView;
}

- (UIImageView *)stateIcon {
    if (!_stateIcon) {
        _stateIcon = [[UIImageView alloc] init];
        _stateIcon.image = [UIImage imageNamed:@"im_faild"];
        _stateIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resendMessage)];
        [_stateIcon addGestureRecognizer:tap];
    }
    return _stateIcon;
}

- (UIActivityIndicatorView *)circleIcon {
    if (!_circleIcon) {
        _circleIcon = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _circleIcon;
}

//------------ Layout -------------/

- (void)userAvaterConstraint {
    [self.userAvater mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.message.isReceived) {
            //别人发的，展示在左侧
            make.left.equalTo(self.contentView).offset(kMarginX).priority(751);
        }else {
            make.right.equalTo(self.contentView).offset(-kMarginX).priority(751);
        }
        make.size.mas_equalTo(CGSizeMake(40, 40)).priority(751);
        CGFloat offset = [self showTime] ? 45 : 10;
        make.top.equalTo(self.contentView).offset(offset).priority(751);
    }];
}

- (void)nikenameConstraint {
    self.nikenameLabel.hidden = NO;
    [self.nikenameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.message.isReceived) {
            //别人发的，展示在左侧
            make.left.equalTo(self.userAvater.mas_right).offset(8).priority(751);
        }else {
            make.right.equalTo(self.userAvater.mas_left).offset(-8).priority(751);
        }
        make.top.equalTo(self.userAvater).priority(751);
    }];
}

- (void)readConstraint {
    self.readLabel.hidden = NO;
    [self.readLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageView.mas_bottom).offset(5).priority(751);
        make.right.equalTo(self.contentView).offset(-57).priority(751);
    }];
}

- (void)timeConstraint {
    self.timeLabel.hidden = NO;
    NSString *timeText = [self formatSendTime];
    CGFloat textWdith = [timeText getTextWidthFont:kFont(13)];
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10).priority(751);
        make.centerX.equalTo(self.contentView).priority(751);
        make.width.mas_equalTo(textWdith +20).priority(751);
        make.height.mas_equalTo(25).priority(751);
    }];
}

- (void)makeGoodLinkConstraint {
    [self.messageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12).priority(751);
        make.right.equalTo(self.contentView).offset(-12).priority(751);
        CGFloat offset = [self showTime] ? 45 : 10;
        make.top.equalTo(self.contentView).offset(offset).priority(751);
//        CGFloat offsetBottom = self.message.isReceived ? 20 : 28;//多一个阅读标识
        CGFloat offsetBottom = 20;
        make.bottom.equalTo(self.contentView).offset(-offsetBottom).priority(751);
    }];
}

- (void)makeContentConstraints {
    [self.messageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.message.isReceived) {
            //别人发的，在左边
            make.left.equalTo(self.userAvater.mas_right).offset(8).priority(751);
            make.top.equalTo(self.nikenameLabel.mas_bottom).offset(3).priority(751);
            make.right.lessThanOrEqualTo(self.contentView).offset(-60).priority(751);
        }else {
            make.right.equalTo(self.userAvater.mas_left).offset(-8).priority(751);
            make.top.equalTo(self.userAvater);
            make.left.greaterThanOrEqualTo(self.contentView).offset(60).priority(751);
        }
        //最后添加距离cell底部的垂直方向的约束
//        CGFloat offsetBottom = self.message.isReceived ? 20 : 28;//多一个阅读标识
        CGFloat offsetBottom = 20;
        make.bottom.equalTo(self.contentView).offset(-offsetBottom).priority(751);
    }];
}

- (void)makeStateIconConstraints {
    if (self.message.isReceived) {
        self.stateIcon.hidden = YES;
        self.circleIcon.hidden = YES;
        return ;
    }
    [self.stateIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageView).offset(8);
        make.right.equalTo(self.messageView.mas_left).offset(-6);
    }];
    [self.circleIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageView).offset(8);
        make.right.equalTo(self.messageView.mas_left).offset(-6);
    }];
}

- (void)removeView:(UIView *)view {
    view.hidden = YES;
    for (MASConstraint *c in [MASViewConstraint installedConstraintsForView:view]) {
        [c uninstall];
    }
}

- (void)resendMessage {
    if (self.actionBlock) {
        self.actionBlock(ActionTypeResend);
    }
}

@end
