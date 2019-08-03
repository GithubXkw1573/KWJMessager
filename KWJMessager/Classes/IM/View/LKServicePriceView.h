//
//  LKServicePriceView.h
//  WormwormLife
//
//  Created by 小屁孩 on 2018/11/3.
//  Copyright © 2018年 张文彬. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, LKServicePriceType) {
    LKServicePriceTypeOrigin,//原价
    LKServicePriceTypeVip,//会员
//    LKServicePriceTypeDeleteLine, //带删除置灰线的View
};


@interface LKServicePriceView : UIView

@property (nonatomic, assign) LKServicePriceType type;
@property (nonatomic, copy) NSString *priceColor; //金额的颜色的
@property (nonatomic, assign) CGFloat priceBigFontSize; //金额整数字体大小
@property (nonatomic, assign) CGFloat priceSmallFontSize; //金额小字的大小
@property (nonatomic, assign) CGFloat rightContentFontSize; //右边的字体大小
/**
 服务的付款方式
 @param deposit 预付款金额，直接用接口的deposit，可以为0
 @param servicePriceType 接口的servicePriceType
 @return 返回值为服务的付款方式（一口价，预付款，免费预约）
 */

+ (NSString *)payTypeWithDeposit:(long)deposit servicePriceType:(NSInteger)servicePriceType;



//左边是价格，可以为空，右边根据类型来传入响应的值：（比如会员传入“会员7.2折”，普通的值就传入“一口价“，”免费预约”等）
- (void)bindModelWithPrice:(long)price rightLabelContent:(NSString *)content;


@end


