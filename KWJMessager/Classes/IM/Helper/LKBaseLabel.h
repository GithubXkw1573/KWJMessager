//
//  LKBaseLabel.h
//  WormwormLife
//
//  Created by 小屁孩 on 2018/10/18.
//  Copyright © 2018年 张文彬. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKBaseLabel : UILabel

- (instancetype)initWithTextSize:(CGFloat)textSize isBold:(BOOL)isBold;
@property (assign, nonatomic) UIEdgeInsets edgeInsets;

@end

NS_ASSUME_NONNULL_END
