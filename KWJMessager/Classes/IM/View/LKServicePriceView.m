//
//  LKServicePriceView.m
//  WormwormLife
//
//  Created by 小屁孩 on 2018/11/3.
//  Copyright © 2018年 张文彬. All rights reserved.
//

#import "LKServicePriceView.h"
#import "LKBaseLabel.h"
#import <KWOCMacroDefinite/KWOCMacro.h>
#import <KWLogger/KWLogger.h>
#import <KWPublicUISDK/PublicHeader.h>
#import <KWCategoriesLib/NSArray+Safe.h>
#import <KWCategoriesLib/UIView+Common.h>
#import <Masonry/Masonry.h>

@interface LKServicePriceView()

@property (nonatomic,strong) LKBaseLabel *priceLabel; //金额
@property (nonatomic,strong) LKBaseLabel *statusLabel; //付款状态
@property (nonatomic,strong) UIImageView *vipIconImgV; //会员Vip的图标
@property (nonatomic,strong) LKBaseLabel *discountLabel; //会员折扣
@property (nonatomic,strong) LKBaseLabel *deleteLine; //删除线


@end

@implementation LKServicePriceView

#pragma mark --------initUI
- (instancetype)init{
    self = [super init];
    if (self) {
        _priceBigFontSize = 16;
        _priceSmallFontSize = 10;
    }
    return self;
}

- (void)setType:(LKServicePriceType)type{
    _type = type;
    switch (self.type) {
        case LKServicePriceTypeOrigin:{ //普通价格
            [self configOriginMasonry];
        }
            break;
        case LKServicePriceTypeVip:{ //Vip
            [self configVipUIMasonry];
        }
            break;
//        case LKServicePriceTypeDeleteLine:{ //删除
//            [self configDeleteUIMasonry];
//        }
//            break;
        default:
            [self configOriginMasonry];
            break;
    }
    
}

//普通显示价格
- (void)configOriginMasonry{
    
    self.priceLabel.textColor = hexColor(@"ff3432");
    self.statusLabel.backgroundColor = hexColor(@"#FFF6E7");
    self.statusLabel.textColor = hexColor(@"#FFA206");
    
    _deleteLine.hidden = YES;
    _discountLabel.hidden = YES;
    _vipIconImgV.hidden = YES;
    [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.and.and.left.mas_equalTo(0);
        make.bottom.offset(0).priorityHigh();
        make.height.mas_greaterThanOrEqualTo(kWidth(20));
    }];
    
    [self.statusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.priceLabel);
        make.left.equalTo(self.priceLabel.mas_right).with.mas_offset(kWidth(3));
        make.right.mas_equalTo(0);
    }];
    
    [self.priceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.statusLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

//会员类型的价格
- (void)configVipUIMasonry{
    
    self.priceLabel.textColor = hexColor(@"333333");
    
    _deleteLine.hidden = YES;
    _statusLabel.hidden = YES;
    
    [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.and.and.left.mas_equalTo(0);
        make.bottom.offset(0).priorityHigh();
        make.height.mas_greaterThanOrEqualTo(kWidth(20));
    }];
    
    [self.vipIconImgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.priceLabel);
        make.left.equalTo(self.priceLabel.mas_right).with.mas_offset(kWidth(3));
        make.size.mas_equalTo(CGSizeMake(kWidth(10)+4, kWidth(10)+4));
    }];
    
    [self.discountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.vipIconImgV.mas_centerY);
        make.left.equalTo(self.vipIconImgV.mas_centerX).with.mas_offset(-2);
        make.right.mas_equalTo(0);
        make.height.equalTo(self.vipIconImgV);
    }];
    
    [self.priceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.vipIconImgV setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.discountLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self bringSubviewToFront:self.vipIconImgV];
}
/*
//带删除线的价格
- (void)configDeleteUIMasonry{
    
    self.priceLabel.textColor = HLSLightGrayColor;
    self.priceLabel.font = TextFontSize(12);
    self.statusLabel.backgroundColor = RGBA(153, 153, 153, 0.2);
    self.statusLabel.textColor = HLSLightGrayColor;
    
    _discountLabel.hidden = YES;
    _vipIconImgV.hidden = YES;
    
    [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.and.and.left.offset(0);
        make.bottom.offset(0).priorityHigh();
        make.height.mas_greaterThanOrEqualTo(kWidth(20)).priorityMedium();
    }];

    
    [self.statusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.priceLabel);
        make.left.equalTo(self.priceLabel.mas_right).with.mas_offset(kWidth(3));
    }];
    
    [self.deleteLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.left.equalTo(self.priceLabel.mas_left).with.mas_offset(-kWidth(1));
        make.right.equalTo(self.statusLabel.mas_right).with.mas_offset(kWidth(2)).priorityHigh();
        make.right.mas_equalTo(0);
        make.centerY.equalTo(self.priceLabel.mas_centerY);
    }];
    
}
 */
