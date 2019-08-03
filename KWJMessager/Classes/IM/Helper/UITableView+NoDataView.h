//
//  UITableView+NoDataView.h
//  WowoMerchant
//
//  Created by kaiwei Xu on 2018/6/28.
//  Copyright © 2018年 NanjingYunWo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (NoDataView)

- (void)addNoDataViewImageName:(NSString *)imageName
                          text:(NSString *)text;

- (void)addNoDataViewImageName:(NSString *)imageName
                          text:(NSString *)text
                    detailText:(NSString *)detail
                   buttonTitle:(NSString *)buttonTitle;

- (void)showNoDataView;
- (void)hiddenNoDataView;
- (void)adjustNoDataTopPosition;
//没有网络的时候的View
- (void)showNoNetViewWithReloadBlock:(void (^)(void))block;



@end
