//
//  UITableView+NoDataView.m
//  WowoMerchant
//
//  Created by kaiwei Xu on 2018/6/28.
//  Copyright © 2018年 NanjingYunWo. All rights reserved.
//

#import "UITableView+NoDataView.h"
#import "PrefixHeader.pch"
#import "WOWONoDataView.h"

#define noViewTag 8856
#define noNetTag  8888
@implementation UITableView (NoDataView)

- (void)addNoDataViewImageName:(NSString *)imageName text:(NSString *)text{
    [self addNoDataViewImageName:imageName
                            text:text
                      detailText:nil
                     buttonTitle:nil];
}

- (void)addNoDataViewImageName:(NSString *)imageName
                          text:(NSString *)text
                    detailText:(NSString *)detail
                   buttonTitle:(NSString *)buttonTitle{
    WOWONoDataView *noView = [[WOWONoDataView alloc]
                              initWithImageName:imageName
                              text:text detailText:detail
                              buttonTitle:buttonTitle];
    noView.tag = noViewTag;
    noView.hidden = YES;
    [self addSubview:noView];
}

- (void)adjustNoDataTopPosition {
    WOWONoDataView *view = [self viewWithTag:noViewTag];
    view.height = SCREEN_HEIGHT/2.0;
    view.isAdjust = YES;
}

- (void)showNoDataView{
    WOWONoDataView *view = [self viewWithTag:noViewTag];
    view.hidden = NO;
    [self bringSubviewToFront:view];
}
- (void)showNoNetViewWithReloadBlock:(void (^)(void))block{
    WOWONoDataView *view = [[WOWONoDataView alloc] initWithNoNetViewWithReloadBlock:^{
        if (block) {
            block();
        }
    }];
    view.backgroundColor = [UIColor clearColor];
    view.frame = self.bounds;
    [self addSubview:view];
 
}

- (void)hiddenNoDataView{
    WOWONoDataView *view = [self viewWithTag:noViewTag];
    view.hidden = YES;
}
@end