#pragma mark --------bindModel
- (void)bindModelWithPrice:(long)price rightLabelContent:(NSString *)content{
    if (price) {  //有价格,
        self.priceLabel.attributedText = [self formatPrice:price/100.0 bigFont:self.priceBigFontSize smallFont:self.priceSmallFontSize color:self.priceColor];
    }else{ //没有价格就是免费预约
        self.priceLabel.text = @"";
    }
    
    if (self.type == LKServicePriceTypeVip) {//折扣
        self.discountLabel.text = String_NotNil(content);
        [self.vipIconImgV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.priceLabel.mas_right).with.mas_offset(price?kWidth(3):kWidth(0));
        }];
    }else{ //状态
        self.statusLabel.text = String_NotNil(content);
        [self.statusLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.priceLabel.mas_right).with.mas_offset(price?kWidth(3):kWidth(0));
        }];
    }
    
}

+ (NSString *)payTypeWithDeposit:(long)deposit servicePriceType:(NSInteger)servicePriceType{
    
    if (servicePriceType == 2) { //一口价
        return @"一口价";
    }
    //预付款为0是免费预约
    if (deposit == 0) {
        return @"免费预约";
    }
    
    return @"预付款";

}
- (void)setRightContentFontSize:(CGFloat)rightContentFontSize{
    _rightContentFontSize = rightContentFontSize;
    if (_statusLabel) {
        self.statusLabel.font = kFont(rightContentFontSize);
    }else if (_discountLabel){
        self.discountLabel.font = kFont(rightContentFontSize);
    }
}



#pragma mark -------懒加载
- (LKBaseLabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[LKBaseLabel alloc] initWithTextSize:16 isBold:YES];
        [self addSubview:_priceLabel];
        _priceLabel.mas_key = @"priceLabel";
    }
    _priceLabel.hidden = NO;
    return _priceLabel;
}

- (LKBaseLabel *)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [[LKBaseLabel alloc] initWithTextSize:10 isBold:YES];
        _statusLabel.edgeInsets = UIEdgeInsetsMake(3, 4, 3, 4);
        _statusLabel.layer.cornerRadius = kWidth(1);
        [self addSubview:_statusLabel];
        _statusLabel.clipsToBounds = YES;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.mas_key = @"statusLabel";
    }
    _statusLabel.hidden = NO;
    return _statusLabel;
    
}

- (UIImageView *)vipIconImgV{
    if (!_vipIconImgV) {
        _vipIconImgV = [[UIImageView alloc] initWithImage:ImageNamed(@"vip")];
        [self addSubview:_vipIconImgV];
        
    }
    _vipIconImgV.hidden = NO;
    return _vipIconImgV;
}

