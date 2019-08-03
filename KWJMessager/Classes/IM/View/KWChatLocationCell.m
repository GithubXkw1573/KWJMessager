//
//  KWChatLocationCell.m
//  WormwormLife
//
//  Created by kaiwei Xu on 2019/3/6.
//  Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
//

#import "KWChatLocationCell.h"
#import <MAMapKit/MAMapKit.h>
#import "PrefixHeader.pch"

@interface KWChatLocationCell ()
@property (nonatomic, strong) UIView *locationView;
@property (nonatomic, strong) UIImageView *locationImageView;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *weizhi;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UIImageView *pinImageIcon;
@end

@implementation KWChatLocationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.messageView addSubview:self.locationView];
        [self.locationView addSubview:self.mapView];
        [self.locationView addSubview:self.locationImageView];
        [self.locationView addSubview:self.addressLabel];
        [self.locationView addSubview:self.icon];
        [self.locationView addSubview:self.weizhi];
        [self.locationImageView addSubview:self.pinImageIcon];
    }
    return self;
}

//覆写父类的方法
- (void)layout {
    [super layout];
    
    [self.locationView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.messageView).priority(751);
    }];
    [self.locationImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.locationView).priority(751);
        make.height.mas_equalTo(90).priority(751);
        make.width.mas_equalTo(kWidth(245)).priority(751);
    }];
    [self.mapView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.locationImageView).priority(751);
    }];
    [self.pinImageIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mapView);
        make.centerY.equalTo(self.mapView).offset(-10);
    }];
    [self.addressLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.locationView).offset(12).priority(751);
        make.top.equalTo(self.locationImageView.mas_bottom).offset(10).priority(751);
        make.right.equalTo(self.locationView).offset(-10).priority(751);
        make.bottom.equalTo(self.locationView).offset(-29).priority(751);
    }];
    [self.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addressLabel).priority(751);
        make.top.equalTo(self.addressLabel.mas_bottom).offset(7).priority(751);
    }];
    [self.weizhi mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.icon.mas_right).offset(5).priority(751);
        make.centerY.equalTo(self.icon).priority(751);
    }];
}

//覆写父类的属性
- (void)setMessage:(JMSGMessage *)message {
    [super setMessage:message];
    
    //专注定位区域的赋值即可
    if ([message.content isKindOfClass:[JMSGLocationContent class]]) {
        JMSGLocationContent *content = (JMSGLocationContent *)message.content;
        self.addressLabel.text = content.address;
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake([content.latitude doubleValue], [content.longitude doubleValue]);
        self.mapView.zoomLevel = [content.scale floatValue];
        [self.contentView layoutIfNeeded];
        Weakify(self);
        [self.mapView takeSnapshotInRect:self.mapView.bounds withCompletionBlock:^(UIImage *resultImage, NSInteger state) {
            weakself.locationImageView.image = resultImage;
        }];
    }
}

- (UIView *)locationView {
    if (!_locationView) {
        _locationView = [[UIView alloc] init];
        _locationView.backgroundColor = KWhite;
        _locationView.layer.cornerRadius = 5;
        _locationView.layer.masksToBounds = YES;
        _locationView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationClicked)];
        [_locationView addGestureRecognizer:tap];
    }
    return _locationView;
}

- (void)locationClicked {
    if (self.actionBlock) {
        self.actionBlock(ActionTypeLookDetail);
    }
}

- (UIImageView *)locationImageView {
    if (!_locationImageView) {
        _locationImageView = [[UIImageView alloc] init];
    }
    return _locationImageView;
}

- (UIImageView *)pinImageIcon {
    if (!_pinImageIcon) {
        _pinImageIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buoy"]];
        _pinImageIcon.transform = CGAffineTransformMakeScale(0.7, 0.7);
    }
    return _pinImageIcon;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.textColor = hexColor(@"333333");
        _addressLabel.font = kFont(12);
    }
    return _addressLabel;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.image = [UIImage imageNamed:@"chat_map_loc"];
    }
    return _icon;
}

- (UILabel *)weizhi {
    if (!_weizhi) {
        _weizhi = [[UILabel alloc] init];
        _weizhi.textColor = hexColor(@"b3b3b3");
        _weizhi.font = kFont(11);
        _weizhi.text = @"位置";
    }
    return _weizhi;
}

- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc] init];
        _mapView.hidden = YES;
    }
    return _mapView;
}

@end
