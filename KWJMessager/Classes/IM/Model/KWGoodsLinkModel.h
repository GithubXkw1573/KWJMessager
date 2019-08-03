// Auther: kaiwei Xu.
// Created Date: 2019/3/11.
// Version: 1.0.6
// Since: 1.0.0
// Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
// Descriptioin: 文件描述.


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KWGoodsLinkModel : NSObject
@property (nonatomic, copy) NSString *serviceTitle;
@property (nonatomic, copy) NSString *servicePrice;
@property (nonatomic, copy) NSString *servicePictureUrl;
@property (nonatomic, copy) NSDictionary *servicePriceUnitObject;
@property (nonatomic, assign) NSInteger servicePriceType;//1预付款 2一口价
@property (nonatomic, assign) long deposit;
@property (nonatomic, assign) long vipPrice;
@property (nonatomic, assign) long vipDeposit;
@property (nonatomic, assign) NSInteger promotionType; //促销方式 0无 1折扣
@property (nonatomic, assign) double discount; //会员折扣
@end

NS_ASSUME_NONNULL_END
