// Auther: kaiwei Xu.
// Created Date: 2019/3/15.
// Version: 1.0.6
// Since: 1.0.0
// Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
// Descriptioin: 文件描述.


#import "KWPOIItemCell.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "KWPOI.h"
#import "PrefixHeader.pch"

@interface KWPOIItemCell ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIImageView *markIcon;
@property (nonatomic, strong) UIView *bottomLine;
@end

@implementation KWPOIItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //cell背景色、选中样式设置
        self.backgroundColor = KWhite;
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
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.addressLabel];
    [self.contentView addSubview:self.markIcon];
    [self.contentView addSubview:self.bottomLine];
}

//添加约束
- (void)layout {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12);
        make.top.equalTo(self.contentView).offset(6);
        make.right.equalTo(self.contentView).offset(-60);
    }];
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12);
        make.bottom.equalTo(self.contentView).offset(-6);
        make.right.equalTo(self.contentView).offset(-60);
    }];
    [self.markIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-12);
    }];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)bindModel:(id)model selected:(BOOL)selected {
    self.markIcon.hidden = !selected;
    if ([model isKindOfClass:[AMapPOI class]]) {
        AMapPOI *poi = model;
        self.nameLabel.text = poi.name;
        self.addressLabel.text = [NSString stringWithFormat:@"%@%@%@%@",
                                  poi.province,poi.city,poi.district,poi.address];
        self.addressLabel.hidden = NO;
        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(6);
        }];
    }else {
        //当前位置
        KWPOI *loaction = model;
        self.nameLabel.text = loaction.address;
        self.addressLabel.hidden = YES;
        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(18);
        }];
    }
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = hexColor(@"333333");
        _nameLabel.font = kFont(16);
    }
    return _nameLabel;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.textColor = hexColor(@"b2b2b2");
        _addressLabel.font = kFont(12);
    }
    return _addressLabel;
}

- (UIImageView *)markIcon {
    if (!_markIcon) {
        _markIcon = [[UIImageView alloc] init];
        _markIcon.image = [UIImage imageNamed:@"choice_user"];
    }
    return _markIcon;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = hexColor(@"e6e6e6");
    }
    return _bottomLine;
}

@end
