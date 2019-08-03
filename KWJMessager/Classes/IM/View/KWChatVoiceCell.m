//
//  KWChatVoiceCell.m
//  WormwormLife
//
//  Created by kaiwei Xu on 2019/3/6.
//  Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
//

#import "KWChatVoiceCell.h"
#import "PrefixHeader.pch"

@interface KWChatVoiceCell ()
@property (nonatomic, strong) UIView *voiceView;
@property (nonatomic, strong) UIImageView *audioIcon;
@property (nonatomic, strong) UILabel *durationLabel;
@end

@implementation KWChatVoiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.messageView addSubview:self.voiceView];
        [self.voiceView addSubview:self.audioIcon];
        [self.voiceView addSubview:self.durationLabel];
    }
    return self;
}

//添加约束
- (void)layout {
    [super layout];
    
    JMSGVoiceContent *voice = (JMSGVoiceContent *)self.message.content;
    [self.voiceView mas_remakeConstraints:^(MASConstraintMaker *make) {
        CGFloat precent = MIN([voice.duration integerValue], 60) / 60.0;
        CGFloat dynamicTotalWidth = (SCREEN_WIDTH - 120) * 0.65;//动态最大宽度
        CGFloat baseWidth = (SCREEN_WIDTH - 120) * 0.35;//基础宽度，给图标和秒数显示的
        CGFloat realWdith = baseWidth + dynamicTotalWidth * precent;
//        make.top.bottom.equalTo(self.messageView).priority(751);
        make.height.mas_equalTo(39).priority(751);
        make.width.mas_equalTo(realWdith).priority(751);
//        if (self.message.isReceived) {
//            make.left.equalTo(self.messageView).priority(751);
//        }else {
//            make.right.equalTo(self.messageView).priority(751);
//        }
        make.edges.equalTo(self.messageView).priority(751);
    }];
    
    [self.audioIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.voiceView).priority(751);
        if (self.message.isReceived) {
            make.left.equalTo(self.voiceView).offset(12).priority(751);
        }else {
            make.right.equalTo(self.voiceView).offset(-12).priority(751);
        }
    }];
    
    [self.durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.voiceView).priority(751);
        if (self.message.isReceived) {
            make.left.equalTo(self.audioIcon.mas_right).offset(13).priority(751);
        }else {
            make.right.equalTo(self.audioIcon.mas_left).offset(-13).priority(751);
        }
    }];
}

//覆写父类的属性
- (void)setMessage:(JMSGMessage *)message {
    [super setMessage:message];
    
    //专注定位区域的赋值即可
    if ([message.content isKindOfClass:[JMSGVoiceContent class]]) {
        JMSGVoiceContent *content = (JMSGVoiceContent *)message.content;
        
        self.durationLabel.text = [NSString stringWithFormat:@"%@''",content.duration];
        
        if (self.message.isReceived) {
            self.audioIcon.image = [UIImage imageNamed:@"yunyin_left3"];
        }else {
            self.audioIcon.image = [UIImage imageNamed:@"yunyin_right3"];
        }
    }
}

- (UIView *)voiceView {
    if (!_voiceView) {
        _voiceView = [[UIView alloc] init];
        _voiceView.backgroundColor = KWhite;
        _voiceView.layer.cornerRadius = 5;
        _voiceView.layer.masksToBounds = YES;
        _voiceView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(voiceClicked)];
        [_voiceView addGestureRecognizer:tap];
    }
    return _voiceView;
}

- (UIImageView *)audioIcon {
    if (!_audioIcon) {
        _audioIcon = [[UIImageView alloc] init];
    }
    return _audioIcon;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = WormThemeColor;
        _durationLabel.font = kFont(15);
    }
    return _durationLabel;
}

- (void)voiceClicked {
    if (self.actionBlock) {
        self.actionBlock(ActionTypeLookDetail);
    }
}

- (NSArray *)animatePlayingImage {
    NSMutableArray *imags = [NSMutableArray array];
    NSString *prefex = @"yunyin_right";
    if (self.message.isReceived) {
        prefex = @"yunyin_left";
    }
    for (NSInteger i=1; i<=3; i++) {
        [imags addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@",prefex, @(i)]]];
    }
    return imags;
}

- (void)startPlayingAnimate {
    self.audioIcon.animationImages = [self animatePlayingImage];
    self.audioIcon.animationDuration = 1;
    [self.audioIcon startAnimating];
}

- (void)stopPlayingAnimate {
    [self.audioIcon stopAnimating];
    if (self.message.isReceived) {
        self.audioIcon.image = [UIImage imageNamed:@"yunyin_left3"];
    }else {
        self.audioIcon.image = [UIImage imageNamed:@"yunyin_right3"];
    }
}

@end
