//
//  KWChatTextCell.m
//  WormwormLife
//
//  Created by kaiwei Xu on 2019/3/6.
//  Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
//

#import "KWChatTextCell.h"
#import "PrefixHeader.pch"

@interface KWChatTextCell ()
@property (nonatomic, strong) UIView *textContentView;
@property (nonatomic, strong) UILabel *textContentLabel;
@end

@implementation KWChatTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.textContentView];
        [self.textContentView addSubview:self.textContentLabel];
    }
    return self;
}

//覆写父类的方法
- (void)layout {
    [super layout];
    
    //专注文本区域的布局即可
    [self.textContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.messageView).priority(751);
    }];
    [self.textContentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.textContentView).insets(UIEdgeInsetsMake(10, 12, 10, 12)).priority(751);
    }];
}

//覆写父类的属性
- (void)setMessage:(JMSGMessage *)message {
    [super setMessage:message];
    
    //专注文本区域的赋值即可
    if ([message.content isKindOfClass:[JMSGTextContent class]]) {
        JMSGTextContent *content = (JMSGTextContent *)message.content;
        self.textContentLabel.text = content.text;
    }
}

- (UIView *)textContentView {
    if (!_textContentView) {
        _textContentView = [[UIView alloc] init];
        _textContentView.backgroundColor = KWhite;
        _textContentView.layer.cornerRadius = 5;
        _textContentView.layer.masksToBounds = YES;
    }
    return _textContentView;
}

- (UILabel *)textContentLabel {
    if (!_textContentLabel) {
        _textContentLabel = [[UILabel alloc] init];
        _textContentLabel.textColor = hexColor(@"333333");
        _textContentLabel.font = kFont(15);
        _textContentLabel.numberOfLines = 0;
    }
    return _textContentLabel;
}


@end
