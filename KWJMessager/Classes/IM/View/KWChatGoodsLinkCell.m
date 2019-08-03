//
//  KWChatGoodsLinkCell.m
//  WormwormLife
//
//  Created by kaiwei Xu on 2019/3/6.
//  Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
//

#import "KWChatGoodsLinkCell.h"
#import "LKServicePriceView.h"
#import "PrefixHeader.pch"
#import <SDWebImage/UIImageView+WebCache.h>
#import <KWCategoriesLib/UIButton+ClickBounds.h>

@interface KWChatGoodsLinkCell ()
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *headPicView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) LKServicePriceView *priceView;
@property (nonatomic, strong) LKServicePriceView *priceViewRight;
@property (nonatomic, strong) UIView *sepLine;
@property (nonatomic, strong) UIButton *sendLinkBtn;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation KWChatGoodsLinkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //cell背景色、选中样式设置
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //添加子view
        [self setup];
        //设置约束
        [self layout];
    }
    return self;
}

//添加子view
- (void)setup {
    [self.contentView addSubview:self.mainView];
    [self.mainView addSubview:self.headPicView];
    [self.mainView addSubview:self.titleLabel];
    [self.mainView addSubview:self.priceView];
    [self.mainView addSubview:self.priceViewRight];
    [self.mainView addSubview:self.sepLine];
    [self.mainView addSubview:self.sendLinkBtn];
    [self.contentView addSubview:self.timeLabel];
}


- (void)setMessage:(JMSGMessage *)message {
    _message = message;
    if ([message.content isKindOfClass:[JMSGCustomContent class]]) {
        JMSGCustomContent *content = (JMSGCustomContent *)message.content;
        NSString *jsonString = [content.customDictionary objectForKey:@"servcieMap"];
        NSDictionary *dict = [jsonString mj_JSONObject];
        KWGoodsLinkModel *linkModel = [KWGoodsLinkModel mj_objectWithKeyValues:dict];
        NSString *picUrl = linkModel.servicePictureUrl;
        if (!picUrl.length) {
            //安卓端发送的服务字段兼容
            id data = [dict objectForKey:@"servicePictureList"];
            if ([data isKindOfClass:[NSString class]]) {
                data = [data mj_JSONObject];
            }
            if (data && [data isKindOfClass:[NSArray class]]) {
                picUrl = [data safeObjectAtIndex:0];
                if ([picUrl isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *picDic = (NSDictionary *)picUrl;
                    picUrl = [picDic objectForKey:@"pictureUrl"];
                }
            }
        }
        DDLogDebug(@"图片链接==>%@",picUrl);
        [self.headPicView sd_setImageWithURL:[NSURL URLWithString:picUrl]];
        self.titleLabel.text = String_NotNil(linkModel.serviceTitle);
        [self bindServiceListPriceUI:linkModel];
        
        //是否显示时间
        if ([self showTime]) {
            self.timeLabel.text = [self formatSendTime];
        }
    }
    [self layout];
}

//服务的金额展示
- (void)bindServiceListPriceUI:(KWGoodsLinkModel *)model{
    self.priceView.type = LKServicePriceTypeOrigin;
    self.priceViewRight.type = LKServicePriceTypeVip;
    
    self.priceViewRight.hidden = NO;
    NSString *type = [LKServicePriceView payTypeWithDeposit:model.deposit servicePriceType:model.servicePriceType];
    long price = [type isEqualToString:@"一口价"] ? [model.servicePrice longLongValue] : model.deposit;
    [self.priceView bindModelWithPrice:price rightLabelContent:type];
    
    self.priceViewRight.hidden = model.promotionType == 0;
    if (model.promotionType == 1) { //有促销
        
        long price = [type isEqualToString:@"一口价"]?model.vipPrice:model.vipDeposit;
        [self.priceViewRight bindModelWithPrice:price rightLabelContent:[NSString stringWithFormat:@"会员%@折",[NSString stringWithFormat:@"%.2f",model.discount]]];
    }
    
}

- (BOOL)showTime {
    BOOL showTime = [[self.message.content.extras objectForKey:kShowTimeKey] boolValue];
    return showTime;
}

//添加约束
- (void)layout {
    if ([self showTime]) {
        [self timeConstraint];
    }else {
        self.timeLabel.hidden = YES;
    }
    NSInteger topOffset = [self showTime] ? 45 : 10;
    [self.mainView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(topOffset, 12, 10, 12)).priority(751);
    }];
    [self.headPicView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainView).offset(14).priority(751);
        make.top.equalTo(self.mainView).offset(14).priority(751);
        make.bottom.lessThanOrEqualTo(self.mainView).offset(-14).priority(751);
        make.size.mas_equalTo(CGSizeMake(60, 60)).priority(751);
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headPicView.mas_right).offset(14).priority(751);
        make.top.equalTo(self.headPicView).priority(751);
        make.right.equalTo(self.mainView).offset(-12).priority(751);
    }];
    [self.priceView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel).priority(751);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8).priority(751);
        if (!self.showSendLinkBtn) {
            make.bottom.equalTo(self.mainView).offset(-14).priority(751);
        }
    }];
    [self.priceViewRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.priceView.mas_right).with.offset(kWidth(8)).priority(751);
        make.centerY.equalTo(self.priceView.mas_centerY);
    }];
    self.sepLine.hidden = !self.showSendLinkBtn;
    self.sendLinkBtn.hidden = !self.showSendLinkBtn;
    if (self.showSendLinkBtn) {
        [self.sepLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headPicView).priority(751);
            make.right.equalTo(self.mainView).offset(-12).priority(751);
            make.top.equalTo(self.headPicView.mas_bottom).offset(12).priority(751);
            make.height.mas_equalTo(0.5).priority(751);
        }];
        [self.sendLinkBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mainView).priority(751);
            make.top.left.right.equalTo(self.sepLine).priority(751);
            make.height.mas_equalTo(34).priority(751);
            make.bottom.equalTo(self.mainView).priority(751);
        }];
    }else {
        for (MASConstraint *c in [MASViewConstraint installedConstraintsForView:self.sepLine]) {
            [c uninstall];
        }
        for (MASConstraint *c in [MASViewConstraint installedConstraintsForView:self.sendLinkBtn]) {
            [c uninstall];
        }
    }
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

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] init];
        _mainView.backgroundColor = KWhite;
        _mainView.layer.cornerRadius = 5;
        _mainView.layer.masksToBounds = YES;
    }
    return _mainView;
}

