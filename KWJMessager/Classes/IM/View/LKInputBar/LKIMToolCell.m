// Auther: 小屁孩.
// Created Date: 2019/3/11.
// Version: 1.0.6
// Since: 1.0.0
// Copyright © 2019年 NanjingYunWo Infomation technology co.LTD. All rights reserved.
// Descriptioin: 文件描述.


#import "LKIMToolCell.h"
#import "LKBaseLabel.h"
#import "PrefixHeader.pch"

@interface LKIMToolCell()
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) LKBaseLabel *nameLabel;
@end
@implementation LKIMToolCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}
- (void)initUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.imgView];
    [self addSubview:self.nameLabel];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.offset(2);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.imgView.mas_bottom).with.offset(kWidth(5));
    }];
}

- (void)setModel:(NSDictionary *)model {
    _model = model;
    self.nameLabel.text = [model objectForKey:@"name"];
    self.imgView.image = ImageNamed([model objectForKey:@"icon"]);
}
#pragma mark ------懒加载
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
    }
    return _imgView;
}

- (LKBaseLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[LKBaseLabel  alloc] initWithTextSize:11 isBold:NO];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

@end
