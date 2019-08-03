//
//  YWLocationManager.h
//  WormwormLife
//
//  Created by kaiwei Xu on 2018/8/31.
//  Copyright © 2018年 张文彬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapLocationKit/AMapLocationKit.h>

@interface YWLocationResult : NSObject
@property (nonatomic, assign) BOOL success;//是否定位成功
@property (nonatomic, strong) AMapLocationReGeocode *regeocode;//高德定位具体地理信息
@property (nonatomic, strong) CLLocation *location;//定位结果经纬度
@property (nonatomic, strong) NSError *error;//定位失败原因
@property (nonatomic, assign) CLAuthorizationStatus authStatus;//定位权限
@end



@interface YWLocationManager : NSObject

/**
 Singleon
 
 @return return 单例
 */
+ (instancetype)shared;

/**
 请求定位信息
 
 @param block block description
 */
- (void)loactionWithResultBlock:(void(^)(YWLocationResult *result))block;

@end


