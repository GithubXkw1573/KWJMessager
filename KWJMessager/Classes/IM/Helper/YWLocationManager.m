//
//  YWLocationManager.m
//  WormwormLife
//
//  Created by kaiwei Xu on 2018/8/31.
//  Copyright © 2018年 张文彬. All rights reserved.
//

#import "YWLocationManager.h"

@implementation YWLocationResult
@end


@interface YWLocationManager ()<AMapLocationManagerDelegate>
@property (nonatomic, strong) AMapLocationManager *locationManager;
@end

@implementation YWLocationManager


/**
 Singleon

 @return return 单例
 */
+ (instancetype)shared{
    static YWLocationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YWLocationManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        self.locationManager = [[AMapLocationManager alloc] init];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        //   定位超时时间，最低2s，此处设置为2s
        self.locationManager.locationTimeout =2;
        //   逆地理请求超时时间，最低2s，此处设置为2s
        self.locationManager.reGeocodeTimeout = 2;
        self.locationManager.delegate = self;
    }
    return self;
}


/**
 请求定位信息

 @param block block description
 */
- (void)loactionWithResultBlock:(void(^)(YWLocationResult *result))block{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusDenied) {
        YWLocationResult *locationiResult = [[YWLocationResult alloc] init];
        locationiResult.success = NO;
        locationiResult.authStatus = status;
        if (block) {
            block(locationiResult);
        }
    }else{
        [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            YWLocationResult *locationiResult = [[YWLocationResult alloc] init];
            locationiResult.authStatus = [CLLocationManager authorizationStatus];
            locationiResult.error = error;
            locationiResult.location = location;
            locationiResult.regeocode = regeocode;
            locationiResult.success = error ? NO : YES;
            if (block) {
                block(locationiResult);
            }
        }];
    }
}



@end
