// Auther: kaiwei Xu.
// Created Date: 2019/3/11.
// Version: 1.0.6
// Since: 1.0.0
// Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
// Descriptioin: 文件描述.


#import "KWMessageListCell.h"
#import <JMessage/JMessage.h>
#import "MesageModel.h"
#import "PrefixHeader.pch"
#import <SDWebImage/UIImageView+WebCache.h>
#import <KWCategoriesLib/NSString+Addition.h>
@interface KWMessageListCell ()
@property (nonatomic, strong) UIImageView *headerPicView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *bottomLine;
@end

@implementation KWMessageListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //cell背景色、选中样式设置
        self.backgroundColor = KWhite;
        
        //添加子view
        [self setup];
        //设置约束
        [self layout];
    }
    return self;
}

//添加子view
- (void)setup {
    [self.contentView addSubview:self.headerPicView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.numLabel];
    [self.contentView addSubview:self.bottomLine];
}

//添加约束
- (void)layout {
    [self.headerPicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12);
        make.top.equalTo(self.contentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerPicView);
        make.left.equalTo(self.headerPicView.mas_right).offset(12);
        make.right.lessThanOrEqualTo(self.timeLabel.mas_left).offset(-10);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.right.equalTo(self.contentView).offset(-12);
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerPicView.mas_right).offset(12);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
        make.right.equalTo(self.timeLabel);
    }];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.headerPicView);
        make.right.equalTo(self.timeLabel);
        make.height.mas_equalTo(0.5);
    }];
    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headerPicView).offset(3);
        make.top.equalTo(self.headerPicView).offset(-3);
        make.height.mas_equalTo(18);
        make.width.mas_equalTo(18);
    }];
}

- (NSString *)showMessageText:(JMSGMessage *)message {
    if (message.contentType == kJMSGContentTypeText) {
        JMSGTextContent *textContent = (JMSGTextContent *)message.content;
        return textContent.text;
    }else if (message.contentType == kJMSGContentTypeImage) {
        return @"[图片]";
    }else if (message.contentType == kJMSGContentTypeVoice) {
        return @"[语音]";
    }else if (message.contentType == kJMSGContentTypeVideo) {
        return @"[视频]";
    }else if (message.contentType == kJMSGContentTypeLocation) {
        return @"[位置]";
    }else if (message.contentType == kJMSGContentTypeCustom) {
//        return @"[自定义消息]";
        return @"[服务]";
    }else {
        return @"[未知消息]";
    }
}

- (void)bindModel:(id)model {
    if ([model isKindOfClass:[JMSGConversation class]]) {
        JMSGConversation *conv = model;
        self.titleLabel.text = conv.title;
        self.descLabel.text = [self showMessageText:conv.latestMessage];
        NSTimeInterval inteval = [conv.latestMsgTime doubleValue]/1000.0;
        NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:inteval];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy/MM/dd"];
        self.timeLabel.text = [format stringFromDate:msgDate];
        JMSGUser *target = conv.target;
        NSString *avater = target.avatar;
        [self.headerPicView sd_setImageWithURL:[NSURL URLWithString:avater]
                              placeholderImage:[UIImage imageNamed:@"share"]];
        if ([conv.unreadCount integerValue] > 0) {
            self.numLabel.hidden = NO;
            self.numLabel.text = [self formatNum:[conv.unreadCount integerValue]];
        }else {
            self.numLabel.hidden = YES;
        }
    }else {
        MesageModel *msg = model;
        self.titleLabel.text = msg.messageType;
        self.descLabel.text = msg.notificationTitle;
        if (msg.noReadCount > 0) {
            self.numLabel.hidden = NO;
            self.numLabel.text = [self formatNum:msg.noReadCount];
        }else {
            self.numLabel.hidden = YES;
        }
        if ([msg.messageType isEqualToString:@"服务消息"]) {
            self.headerPicView.image = [UIImage imageNamed:@"news_service"];
        }else {
            self.headerPicView.image = [UIImage imageNamed:@"news_order"];
        }
        self.timeLabel.text = msg.pushTime;
    }
}

- (NSString *)formatNum:(NSInteger)count {
    NSString *text = @"";
    if (count < 100) {
        text = [NSString stringWithFormat:@"%@",@(count)];
    }else {
        text = @"99+";
    }
    [self.numLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat width = MAX(18, [text getTextWidthFont:kFont(12)]+10);
        make.width.mas_equalTo(width);
    }];
    return text;
}

- (UIImageView *)headerPicView {
    if (!_headerPicView) {
        _headerPicView = [[UIImageView alloc] init];
        _headerPicView.backgroundColor = hexColor(@"f5f5f5");
        _headerPicView.layer.cornerRadius = 10;
        _headerPicView.layer.masksToBounds = YES;
        _headerPicView.contentMode = UIViewContentModeScaleAspectFill;
        _headerPicView.image = [UIImage imageNamed:@"share"];
    }
    return _headerPicView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kBlackFontColor;
        _titleLabel.font = kFont(17);
    }
    return _titleLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.textColor = kLightFontColor;
        _descLabel.font = kFont(13);
    }
    return _descLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = kBlackFontColor;
        _timeLabel.font = kFont(12);
    }
    return _timeLabel;
}

- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] init];
        _numLabel.textColor = KWhite;
        _numLabel.font = kFont(12);
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.backgroundColor = hexColor(@"ff3432");
        _numLabel.layer.cornerRadius = 9;
        _numLabel.layer.masksToBounds = YES;
        _numLabel.layer.borderColor = KWhite.CGColor;
        _numLabel.layer.borderWidth = 2;
        _numLabel.hidden = YES;
    }
    return _numLabel;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = hexColor(@"e6e6e6");
    }
    return _bottomLine;
}

@end