- (LKBaseLabel *)discountLabel{
    if (!_discountLabel) {
        _discountLabel = [[LKBaseLabel alloc] initWithTextSize:9 isBold:YES];
        _discountLabel.textColor = hexColor(@"#775218");
        _discountLabel.backgroundColor = hexColor(@"#F7F2E5");
        _discountLabel.edgeInsets = UIEdgeInsetsMake(3, 10, 3, 5);
        [self addSubview:_discountLabel];
        _discountLabel.clipsToBounds = YES;
    }
    _discountLabel.hidden = NO;
    return _discountLabel;
}

- (LKBaseLabel *)deleteLine{
    if (!_deleteLine) {
        _deleteLine = [[LKBaseLabel alloc] init];
        _deleteLine.backgroundColor = hexColor(@"cccccc");
        [self addSubview:_deleteLine];
    }
    _deleteLine.hidden = NO;
    return _deleteLine;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if (_discountLabel) {
        [_discountLabel layoutIfNeeded];
        [_vipIconImgV layoutIfNeeded];
        _discountLabel.layer.cornerRadius = _discountLabel.height/2.0;
        _vipIconImgV.layer.cornerRadius = _vipIconImgV.height/2.0;
    }
}


- (NSAttributedString *)formatPrice:(float)price bigFont:(NSInteger)big smallFont:(NSInteger)smallFont color:(NSString *)color {
    NSString *str = [self formatPricefloat:price decimalCount:2];
    NSString *priceStr = [NSString stringWithFormat:@"%@元", str];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:priceStr];
    if (color.length) {
        [attr addAttribute:NSForegroundColorAttributeName value:hexColor(color) range:NSMakeRange(0, priceStr.length)];
    }
    if ([priceStr containsString:@"."]) {
        NSRange range = [priceStr rangeOfString:@"."];
        [attr addAttribute:NSFontAttributeName value:kFont(big) range:NSMakeRange(0, range.location)];
        [attr addAttribute:NSFontAttributeName value:kFont(smallFont) range:NSMakeRange(range.location, priceStr.length - range.location)];
    } else {
        [attr addAttribute:NSFontAttributeName value:kFont(big) range:NSMakeRange(0, priceStr.length - 1)];
        [attr addAttribute:NSFontAttributeName value:kFont(smallFont) range:NSMakeRange(priceStr.length - 1, 1)];
    }
    return attr;
}

/**
 如果有小数显示指定count小数位，没有显示整数
 
 @param f 浮点数
 @param count 指定显示小数点位数
 @return 显示指定count小数位，没有显示整数
 */
- (NSString *)formatPricefloat:(float)f decimalCount:(NSInteger)count{
    if (fmodf(f, 1)==0) {//没有小数
        return [NSString stringWithFormat:@"%.0f",f];
    }else{
        if (count == 1) {
            return [self roundUpFloat:f scale:1];
        }else{
            return [self roundUpFloat:f scale:2];
        }
    }
    
}

//进1法（不采用四舍五入）
- (NSString *)roundUpFloat:(float)f scale:(NSInteger)scale {
    NSString *value = [NSString stringWithFormat:@"%.5f",f];
    NSDecimalNumber *numResult = [NSDecimalNumber decimalNumberWithString:value];
    NSDecimalNumberHandler *handler = [[NSDecimalNumberHandler alloc]
                                       initWithRoundingMode:NSRoundUp scale:scale
                                       raiseOnExactness:NO raiseOnOverflow:YES
                                       raiseOnUnderflow:YES raiseOnDivideByZero:YES];
    NSString *resultStr = [[numResult decimalNumberByRoundingAccordingToBehavior:handler] stringValue];
    if ([resultStr containsString:@"."]) {
        NSArray *temp = [resultStr componentsSeparatedByString:@"."];
        NSString *last = [temp lastObject];
        if (last.length < scale) {
            for (int i = 0; i < scale - last.length; i++) {
                last = [NSString stringWithFormat:@"%@%@",last, @"0"];
            }
            resultStr = [NSString stringWithFormat:@"%@.%@", [temp firstObject], last];
        }
    }
    return resultStr;
}



@end
