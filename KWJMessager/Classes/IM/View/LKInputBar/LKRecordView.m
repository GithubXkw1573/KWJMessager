// Auther: 小屁孩.
// Created Date: 2019/3/12.
// Version: 1.0.6
// Since: 1.0.0
// Copyright © 2019年 NanjingYunWo Infomation technology co.LTD. All rights reserved.
// Descriptioin: 文件描述.


#import "LKRecordView.h"
#import <KWOCMacroDefinite/KWOCMacro.h>
#import <KWLogger/KWLogger.h>
#import <KWPublicUISDK/PublicHeader.h>
#import <KWCategoriesLib/NSArray+Safe.h>
#import <KWCategoriesLib/UIView+Common.h>
#import <Masonry.h>

@interface LKRecordView()
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UILabel *contentL;

@end

@implementation LKRecordView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.imgV];
    [self addSubview:self.contentL];
    [self.imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150, 150));
        make.edges.equalTo(self);
    }];
    [self.contentL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-kWidth(10));
        make.left.and.right.offset(0);
    }];
}
- (void)showCancel {
    self.imgV.image = ImageNamed(@"im_backout");
    self.contentL.hidden = YES;
}

- (void)configRecordingImageWithPeakPower:(CGFloat)peakPower {
    NSString *imageName = @"recording";
    if (peakPower >= 0 && peakPower <= 0.1) {
        imageName = [imageName stringByAppendingString:@"1"];
    } else if (peakPower > 0.1 && peakPower <= 0.2) {
        imageName = [imageName stringByAppendingString:@"2"];
    } else if (peakPower > 0.3 && peakPower <= 0.4) {
        imageName = [imageName stringByAppendingString:@"3"];
    } else if (peakPower > 0.4 && peakPower <= 0.5) {
        imageName = [imageName stringByAppendingString:@"4"];
    } else if (peakPower > 0.5 && peakPower <= 0.6) {
        imageName = [imageName stringByAppendingString:@"5"];
    } else if (peakPower > 0.7 && peakPower <= 0.8) {
        imageName = [imageName stringByAppendingString:@"6"];
    } else if (peakPower > 0.8 && peakPower <= 0.85) {
        imageName = [imageName stringByAppendingString:@"7"];
    } else if (peakPower > 0.85 && peakPower <= 0.95) {
        imageName = [imageName stringByAppendingString:@"8"];
    } else {
        imageName = [imageName stringByAppendingString:@"9"];
    }
    self.imgV.image = [UIImage imageNamed:imageName];
}

- (void)setRecordContent:(NSString *)recordContent {
    _recordContent = recordContent;
    self.contentL.text = recordContent;
}
- (void)setRecordContentHidden:(BOOL)recordContentHidden {
    _recordContentHidden = recordContentHidden;
    self.contentL.hidden = recordContentHidden;
}

#pragma mark ----懒加载
- (UIImageView *)imgV {
    if (!_imgV) {
        _imgV = [[UIImageView alloc] initWithImage:ImageNamed(@"recording1")];
    }
    return _imgV;
}

- (UILabel *)contentL {
    if (!_contentL) {
        _contentL = [[UILabel alloc] init];
        _contentL.text = LKDefaultRecordConten;
        _contentL.font = kFont(14);
        _contentL.textColor = [UIColor whiteColor];
        _contentL.textAlignment = NSTextAlignmentCenter;
    }
    return _contentL;
}
@end
