//
//  YWNavigationSheeter.h
//  WormwormLife
//
//  Created by kaiwei Xu on 2018/9/6.
//  Copyright © 2018年 张文彬. All rights reserved.
//  导航选择器

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

static NSString * const AppleMap = @"apple";
static NSString * const BaiduMap = @"baidu";
static NSString * const GaodeMap = @"gaode";
static NSString * const TengxunMap = @"tengxun";

@interface YWNavigationSheeter : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D endLocation;//导航终点坐标
@property (nonatomic, copy) NSString *endPlaceName;//终点地点名称

/**
 单例
 @return return value description
 */
+ (instancetype)shared;

//单例销毁
+ (void)destroy;

//弹出地图导航选择列表
- (void)showWithEndLocation:(CLLocationCoordinate2D)loc endPlaceName:(NSString *)name;

/**
 返回本机安装的地图导航软件
 
 @return 数组<NSDictionary>
 */
- (NSArray *)avalibleMapApps;
@end


