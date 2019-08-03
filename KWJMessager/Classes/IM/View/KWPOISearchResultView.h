// Auther: kaiwei Xu.
// Created Date: 2019/3/15.
// Version: 1.0.6
// Since: 1.0.0
// Copyright © 2019 NanjingYunWo Infomation technology co.LTD. All rights reserved.
// Descriptioin: 文件描述.


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class AMapPOI;
@interface KWPOISearchResultView : UIView
@property (nonatomic, copy) void(^selectAtPOI)(AMapPOI *poi);
@property (nonatomic, copy) NSString *limitCity;//搜索结果必须位于该城市内
@property (nonatomic, copy) NSString *suguestCity;//首选搜索城市，但不局限该城市
- (void)show;
@end

NS_ASSUME_NONNULL_END