- (UIImageView *)headPicView {
    if (!_headPicView) {
        _headPicView = [[UIImageView alloc] init];
        _headPicView.backgroundColor = hexColor(@"f5f5f5");
        _headPicView.layer.cornerRadius = 3;
        _headPicView.layer.masksToBounds = YES;
        _headPicView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headPicView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = hexColor(@"333333");
        _titleLabel.font = kFont(13);
    }
    return _titleLabel;
}

- (LKServicePriceView *)priceView {
    if (!_priceView) {
        _priceView = [[LKServicePriceView alloc] init];
    }
    return _priceView;
}

- (LKServicePriceView *)priceViewRight {
    if (!_priceViewRight) {
        _priceViewRight = [[LKServicePriceView alloc] init];
    }
    return _priceViewRight;
}

- (UIView *)sepLine {
    if (!_sepLine) {
        _sepLine = [[UIView alloc] init];
        _sepLine.backgroundColor = hexColor(@"f0f0f0");
    }
    return _sepLine;
}

- (UIButton *)sendLinkBtn {
    if (!_sendLinkBtn) {
        _sendLinkBtn = [[UIButton alloc] init];
        [_sendLinkBtn setTitle:@"发送链接" forState:UIControlStateNormal];
        _sendLinkBtn.titleLabel.font = kFont(13);
        [_sendLinkBtn setTitleColor:hexColor(@"ff3432") forState:UIControlStateNormal];
        [_sendLinkBtn setImage:[UIImage imageNamed:@"im_left"] forState:UIControlStateNormal];
        [_sendLinkBtn addTarget:self action:@selector(linkClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendLinkBtn;
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

- (void)linkClicked {
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (BOOL)showSendLinkBtn {
    BOOL show = [[self.message.content.extras objectForKey:kShowSendKey] boolValue];
    return show;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //[self.sendLinkBtn imagePositionStyle:ImagePositionStyleRight spacing:4];
}


@end
